--[[
    Author: Igromanru
    Date: 20.08.2024
    Mod Name: Instant Fishing
]]

---------- Configurations ----------
-- Enable mod from the start
ModEnabled = true
-- Set to true to disable the bait usage
InfiniteBait = false
-------------- Hotkeys -------------
-- Possible keys: https://github.com/UE4SS-RE/RE-UE4SS/blob/main/docs/lua-api/table-definitions/key.md
-- See ModifierKey: https://github.com/UE4SS-RE/RE-UE4SS/blob/main/docs/lua-api/table-definitions/modifierkey.md
-- ModifierKeys can be combined. e.g.: {ModifierKey.CONTROL, ModifierKey.ALT} = CTRL + ALT + Q
-- Set to `nil` to disable hotkey.
ToggleKey = Key.F5
ToggleKeyModifiers = {}
------------------------------------

------------------------------
-- Don't change code below --
------------------------------
local AFUtils = require("AFUtils.AFUtils")

ModName = "InstantFishing"
ModVersion = "1.3.0"
DebugMode = true

LogInfo("Starting mod initialization")

--------- Call order ---------
---
-- 1. OnRep_ActiveFishingLocation
-- 2. Local_DetermineReward
-- 3. Start Fishing Minigame
--- After catching a fish ---
-- 4. Request_FishingReward
-- 5. OnRep_ActiveFishingLocation
-- 6. EndFishingMinigame
-- 7. FishingSuccess
------------------------------

local function StartFishingMinigameHook(Context)
    local fishingRod = Context:get() ---@type AWeapon_FishingRod_C

    -- if DebugMode then
    --     print(ModInfoAsPrefix().."---- [Start Fishing Minigame] called ----\n")
    --     print(ModInfoAsPrefix()..string.format("CatchingJunk: %s\n", tostring(fishingRod.CatchingJunk)))
    --     print(ModInfoAsPrefix()..string.format("LuckyHat: %s\n", tostring(fishingRod.LuckyHat)))
    --     print(ModInfoAsPrefix().."------------------------------\n")
    -- end
    if ModEnabled then
        if not InfiniteBait then
            fishingRod:Request_TriggerBaitUsage()
        end
        fishingRod:FishingSuccess()
    end
end

ExecuteInGameThread(function()
    LogInfo("Initializing hooks")
    LoadAsset("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C")
    RegisterHook("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:Start Fishing Minigame", StartFishingMinigameHook)
    LogInfo("Hooks initialized")
end)

if ToggleKey and ToggleKeyModifiers then
    local function SetModState(Enable)
        ExecuteInGameThread(function()
            Enable = Enable or false
            ModEnabled = Enable
            local state = "Disabled"
            local warningColor =  AFUtils.CriticalityLevels.Red
            if ModEnabled then
                state = "Enabled"
                warningColor =  AFUtils.CriticalityLevels.Green
            end
            local stateMessage = "Instant Fishing: " .. state
            LogInfo(stateMessage)
            AFUtils.ModDisplayTextChatMessage(stateMessage)
            AFUtils.ClientDisplayWarningMessage(stateMessage, warningColor)
        end)
    end
    
    RegisterKeyBind(ToggleKey, ToggleKeyModifiers, function()
        SetModState(not ModEnabled)
    end)
end

LogInfo("Mod loaded successfully")
