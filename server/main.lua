
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

local function CreateDispatch(coords, targetJob, message, dispatchType, reporterSource)
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

    TriggerClientEvent('mfp_lb-dispatches:app:add', -1, Dispatches[id])

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

-- Legacy event name from asuna_dispatch, kept so the medic script needs no changes
RegisterNetEvent('asuna_dispatch:serverCreateFromDeathscreen')
AddEventHandler('asuna_dispatch:serverCreateFromDeathscreen', function()
    CreateDeathDispatch(source)
end)

RegisterNetEvent('mfp_lb-dispatches:serverCreateFromDeathscreen')
AddEventHandler('mfp_lb-dispatches:serverCreateFromDeathscreen', function()
    CreateDeathDispatch(source)
end)

RegisterNetEvent('mfp_lb-dispatches:app:requestOpen')
AddEventHandler('mfp_lb-dispatches:app:requestOpen', function(jobName)
    local src = source
    if not isValidJob(jobName) then return end

    local open = {}
    for _, dispatch in pairs(Dispatches) do
        if dispatch.targetJob == jobName then
            open[#open + 1] = dispatch
        end
    end

    TriggerClientEvent('mfp_lb-dispatches:app:sync', src, open)
end)

RegisterNetEvent('mfp_lb-dispatches:app:accept')
AddEventHandler('mfp_lb-dispatches:app:accept', function(id, jobName)
    local src = source
    local dispatch = Dispatches[id]

    if not dispatch or dispatch.status ~= 'open' then return end
    if not isValidJob(jobName) or dispatch.targetJob ~= jobName then return end

    dispatch.status = 'accepted'
    Dispatches[id] = nil

    TriggerClientEvent('mfp_lb-dispatches:app:remove', -1, id)
    TriggerClientEvent('mfp_lb-dispatches:app:accepted', src, { id = id, coords = dispatch.coords, postal = dispatch.postal })

    if dispatch.reporterSource then
        TriggerClientEvent('mfp_lb-dispatches:app:notifyAccepted', dispatch.reporterSource)
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for id, dispatch in pairs(Dispatches) do
            if (now - dispatch.createdAt) > (Config.DispatchExpireMinutes * 60) then
                Dispatches[id] = nil
                TriggerClientEvent('mfp_lb-dispatches:app:remove', -1, id)
            end
        end
    end
end)
