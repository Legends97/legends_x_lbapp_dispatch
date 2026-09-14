
local activeBlips = {}

function createBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 137)
    SetBlipScale(blip, 1.5)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Translation['emergency'])
    EndTextCommandSetBlipName(blip)

    table.insert(activeBlips, blip)

    SetNewWaypoint(coords.x, coords.y)

    Citizen.SetTimeout(420000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end

function notifyPlayer(ttl, msg, data)
    if Config.Notification == 'lb-phone' then
        exports["lb-phone"]:SendNotification({
            app = "mfp_lb-dispatches",
            title = ttl,
            content = msg,
        })
    elseif Config.Notification == 'mfp' then
        exports['mfp_notify']:ShowNotification(
            ttl,
            msg,
            "icons/emergency-icon.png"
        )
    elseif Config.Notification == 'lux' then
        LUX = exports['Lux_Lib']:getLibObject()
        LUX.Notify(msg, ttl, 6000, info)
    elseif Config.Notification == 'custom' then
        SendCustomNotify(ttl, msg)
    else
        Notify(msg)
    end
end


function createDispatch(data)
    local department = data.job
    local message = data.message

    local ped = PlayerPedId()
    local myPos = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
    local streetName = GetStreetNameFromHashKey(streetHash) or Translation['unknown_location']

        -- Placeholder for player sex (FiveM does not provide this natively)
    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local gameTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)

    -- Dispatches
    if Config.DispatchSystem == 'lb-tablet' then
        local lbDispatch = {
                priority = 'medium',
                code = Config.CallCode,
                title = Translation['emergency'],
                description = message..' ('..streetName..')',
                location = {
                    label = Translation['emergency'],
                    coords = { x = myPos.x, y = myPos.y } -- Ensuring correct format
                },
                time = 400, -- Dispatch lasts for 5 minutes
                job = department, -- Police only
                fields = {
                    { icon = 'map-marker', label = Translation['location'], value = streetName },
                    { icon = 'clock', label = Translation['time'], value = gameTime }
                }
            }
    
        if data.job == Config.Jobs.police or data.job == Config.Jobs.ambulance then
            TriggerServerEvent('mfp_lb-dispatches:lb-tablet:triggerDispatch', lbDispatch)
            -- NOTE: LB-Tablet only supports police and ambulance, rest will be framework
        else
            TriggerServerEvent('mfp_lb-dispatches:sendDispatchToAll', myPos, data.job, data.message)
        end
    elseif Config.DispatchSystem == 'qs-dispatch' then
        TriggerServerEvent('mfp_lb-dispatches:qs-dispatch:sendDispatch', data.job, data.message, myPos)
    elseif Config.DispatchSystem == 'core' then
        TriggerServerEvent("core_dispatch:addCall", 
  		    Config.CallCode, 
  		    Translation['emergency'], 
  		    {
    	        {icon = "fa-bullhorn", info = data.message}
  		    },
  		    { 
                playerCoords.x, playerCoords.y, playerCoords.z 
            },
 		    data.job,
  		    5000,
  		    60, 
  		    1
		)
    elseif Config.DispatchSystem == 'aty' then
        TriggerEvent("aty_dispatch:SendDispatch",Translation['emergency'].." - "..data.message, Config.CallCode, 60, {"police"})
    elseif Config.DispatchSystem == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {data.job}, 
            coords = data.coords,
            title = Config.CallCode..' - '..Translation['emergency'],
            message = data.message, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, 
                scale = 1.2, 
                colour = 3,
                flashes = false, 
                text = Translation['emergency'],
                time = 5,
                radius = 0,
            }
        })
    elseif Config.DispatchSystem == 'framework' then
        TriggerServerEvent('mfp_lb-dispatches:sendDispatchToAll', myPos, data.job, data.message)
    else
        if Config.useCustomDispatchClientside then
            SendCustomDispatch(data.job, myPos, data.message)
        else
            TriggerServerEvent('mfp_lb-dispatches:sendCustomDispatch', myPos, data.job, data.message)
        end
    end
end -- end of function