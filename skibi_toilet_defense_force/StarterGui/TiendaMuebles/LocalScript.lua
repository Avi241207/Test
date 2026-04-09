-- @ScriptType: LocalScript
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

--rellenar la lista

local abierto = false
local ping = true
local pong = true


--generar todos los botones de caja de clase
local botonesClase = {}

for i, v in pairs(game.ReplicatedStorage:WaitForChild("Classes"):GetChildren()) do
	local frame = game.ReplicatedStorage.FrameCajasVerdesClase:Clone()
	frame.LayoutOrder = i+3
	frame.Parent = script.Parent.Tienda.ScrollingFrame
	frame.ClaseTitulo.TLNombre.Text = v.Name
	--imagen de arma
	if v.Name ~= "Brawler" then
		local arma = v.Configuration.Equipment:FindFirstChildWhichIsA("Model", true):Clone()
		arma.Parent = frame.ClaseTitulo.ViewportFrame
		local cam = Instance.new("Camera")
		cam.Parent = frame.ClaseTitulo.ViewportFrame
		cam.CFrame = CFrame.new(arma.PrimaryPart.Position + Vector3.new(6,2,0), arma.PrimaryPart.Position) 
		frame.ClaseTitulo.ViewportFrame.CurrentCamera = cam
		table.insert(botonesClase, arma)
	end
	frame.UnaCaja.Activated:Connect(function()
		--print(v.Configuration.ID1Caja.Value)
		MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, v.Configuration.ID1Caja.Value)
	end)
	frame.CincoCajas.Activated:Connect(function()
		--print(v.Configuration.ID5Caja.Value)
		MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, v.Configuration.ID5Caja.Value)
	end)
end

--ajusta el tamaño del scroll
script.Parent.Tienda.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,script.Parent.Tienda.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 200) 

--actuacion de los botones de cajas rojas
for i, v in pairs(script.Parent.Tienda.ScrollingFrame.FrameCajasRojas:GetChildren()) do
	if v:IsA("TextButton") then
		v.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, v.IDDevProduct.Value)
		end)
	end
end

--girar miniaturas
while wait() do
	for i, v in pairs(botonesClase) do
		v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame * CFrame.Angles(0,0,0.05))
	end
end
