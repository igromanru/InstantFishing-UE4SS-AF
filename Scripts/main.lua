--[[
    Author: Igromanru
    Date: 20.08.2024
    Mod Name: Instant Fishing
]]

---------- Configurations ----------
-- Enable mod from the start
ModEnabled = true
-- Set to `true` to disable the bait usage
InfiniteBait = false
-- Set delay in milliseconds (1 sec = 1000 milliseconds)
PullingOutDelay = 0
-- Set to `true` to wait until the fish bites
WaitForFish = false
-------------- Hotkeys -------------
-- Possible keys: https://github.com/UE4SS-RE/RE-UE4SS/blob/main/docs/lua-api/table-definitions/key.md
-- See ModifierKey: https://github.com/UE4SS-RE/RE-UE4SS/blob/main/docs/lua-api/table-definitions/modifierkey.md
-- ModifierKeys can be combined. e.g.: {ModifierKey.CONTROL, ModifierKey.ALT} = CTRL + ALT + Q
-- Set to `nil` to disable hotkey.
ToggleKey = nil
ToggleKeyModifiers = {}
------------------------------------

------------------------------
-- Don't change code below --
------------------------------
local AFUtils = require("AFUtils.AFUtils")

ModName = "InstantFishing"
ModVersion = "1.5.1"
DebugMode = true

LogInfo("Starting mod initialization")

--------- Call order ---------
---
-- 1. OnRep_ActiveFishingLocation
-- 2. Local_DetermineReward
-- 3. Start Fishing Minigame
-- 4. ChooseNewDirection (each time the fish changes the pull direction)
--- After catching a fish ---
-- 5. Request_FishingReward
-- 6. OnRep_ActiveFishingLocation
-- 7. EndFishingMinigame
-- 8. FishingSuccess
------------------------------

if not PullingOutDelay or type(PullingOutDelay) ~= "number" or PullingOutDelay < 0 then
    PullingOutDelay = 0
    LogWarn("PullingOutDelay set to an invalid value! Reset it back to 0.")
end

local function FinishFishing()
    if ModEnabled then
        ExecuteWithDelay(PullingOutDelay, function()
            ExecuteInGameThread(function()
                local fishingRod = AFUtils.GetCurrentFishingRod()
                if fishingRod then
                    if not InfiniteBait then
                        fishingRod:Request_TriggerBaitUsage()
                    end
                    fishingRod:FishingSuccess()
                end
            end)
        end)
    end
end

local function ChooseNewDirectionHook(Context, AngleOnly)
    -- local fishingRod = Context:get() ---@type AWeapon_FishingRod_C
    -- local angleOnly = AngleOnly:get() ---@type boolean
    FinishFishing()
end

local function StartFishingMinigameHook(Context)
    -- local fishingRod = Context:get() ---@type AWeapon_FishingRod_C

    -- if DebugMode then
    --     print(ModInfoAsPrefix().."---- [Start Fishing Minigame] called ----\n")
    --     print(ModInfoAsPrefix()..string.format("CatchingJunk: %s\n", tostring(fishingRod.CatchingJunk)))
    --     print(ModInfoAsPrefix()..string.format("LuckyHat: %s\n", tostring(fishingRod.LuckyHat)))
    --     print(ModInfoAsPrefix().."------------------------------\n")
    -- end
    FinishFishing()
end

if AFUtils.IsDedicatedServer() then
    LogError("Doesn't work on a dedicated server! The mod is disabled.")
else
    ExecuteWithDelay(10000, function()
        ExecuteInGameThread(function()
            LogInfo("Initializing hooks")
            LoadAsset("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C")
            if WaitForFish then
                RegisterHook("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:ChooseNewDirection", ChooseNewDirectionHook)
            else
                RegisterHook("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:Start Fishing Minigame", StartFishingMinigameHook)
            end
            LogInfo("Hooks initialized")
        end)
    end)
end

if ToggleKey and type(ToggleKeyModifiers) == "table" and #ToggleKeyModifiers > 0 then
    local function SetModState(Enable)
        ExecuteInGameThread(function()
            ModEnabled = Enable or false
            local state = "Disabled"
            local warningColor = AFUtils.CriticalityLevels.Red
            if ModEnabled then
                state = "Enabled"
                warningColor = AFUtils.CriticalityLevels.Green
            end
            local stateMessage = "Instant Fishing: " .. state
            LogInfo(stateMessage)
            -- AFUtils.ModDisplayTextChatMessage(stateMessage)
            AFUtils.ClientDisplayWarningMessage(stateMessage, warningColor)
        end)
    end

    RegisterKeyBind(ToggleKey, ToggleKeyModifiers, function()
        SetModState(not ModEnabled)
    end)
end

LogInfo("Mod loaded successfully")
