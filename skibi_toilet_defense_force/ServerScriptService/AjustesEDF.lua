-- @ScriptType: Script
local copiaClases = game.ServerStorage.Classes:Clone()
for i, v in pairs(copiaClases:GetDescendants()) do
	if v:IsA("Script") or v:IsA("LocalScript") then
		v:Destroy()
	end
end
copiaClases.Parent = game.ReplicatedStorage
