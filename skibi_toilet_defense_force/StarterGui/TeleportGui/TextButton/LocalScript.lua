-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local button = script.Parent
local targetPlaceID = 13671233559  -- Change this to your place ID

local teleportEvent = ReplicatedStorage:WaitForChild("TeleportEvent")

local function onButtonActivated()
	for i, v in pairs(game.Workspace.Teleports.puntos:GetChildren()) do
		if game.Players.LocalPlayer:GetAttribute("TeleportSpot" .. v.Name) ~= nil then
			script.Parent.Parent.Enabled = false
			teleportEvent:FireServer(targetPlaceID, v.Name, script.Parent.Parent.fasesco.Value)
		end
	end
end

button.Activated:Connect(onButtonActivated)
