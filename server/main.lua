
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