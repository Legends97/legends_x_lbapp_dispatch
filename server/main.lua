
local timeouts = {}

local function canTriggerDispatch(src)
    local gameTime = GetGameTimer()
    if timeouts[src] and timeouts[src] < gameTime then
        timeouts[src] = gameTime
        return true
    elseif not timeouts[src] then
        timeouts[src] = gameTime
        return true
    else
        return false
    end
end

RegisterNetEvent('mfp_lb-dispatches:lb-tablet:triggerDispatch', function (data)
    local src = source

    if not canTriggerDispatch(src) then return end

    if #data == 0 then
        exports['lb-tablet']:AddDispatch(data)
    else
        for i = 1, #data do
            local nData = data[i]
            exports['lb-tablet']:AddDispatch(nData)
        end
    end
end)


-------------------------------
RegisterNetEvent('mfp_lb-dispatches:sendDispatchToAll')
AddEventHandler('mfp_lb-dispatches:sendDispatchToAll', function(coords, jobName, message)
    TriggerClientEvent('mfp_lb-dispatches:showDispatchDefault', -1, coords, jobName, message)
end)

RegisterNetEvent('mfp_lb-dispatches:sendCustomDispatch')
AddEventHandler('mfp_lb-dispatches:sendCustomDispatch', function(coords, jobName, message)
    SendCustomDispatch(data.department, myPos, data.message)
end)

RegisterServerEvent('mfp_lb-dispatches:qs-dispatch:sendDispatch')
AddEventHandler('mfp_lb-dispatches:qs-dispatch:sendDispatch', function(department, dmessage, coords)

    TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
        job = { department },
        callLocation = vector3(coords.x, coords.y, coords.z),
        callCode = { code = Config.CallCode, snippet = Translation['emergency'] },
        message = dmessage, -- Dispatch call message
        flashes = false, -- Should the blip on the map flash?
        
        blip = { -- Blip details for the map
            sprite = Config.Blip.sprite, -- Blip icon type
            scale = Config.Blip.scale, -- Blip size
            colour = Config.Blip.color, -- Blip color
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