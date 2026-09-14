
local timeouts = {}
local COOLDOWN_MS = Config.TimeOut * 1000

local function canTriggerDispatch(src)
    local now = GetGameTimer()
    local last = timeouts[src]
    if last and (now - last) < COOLDOWN_MS then
        return false
    end
    timeouts[src] = now
    return true
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

RegisterNetEvent('mfp_lb-dispatches:app:create')
AddEventHandler('mfp_lb-dispatches:app:create', function(coords, jobName, message)
    local src = source
    if not canTriggerDispatch(src) then return end
    if not isValidJob(jobName) then return end

    CreateDispatch(coords, jobName, message, 'sos', src)
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

RegisterNetEvent('mfp_lb-dispatches:lb-tablet:triggerDispatch', function (data)
    local src = source

    if not canTriggerDispatch(src) then return end
    if type(data) ~= 'table' then return end

    if #data == 0 then
        if isValidJob(data.job) then
            exports['lb-tablet']:AddDispatch(data)
        end
    else
        for i = 1, #data do
            local nData = data[i]
            if type(nData) == 'table' and isValidJob(nData.job) then
                exports['lb-tablet']:AddDispatch(nData)
            end
        end
    end
end)


-------------------------------
RegisterNetEvent('mfp_lb-dispatches:sendDispatchToAll')
AddEventHandler('mfp_lb-dispatches:sendDispatchToAll', function(coords, jobName, message)
    local src = source
    if not canTriggerDispatch(src) then return end
    if not isValidJob(jobName) then return end

    TriggerClientEvent('mfp_lb-dispatches:showDispatchDefault', -1, coords, jobName, message)
end)

RegisterNetEvent('mfp_lb-dispatches:sendCustomDispatch')
AddEventHandler('mfp_lb-dispatches:sendCustomDispatch', function(coords, jobName, message)
    local src = source
    if not canTriggerDispatch(src) then return end
    if not isValidJob(jobName) then return end

    SendCustomDispatch(jobName, coords, message)
end)

RegisterServerEvent('mfp_lb-dispatches:qs-dispatch:sendDispatch')
AddEventHandler('mfp_lb-dispatches:qs-dispatch:sendDispatch', function(department, dmessage, coords)
    local src = source
    if not canTriggerDispatch(src) then return end
    if not isValidJob(department) then return end

    TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
        job = { department },
        callLocation = vector3(coords.x, coords.y, coords.z),
        callCode = { code = Config.CallCode, snippet = Translation['emergency'] },
        message = dmessage, -- Dispatch call message
        flashes = false, -- Should the blip on the map flash?
        
        blip = { -- Blip details for the map
            sprite = Config.Blip.sprite, -- Blip icon type
            scale = Config.Blip.scale, -- Blip size
            colour = Config.Blip.colour, -- Blip color
            flashes = false,
            text = Translation['emergency'], -- Blip label
            time = (Config.Blip.time * 1000), -- Duration of the blip (milliseconds)
        },
        otherData = { -- Additional optional information
            {
                text = Translation['send_via_sos_app'], -- Additional detail
                icon = 'fas fa-user-secret' -- Font Awesome icon
            }
        }
    })

end)