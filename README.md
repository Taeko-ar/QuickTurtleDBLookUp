# QuickTurtleDBLookUp

Why? I'm lazy and I don't want to type on the db the name of the npc and search for the specific npc I'm looking for.

## Dependencies

Because the base Vanilla 1.12 client does not natively expose precise NPC IDs to the Lua API, **this addon utilizes [SuperWow](https://github.com/balakethelock/SuperWoW)** 

*If neither of these native IDs are found, the addon features an automatic smart-fallback that generates a URL to query the database by the NPC's actual name rather than their exact database ID.*

## How it Works

1. Target an NPC anywhere in the game, find an Item/Quest Link in the chat, or open your inventory bags.
2. **Right-click** the NPC's target portrait natively, **Right-click** an Item/Quest link in chat natively, or **Ctrl+Right-Click** any item in your inventory bags.
3. A small dropdown context menu will appear by your cursor. Click **TurtleDB Lookup**.
4. A popup window will appear on your screen containing a direct link to the NPC or Item on `https://database.turtlecraft.gg`.
5. The URL text is automatically highlighted, so you can instantly press `Ctrl+C` to copy it and paste it into your browser.

## Commands

- `/qdb` - Force a database lookup on your current target via chat instead of using the right-click menu.
- `/qdb toggle` - Enable or disable the addon.
- `/qdb debug` - Toggles the debug mode.
- `/qdb help` - Shows a list of available slash commands.

## Translations

This plugin has translations and support for Spanish and Portuguese. (Aprende ingles porrito lpm)

## Supported Unitframes

The right-click context menu seamlessly intercepts interaction for most commonly used Vanilla / Turtle WoW Unitframe addons natively:
- **Default Blizzard Target Frames**
- **pfUI** (`pfTarget`)
- **LunaUnitFrames** (`LunaTargetFrame`)
- **XPerl** (`XPerl_Target`)
- **Shadowed Unit Frames** (`SUFUnittarget`)
- **DiscordUnitFrames** (`DUF_TargetFrame`)

*Note: The addon also explicitly hooks into the overarching `ClickCastFrames` API protocol, granting it universal out-of-the-box compatibility with almost any obscure or custom unit frame addon that interacts cleanly with the Vanilla ecosystem*
