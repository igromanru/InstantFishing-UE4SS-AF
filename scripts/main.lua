--[[
    Author: Igromanru
    Date: 20.08.2024
    Mod Name: Instant Fishing
]]

------------------------------
-- Don't change code below --
------------------------------
local AFUtils = require("AFUtils.AFUtils")

ModName = "InstantFishing"
ModVersion = "1.0.0"
DebugMode = true

LogInfo("Starting mod initialization")

local IsModEnabled = true

local function TickMinigameHook(Context, DeltaTime)
    local this = Context:get()
    if IsModEnabled and this.ActiveFishSpeed > 0 and this.CurrentOwner and this.CurrentOwner:IsValid() then
        LogDebug("[TickMinigame] called:")
        LogDebug("ActiveRodTension: " .. this.ActiveRodTension)
        LogDebug("NextDirectionChangeTime: " .. this.NextDirectionChangeTime)
        LogDebug("NextCooldownTime: " .. this.NextCooldownTime)
        LogDebug("FishCaptureProgress: " .. this.FishCaptureProgress)
        LogDebug("FishCaptureDistance: " .. this.FishCaptureDistance)
        LogDebug("FishCaptureStage: " .. this.FishCaptureStage)
        LogDebug("ActiveFishSpeed: " .. this.ActiveFishSpeed)
        LogDebug("TimeToStartMinigame: " .. this.TimeToStartMinigame)
        LogDebug("HasActiveFish: " .. tostring(this.HasActiveFish))
        LogDebug("ReelAnimTime: " .. this.ReelAnimTime)
        LogDebug("Reeling: " .. tostring(this.Reeling))
        LogDebug("HotspotActive: " .. tostring(this.HotspotActive))
        LogDebug("LastTimeFishingEnded: " .. this.LastTimeFishingEnded)
        LogDebug("CatchingJunk: " .. tostring(this.CatchingJunk))
        LogDebug("JunkReward.RowName: " .. this.JunkReward.RowName:ToString())
        LogDebug("FishReward.RowName: " .. this.FishReward.RowName:ToString())
        LogDebug("FishReward.DataTablePath: " .. this.FishReward.DataTablePath:ToString())
        LogDebug("RequiredCaptures: " .. this.RequiredCaptures)
        LogDebug("TackleboxActive: " .. tostring(this.TackleboxActive))
        LogDebug("LuckyHat: " .. tostring(this.LuckyHat))
        LogDebug("OwnerLastKnownLevel: " .. this.OwnerLastKnownLevel)
        
        local myPlayer = AFUtils.GetMyPlayer()
        -- Make sure that my player is the owner
        if myPlayer and myPlayer:GetAddress() == this.CurrentOwner:GetAddress() then
            if this.ActiveRodTension > 0 then
                this:FishingSuccess()
            end
            this.TimeToStartMinigame = 10.0
        end
        LogDebug("------------------------------")
    end
end

local IsTickMinigameHooked = false
local function HookTickMinigame()
    if not IsTickMinigameHooked then
        RegisterHook("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:TickMinigame", TickMinigameHook)
        IsTickMinigameHooked = true
    end
end

-- For hot reload
if DebugMode then
    HookTickMinigame()
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context, NewPawn)
    LogDebug("[ClientRestart] called:")
    HookTickMinigame()
    LogDebug("------------------------------")
end)

LogInfo("Mod loaded successfully")
