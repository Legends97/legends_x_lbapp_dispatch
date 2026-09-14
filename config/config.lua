Config = {}

----------- App Settings -------
Config.AppName = "SOS"
-- Displayed Name for OS & AppStore
Config.Description = "Sende Notrufe an das ARPD, ARRS oder Vega Performance"
-- Displayed Description for AppStore
Config.DefaultApp = true
-- 'true' sets App Pre-Installed, 'false' requires download via AppStore
Config.Size = 52812
-- Sets App Size for Storage Usage from Phone
Config.Images = {}
-- Displayed Images in AppStore, 
-- Usage: {"https://link.com/example.png", "https://link.com/example2.png"}


----------- FRAMEWORK & SCRIPTS -------
Config.Framework = 'esx'
-- 'auto' for auto selection
-- 'qb-core' for qbcore
-- 'esx' for aty_dispatch
-- 'custom' for own framework

Config.Locale = 'de' -- see folder: locales/*lua for all translations
-- Constribute on adding your own translation at: https://github.com/mfpscripts/TRANSLATIONS

Config.Jobs = {
    police = 'arpd',
    ambulance = 'arrs',
    mechanic = 'vega_performance'
    -- 'police' sets police job name
    -- 'ambulance' sets ambulance/fire job name
    -- 'mechanic' sets mechanic/bennys job name
}

------------ DISPATCH & SETTINGS --------
Config.TimeOut = 10 -- in seconds, until the message button can be used again to send dispatch
Config.CallCode = "10-19"
Config.DispatchSystem = 'custom'
-- 'framework' for default core dispatch
-- 'lb-tablet' for LB-Tablet (only Police & Ambulance, others are using framework!)
-- 'qs-dispatch' for Quasar Dispatch
-- 'aty' for aty_dispatch
-- 'cd_dispatch' for cd_dispatch
-- 'custom' for custom script

Config.Notification = 'lb-phone'
-- 'lb-phone' uses lb-app-notifications
-- 'framework' uses framework related notify
-- 'mfp' uses mfp notifications
-- 'lux' uses lux notifications
-- 'custom' uses SendCustomNotify

function SendCustomNotify(title, message)
    -- add your own here
end

Config.useCustomDispatchClientside = true
-- false if you want this to be serverside, default true
function SendCustomDispatch(job, pos, message)
    -- add your own here
end

------------ BLIPS ---------
Config.Blip = {
    sprite = 526,
    scale = 1.5,
    colour = 1,
    time = 300

    -- 'label' sets Blip Label text
    -- 'sprite' sets Blip icon type
    -- 'scale' sets Blip scale
    -- 'colour' sets Blip color
    -- 'time' sets Blip time until it disapears from map
}

-----------------------------