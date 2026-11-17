local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local HRP = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local Tween = {}

local Speeds = {
    [1] = 30, [2] = 45, [3] = 60, [4] = 75,
    [5] = 90, [6] = 100, [7] = 110, [8] = 120,
    [9] = 130, [10] = 140, [11] = 145, [12] = 150,
}

function Tween.To(position, level)
    level = math.clamp(level or 6, 1, 12)
    local speed = Speeds[level]
    local distance = (HRP.Position - position).Magnitude
    local duration = math.max(distance / speed, 0.05)
    
    local tween = TweenService:Create(HRP, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(position)
    })
    tween:Play()
    tween.Completed:Wait()
end

function Tween.Fast(position)
    Tween.To(position, 12)
end

function Tween.Slow(position)
    Tween.To(position, 4)
end

return Tween
