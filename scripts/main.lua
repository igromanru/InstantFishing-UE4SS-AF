--[[
    Author: Igromanru
    Date: 20.08.2024
    Mod Name: Instant Fishing
]]

------------------------------
-- Don't change code below --
------------------------------
local ModName = "InstantFishing"
local ModVersion = "1.1.1"
local DebugMode = false

local function ModInfoAsPrefix()
    return "["..ModName.." v"..ModVersion.."] "
end

print(ModInfoAsPrefix().."Starting mod initialization")

local IsModEnabled = true

local function StartFishingMinigameHook(Context)
    local fishingRod = Context:get()

    if IsModEnabled then
        fishingRod:FishingSuccess()
    end
end

local IsStartFishingMinigameHooked = false
local function HookStartFishingMinigame()
    if not IsStartFishingMinigameHooked then
        RegisterHook("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:Start Fishing Minigame", StartFishingMinigameHook)
        IsStartFishingMinigameHooked = true
    end
end

-- For hot reload
if DebugMode then
    HookStartFishingMinigame()
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context, NewPawn)
    HookStartFishingMinigame()
end)

print(ModInfoAsPrefix().."Mod loaded successfully")
