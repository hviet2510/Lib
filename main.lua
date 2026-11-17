local ClaimHive = require(script.Parent.Modules.ClaimHive)
local CollectToken = require(script.Parent.Modules.CollectToken)

local Settings = {
    AutoClaimHive = true,
    AutoCollectToken = true,
}

if Settings.AutoClaimHive then
    ClaimHive.Claim()
end

if Settings.AutoCollectToken then
    CollectToken.Start()
end

print("Script loaded!")
