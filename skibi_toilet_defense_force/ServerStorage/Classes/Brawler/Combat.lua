-- @ScriptType: LocalScript
local rp = game:GetService("ReplicatedStorage")
local Combat = rp:WaitForChild("Combat")

local UIS = game:GetService("UserInputService")
local botonMovil = game.ReplicatedStorage.Combate.TouchInputSC:Clone()
local debounce = false
local cds = {
	0,
	1
}

local sequence = ""
local curr = 0
local prev = 0

local function Golpear()
	if debounce == false then
		debounce = true
		curr = os.clock()

		local PT = curr - prev
		--PT determina el tiempo de combo. Si han pasado 2 segundos desde el ultimo golpe, resetea
		if PT < 2 then
			sequence = sequence.."L"
			if string.len(sequence) > 5 then
				sequence = "L"
			end
		else
			sequence = "L"
		end

		--envia la secuencia (el combo) al servidor para el procesamiento
		Combat:FireServer(sequence)				
	end
end

if UIS.TouchEnabled then
	botonMovil.Enabled = true
	botonMovil.Parent = script.Parent.Parent.PlayerGui
	botonMovil.ImageButton.Activated:Connect(function()
		if game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
			Golpear()
		end
	end)
end

--cada vez que se hace click (l.18) hace un ataque
UIS.InputBegan:Connect(function(input, IsTyping)
	if game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
		if not IsTyping then
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Golpear()
			end
		end
		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			if input.KeyCode == Enum.KeyCode.ButtonX then
				-- Button A pressed
				Golpear()
			end
		end
	end
end)

--se llama desde el servidor para terminar el tiempo de espera entre un golpe y otro
--si es un fin de combo, espera el tiempo del cd de combo (cds[2])
Combat.OnClientEvent:Connect(function(bool)
	prev = curr
	
	if bool then
		wait(cds[2])
		debounce = false
	else
		debounce = false
	end
end)
