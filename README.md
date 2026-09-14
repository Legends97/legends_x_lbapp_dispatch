# MFP Advanced Dispatch App for LB-Phone

![preview](https://github.com/user-attachments/assets/f74a49fd-3f74-4514-979d-54f5590c2e33)

Dispatch-receiving App for **LB-Phone**: players whose job is in `Config.Jobs` get the app, see incoming dispatches in a live list, and can Accept (sets a waypoint/blip) or Decline. Works with ESX, QB-Core, or a custom framework.

## Features

- Compatible with ESX, QB-Core, and custom frameworks
- App UI text follows `Config.Locale` too, not just server-side notifications
- App is only added to players whose job is in `Config.Jobs` — citizens never see it, and it's added/removed live on job change
- Dispatch list with postal-code lookup, Accept/Decline, auto-expiry
- `exports('CreateAlertDispatch', ...)` for other resources (robbery, medic, etc.) to report an alert
- Included languages: English, German, French, Spanish, Italian, Portuguese, Brazilian Portuguese, Dutch, Polish, Russian, Turkish (`locales/*.lua`)

## Dependencies

- [lb-phone](https://github.com/Loaf-Scripts/lb-phone) (required)
- One of: `es_extended` (ESX), `qb-core` (QB-Core), or your own framework

## Installation

1. Drop this resource into your server's `resources` folder.
2. Add `ensure <resource-name>` to your `server.cfg`, after `lb-phone` and your framework.
3. Configure `config/config.lua` (see below).
4. Restart the resource / server.

## Configuration (`config/config.lua`)

| Setting | Purpose |
|---|---|
| `Config.AppName`, `Config.Description`, `Config.Images` | LB-Phone app store listing |
| `Config.DefaultApp` | `true` = pre-installed, `false` = downloadable via App Store, for eligible jobs |
| `Config.Framework` | `'auto'`, `'esx'`, `'qb-core'`, or `'custom'` |
| `Config.Locale` | Translation file to load from `locales/` |
| `Config.Jobs` | Jobs that get the app and receive dispatches (maps `police`/`ambulance`/... to your actual job names) |
| `Config.DispatchExpireMinutes` | how long an unaccepted dispatch stays in the queue |
| `Config.Postals` | `{enabled, file}` — postal-code lookup table shown on dispatches |
| `Config.Notification` | `'lb-phone'`, `'framework'`, `'mfp'`, `'lux'`, or `'custom'` |
| `Config.Blip` | Map blip sprite/scale/colour/duration for the accepted dispatch's waypoint |

For `Config.Framework = 'custom'`, implement `GetPlayerData()` in `bridge/custom/client.lua`. For `Config.Notification = 'custom'`, implement `SendCustomNotify()` in `config/config.lua`.

## Creating dispatches

The app itself has no "send" UI — dispatches come from other resources:

- `exports['<this-resource-name>']:CreateAlertDispatch(coords, message, targetJob, dispatchType)` — generic alert
- `exports['<this-resource-name>']:CreateDeathDispatchFromDeathscreen(playerId)` — downed-player dispatch to `Config.Jobs.ambulance`
- `TriggerServerEvent('asuna_dispatch:serverCreateFromDeathscreen')` — legacy event name kept for drop-in compatibility with asuna_dispatch-based medic scripts, no changes needed on their side

## Adding a translation

Copy `locales/en.lua`, translate the strings, save as `locales/<code>.lua`, then set `Config.Locale = '<code>'`. Contribute translations upstream at https://github.com/mfpscripts/TRANSLATIONS.

## Support

This is community-released, unsupported code — no official support is provided.
