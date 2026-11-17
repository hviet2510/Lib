local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local WalkAI = require(script.Parent.WalkAI)

local CollectToken = {}

local TokenFolders = {
    Workspace:FindFirstChild("Collectibles"),
    Workspace:FindFirstChild("Tokens"),
    Workspace:FindFirstChild("Debris"),
}

local CachedTokens = {}

local function UpdateTokenCache()
    table.clear(CachedTokens)
    for _, folder in pairs(TokenFolders) do
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    table.insert(CachedTokens, obj)
                end
            end
        end
    end
end

local function GetNearestToken()
    local nearest = nil
    local shortest = 60
    
    for _, token in pairs(CachedTokens) do
        if token and token.Parent then
            local pos = token:IsA("Model") and token:GetPivot().Position or token.Position
            local dist = (HRP.Position - pos).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = token
            end
        end
    end
    return nearest
end

function CollectToken.CollectNearest()
    local token = GetNearestToken()
    if not token then return false end
    
    local pos = token:IsA("Model") and token:GetPivot().Position or token.Position
    WalkAI.MoveTo(pos)
    return true
end

function CollectToken.Start()
    task.spawn(function()
        while true do
            UpdateTokenCache()
            task.wait(1.5)
        end
    end)
    
    task.spawn(function()
        while true do
            CollectToken.CollectNearest()
            task.wait(0.4)
        end
    end)
end

return CollectToken
