-- @ScriptType: LocalScript
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local c1 = script.Parent.ImageButton

RunService.Heartbeat:Connect(function(step)
	c1.Rotation = c1.Rotation + 1
end)

local girando = false

--evento para cambiar el nombre de la clase que se muestra bajo el boton
game.Workspace.Primaries.Clase.cambiaclas.OnClientEvent:Connect(function(clase)
	script.Parent.TextLabel.Text = clase
	for i, v in pairs(script.Parent.Frame.ScrollingFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v.BackgroundColor3 = Color3.new(0.933333, 0.964706, 1)
			if v.TLNombre.Text == clase then
				v.BackgroundColor3 = Color3.new(0.784314, 1, 0.760784)
			end 
		end
	end
end)

--equipar clase
script.Parent.Frame.FrameDesc.TextButton.Activated:Connect(function()
	if script.Parent.Frame.FrameDesc.Visible == true then
		game.Workspace.Primaries.Clase.cambiaclas:FireServer(script.Parent.Frame.FrameDesc.nome.Value)
	end
end)

local actuando = false

--abrir pantalla/popular lista de clases
script.Parent.ImageButton.Activated:Connect(function()
	if actuando == false then
		actuando = true
		girando = false
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 0
		script.Parent.FrameBG.Visible = true
		TS:Create(script.Parent.FrameBG, TweenInfo.new(2), {BackgroundTransparency = 0.1}):Play()
		script.Parent.Frame:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 2)
		local clases = game.Workspace.Primaries.Clase.dameclas:InvokeServer()
		--borra los cuadritos
		for i, v in pairs(script.Parent.Frame.ScrollingFrame:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		--pone los cuadritos
		for i, v in pairs(clases) do
			if v[1] > 0 then
				local cuadrito  = game.ReplicatedStorage.clasesUi.Fram:Clone()
				if v[6] == 1 then
					cuadrito.BackgroundColor3 = Color3.new(0.784314, 1, 0.760784)
				end
				cuadrito.Parent = script.Parent.Frame.ScrollingFrame
				cuadrito.TLNombre.Text = i
				cuadrito.TLLevel.Text = "Level " .. v[1]
				--pone la imagen del arma
				if i ~= "Brawler" then
					local arma = game:WaitForChild("ReplicatedStorage").Classes:FindFirstChild(i).Configuration.Equipment:Clone()
					arma.Parent = cuadrito.ViewportFrame
					local wPos = arma:FindFirstChild("Model", true).PrimaryPart
					local cama = Instance.new("Camera")
					cama.Parent = cuadrito.ViewportFrame
					cama.CFrame = CFrame.new(wPos.Position + Vector3.new(4,2,0), wPos.Position)
					cuadrito.ViewportFrame.CurrentCamera = cama
				end
				
				cuadrito.Activated:Connect(function()
					script.Parent.Frame.FrameDesc.TLTitulo.Text = i
					script.Parent.Frame.FrameDesc.TLNivel.Text = "Level " .. v[1]
					script.Parent.Frame.FrameDesc.TLWeapon.Text = v[4]
					script.Parent.Frame.FrameDesc.TLDesc.Text = v[5]
					script.Parent.Frame.FrameDesc.TLVida.Text = v[3]
					script.Parent.Frame.FrameDesc.TLDama.Text = v[2]
					script.Parent.Frame.FrameDesc.nome.Value = i
					script.Parent.Frame.FrameDesc.Visible = true
				end)
			end
		end	
		girando = true
		script.Parent.Frame.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,script.Parent.Frame.ScrollingFrame.UIGridLayout.AbsoluteContentSize.Y + 150) 

		actuando = false
	end
	
end)

--cerrar pantalla
script.Parent.Frame.TextButton.Activated:Connect(function()
	if actuando == false then
		actuando = true
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 20
		
		script.Parent.Frame:TweenPosition(UDim2.new(-2,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 2)
		TS:Create(script.Parent.FrameBG, TweenInfo.new(2), {BackgroundTransparency = 1}):Play()
		wait(2)
		for i, v in pairs(script.Parent.Frame.ScrollingFrame:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		script.Parent.FrameBG.Visible = false
		actuando = false
		girando = false
	end
end)

--mostrar el cursor si lleva brawler
game.ReplicatedStorage.AvisarClaseBrawler.OnClientEvent:Connect(function(nivelesUnlocked)
	print(nivelesUnlocked)
	if nivelesUnlocked[1] == 1 then
		script.Parent.ILFlecha:TweenPosition(UDim2.new(0.888, 0,0.103, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 2)
		wait(3)
		TS:Create(script.Parent.ILFlecha, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true), {Size = UDim2.new(0.1, 0,0.262, 0)}):Play()
		wait(2)
		TS:Create(script.Parent.ILFlecha, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true), {ImageTransparency = 1}):Play()
		wait(2)
		script.Parent.ILFlecha.Position = UDim2.new(-0.2, 0,0.157, 0)
		script.Parent.ILFlecha.ImageTransparency = 0
	end
	
	--mostrar flecha
	local flecha = game.ReplicatedStorage.Beam:Clone()
	flecha.Parent = game.Players.LocalPlayer.Character
	flecha.Attachment0 = game.Players.LocalPlayer.Character:FindFirstChild("BodyFrontAttachment", true)
	flecha.Attachment1 = game.Workspace.Primaries.Tutorial.Part.Attachment
	
	game.Workspace.Primaries.Tutorial.Part.Touched:Connect(function()
		if flecha then
			flecha:Destroy()
		end
	end)
end)

while wait() do
	if girando == true then
		for i, v in pairs(script.Parent.Frame.ScrollingFrame:GetChildren()) do
			if v:IsA("TextButton") then
				local mod = v.ViewportFrame:FindFirstChild("Model", true)
				if mod then
					v.ViewportFrame:FindFirstChild("Model", true):SetPrimaryPartCFrame(v.ViewportFrame:FindFirstChild("Model", true).PrimaryPart.CFrame * CFrame.Angles(0,0,0.1))
				end
			end
		end
	end
end