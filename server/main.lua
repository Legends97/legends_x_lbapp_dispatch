
local function DebugPrint(msg)
    if Config.Debug then print(msg) end
end

local function isValidJob(job)
    for _, configuredJob in pairs(Config.Jobs) do
        if configuredJob == job then
            return true
        end
    end
    return false
end

------------ APP DISPATCH QUEUE --------

local Dispatches = {}
local nextDispatchId = 1

local Postals = {}
if Config.Postals.enabled then
    local raw = LoadResourceFile(GetCurrentResourceName(), Config.Postals.file)
    Postals = raw and json.decode(raw) or {}
end

local function GetNearestPostal(coords)
    local nearest, nearestDist

    for i = 1, #Postals do
        local p = Postals[i]
        local dist = (p.x - coords.x) ^ 2 + (p.y - coords.y) ^ 2
        if not nearestDist or dist < nearestDist then
            nearest, nearestDist = p, dist
        end
    end

    return nearest and nearest.code or 'N/A'
end

local function BroadcastToJob(targetJob, event, payload)
    for _, playerId in ipairs(GetPlayers()) do
        local job = GetPlayerJob(tonumber(playerId))
        DebugPrint(("^3[DEBUG]^7 BroadcastToJob: player %s has job '%s', dispatch targetJob '%s' -> %s"):format(playerId, tostring(job), targetJob, tostring(job == targetJob)))
        if job == targetJob then
            TriggerClientEvent(event, playerId, payload)
        end
    end
end

local function CreateDispatch(coords, targetJob, message, dispatchType, reporterSource)
    if not isValidJob(targetJob) then
        print("^1[ERROR]^7 CreateDispatch: unknown targetJob '" .. tostring(targetJob) .. "', not in Config.Jobs")
        return nil
    end

    local id = nextDispatchId
    nextDispatchId = nextDispatchId + 1

    Dispatches[id] = {
        id = id,
        type = dispatchType,
        title = message,
        targetJob = targetJob,
        postal = GetNearestPostal(coords),
        time = os.date('%H:%M'),
        coords = coords,
        status = 'open',
        reporterSource = reporterSource,
        createdAt = os.time()
    }

    BroadcastToJob(targetJob, 'ls_lb-dispatches:app:add', Dispatches[id])

    return id
end

exports('CreateAlertDispatch', function(coords, message, targetJob, dispatchType)
    return CreateDispatch(coords, targetJob, message, dispatchType or 'alert', nil)
end)

local function CreateDeathDispatch(playerSource)
    local ped = GetPlayerPed(playerSource)
    local coords = GetEntityCoords(ped)

    return CreateDispatch(coords, Config.Jobs.ambulance, Translation['downed_person'], 'downed', playerSource)
end

exports('CreateDeathDispatchFromDeathscreen', function(playerId)
    return CreateDeathDispatch(playerId)
end)

if Config.Debug then
    RegisterCommand('testdispatch', function(src)
        local id = CreateDeathDispatch(src)
        print(("^3[DEBUG]^7 /testdispatch: created dispatch id=%s for player %s"):format(tostring(id), src))
    end, false)
end

-- Legacy event name from asuna_dispatch, kept so the medic script needs no changes
RegisterNetEvent('asuna_dispatch:serverCreateFromDeathscreen')
AddEventHandler('asuna_dispatch:serverCreateFromDeathscreen', function()
    CreateDeathDispatch(source)
end)

RegisterNetEvent('ls_lb-dispatches:serverCreateFromDeathscreen')
AddEventHandler('ls_lb-dispatches:serverCreateFromDeathscreen', function()
    CreateDeathDispatch(source)
end)

RegisterNetEvent('ls_lb-dispatches:app:requestOpen')
AddEventHandler('ls_lb-dispatches:app:requestOpen', function()
    local src = source
    local jobName = GetPlayerJob(src)
    if not isValidJob(jobName) then
        DebugPrint(("^1[DEBUG]^7 app:requestOpen: player %s has job '%s' -> not in Config.Jobs, no sync sent"):format(src, tostring(jobName)))
        return
    end

    local open = {}
    for _, dispatch in pairs(Dispatches) do
        if dispatch.targetJob == jobName then
            open[#open + 1] = dispatch
        end
    end

    if Config.Debug then
        local total = 0
        for _ in pairs(Dispatches) do total = total + 1 end
        DebugPrint(("^3[DEBUG]^7 app:requestOpen: player %s job '%s' -> syncing %d dispatch(es) (total in queue: %d)"):format(src, jobName, #open, total))
    end

    TriggerClientEvent('ls_lb-dispatches:app:sync', src, open)
end)

RegisterNetEvent('ls_lb-dispatches:app:accept')
AddEventHandler('ls_lb-dispatches:app:accept', function(id)
    local src = source
    local jobName = GetPlayerJob(src)
    local dispatch = Dispatches[id]

    if not dispatch or dispatch.status ~= 'open' then return end
    if not isValidJob(jobName) or dispatch.targetJob ~= jobName then return end

    Dispatches[id] = nil

    TriggerClientEvent('ls_lb-dispatches:app:remove', -1, id)
    TriggerClientEvent('ls_lb-dispatches:app:accepted', src, { id = id, coords = dispatch.coords, postal = dispatch.postal })

    if dispatch.reporterSource then
        TriggerClientEvent('ls_lb-dispatches:app:notifyAccepted', dispatch.reporterSource)
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for id, dispatch in pairs(Dispatches) do
            if (now - dispatch.createdAt) > (Config.DispatchExpireMinutes * 60) then
                Dispatches[id] = nil
                TriggerClientEvent('ls_lb-dispatches:app:remove', -1, id)
            end
        end
    end
end)
