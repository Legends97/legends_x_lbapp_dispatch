# MFP Advanced Dispatch App for LB-Phone

![preview](https://github.com/user-attachments/assets/f74a49fd-3f74-4514-979d-54f5590c2e33)

Custom Dispatches App for **LB-Phone**, for FiveM roleplay servers. Works with ESX, QB-Core, or a custom framework, and forwards emergency calls to your dispatch system of choice.

:clapper: Demo: https://www.youtube.com/watch?v=O6yrWtXWzi0

## Features

- Compatible with ESX, QB-Core, and custom frameworks
- Fully configurable in `config/config.lua`
- Works with custom notification scripts
- Integrates with QS-Dispatch, LB-Tablet, Core-Dispatch, ATY Dispatch, CD Dispatch, or a fully custom dispatch handler
- Included languages: English, German, French, Spanish, Italian, Portuguese, Brazilian Portuguese, Dutch, Polish, Russian, Turkish (`locales/*.lua`)

## Dependencies

- [lb-phone](https://github.com/Loaf-Scripts/lb-phone) (required)
- One of: `es_extended` (ESX), `qb-core` (QB-Core), or your own framework
- One of the supported dispatch resources, if not using the built-in custom handler

## Installation

1. Drop this resource into your server's `resources` folder.
2. Add `ensure <resource-name>` to your `server.cfg`, after `lb-phone` and your framework/dispatch resources.
3. Configure `config/config.lua` (see below).
4. Restart the resource / server.

## Configuration (`config/config.lua`)

| Setting | Purpose |
|---|---|
| `Config.AppName`, `Config.Description`, `Config.Images` | LB-Phone app store listing |
| `Config.DefaultApp` | `true` = pre-installed, `false` = downloadable via App Store |
| `Config.Framework` | `'auto'`, `'esx'`, `'qb-core'`, or `'custom'` |
| `Config.Locale` | Translation file to load from `locales/` |
| `Config.Jobs` | Maps `police` / `ambulance` / `mechanic` to your actual job names |
| `Config.TimeOut` | Seconds between dispatch messages a player can send |
| `Config.DispatchSystem` | `'app'` (built-in queue, see below), `'framework'`, `'lb-tablet'`, `'qs-dispatch'`, `'aty'`, `'cd_dispatch'`, or `'custom'` |
| `Config.DispatchExpireMinutes` | how long an unaccepted `'app'` dispatch stays in the queue |
| `Config.Postals` | `{enabled, file}` — postal-code lookup table shown on `'app'` dispatches |
| `Config.Notification` | `'lb-phone'`, `'framework'`, `'mfp'`, `'lux'`, or `'custom'` |
| `Config.Blip` | Map blip sprite/scale/colour/duration for received dispatches |

For `Config.Framework = 'custom'`, implement `GetPlayerData()` in `bridge/custom/client.lua`. For `Config.DispatchSystem = 'custom'` / `Config.Notification = 'custom'`, implement `SendCustomDispatch()` / `SendCustomNotify()` in `config/config.lua`.

## Built-in dispatch queue (`Config.DispatchSystem = 'app'`)

Job members whose job is in `Config.Jobs` see a "Notrufe" button in the app: it lists open dispatches (title, time, postal), with Accept (sets a waypoint/blip) and Decline. Sources of a dispatch:

- Citizens using the app's SOS message screen
- Any other resource, via `exports['<this-resource-name>']:CreateAlertDispatch(coords, message, targetJob, dispatchType)` — same signature as `asuna_dispatch`'s export, for drop-in replacement of that resource (e.g. a robbery or medic script reporting an alert)

## Adding a translation

Copy `locales/en.lua`, translate the strings, save as `locales/<code>.lua`, then set `Config.Locale = '<code>'`. Contribute translations upstream at https://github.com/mfpscripts/TRANSLATIONS.

## Support

This is community-released, unsupported code — no official support is provided.
