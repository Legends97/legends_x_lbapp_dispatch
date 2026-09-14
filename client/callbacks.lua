local timeout = false
RegisterNUICallback('sendEmergencyMessage', function(data, cb)
    if not timeout then

        local department = data.job
        if department == 'police' then
            data.job = Config.Jobs.police
        elseif department == 'ambulance' then
            data.job = Config.Jobs.ambulance
        elseif department == 'mechanic' then
            data.job = Config.Jobs.mechanic
        end

        createDispatch(data, nil)
        notifyPlayer(Translation['dispatch_send'], Translation['dispatch_message']..": "..data.message)
        timeout = true
    end

    Wait(Config.TimeOut * 1000)
    timeout = false
end)


RegisterNUICallback('app:ready', function(data, cb)
    local playerData = GetPlayerData()
    local job = playerData and playerData.job and playerData.job.name
    local isDispatchJob = false

    for _, configuredJob in pairs(Config.Jobs) do
        if configuredJob == job then
            isDispatchJob = true
            break
        end
    end

    if isDispatchJob then
        TriggerServerEvent('mfp_lb-dispatches:app:requestOpen', job)
    end

    cb({ isDispatchJob = isDispatchJob })
end)

RegisterNUICallback('app:accept', function(data, cb)
    local playerData = GetPlayerData()
    local job = playerData and playerData.job and playerData.job.name

    TriggerServerEvent('mfp_lb-dispatches:app:accept', data.id, job)
    cb('ok')
end)

RegisterNUICallback('app:decline', function(data, cb)
    ActiveDispatches[data.id] = nil
    cb('ok')
end)

RegisterNUICallback('callEmergencyHotline', function(data, cb)
    local department = data.job

    if data.job == 'police' then
        department = Config.Jobs.police
    elseif data.job == 'ambulance' then
        department = Config.Jobs.ambulance
    elseif data.job == 'mechanic' then
        department = Config.Jobs.mechanic
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local pos = {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }

    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber()
    local options = {number = phoneNumber, company = department, videoCall = false, hideNumber = true}
    exports["lb-phone"]:CreateCall(options)

end)