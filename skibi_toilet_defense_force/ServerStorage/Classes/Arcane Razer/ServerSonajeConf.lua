-- @ScriptType: Script
local tiempo = script.TMagiaRecarga.Value

script.jugador.Value.AttributeChanged:Connect(function(attributeName)
	if attributeName == "Balas" then
		tiempo = script.TMagiaRecarga.Value
	end
end)

while wait(1) do
	tiempo = tiempo -1 
	if tiempo < 0 then
		if script.jugador.Value:GetAttribute("Balas") < script.jugador.Value:GetAttribute("MaxBalas") then
			script.jugador.Value:SetAttribute("Balas", script.jugador.Value:GetAttribute("Balas") + 1)
		end
		tiempo = script.TMagiaRecarga.Value
	end
end
