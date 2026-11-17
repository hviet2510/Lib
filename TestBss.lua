--// Claim Hive theo logic open source
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local Hives = Workspace:WaitForChild("Honeycombs")
local claimHive = ReplicatedStorage.Events.ClaimHive

local function claimPlayerHive()
    for _, Hive in pairs(Hives:GetChildren()) do
        if Hive.Owner.Value == nil then
            print("Found Empty Hive")
            
            -- Teleport đến SpawnPos (giống open source)
            HRP.CFrame = Hive.SpawnPos.Value + Vector3.new(0, 3, 0)
            print("Teleport To Empty Hive")
            task.wait(1)
            
            local args = {
                [1] = Hive.HiveID.Value
            }
            claimHive:FireServer(unpack(args))
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
    
    -- Nếu chưa có thì claim
    claimPlayerHive()
    task.wait(2)
    return getPlayerHive()
end

-- Chạy
local playerHive = getPlayerHive()
print("Player Hive:", playerHive)
