-- @ScriptType: LocalScript
local LocalizationService = game:GetService("LocalizationService")
local player = game.Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
function getplatform()
	if (GuiService:IsTenFootInterface()) then
		return "Console"
	elseif (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
		--touchscreen computers now have touchenabled so make sure to check for lack of mouse too
		--also, not all phones/tablets have accelerometer and/or gyroscope
		local DeviceSize = workspace.CurrentCamera.ViewportSize; 
		if ( DeviceSize.Y > 600 ) then
			return "Mobile (tablet)"
		else
			return "Mobile (phone)"
		end
	else
		return "Desktop"
	end
end


local result, code = pcall(function()
	return LocalizationService:GetCountryRegionForPlayerAsync(player)
end)

print("************CONTROL DE TESTEO DE VARIABLES ")

if result and code == "ES" then
	print("Hello, friend from Spain!")
else
	print("GetCountryRegionForPlayerAsync failed: " .. code)
end
print(player.MembershipType)
print(getplatform())

print("************FIN CONTROL DE TESTEO DE VARIABLES ")

