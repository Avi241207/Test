-- @ScriptType: Script
local clave = game.Workspace.Primaries.Gameplay.Configuration.ClaveSaveData.Value
DataStore2 = require(game.ServerStorage.MainModule)
DataStore2.Combine(clave, "Niveles")
DataStore2.Combine(clave, "NivelElegido")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require teleport module
local TeleportModule = require(ReplicatedStorage.Teleport:WaitForChild("TeleportModule"))

-- Fire the module function on server event
local teleportEvent = ReplicatedStorage:WaitForChild("TeleportEvent")
teleportEvent.OnServerEvent:Connect(function(player, targetPlaceID, numespot, numeroNivel)
	--comprueba si el jugador tiene ese nivel disponible
	local lStore = DataStore2("Niveles", player)
	local nivebase = {}
	for i, v in pairs(game.ServerStorage.Levels:GetChildren()) do
		nivebase[tonumber(v.Name)] = 0
	end
	local nivelesUnlocked = lStore:GetTable(nivebase)
	if numeroNivel == 1 or nivelesUnlocked[numeroNivel-1] == 1 then
		--pone GUI
		game.ReplicatedStorage.Teleport.TeleportEvent:FireClient(player)
		-- Define teleport options
		local teleportOptions = Instance.new("TeleportOptions")
		local teleportData = {
			NumeroNivel = numeroNivel
		}
		teleportOptions.ShouldReserveServer = true
		teleportOptions:SetTeleportData(teleportData)
		-- junta a los jugadores 
		local tablapla = {}
		for i, v in pairs(game.Players:GetChildren()) do
			if v:GetAttribute("TeleportSpot"..numespot) == player:GetAttribute("TeleportSpot"..numespot) then
				table.insert(tablapla, v)
				if v ~= player then
					v:SetAttribute("TeleportSpot"..numespot, nil)
				end
				local nStore = DataStore2("NivelElegido", v)
				nStore:Set(numeroNivel)
			end
		end
		--targetPlaceID
		local teleportResult = TeleportModule.teleportWithRetry(13671233559, tablapla, teleportOptions)
	end
end)
 