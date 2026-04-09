-- @ScriptType: LocalScript
local CollectionService = game:GetService("CollectionService")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local itemName = "Carrito"
local Got = false

TOUCHING = nil
-- Iterate through all tagged parts
for _, region in ipairs(CollectionService:GetTagged("Carrito")) do
	region.Touched:Connect(function(HumanoidRootPart)
		if Player:GetAttribute("Role") == "Parent" and Player.Backpack:FindFirstChild(itemName) and HumanoidRootPart.Parent == game.Players.LocalPlayer.Character and TOUCHING == nil then
			TOUCHING = HumanoidRootPart
			if Got == false then
				Humanoid:EquipTool(Player.Backpack:FindFirstChild(itemName))
				Got = true
			end
		end
	end)

	region.TouchEnded:Connect(function()
		for _, part in pairs(region:GetTouchingParts()) do
			if part == TOUCHING then return end
		end
		if Character:FindFirstChild(itemName) then
			Humanoid:UnequipTools()
			Got = false
			TOUCHING = nil
		end
	end)
end