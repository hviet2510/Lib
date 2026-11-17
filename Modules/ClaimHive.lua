local Tween = require(script.Parent.Tween)

local ClaimHive = {}

function ClaimHive.Claim()
    local Hives = workspace.Honeycombs
    local ClaimEvent = game.ReplicatedStorage.Events.ClaimHive
    
    for _, hive in pairs(Hives:GetChildren()) do
        if hive:FindFirstChild("Owner") and hive.Owner.Value == nil then
            local pos = hive.SpawnPos.Value.Position + Vector3.new(0, 3, 0)
            Tween.Fast(pos)
            task.wait(0.1)
            ClaimEvent:FireServer(hive.HiveID.Value)
            print("Claimed hive!")
            return true
        end
    end
    return false
end

return ClaimHive
