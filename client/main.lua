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