local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local WalkAI = {}

function WalkAI.MoveTo(position)
    Humanoid:MoveTo(position)
    Humanoid.MoveToFinished:Wait()
end

function WalkAI.PathTo(position)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })
    
    path:ComputeAsync(HRP.Position, position)
    
    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in pairs(path:GetWaypoints()) do
            Humanoid:MoveTo(waypoint.Position)
            Humanoid.MoveToFinished:Wait()
        end
    else
        Humanoid:MoveTo(position)
        Humanoid.MoveToFinished:Wait()
    end
end

return WalkAI
