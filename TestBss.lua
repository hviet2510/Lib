--// Claim Hive - Atlas Style Tween
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Hives = Workspace:WaitForChild("Honeycombs")
local claimHive = ReplicatedStorage.Events.ClaimHive

local function AtlasTween(targetPosition, speed)
    speed = speed or 220
    local startPos = HRP.Position
    local distance = (startPos - targetPosition).Magnitude
    local duration = math.clamp(distance / speed, 0.1, 2)
    
    -- Tạm tắt collision để đi xuyên vật (giống nhiều script Atlas-style)
    local oldCanCollide = {}
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            oldCanCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,   -- Atlas thường dùng Linear hoặc Quad cho farm
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(HRP, tweenInfo, {
        CFrame = CFrame.new(targetPosition)
    })
    
    tween:Play()
    tween.Completed:Wait()
    
    -- Khôi phục collision
    for part, value in pairs(oldCanCollide) do
        part.CanCollide = value
    end
end

local function claimPlayerHive()
    for _, Hive in pairs(Hives:GetChildren()) do
        if Hive:FindFirstChild("Owner") and Hive.Owner.Value == nil then
            print("[Atlas Claim] Tìm thấy hive trống")
            
            local target = Hive.SpawnPos.Value.Position + Vector3.new(0, 3, 0)
            AtlasTween(target, 180)
            
            task.wait(0.1)
            claimHive:FireServer(Hive.HiveID.Value)
            print("[Atlas Claim] Đã claim!")
            return true
        end
    end
    return false
end

-- Chạy
task.spawn(function()
    claimPlayerHive()
end)
