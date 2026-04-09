-- @ScriptType: LocalScript
game.ReplicatedStorage.TeleportEvent.OnClientEvent:Connect(function(valore)
	if valore == true then
		script.Parent.Enabled = true
	else
		script.Parent.Enabled = false
	end
end)
