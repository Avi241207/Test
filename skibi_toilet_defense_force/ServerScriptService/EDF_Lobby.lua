-- @ScriptType: ModuleScript
--Required components
local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")

--datastores
local clave = game.Workspace.Primaries.Gameplay.Configuration.ClaveSaveData.Value
DataStore2 = require(game.ServerStorage.MainModule)
DataStore2.Combine(clave, "ClaseElegida")
DataStore2.Combine(clave, "Niveles")
DataStore2.Combine(clave, "ClassesCajas")

local module = {}

function module.ColocaBillBoard(player)
	local tStore = DataStore2("ClaseElegida", player)
	local nStore = DataStore2("Niveles", player)
	local nivelesUnlocked = nStore:GetTable({})
	local cStore = DataStore2("ClassesCajas", player)

	local clasesbase = {}
	for i, v in pairs(game.ServerStorage.Classes:GetChildren()) do
		clasesbase[v.Name] = 0
	end
	local clases = cStore:GetTable(clasesbase)
	local char = player.Character
	local nivel = 0
	if clases[tStore:Get("Brawler")] then
		nivel = clases[tStore:Get("Brawler")]
	end
	
	--billboard
	if char.PrimaryPart:FindFirstChild("BillboardGuiLabel", true) then
		char.PrimaryPart:FindFirstChild("BillboardGuiLabel", true).TextLabel.Text = tStore:Get("Brawler") .. " Level " .. nivel .. ""
	else
		local bbg = game.ServerStorage.BillboardGuiLabel:Clone()
		bbg.Parent = char.PrimaryPart
		local nivel = 0
		if clases[tStore:Get("Brawler")] then
			nivel = clases[tStore:Get("Brawler")]
		end
		bbg.TextLabel.Text = tStore:Get("Brawler") .. " Level " .. nivel .. ""
	end
	
	--arma equipar
	if char:FindFirstChild("ArmaEquipada", true) then
		char:FindFirstChild("ArmaEquipada", true):Destroy()
	end
	if tStore:Get("Brawler") ~= "Bralwer" then
		local arma = game.ServerStorage.Classes:FindFirstChild(tStore:Get("Brawler")).Configuration.Equipment:FindFirstChildWhichIsA("Model", true):Clone()
		arma.Parent = char
		arma.Name = "ArmaEquipada"
		arma.PrimaryPart = arma.UpperTorso
		arma:SetPrimaryPartCFrame(char.UpperTorso.CFrame)
		local weld = Instance.new("WeldConstraint")
		weld.Parent = arma
		weld.Part0 = char.UpperTorso
		weld.Part1 = arma.PrimaryPart
	end
end

return module
