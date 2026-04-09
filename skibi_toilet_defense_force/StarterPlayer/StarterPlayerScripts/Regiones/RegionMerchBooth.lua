-- @ScriptType: LocalScript
repeat
	wait()
until game:IsLoaded()	-- Espera hasta que se cargue el juego / Wait until game loads

-- Player
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
--if LP then print(LP.Name) end

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Tienda Muebles
local FurnitureGui = LP.PlayerGui:WaitForChild("TiendaMuebles")
local VentanaTienda = FurnitureGui:FindFirstChild("Tienda")

local ntween = 1.1
local taskManager = LP.PlayerGui:WaitForChild("TiendaMuebles"):WaitForChild("Tienda")		-- Boolean para asegurarnos de que existe el Gui de la Tienda de muebles

-- Iterate through all tagged parts
for _, region in ipairs(CollectionService:GetTagged("ShopRegion")) do
	region.Touched:Connect(function(otherPart)													-- Enter Region
		local character = LP.Character
		if character and character:FindFirstChild("HumanoidRootPart") == otherPart then
			-- Comprueba Región Concreta
			if region.Name == "AvatarReg" then
				
			elseif region.Name == "FurnitureReg" then
				-- Lanzar tienda sin el MerchBooth
				if FurnitureGui then FurnitureGui.Enabled = true end
				if taskManager and VentanaTienda then
					VentanaTienda:TweenPosition(UDim2.new(0.086,0,0.054,0), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, ntween, false)	-- Fallo en Web (vuelve a fallar)
				end
			end
		end
	end)

	region.TouchEnded:Connect(function(otherPart)												-- Exit Region
		local character = LP.Character
		if character and character:FindFirstChild("HumanoidRootPart") == otherPart then
			-- Comprueba Región Concreta
			if region.Name == "FurnitureReg" and taskManager then
				-- Cerrar tienda (no MerchBooth)
				VentanaTienda:TweenPosition(UDim2.new(1,0,0.054,0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, ntween/2, false)		-- Fallo en Web (vuelve a fallar)
				wait(ntween/2)
				FurnitureGui.Enabled = false
			end
		end
	end)
end