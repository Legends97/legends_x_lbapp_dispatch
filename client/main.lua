local identifier = "mfp_lb-dispatches"

CreateThread(function ()
    while GetResourceState("lb-phone") ~= "started" do
        Wait(500)
    end

    local function AddApp()
        local added, errorMessage = exports["lb-phone"]:AddCustomApp({
            identifier = identifier,
            name = Config.AppName,
            description = Config.Description,
            developer = "MFPSCRIPTS.com",
            defaultApp = Config.DefaultApp,
            size = Config.Size,
            images = Config.Images,
            ui = GetCurrentResourceName() .. "/html/index.html",
            icon = "https://cfx-nui-" .. GetCurrentResourceName() .. "/html/app.png"
        })

        if not added then
            print("Could not add app:", errorMessage)
        end
    end

    AddApp()

    AddEventHandler("onResourceStart", function(resource)
        if resource == "lb-phone" then
            AddApp()
        end
    end)
end)

RegisterNetEvent('mfp_lb-dispatches:showDispatchDefault')
AddEventHandler('mfp_lb-dispatches:showDispatchDefault', function(coords, jobName, message)
    local player = PlayerPedId()
    local playerData = GetPlayerData()

    if playerData.job and playerData.job.name == jobName then
            notifyPlayer(Translation['dispatch_got'], Translation['dispatch']..": "..message)
            createBlip(coords)
        end

end)

------------ APP DISPATCH QUEUE --------

ActiveDispatches = {}

local function myJob()
    local playerData = GetPlayerData()
    return playerData and playerData.job and playerData.job.name
end

RegisterNetEvent('mfp_lb-dispatches:app:add')
AddEventHandler('mfp_lb-dispatches:app:add', function(dispatch)
    if dispatch.targetJob ~= myJob() then return end

    ActiveDispatches[dispatch.id] = dispatch
    SendNUIMessage({ action = 'addDispatch', dispatch = dispatch })
    notifyPlayer(Translation['dispatch_got'], Translation['dispatch']..": "..dispatch.title)
end)

RegisterNetEvent('mfp_lb-dispatches:app:remove')
AddEventHandler('mfp_lb-dispatches:app:remove', function(id)
    ActiveDispatches[id] = nil
    SendNUIMessage({ action = 'removeDispatch', id = id })
end)

RegisterNetEvent('mfp_lb-dispatches:app:sync')
AddEventHandler('mfp_lb-dispatches:app:sync', function(dispatches)
    ActiveDispatches = {}
    for _, dispatch in ipairs(dispatches) do
        ActiveDispatches[dispatch.id] = dispatch
    end
    SendNUIMessage({ action = 'setDispatches', dispatches = dispatches })
end)

RegisterNetEvent('mfp_lb-dispatches:app:accepted')
AddEventHandler('mfp_lb-dispatches:app:accepted', function(data)
    createBlip(data.coords, Translation['emergency']..' | Postal '..data.postal)
end)

RegisterNetEvent('mfp_lb-dispatches:app:notifyAccepted')
AddEventHandler('mfp_lb-dispatches:app:notifyAccepted', function()
    notifyPlayer(Translation['dispatch'], Translation['dispatch_accepted_notify'])
end)