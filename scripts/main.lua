--[[
    Author: Igromanru
    Date: 20.08.2024
    Mod Name: Instant Fishing
]]

---------- Configurations ----------
InfiniteBait = false
-------------------------------------

------------------------------
-- Don't change code below --
------------------------------
local ModName = "InstantFishing"
local ModVersion = "1.2.0"
local DebugMode = true
local IsModEnabled = true

local function ModInfoAsPrefix()
    return "["..ModName.." v"..ModVersion.."] "
end

print(ModInfoAsPrefix().."Starting mod initialization\n")

local function StartFishingMinigameHook(Context)
    local fishingRod = Context:get() ---@type AWeapon_FishingRod_C

    -- if DebugMode then
    --     print(ModInfoAsPrefix().."---- [Start Fishing Minigame] called ----\n")
    --     print(ModInfoAsPrefix()..string.format("CatchingJunk: %s\n", tostring(fishingRod.CatchingJunk)))
    --     print(ModInfoAsPrefix()..string.format("LuckyHat: %s\n", tostring(fishingRod.LuckyHat)))
    --     print(ModInfoAsPrefix().."------------------------------\n")
    -- end
    if IsModEnabled then
        if not InfiniteBait then
            fishingRod:Request_TriggerBaitUsage()
        end
        fishingRod:FishingSuccess()
    end
end

ExecuteInGameThread(function()
    print(ModInfoAsPrefix().."Initializing hooks\n")
    LoadAsset("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C")
    RegisterHook("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:Start Fishing Minigame", StartFishingMinigameHook)
    print(ModInfoAsPrefix().."Hooks initialized\n")
end)

print(ModInfoAsPrefix().."Mod loaded successfully\n")
