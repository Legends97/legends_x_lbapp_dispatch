
local activeBlips = {}

function createBlip(coords, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.colour)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label or Translation['emergency'])
    EndTextCommandSetBlipName(blip)

    table.insert(activeBlips, blip)

    SetNewWaypoint(coords.x, coords.y)

    Citizen.SetTimeout(Config.Blip.time * 1000, function()
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
        LUX.Notify(msg, ttl, 6000, nil)
    elseif Config.Notification == 'custom' then
        SendCustomNotify(ttl, msg)
    else
        Notify(msg)
    end
end
