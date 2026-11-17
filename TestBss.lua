--// Claim Hive - Fast Tween
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local Hives = Workspace:WaitForChild("Honeycombs")
local claimHive = ReplicatedStorage.Events.ClaimHive

local function FastTween(targetCFrame, speed)
    local distance = (HRP.Position - targetCFrame.Position).Magnitude
    local duration = math.max(distance / (speed or 200), 0.05) -- tốc độ cao, tối thiểu 0.05s
    
    local tween = TweenService:Create(HRP, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = targetCFrame
    })
    tween:Play()
    tween.Completed:Wait()
end

local function claimPlayerHive()
    for _, Hive in pairs(Hives:GetChildren()) do
        if Hive.Owner.Value == nil then
            print("Found Empty Hive")
            
            local targetPos = Hive.SpawnPos.Value + Vector3.new(0, 3, 0)
            FastTween(targetPos, 250) -- số càng lớn càng nhanh
            print("Tweened To Empty Hive")
            
            task.wait(0.2)
            claimHive:FireServer(Hive.HiveID.Value)
            print("Claimed Hive!")
            break
        end
    end
end

local function getPlayerHive()
    for _, Hive in pairs(Hives:GetChildren()) do
        if tostring(Hive.Owner.Value) == tostring(Player.Name) then
            print("Found Hive!")
            return Hive
        end
    end
    
    claimPlayerHive()
    task.wait(1.5)
    return getPlayerHive()
end

-- Chạy
local playerHive = getPlayerHive()
print("Done:", playerHive)
