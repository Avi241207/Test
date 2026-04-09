-- @ScriptType: Script
local MarketplaceService = game:GetService("MarketplaceService")
--local SE = require(game.ServerScriptService.SaveExternalModule)

-- Llamada a ServerScriptServer.DataStore2
local ServerScriptService = game:GetService("ServerScriptService")
local clave = game.Workspace.Primaries.Gameplay.Configuration.ClaveSaveData.Value
DataStore2 = require(game.ServerStorage.MainModule)
DataStore2.Combine(clave, "ClaseElegida")
DataStore2.Combine(clave, "CajasShield")
DataStore2.Combine(clave, "ClassesCajas")

local EDF = require(game.ServerScriptService.EDF_Lobby)

local Cantidades = {}
--red crates
Cantidades[1558587603] = {"Shield", 5, 30}    -- 5 crates
Cantidades[1558587748] = {"Shield", 20, 100}   -- 20 crates
Cantidades[1558587822] = {"Shield", 50, 400}   -- 50 crates
Cantidades[1558587894] = {"Shield", 100 , 1000}  -- 100 crates
Cantidades[1558587949] = {"Shield", 500 ,2500}  -- 500 crates
Cantidades[1558588043] = {"Shield", 1000 ,8000}  -- 1000 crates
-- class crates
Cantidades[1558587597] = {"Arcane Razer", 1, 20} -- arcane razer 1
Cantidades[1558587598] = {"Arcane Razer", 5, 80} -- arcane razer 5

Cantidades[1558587600] = {"Assault", 1, 20} -- assault 1
Cantidades[1558587601] = {"Assault", 5, 80} -- assault 5

Cantidades[1558587602] = {"Brawler", 1, 20} -- brawler 1
Cantidades[1559487646] = {"Brawler", 5, 80} -- brawler 5

Cantidades[1559488115] = {"Cyber Assault", 1, 20} -- cyber assault 1
Cantidades[1559488116] = {"Cyber Assault", 5, 80} -- cyber assault 5

Cantidades[1559488846] = {"Fire Wizard", 1, 20} -- fire wizard 1
Cantidades[1559488845] = {"Fire Wizard", 5, 80} -- fire wizard 5

Cantidades[1559489205] = {"Gunner", 1, 20} -- gunner 1
Cantidades[1559489206] = {"Gunner", 5, 80} -- gunner 5

Cantidades[1559489749] = {"Lazer Gunner", 1, 20} -- lazer gunner 1
Cantidades[1559489748] = {"Lazer Gunner", 5, 80} -- lazer gunner 5

Cantidades[1559489750] = {"Swordman", 1, 20} -- swordman 1
Cantidades[1559489751] = {"Swordman", 5, 80} -- swordman 5
-- gamepasses

------------- GAMEPASS

local function gamepassPurchaseFinished(player, id, operation)
	-- Print all the details of the prompt, for example:
	-- PromptGamePassPurchaseFinished PlayerName 123456 false
	--print("PromptGamePassPurchaseFinished", ...)
	if operation == true then
		if game.ServerStorage.Gamepass:FindFirstChild(id) then
			fdf.PoneGPass(player, id)
			SE:GuardaDataEnCompra(player, id, Cantidades[id])
		end
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(gamepassPurchaseFinished)

------------- DEVPRODUCTS

MarketplaceService.PromptProductPurchaseFinished:Connect(function(player, id, operation)
	if operation == true then
		if Cantidades[id][1] == "Shield" then
			print("Comprar Caja Roja")
			local coinStore = DataStore2("CajasShield", game:GetService("Players"):GetPlayerByUserId(player))
			coinStore:Increment(Cantidades[id][2], 0)
		else
			print("Comprar Caja Verde")
			local cStore = DataStore2("ClassesCajas", game:GetService("Players"):GetPlayerByUserId(player))
			local clases = cStore:GetTable({})
			if clases[Cantidades[id][1]] then
				clases[Cantidades[id][1]] = clases[Cantidades[id][1]] + Cantidades[id][2]
			else
				clases[Cantidades[id][1]] = Cantidades[id][2]
			end
			cStore:Set(clases)
			EDF.ColocaBillBoard(game:GetService("Players"):GetPlayerByUserId(player))
		end
		
		--SE:GuardaDataEnCompra(game:GetService("Players"):GetPlayerByUserId(player), id, Cantidades[id])
	end
end)