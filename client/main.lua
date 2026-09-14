local identifier = "mfp_lb-dispatches"
local appAdded = false

local function isEligibleJob(job)
    for _, configuredJob in pairs(Config.Jobs) do
        if configuredJob == job then
            return true
        end
    end
    return false
end

local function AddApp()
    if appAdded then return end

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

    if added then
        appAdded = true
    else
        print("Could not add app:", errorMessage)
    end
end

local function RemoveApp()
    if not appAdded then return end

    local removed, errorMessage = exports["lb-phone"]:RemoveCustomApp(identifier)

    if removed then
        appAdded = false
    else
        print("Could not remove app:", errorMessage)
    end
end

-- Only players whose job is in Config.Jobs get the app (police/ambulance/etc),
-- citizens never see it. Call this again whenever the local player's job changes.
function RefreshDispatchAppVisibility()
    if not Loaded then return end

    local playerData = GetPlayerData()
    local job = playerData and playerData.job and playerData.job.name

    if isEligibleJob(job) then
        AddApp()
    else
        RemoveApp()
    end
end

CreateThread(function ()
    while GetResourceState("lb-phone") ~= "started" do
        Wait(500)
    end

    while not Loaded do
        Wait(500)
    end

    RefreshDispatchAppVisibility()

    AddEventHandler("onResourceStart", function(resource)
        if resource == "lb-phone" then
            appAdded = false
            RefreshDispatchAppVisibility()
        end
    end)
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
    createBlip(data.coords, Translation['emergency']..' | '..Translation['postal']..' '..data.postal)
end)

RegisterNetEvent('mfp_lb-dispatches:app:notifyAccepted')
AddEventHandler('mfp_lb-dispatches:app:notifyAccepted', function()
    notifyPlayer(Translation['dispatch'], Translation['dispatch_accepted_notify'])
end)