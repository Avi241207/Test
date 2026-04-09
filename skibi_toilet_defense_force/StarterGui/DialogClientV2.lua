-- @ScriptType: LocalScript
local evento = game.ReplicatedStorage.VDialog.OpenDialog
local Players = game:GetService("Players")
local Posiciones = {}
Posiciones["Derecha"] = UDim2.new(0.58, 0,0, 0)
Posiciones["Centro"] = UDim2.new(0.305, 0,0, 0)
Posiciones["Izquierda"] = UDim2.new(0.025, 0,0, 0)

local function CreateDialog(personaje, configuracion)
	if script.Parent:FindFirstChild("Dialog") then return end
	--pone camara en tercera persona
	Players.LocalPlayer.CameraMinZoomDistance = 20
	Players.LocalPlayer.CameraMinZoomDistance = 0.5
	--
	local player = Players.LocalPlayer
	local config = configuracion
	--desactiva backpack si encarta
	if config.DisableBackpack.Value == true then
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end
	--crea screengui
	local gui = Instance.new("ScreenGui")
	gui.Name = "Dialog"
	gui.Parent = script.Parent
	gui.DisplayOrder = 99
	gui.IgnoreGuiInset = true
	--crea la pantalla de fondo
	local boton = Instance.new("TextButton")
	boton.Parent = gui
	boton.Size = UDim2.new(1,0,1,0)
	boton.BackgroundColor3 = Color3.new(135/255, 135/255, 135/255)
	boton.BackgroundTransparency = 0.5
	boton.Text = ""
	--crea un frame por cada linea de dialogo------
	----ordena de forma inversa las lineas
	local dialogo = config.Dialog:GetChildren()
	table.sort(dialogo, function(a, b)
		return a.Name > b.Name -- answers the question "should a come before b?"
	end)
	--crea el Viewport y lo anima
	local vpfP = Instance.new("ViewportFrame")
	vpfP.Parent = gui
	vpfP.Size = UDim2.new(0.4, 0,1, 0)
	vpfP.BackgroundTransparency = 1
	local npj = personaje:Clone()
	npj.Parent = vpfP
	npj:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0,0,0)))
	if npj:FindFirstChild("Animate") then
		npj:FindFirstChild("Animate"):Destroy()
	end

	if config.Interlocutor.Value == true then
		local cam = Instance.new("Camera")
		cam.Parent = vpfP
		cam.CFrame = CFrame.new(Vector3.new(-5,npj.PrimaryPart.Size.Y + npj.PrimaryPart.Position.Y,-1*config.DistanciaCamara.Value), npj.PrimaryPart.Position)
		vpfP.CurrentCamera = cam
		vpfP.Position = UDim2.new(1.4, 0,0, 0)
		vpfP:TweenPosition(
			Posiciones["Derecha"],           -- Final position the tween should reach
			Enum.EasingDirection.In, -- Direction of the easing
			Enum.EasingStyle.Linear,   -- Kind of easing to apply
			0.5,                       -- Duration of the tween in seconds
			false,                    -- Whether in-progress tweens are interrupted
			nil                -- Function to be callled when on completion/cancelation
		)
		--setea ViewPortFrame del jugador
		local vpfC = Instance.new("ViewportFrame")
		vpfC.Parent = gui
		vpfC.Size = UDim2.new(0.4, 0,1, 0)
		vpfC.Position = UDim2.new(-0.4, 0,0, 0)
		vpfC.BackgroundTransparency = 1
		game.Workspace:FindFirstChild(player.Name).Archivable = true
		local pj = game.Workspace:FindFirstChild(player.Name):Clone()
		pj.Parent = vpfC
		pj:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0,0,0)))
		if pj:FindFirstChild("Animate") then
			pj:FindFirstChild("Animate"):Destroy()
		end
		local cam = Instance.new("Camera")
		cam.Parent = vpfC
		cam.CFrame = CFrame.new(Vector3.new(5,pj.PrimaryPart.Size.Y + pj.PrimaryPart.Position.Y,-1*config.DistanciaCamara.Value), pj.PrimaryPart.Position)
		vpfC.CurrentCamera = cam
		vpfC:TweenPosition(
			Posiciones["Izquierda"],           -- Final position the tween should reach
			Enum.EasingDirection.In, -- Direction of the easing
			Enum.EasingStyle.Linear,   -- Kind of easing to apply
			0.5,                       -- Duration of the tween in seconds
			false,                    -- Whether in-progress tweens are interrupted
			nil                -- Function to be callled when on completion/cancelation
		)
	else
		local cam = Instance.new("Camera")
		cam.Parent = vpfP
		cam.CFrame = CFrame.new(Vector3.new(0,npj.PrimaryPart.Size.Y + npj.PrimaryPart.Position.Y,-1*config.DistanciaCamara.Value), npj.PrimaryPart.Position)
		vpfP.CurrentCamera = cam
		vpfP.Position = UDim2.new(1.4, 0,0, 0)
		vpfP:TweenPosition(
			Posiciones["Centro"],           -- Final position the tween should reach
			Enum.EasingDirection.In, -- Direction of the easing
			Enum.EasingStyle.Sine,   -- Kind of easing to apply
			0.5,                       -- Duration of the tween in seconds
			false,                    -- Whether in-progress tweens are interrupted
			nil                -- Function to be callled when on completion/cancelation
		)
	end
	----crea de la ultima a la primera linea los frames del dialogo
	local IndexAnterior = nil	--FIX
	for i, v in pairs(dialogo) do
		local frame
		if v:FindFirstChild("Seleccion") == nil then
			if config:FindFirstChild("Template") then
				frame = game.ReplicatedStorage.VDialog.DialogFrameTemplates:FindFirstChild(config:FindFirstChild("Template").Value):Clone()
			else
				frame = game.ReplicatedStorage.VDialog.DialogFrame:Clone()
			end
		else
			frame = game.ReplicatedStorage.VDialog.DialogFrameSelection:Clone()
		end
		frame.Parent = gui
		frame.ZIndex = 999 - v.Name
		frame.Nombre.ZIndex = 999 - v.Name + 1
		frame.Texto.ZIndex = 999 - v.Name + 1
		frame.FondoTexto.ZIndex = 999 - v.Name
		frame.FondoNombre.ZIndex = 999 - v.Name
		frame.Btn.ZIndex = 999 - v.Name + 1
		frame.Nombre.Text = personaje.Name
		if v:FindFirstChild("RichT") then
			if v:FindFirstChild("RichT").Value == true then
				frame.Texto.RichText = true
			end
		end
		frame.Texto.Text = v.Text.Value
		--if bool then frame.Texto.Size.X.Scale = 0.9 end
		if config:FindFirstChild("Fuente") then
			if config:FindFirstChild("Fuente").Value == "Bangers" then
				frame.Texto.Font = Enum.Font.Bangers
			elseif config:FindFirstChild("Fuente").Value == "Code" then
				frame.Texto.Font = Enum.Font.Code
			elseif config:FindFirstChild("Fuente").Value == "Jura" then
				frame.Texto.Font = Enum.Font.Jura
			elseif config:FindFirstChild("Fuente").Value == "Arial" then
				frame.Texto.Font = Enum.Font.Arial
			elseif config:FindFirstChild("Fuente").Value == "Kalam" then
				frame.Texto.Font = Enum.Font.Kalam
			elseif config:FindFirstChild("Fuente").Value == "Gotham" then
				frame.Texto.Font = Enum.Font.Gotham
			end
		end
		frame.Name = i
		local IAnt = Instance.new("ObjectValue")
		IAnt.Name = "ObjectValue"
		IAnt.Parent = frame
		IAnt.Value = IndexAnterior	--FIX
		IndexAnterior = frame		--FIX
		frame.Visible = false
		if v:FindFirstChild("Event") then
			frame.Evento.Value = v:FindFirstChild("Event").Value
		end
		--si hay eleccion, meterlas
		if v:FindFirstChild("Seleccion") then
			local dialogoBranch = v:FindFirstChild("Seleccion"):GetChildren()
			table.sort(dialogoBranch, function(a, b)
				return a.Name > b.Name -- answers the question "should a come before b?"
			end)
			for h, j in pairs(dialogoBranch) do
				local opcion = game.ReplicatedStorage.VDialog.FondoTexto:Clone()
				opcion.Parent = frame.FrameSelecciones
				opcion.Name = j.Name
				opcion.TextLabel.Text = j.Text.Value
				opcion.MouseButton1Click:Connect(function()
					local branch = frame.ObjectValue.Value
					local dialogoBranchOp = j:GetChildren()
					table.sort(dialogoBranchOp, function(a, b)
						return a.Name > b.Name -- answers the question "should a come before b?"
					end)
					for n,m in pairs(dialogoBranchOp) do
						if m:IsA("Folder") then
							local subframe = game.ReplicatedStorage.VDialog.DialogFrame:Clone()
							subframe.Parent = gui
							print(frame.ZIndex)
							print(m.Name )
							subframe.ZIndex = frame.ZIndex - m.Name 
							subframe.Nombre.ZIndex = frame.ZIndex - m.Name + 1 
							subframe.Texto.ZIndex = frame.ZIndex - m.Name + 1 
							subframe.FondoTexto.ZIndex = frame.ZIndex - m.Name 
							subframe.FondoNombre.ZIndex = frame.ZIndex - m.Name 
							subframe.Btn.ZIndex = frame.ZIndex - m.Name + 1 
							subframe.Nombre.Text = personaje.Name
							subframe.Texto.Text = m.Text.Value
							subframe.Name = i .. " - " .. n
							subframe.Visible = false
							local IAntB = Instance.new("ObjectValue")
							IAntB.Name = "ObjectValue"
							IAntB.Parent = subframe
							IAntB.Value = branch
							branch = subframe
							if m:FindFirstChild("Event") then
								subframe.Evento.Value = m:FindFirstChild("Event").Value
							end
							IAnt.Value = branch
							subframe.Btn.MouseButton1Click:connect(function()
								if subframe:FindFirstChild("Evento") then
									if subframe.Evento.Value ~= nil then
										-- Disparar Evento
										if subframe.Evento.Value:IsA("RemoteEvent") then
											subframe.Evento.Value:FireServer()
										elseif subframe.Evento.Value:IsA("BindableEvent") then
											subframe.Evento.Value:Fire()
										end
									end
								end
								subframe.Visible = false
								subframe.ObjectValue.Value.Visible = true
								subframe:Destroy()
							end)
						end
						IndexAnterior = branch	--FIX
					end
					if frame.ObjectValue.Value == nil then
						if config.DisableBackpack.Value == true then
							game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
						end
						if frame.Evento.Value ~= nil then
							-- Disparar Evento
							if frame.Evento.Value:IsA("RemoteEvent") then
								frame.Evento.Value:FireServer()
							elseif frame.Evento.Value:IsA("BindableEvent") then
								frame.Evento.Value:Fire()
							end
						end
						gui:Destroy()
					else
						frame.Visible = false
						frame.ObjectValue.Value.Visible = true
						if frame.ObjectValue.Value:FindFirstChild("FrameSelecciones") then
							frame.ObjectValue.Value:FindFirstChild("FrameSelecciones").Visible = true
						end
					end
					frame:Destroy()
				end)
			end
		end
		--meter lógica de pasar al siguiente diálogo solo si no hay eleccion
		if v:FindFirstChild("Seleccion") == nil then
			frame.Btn.MouseButton1Click:connect(function()
				if frame.ObjectValue.Value == nil then
					if config.DisableBackpack.Value == true then
						game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
					end
					if frame.Evento.Value ~= nil then
						-- Disparar Evento
						if frame.Evento.Value:IsA("RemoteEvent") then
							frame.Evento.Value:FireServer()
						elseif frame.Evento.Value:IsA("BindableEvent") then
							frame.Evento.Value:Fire()
						end
					end
					gui:Destroy()
				else
					frame.Visible = false
					frame.ObjectValue.Value.Visible = true
					if frame.ObjectValue.Value:FindFirstChild("FrameSelecciones") then
						frame.ObjectValue.Value:FindFirstChild("FrameSelecciones").Visible = true
					end
				end
				frame:Destroy()
			end)
		end
	end
	IndexAnterior.Visible = true	--FIX
end

evento.OnClientEvent:Connect(CreateDialog)