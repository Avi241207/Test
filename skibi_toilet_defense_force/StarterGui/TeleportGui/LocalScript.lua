-- @ScriptType: LocalScript
game.ReplicatedStorage.Teleport.ShowTeleportEvent.OnClientEvent:Connect(function(debe, levels)
	if debe == 1 then
		--habilita
		script.Parent.Enabled = true
	else
		script.Parent.Enabled = false
	end
end)

for i, v in pairs(game.Workspace.Teleports.puntos:GetChildren()) do
	game.Players.LocalPlayer:GetAttributeChangedSignal("TeleportSpot" .. v.Name):Connect(function(value)
		if game.Players.LocalPlayer:GetAttribute("TeleportSpot" .. v.Name) == nil then
			script.Parent.Enabled = false
			game.Workspace.Teleports.Configurar.PonerIconoCabeza:FireServer("NO")
		else
			local gente = game.Workspace.Teleports.Configurar.DimeGente:InvokeServer(v.Name)
			if #gente == 1 then
				script.Parent.Enabled = true
				game.Workspace.Teleports.Configurar.PonerIconoCabeza:FireServer("MASTER")
			else
				game.Workspace.Teleports.Configurar.PonerIconoCabeza:FireServer("SLAVE")
			end
		end
	end)
end


script.Parent.Changed:Connect(function(property)
	if property == "Enabled" and script.Parent.Enabled == true then
		--pone los niveles
		local niveles, nombresLevels = game.Workspace.Teleports.Configurar.DimeLevels:InvokeServer()
		for i, v in pairs(script.Parent.ScrollingFrame:GetChildren()) do
			if v:IsA("UIGridLayout") then
			else
				v:Destroy()
			end
		end
		--pone el primer nivel
		local pieza	= game.ReplicatedStorage.Teleport.Etiquetafase_b:Clone()
		pieza.Name = 1
		pieza.Text = "1 - Learn to fight"
		pieza.Parent = script.Parent.ScrollingFrame
		pieza.LayoutOrder = 1
		pieza.Activated:Connect(function()
			script.Parent.TextLabelLevel.Text = "1 - Learn to fight"
			script.Parent.fasesco.Value = 1
			script.Parent.TextButton.Visible = true
			game.Workspace.Teleports.Configurar.Ponefase:FireServer(1)
		end)
		--pone el resto de niveles
		for i, v in pairs(niveles) do
			if i~= 1 then
				if niveles[i-1] == 0 then
					local pieza	= game.ReplicatedStorage.Teleport.Etiquetafase:Clone()
					pieza.Name = i
					pieza.Text = i .. " - " .. nombresLevels[i]
					pieza.Parent = script.Parent.ScrollingFrame
					pieza.LayoutOrder = i
				else
					local pieza	= game.ReplicatedStorage.Teleport.Etiquetafase_b:Clone()
					pieza.Name = i
					pieza.Text = i .. " - " .. nombresLevels[i]
					pieza.Parent = script.Parent.ScrollingFrame
					pieza.LayoutOrder = i
					pieza.Activated:Connect(function()
						script.Parent.TextLabelLevel.Text = i .. " - " .. nombresLevels[i]
						script.Parent.fasesco.Value = i
						script.Parent.TextButton.Visible = true
						game.Workspace.Teleports.Configurar.Ponefase:FireServer(i)
					end)
				end
			end
		end
		script.Parent.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, script.Parent.ScrollingFrame.UIGridLayout.AbsoluteContentSize.Y + 50)
	elseif property == "Enabled" and script.Parent.Enabled == false then
		script.Parent.TextButton.Visible = false
	end
end)

