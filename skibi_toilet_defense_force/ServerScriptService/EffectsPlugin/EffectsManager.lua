-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local efectos = ReplicatedStorage:WaitForChild("Effects")
local TweenService = game:GetService("TweenService")


--Para usar este script hay que hacer un request : local EffectsManager =require(ReplicatedStorage:WaitForChild("EffectsManager"))
-- Con el request hecho, solo hace falta llamar a cada funcion para spawnear un efectito Ej: EffectsManager.GenerarEfectoHumo(modelo)
local EffectsManager = {}


--Función propia del modulo, se llama cada vez que se implementa un nuevo efecto para comprobar que no haya más efectos asociados al part
local function checkEfecto(modelo)
	local check
	for _,child in pairs(modelo:GetChildren()) do
		if(string.find(child.Name,"Efecto")) then
			check = true
		else
			check= false
		end

		if(check==true) then
			break
		end
	end
	return check
end

--Función propia del modulo, se llama cada vez que se quiere borrar un efecto concreto
local function LimpiarEfecto(modelo, nombre)
	local partePrincipal = modelo.PrimaryPart

	for _,child in pairs(partePrincipal:GetChildren()) do
		if(string.find(child.Name,nombre)) then
			child:Destroy()
		end
	end
end

--Función propia del modulo, se llama cada vez que se quiere borrar un efecto concreto en el workspace, pensado para efectos 3D
local function LimpiarEfecto3D(nombre)
	for _,child in pairs(workspace:GetChildren()) do
		if(string.find(child.Name,nombre)) then
			child:Destroy()
		end
	end
end

--Función propia del modulo, ejecuta un tween rotatorio sobre un part
function rotarEfecto(efecto,rotationSpeed,posicion,duracion)

	local parteRotante = efecto
	parteRotante.CFrame=CFrame.new(posicion)

	local tweenInfo
	if(duracion==nil)then
		tweenInfo = TweenInfo.new(rotationSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,10)
	else
		tweenInfo = TweenInfo.new(rotationSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,duracion)
	end
	local goal = {CFrame = parteRotante.CFrame*CFrame.Angles(0,math.rad(120),0)}
	local rotarParte = TweenService:Create(parteRotante,tweenInfo,goal)
	rotarParte:Play()

end


--Efecto de notas musicales hacia afuera
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part
function EffectsManager.GenerarEfectoNotasFuera(modelo,direccionEmision,borrado) 
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.Texture= "rbxassetid://3339206726"
			emisor.Size = NumberSequence.new(3)
			emisor.EmissionDirection=direccionEmision
			emisor.Rate=20
			emisor.Speed=NumberRange.new(5)
			emisor.Lifetime=NumberRange.new(0.5,0.9)
			emisor.Name="EfectoNotasFuera"
		end
	else
		LimpiarEfecto(modelo,"EfectoBrillo")
	end

end

--Efecto de notas musicales hacia adentro
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part
function EffectsManager.GenerarEfectoNotasDentro(modelo) 

	if(checkEfecto(modelo.PrimaryPart)==false)then

		local tempPart = Instance.new("Part")
		tempPart.Parent=modelo.PrimaryPart
		tempPart.CanCollide=false
		tempPart.CanTouch=false
		tempPart.CanQuery=false
		tempPart.Transparency=1
		tempPart.Position=modelo.PrimaryPart.Position
		tempPart.Size=Vector3.new(20,20,20)

		local tempWeld = Instance.new("WeldConstraint")
		tempWeld.Parent=tempPart
		tempWeld.Part1=tempPart
		tempWeld.Part0=modelo.PrimaryPart

		local emisor = Instance.new("ParticleEmitter")
		emisor.Texture= "rbxassetid://3339206726"
		emisor.Parent=tempPart
		emisor.Size = NumberSequence.new(3)
		emisor.Shape="Sphere"
		emisor.ShapeStyle="Volume"
		emisor.ShapeInOut="Inward"
		emisor.Lifetime=NumberRange.new(0.5,0.9)
		emisor.Rate=20
		emisor.Speed=NumberRange.new(5)
		emisor.Name="EfectoNotasDentro"

		spawn(function()
			wait(4)
			tempPart:Destroy()
		end)

	end
end

--Efecto de estrella 3D que asciende y rota
--@Params position = Vector3 = posición donde se genera la estrella, color = Color3 = color del que queremos que salga la estrella
function EffectsManager.GenerarEstrellaTween(position,color) 

	local estrella3D = efectos.estrella:Clone()
	estrella3D.Parent=workspace
	estrella3D.star.CanCollide=false
	estrella3D.star.CanTouch=false
	estrella3D.star.CanQuery=false

	estrella3D.PrimaryPart.CFrame=CFrame.new(Vector3.new(position.X,position.Y+3.5,position.Z))*CFrame.Angles(math.rad(-90),0,0)
	estrella3D.star.Size=Vector3.new(1.724, 0.39, 1.647)
	estrella3D.star.Color=color	
	
	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In,
		0,
		false,
		0
	)
	local tweenGoal = {
		Position=Vector3.new(position.X,position.Y+12,position.Z),
		Size= Vector3.new(0.8,0.39,0.8),
		CFrame = estrella3D.PrimaryPart.CFrame*CFrame.Angles(0,math.rad(120),0)
	}
	local tweenStar = TweenService:Create(estrella3D.PrimaryPart,tweenInfo,tweenGoal)
	spawn(function()
		tweenStar:Play()
		wait(1.5)
		estrella3D:Destroy()
	end)

end

--Efecto de estrellitas para indicar conseguir experiencia, coger una moneda, y cosas asi 
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part, color = Color3 del que queremos que salgan las particulas
function EffectsManager.GenerarEfectoEstrellas(position,color) 
			
	local tempPart = Instance.new("Part")
	tempPart.Parent=workspace
	tempPart.CanCollide=false
	tempPart.CanTouch=false
	tempPart.CanQuery=false
	tempPart.Transparency=1
	tempPart.Position=Vector3.new(position.X,position.Y+3.5,position.Z)
	tempPart.Size=Vector3.new(2,2,2)
	tempPart.Anchored=true

	local emisor = Instance.new("ParticleEmitter")
	emisor.Parent=tempPart
	emisor.Texture= "rbxassetid://12051552307"
	emisor.Size = NumberSequence.new(3,0.5)
	--emisor.Shape="Sphere"
	--emisor.ShapeStyle="Volume"
	--emisor.ShapeInOut="Inward"
	--emisor.Lifetime=NumberRange.new(0.5,0.9)
	emisor.Lifetime=NumberRange.new(1.5)
	--emisor.Transparency=NumberSequence.new(0.1,0.3)
	--emisor.EmissionDirection=direccionEmision
	emisor.Rate=7
	emisor.Speed=NumberRange.new(1.75)
	emisor.Color=ColorSequence.new(color)
	emisor.Name="EfectoEstrellas"

	spawn(function()
		wait(1.85)
		tempPart:Destroy()
	end)


end

--Efecto de estrellitas para indicar conseguir experiencia, coger una moneda, y cosas asi. 
--@Params modelo = modelo del jugador al cual se engancha el particle emitter a su upper torso, color = Color3 del que queremos que salgan las particulas
function EffectsManager.GenerarEfectoEstrellasPlayer(modeloJugador,color) 
		if(checkEfecto(modeloJugador.UpperTorso)==false)then
			local tempPart = Instance.new("Part")
			tempPart.Parent=modeloJugador.UpperTorso
			tempPart.CanCollide=false
			tempPart.CanTouch=false
			tempPart.CanQuery=false
			tempPart.Transparency=1
			tempPart.Position=modeloJugador.UpperTorso.Position
			tempPart.Size=Vector3.new(20,20,20)
			
			local tempWeld = Instance.new("WeldConstraint")
			tempWeld.Parent=tempPart
			tempWeld.Part1=tempPart
			tempWeld.Part0=modeloJugador.UpperTorso
			
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=tempPart
			emisor.Size = NumberSequence.new(3)
			emisor.Shape="Sphere"
			emisor.ShapeStyle="Volume"
			emisor.ShapeInOut="Inward"
			emisor.Lifetime=NumberRange.new(0.5,0.9)
			--emisor.Transparency=NumberSequence.new(0.1,0.3)
			--emisor.EmissionDirection=direccionEmision
			emisor.Rate=10
			emisor.Speed=NumberRange.new(5)
			emisor.Color=ColorSequence.new(color)
			emisor.Name="EfectoEstrellas"
			
			spawn(function()
				wait(5)
				tempPart:Destroy()
			end)
			
		end
end

--Tipico Efecto de brillito para indicar un drop de loot y su rareza, por ejemplo. 
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part, color = Color3 del que queremos que salgan las particulas
function EffectsManager.GenerarEfectoBrillo(modelo,color,borrado) 
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.Size = NumberSequence.new(0.3,0.5)
			emisor.Transparency=NumberSequence.new(0.1,0.3)
			--emisor.EmissionDirection=direccionEmision
			emisor.Rate=15
			emisor.Speed=NumberRange.new(2,5)
			emisor.Color=ColorSequence.new(color)
			emisor.Name="EfectoBrillo"
		end
	else
		LimpiarEfecto(modelo,"EfectoBrillo")
	end

end

--Emisor que simula una bengala como las que se usan en los conciertos de rock
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part
function EffectsManager.GenerarEfectoBengala(modelo,borrado) 
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.LightEmission=0
			emisor.LightInfluence=0.5
			emisor.Size = NumberSequence.new(2)
			emisor.Transparency=NumberSequence.new(0.5)
			emisor.Lifetime=NumberRange.new(5,10)
			emisor.Rate=30
			emisor.Speed=NumberRange.new(10)
			emisor.SpreadAngle=Vector2.new(10,10)
			emisor.Name="EfectoBrillo"
		end
	else
		LimpiarEfecto(modelo,"EfectoBrillo")
	end

end

--Tipico Efecto de humo, para fuegos, vapor, etc... 
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part
function EffectsManager.GenerarEfectoHumo(modelo,color,borrado)
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.Texture= "rbxassetid://122434485"
			emisor.Size = NumberSequence.new(0.5,0.7)
			emisor.Transparency=NumberSequence.new(0,0.1)
			emisor.Rate=12
			emisor.Speed=NumberRange.new(2,5)
			emisor.Color=ColorSequence.new(color)
			emisor.Name="EfectoHumo"
		end
	else
		LimpiarEfecto(modelo,"EfectoHumo")
	end
end

--Pequeño spray de partículas que simula dispersión de sangre, por un golpe, un disparo, o algo así
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part, dirección = dirección desde la cual van a salir las partículas, entre comillas y en inglés
function EffectsManager.GenerarEfectoSangre(modelo,direccion)
	if(checkEfecto(modelo.PrimaryPart)==false)then
		local emisor = Instance.new("ParticleEmitter")
		emisor.Name="EfectoSangre"
		emisor.Enabled=false
		emisor.Parent=modelo.PrimaryPart
		emisor.EmissionDirection=direccion
		emisor.Texture= "rbxassetid://300899516"
		emisor.Size = NumberSequence.new(0.2,0.4)
		emisor.Transparency=NumberSequence.new(0)
		emisor.Lifetime=NumberRange.new(0.5,1)
		emisor.Rate=50
		emisor.Speed=NumberRange.new(9,12)
		emisor.Color=ColorSequence.new(Color3.new(0.333333, 0, 0))
		spawn(function()
		emisor.Enabled=true
		wait(1)
		emisor.Enabled=false
			emisor:Destroy()
			end)
	end
end

--Efecto que intenta parecer chispas doradas para dar a entender por ejemplo el haber tocado una nota perfecta en un juego de ritmo
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part
function EffectsManager.GenerarEfectoNotaPerfecta(modelo)
	if(checkEfecto(modelo.PrimaryPart)==false)then
		local emisor = Instance.new("ParticleEmitter")
		emisor.Enabled=false
		emisor.Name="EfectoPerfect"
		emisor.Parent=modelo.PrimaryPart
		emisor.Size = NumberSequence.new(0.5,0.6)
		emisor.Transparency=NumberSequence.new(0)
		--emisor.EmissionDirection=direccionEmision
		emisor.Rate=200
		emisor.Speed=NumberRange.new(9,12)
		emisor.Color=ColorSequence.new(Color3.new(1, 0.717647, 0))
		emisor.Texture= "rbxassetid://528280825"
		spawn(function()
			emisor.Enabled=true
			wait(1)
			emisor.Enabled=false
			emisor:Destroy()
		end)
	end
end
--Efecto que intenta simular una llama con partículas
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part, direccion = direccion de la que sale el fuego
function EffectsManager.GenerarFuego(modelo, direccion,borrado)
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.Name="EfectoFuego"
			emisor.Texture= "rbxassetid://118641183"
			emisor.EmissionDirection=direccion
			emisor.Size = NumberSequence.new(0.4,0.6)
			emisor.Transparency=NumberSequence.new(0)
			emisor.Lifetime=NumberRange.new(0.2,0.5)
			emisor.Rate=5000
			emisor.Speed=NumberRange.new(3,5)
			emisor.Color=ColorSequence.new(Color3.new(1, 1, 0),Color3.new(1, 0.333333, 0),Color3.new(1, 0, 0))
		end
	else
		LimpiarEfecto(modelo,"EfectoFuego")
	end
end

--Efecto que intenta simular un chorro de agua vertical, para fuentes, aspersores, etc
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part
function EffectsManager.GenerarFuenteAgua(modelo,borrado)
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.Name="EfectoFuenteAgua"
			emisor.Texture= "rbxassetid://272050333"
			emisor.Color=ColorSequence.new(Color3.new(0.0666667, 0.921569, 1),Color3.new(0.0313725, 0.709804, 1),Color3.new(0, 0.384314, 1))
			emisor.LightEmission=0.9
			emisor.Size=NumberSequence.new(0.5)
			emisor.Acceleration=Vector3.new(0,-50,0)
			emisor.Lifetime=NumberRange.new(0,1.5)
			emisor.Rate=10000
			emisor.Speed=NumberRange.new(30)
			emisor.VelocitySpread=7
		end
	else
		LimpiarEfecto(modelo,"EfectoFuenteAgua")
	end
end
--Efecto que intenta simular el efecto de veneno de juegos como monster hunter, pokémon, etc
--@Params modelo = modelo al cual se engancha el particle emitter a su primary part, color = Color3 del color que queramos las burbujas, ej: morado o verde para veneno
function EffectsManager.GenerarBurbujas(modelo, color,borrado)
	if(borrado == nil or borrado==false)then
		if(checkEfecto(modelo.PrimaryPart)==false)then
			local emisor = Instance.new("ParticleEmitter")
			emisor.Parent=modelo.PrimaryPart
			emisor.Name="EfectoBurbujas"
			emisor.Texture= "rbxassetid://6603835352"
			emisor.Color=ColorSequence.new(color)
			emisor.LightEmission=0
			emisor.Size=NumberSequence.new(0.25)
			emisor.Lifetime=NumberRange.new(0,1.5)
			emisor.Rate=30
			emisor.Speed=NumberRange.new(0.25)
		end
	else
		LimpiarEfecto(modelo,"EfectoBurbujas")
	end
end

--Efecto que intenta simular el efecto de una explosión o una bola de fuego grande
--@Params posicion = posicion del efecto, color = Color3 del color que queramos laburbuja central, borrado = true/false para saber si queremos borrar un efecto de este tipo o no, player = player que activa el efecto
function EffectsManager.EfectoBolaGiratoria(posicion, color, borrado, player)
	if(borrado == nil or borrado==false)then
		local BolaGiratoria = efectos.BolaGiratoria:Clone()
		BolaGiratoria.PrimaryPart.CFrame=CFrame.new(posicion)
		BolaGiratoria.PrimaryPart.Color=color
		BolaGiratoria.Parent=workspace
		BolaGiratoria.Name="EfectoBolaGiratoria"..player.Name
		spawn(function()
			rotarEfecto(BolaGiratoria.ExplosionMedia,5,posicion)
			rotarEfecto(BolaGiratoria.ExplosionFuera,3,posicion)
			wait(30)
			LimpiarEfecto3D("EfectoBolaGiratoria"..player.Name)
		end)
	else if(borrado==true) then
			LimpiarEfecto3D("EfectoBolaGiratoria"..player.Name)
		end
	end

end

--Efecto que intenta simular el efecto de una explosión o una bola de fuego grande
--@Params player = jugador al que se le quiere asignar el efecto, level = integer = nivel que tendrá el efecto (0 o 1 de momento), borrado = boolean = true si se quiere borrar el efecto, false o nil si se quiere crear
function EffectsManager.EfectoBoost(player,level,borrado)
	if(borrado == nil or borrado==false)then

		local personaje = workspace:FindFirstChild(player.Name)
		if(checkEfecto(personaje)==false)then
			local BoostEffect = efectos.Boost:Clone()
			BoostEffect.Parent=personaje
			BoostEffect:SetPrimaryPartCFrame(CFrame.new(personaje.LowerTorso.Position))
			BoostEffect.Name="EfectoBoost"..player.Name
			if(level < 1) then
				BoostEffect.Lvl1LayerPart.BoostLvl1.Transparency=1
			else if (level ==1) then
					BoostEffect.Lvl1LayerPart.BoostLvl1.Transparency=0
				end
			end

			local weld = Instance.new("WeldConstraint")
			weld.Parent=personaje
			weld.Part0=personaje.LowerTorso
			weld.Part1=BoostEffect.BasePart
			spawn(function()
				wait(15)
				BoostEffect:Destroy()
			end)
		end

	else if(borrado==true) then
			local personaje = workspace:FindFirstChild(player.Name)
			for _,parte in pairs(personaje:GetChildren()) do
				if(parte.Name=="EfectoBoost"..player.Name) then
					parte:Destroy()
				end
			end
		end
	end

end

--Efecto que simula un checkpiont con efectos anime en una posición concreta
--@Params posición - Vector3 - posición donde se spawnea el efecto, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoCheckAnimePosicion(posicion, borrado)
	if(borrado == nil or borrado==false)then

		local CheckAnime = efectos.CheckAnime:Clone()
		CheckAnime:SetPrimaryPartCFrame(CFrame.new(posicion))
		CheckAnime.Parent=workspace
		CheckAnime.Name ="EfectoCheckAnime"
		local tweenInfo = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo2 = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo3 = TweenInfo.new(
			0.5, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo4 = TweenInfo.new(
			0.5, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo5 = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		spawn(function()
			local tween = TweenService:Create(CheckAnime.nubes, tweenInfo, {Size = Vector3.new(22, 4.14, 20)}):Play()
			local tween2 = TweenService:Create(CheckAnime.pinchos, tweenInfo2, {Size = Vector3.new(6.79, 8, 6.85), Position = CheckAnime.pinchos.Position + Vector3.new(0, 2, 0)}):Play()
			local tween3 = TweenService:Create(CheckAnime.rayos, tweenInfo3, {Orientation = CheckAnime.rayos.Orientation + Vector3.new(0, 360, 0)}):Play()
			local tween4 = TweenService:Create(CheckAnime.anillo, tweenInfo4, {Orientation = CheckAnime.anillo.Orientation + Vector3.new(0, -360, 0)}):Play()
			local tween5 = TweenService:Create(CheckAnime.anillo, tweenInfo5, {Size = Vector3.new(22, 0.396, 22)}):Play()
			wait(1.5)
			CheckAnime:Destroy()
		end)
	else if(borrado==true) then
			for _,model in pairs(workspace:GetChildren()) do
				if(model.Name == "EfectoCheckAnime") then
					model:Destroy()
				end
			end
		end
	end

end
--Efecto que simula un checkpiont con efectos anime en un modelo concreto
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoCheckAnimeModel(model, borrado)
	if(borrado == nil or borrado==false)then

		local CheckAnime = efectos.CheckAnime:Clone()
		CheckAnime:SetPrimaryPartCFrame(model.PrimaryPart.CFrame)
		CheckAnime.Parent=workspace
		CheckAnime.Name ="EfectoCheckAnime"
		local tweenInfo = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo2 = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo3 = TweenInfo.new(
			0.5, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo4 = TweenInfo.new(
			0.5, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		local tweenInfo5 = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Linear, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		spawn(function()
			local tween = TweenService:Create(CheckAnime.nubes, tweenInfo, {Size = Vector3.new(22, 4.14, 20)}):Play()
			local tween2 = TweenService:Create(CheckAnime.pinchos, tweenInfo2, {Size = Vector3.new(6.79, 8, 6.85), Position = CheckAnime.pinchos.Position + Vector3.new(0, 2, 0)}):Play()
			local tween3 = TweenService:Create(CheckAnime.rayos, tweenInfo3, {Orientation = CheckAnime.rayos.Orientation + Vector3.new(0, 360, 0)}):Play()
			local tween4 = TweenService:Create(CheckAnime.anillo, tweenInfo4, {Orientation = CheckAnime.anillo.Orientation + Vector3.new(0, -360, 0)}):Play()
			local tween5 = TweenService:Create(CheckAnime.anillo, tweenInfo5, {Size = Vector3.new(22, 0.396, 22)}):Play()
			wait(1.5)
			CheckAnime:Destroy()
		end)
	else if(borrado==true) then
			for _,model in pairs(workspace:GetChildren()) do
				if(model.Name == "EfectoCheckAnime") then
					model:Destroy()
				end
			end
		end
	end

end
--Efecto que coloca un trail tras el player, con unos colores pasados por un colorsequence
--@Params player - jugador - el jugador al que se le quiere poner un trail en el modelo, colorsequence - colorSequence - colorsequence con los colores para el trail, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoTrail(player, colorSequence, borrado)
	if (not borrado or borrado == nil) then	
		local attachmentTrailPlayer = Instance.new("Attachment")
		attachmentTrailPlayer.Parent=player.Character.Head		
		local attachmentTrailPlayer2 = Instance.new("Attachment")
		attachmentTrailPlayer2.Parent=player.Character.LowerTorso
		local trail = Instance.new("Trail")
		trail.Parent = game.Workspace
		trail.Attachment0=attachmentTrailPlayer
		trail.Attachment1=attachmentTrailPlayer2
		trail.Texture= "rbxassetid://7130511549"
		trail.Transparency=NumberSequence.new(0,0.5)
		trail.TextureMode="Static"
		trail.Lifetime=2
		trail.LightEmission=1
		trail.Color = colorSequence
		trail.Enabled=true

	else
		player.Character:FindFirstChild("Trail"):Destroy()
	end
end
--Efecto que intenta simular brillos verdosos de radiación en un modelo concreto
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoRadioactivo(model,borrado)
	if((borrado ~=(nil or false)) and checkEfecto(model)==false) then
		local emisorRayosCirculares= Instance.new("ParticleEmitter")
		emisorRayosCirculares.Parent=model.PrimaryPart
		emisorRayosCirculares.Name="EfectoRadioCirculo"
		emisorRayosCirculares.Color=ColorSequence.new(Color3.new(0, 1, 0),Color3.new(0, 0.666667, 0))
		emisorRayosCirculares.LightEmission=1
		emisorRayosCirculares.LightInfluence=1
		emisorRayosCirculares.Size=NumberSequence.new(1,2.67)
		emisorRayosCirculares.Squash=NumberSequence.new(0)
		emisorRayosCirculares.Texture="rbxassetid://12410504736"
		emisorRayosCirculares.Transparency=NumberSequence.new(0)
		emisorRayosCirculares.EmissionDirection="Top"
		emisorRayosCirculares.Lifetime=NumberRange.new(0,5)
		emisorRayosCirculares.Rate=20
		emisorRayosCirculares.Speed=NumberRange.new(7)
		emisorRayosCirculares.SpreadAngle=Vector2.new(50,0)
		emisorRayosCirculares.Shape="Sphere"
		emisorRayosCirculares.ShapeInOut="Outward"

		local emisorRayosRectos= Instance.new("ParticleEmitter")
		emisorRayosRectos.Parent=model.PrimaryPart
		emisorRayosRectos.Name="EfectoRadioRecto"
		emisorRayosRectos.Color=ColorSequence.new(Color3.new(0, 1, 0),Color3.new(0, 0.666667, 0))
		emisorRayosRectos.LightEmission=1
		emisorRayosRectos.LightInfluence=1
		emisorRayosRectos.Size=NumberSequence.new(1,2.67)
		emisorRayosRectos.Squash=NumberSequence.new(0,-0.5,0,-0.5,0,-0.5,0,-0.5,0)
		emisorRayosRectos.Texture="rbxassetid://12410500786"
		emisorRayosRectos.Transparency=NumberSequence.new(0)
		emisorRayosRectos.EmissionDirection="Top"
		emisorRayosRectos.Lifetime=NumberRange.new(0,5)
		emisorRayosRectos.Rate=20
		emisorRayosRectos.Speed=NumberRange.new(7)
		emisorRayosRectos.SpreadAngle=Vector2.new(50,50)
		emisorRayosRectos.Shape="Sphere"
		emisorRayosRectos.ShapeInOut="Outward"

		local emisorOndasRadio= Instance.new("ParticleEmitter")
		emisorOndasRadio.Parent=model.PrimaryPart
		emisorOndasRadio.Name="EfectoRadioOndas"
		emisorOndasRadio.Color=ColorSequence.new(Color3.new(0, 1, 0))
		emisorOndasRadio.LightEmission=1
		emisorOndasRadio.LightInfluence=0
		emisorOndasRadio.Size=NumberSequence.new(4)
		emisorOndasRadio.Squash=NumberSequence.new(0)
		emisorOndasRadio.Texture="rbxassetid://12410514263"
		emisorOndasRadio.Transparency=NumberSequence.new(0)
		emisorOndasRadio.EmissionDirection="Top"
		emisorOndasRadio.Lifetime=NumberRange.new(0,1)
		emisorOndasRadio.Rate=10
		emisorOndasRadio.Speed=NumberRange.new(80)
		emisorOndasRadio.Shape="Sphere"
		emisorOndasRadio.ShapeInOut="Outward"
		emisorOndasRadio.Drag=500
	else
		if(checkEfecto(model)==true) then
			LimpiarEfecto(model,"Efecto")
		end
	end
end
--Efecto que simula el aura de un personaje de db
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, colorsequence - colorSequence - colorsequence con los colores para el aura, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoSuper(model, colorSequence, borrado)
	
	if((borrado ~=(nil or false)) and checkEfecto(model)==false) then
		local emisorAura = Instance.new("ParticleEmitter")
		emisorAura.Parent=model.PrimaryPart
		emisorAura.Name="EfectoAura"
		emisorAura.Color=colorSequence
		emisorAura.Brightness=1.7
		emisorAura.LightEmission=1
		emisorAura.LightInfluence=0
		emisorAura.Orientation="VelocityParallel"
		emisorAura.Size=NumberSequence.new(10)
		emisorAura.Squash=NumberSequence.new(0)
		emisorAura.Texture="rbxassetid://12410509491"
		emisorAura.Transparency=NumberSequence.new(0.8)
		emisorAura.ZOffset=2.5
		emisorAura.EmissionDirection="Top"
		emisorAura.Lifetime=NumberRange.new(0.2,0.8)
		emisorAura.Rate=100
		emisorAura.Rotation=NumberRange.new(-90)
		emisorAura.RotSpeed=NumberRange.new(-5,5)
		emisorAura.Speed=NumberRange.new(14,30)
		emisorAura.SpreadAngle=Vector2.new(360,360)
		emisorAura.Shape="Box"
		emisorAura.ShapeInOut="Outward"
		emisorAura.ShapeStyle="Volume"
		emisorAura.Acceleration=Vector3.new(0,80,0)
		emisorAura.Drag=5
		emisorAura.TimeScale=1		
		
		local emisorChispas = Instance.new("ParticleEmitter")
		emisorChispas.Parent=model.PrimaryPart
		emisorChispas.Name="EfectoChispas"
		emisorChispas.Brightness=3
		emisorChispas.Color=ColorSequence.new(Color3.new(1, 1, 1),Color3.new(0, 0.87451, 1),Color3.new(0, 0.666667, 1))
		emisorChispas.LightEmission=1
		emisorChispas.LightInfluence=0
		emisorChispas.Orientation="FacingCamera"
		emisorChispas.Size=NumberSequence.new(3)
		emisorChispas.Squash=NumberSequence.new(0)
		emisorChispas.Texture="rbxassetid://12410501419"
		emisorChispas.Transparency=NumberSequence.new(0)
		emisorChispas.ZOffset=2.5
		emisorChispas.EmissionDirection="Top"
		emisorChispas.Lifetime=NumberRange.new(3,5)
		emisorChispas.Rate=1
		emisorChispas.Rotation=NumberRange.new(0)
		emisorChispas.RotSpeed=NumberRange.new(0)
		emisorChispas.Speed=NumberRange.new(5)
		emisorChispas.SpreadAngle=Vector2.new(90,90)
		emisorChispas.Shape="Disc"
		emisorChispas.ShapeInOut="Outward"
		emisorChispas.ShapePartial=1
		emisorChispas.ShapeStyle="Volume"
		emisorChispas.Drag=0.2
		emisorChispas.TimeScale=1
		
		local emisorPolvo = Instance.new("ParticleEmitter")
		emisorPolvo.Parent=model.PrimaryPart
		emisorPolvo.Name="EfectoPolvo"
		emisorPolvo.Brightness=1
		emisorPolvo.Color=ColorSequence.new(Color3.new(0.666667, 0.666667, 0.498039))
		emisorPolvo.LightEmission=0
		emisorPolvo.LightInfluence=0
		emisorPolvo.Orientation="FacingCamera"
		emisorPolvo.Size=NumberSequence.new(2)
		emisorPolvo.Squash=NumberSequence.new(0)
		emisorPolvo.Texture="rbxassetid://12410506450"
		emisorPolvo.Transparency=NumberSequence.new(0.75)
		emisorPolvo.ZOffset=2.5
		emisorPolvo.EmissionDirection="Bottom"
		emisorPolvo.Lifetime=NumberRange.new(0.2,1)
		emisorPolvo.Rate=400
		emisorPolvo.Speed=NumberRange.new(20)
		emisorPolvo.SpreadAngle=Vector2.new(90,90)
		emisorPolvo.Shape="Disc"
		emisorPolvo.ShapeInOut="Outward"
		emisorPolvo.ShapePartial=1
		emisorPolvo.ShapeStyle="Volume"
		emisorPolvo.Acceleration=Vector3.new(0,10,0)
		
	else
		if(checkEfecto(model)==true) then
			LimpiarEfecto(model,"Efecto")
		end
	end
	
end
--Efecto intenta simular el Chaos Blast de cierto erizo
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part,colorsequence - colorSequence - colorsequence con los colores para los brillos de la carga, colorExplosionPrincipio - color3 - color que queremos para el inicio dela explosión, colorExplosionFin - color3 - color que queremos para el final de la explosión, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoBlast(model,colorSequenceCarga,colorExplosionPrincipio,colorExplosionFin)
	
	local emisorCarga = Instance.new("ParticleEmitter")
	emisorCarga.Parent=model.PrimaryPart
	emisorCarga.Name="EfectoCarga"
	emisorCarga.Brightness=5
	emisorCarga.Color=colorSequenceCarga
	emisorCarga.LightEmission=1
	emisorCarga.LightInfluence=0
	emisorCarga.Orientation="VelocityParallel"
	emisorCarga.Size=NumberSequence.new(5)
	emisorCarga.Squash=NumberSequence.new(3)
	emisorCarga.Texture="rbxassetid://12410500585"
	emisorCarga.Transparency=NumberSequence.new(0)
	emisorCarga.ZOffset=0
	emisorCarga.Lifetime=NumberRange.new(2,3)
	emisorCarga.Rate=20
	emisorCarga.Rotation=NumberRange.new(90)
	emisorCarga.Speed=NumberRange.new(5)
	emisorCarga.Shape="Sphere"
	emisorCarga.ShapeInOut="Inward"
	emisorCarga.ShapePartial=1
	emisorCarga.ShapeStyle="Volume"
	
	wait(5)
	
	emisorCarga:Destroy()
	local explosionEffect = script.Parent.Effects["Meshes/Tutorial VFX_Sphere"]:Clone()
	explosionEffect.Parent=model.PrimaryPart
	explosionEffect.Name="EfectoExplosion"
	explosionEffect.Color=colorExplosionPrincipio
	explosionEffect.Material="Neon"
	explosionEffect.Reflectance=0
	explosionEffect.Transparency=0.4
	explosionEffect.Size=Vector3.new(0,0,0)
	explosionEffect.CFrame=model.PrimaryPart.CFrame
	explosionEffect.CanCollide=false
	explosionEffect.CanTouch=false
	explosionEffect.CanQuery=false
	explosionEffect.Anchored=true
	--explosionEffect.Shape="Ball"
	
	local  vortex = Instance.new("Part")
	vortex.Parent=explosionEffect
	vortex.Name="EfectoVortex"
	vortex.Shape="Block"
	vortex.CFrame=explosionEffect.CFrame
	vortex.CanCollide=false
	vortex.CanTouch=false
	vortex.CanQuery=false
	vortex.Anchored=true
	vortex.Transparency=1
	vortex.Size=Vector3.new(0,0,0)
	
	local vortexDecal = Instance.new("Decal")
	vortexDecal.Parent=vortex
	vortexDecal.Face="Top"
	vortexDecal.Texture="rbxassetid://6700005265"
	vortexDecal.Color3=Color3.new(0.666667, 0.666667, 0.498039)
	
	
	local emisorPolvo = Instance.new("ParticleEmitter")
	emisorPolvo.Parent= explosionEffect
	emisorPolvo.Name="EfectoPolvo"
	emisorPolvo.Brightness=1
	emisorPolvo.Color=ColorSequence.new(Color3.new(0.666667, 0.666667, 0.498039))
	emisorPolvo.LightEmission=0
	emisorPolvo.LightInfluence=0
	emisorPolvo.Orientation="FacingCamera"
	emisorPolvo.Size=NumberSequence.new(10)
	emisorPolvo.Squash=NumberSequence.new(0)
	emisorPolvo.Texture="rbxassetid://12410506450"
	emisorPolvo.Transparency=NumberSequence.new(0.5)
	emisorPolvo.ZOffset=2.5
	emisorPolvo.EmissionDirection="Bottom"
	emisorPolvo.Lifetime=NumberRange.new(0.2,1)
	emisorPolvo.Rate=1000
	emisorPolvo.Speed=NumberRange.new(50)
	emisorPolvo.SpreadAngle=Vector2.new(90,90)
	emisorPolvo.Shape="Disc"
	emisorPolvo.ShapeInOut="Outward"
	emisorPolvo.ShapePartial=1
	emisorPolvo.ShapeStyle="Volume"
	emisorPolvo.Acceleration=Vector3.new(0,10,0)
	
	local tweenInfo = TweenInfo.new(
		5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)
	
	local tweenGoal = {
		
		Size = Vector3.new(55,55,55);
		CFrame = explosionEffect.CFrame*CFrame.Angles(0,math.rad(120),0);
		Color=colorExplosionFin
		
	}
	local tweenGoalVortex = {

		Size = Vector3.new(180,0,180);
		CFrame = explosionEffect.CFrame*CFrame.Angles(0,math.rad(120),0)

	}
	local tweenExplosion = TweenService:Create(explosionEffect,tweenInfo,tweenGoal)
	local tweenVortex = TweenService:Create(vortex,tweenInfo,tweenGoalVortex)
	tweenExplosion:Play()
	tweenVortex:Play()
	tweenExplosion.Completed:Connect(function()
		explosionEffect:Destroy()
	end)
	
	
end
--Efecto que intenta simular el coger un bloque de MK. se spawnea y se destruye solo a los pocos segundos
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.EfectoBloque(model)
		local keypoints = {ColorSequenceKeypoint.new(0,Color3.new(0.666667, 0, 1)),ColorSequenceKeypoint.new(0.1,Color3.new(0, 0, 1)),ColorSequenceKeypoint.new(0.2,Color3.new(0, 0.666667, 1)),ColorSequenceKeypoint.new(0.3,Color3.new(0, 0.666667, 0)),ColorSequenceKeypoint.new(0.4,Color3.new(1, 0.333333, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 1, 0))}
		local emisorBloque = Instance.new("ParticleEmitter")
		emisorBloque.Parent=model.PrimaryPart
		emisorBloque.Color=ColorSequence.new(keypoints)
		emisorBloque.Name="EfectoBloque"
		emisorBloque.LightEmission=0
		emisorBloque.LightInfluence=1
		emisorBloque.Size=NumberSequence.new(1)
		emisorBloque.Texture= "rbxassetid://12410498767"
		emisorBloque.Lifetime=NumberRange.new(1)
		emisorBloque.Rate=500
		emisorBloque.Speed=NumberRange.new(20)
		emisorBloque.Shape="Sphere"
		emisorBloque.ShapeInOut="Outward"	
		
		local emisorTrozos = Instance.new("ParticleEmitter")
		emisorTrozos.Parent=model.PrimaryPart
		emisorTrozos.Color=ColorSequence.new(Color3.new(0, 0.666667, 1),Color3.new(0, 1, 0.8))
		emisorTrozos.Name="EfectoTrozos"
		emisorTrozos.LightEmission=0
		emisorTrozos.LightInfluence=1
		emisorTrozos.Orientation="VelocityPerpendicular"
		emisorTrozos.Size=NumberSequence.new(1)
		emisorTrozos.Texture= "rbxassetid://252644715"
		emisorTrozos.Lifetime=NumberRange.new(2,3)
		emisorTrozos.Rate=150
		emisorTrozos.Speed=NumberRange.new(20)
		emisorTrozos.Shape="Sphere"
		emisorTrozos.ShapeInOut="Outward"
		emisorTrozos.Rotation=NumberRange.new(90)
		
		
		wait(0.5)
		
		emisorBloque.Enabled=false
		emisorTrozos.Enabled=false
		wait(0.5)
		emisorBloque:Destroy()
		emisorTrozos:Destroy()
	
end
--Efecto que coloca varios trails tras el player, junto con un emisor de partículas, para simular efecto de supervelocidad
--@Params player - jugador - el jugador al que se le quiere poner el efecto en el modelo, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.Speed(player, borrado)
if((borrado ~=(nil or false)) and checkEfecto(player.Character)==false) then
	local emisorChispas = Instance.new("ParticleEmitter")
	emisorChispas.Parent=player.Character.PrimaryPart
	emisorChispas.Name="EfectoChispas"
	emisorChispas.Brightness=5
	emisorChispas.Color=ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.666667, 1),Color3.new(0, 1, 0.8))
	emisorChispas.LightEmission=1
	emisorChispas.LightInfluence=0
	emisorChispas.Orientation="VelocityParallel"
	emisorChispas.Size=NumberSequence.new(1.8)
	emisorChispas.Squash=NumberSequence.new(1.24,0)
	emisorChispas.Texture="rbxassetid://12410497335"
	emisorChispas.Transparency=NumberSequence.new(0)
	emisorChispas.EmissionDirection="Back"
	emisorChispas.Enabled=true
	emisorChispas.Lifetime=NumberRange.new(2,3)
	emisorChispas.Rate=80
	emisorChispas.Rotation=NumberRange.new(90)
	emisorChispas.Speed=NumberRange.new(50)
	emisorChispas.Shape="Box"
	emisorChispas.ShapeInOut="Outward"
	emisorChispas.ShapeStyle="Volume"
	
	local attachmentTrailPlayer = Instance.new("Attachment")
	attachmentTrailPlayer.Parent=player.Character.Head		
	local attachmentTrailPlayer2 = Instance.new("Attachment")
	attachmentTrailPlayer2.Parent=player.Character.LowerTorso

	local trail = Instance.new("Trail")
	trail.Name="EfectoTrailTorso"
	trail.Parent = player.Character
	trail.Brightness=50
	trail.Color = ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.333333, 1),Color3.new(0, 0.666667, 1))
	trail.LightEmission=1
	trail.Texture= "rbxassetid://12410500786"
	trail.TextureLength=3.5
	trail.TextureMode="Static"
	trail.Transparency=NumberSequence.new(0,0.5)
	trail.Attachment0=attachmentTrailPlayer
	trail.Attachment1=attachmentTrailPlayer2
	trail.Lifetime=2
	trail.Enabled=true
	
	local attachmentTrailPlayerPIzquierdo = Instance.new("Attachment")
	attachmentTrailPlayerPIzquierdo.Parent=player.Character.LeftUpperLeg		
	local attachmentTrailPlayerPIzquierdo2 = Instance.new("Attachment")
	attachmentTrailPlayerPIzquierdo2.Parent=player.Character.LeftFoot
	
	local trail1 = Instance.new("Trail")
	trail1.Name="EfectoTrailPIzquierdo"
	trail1.Parent = player.Character
	trail1.Brightness=50
	trail1.Color = ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.333333, 1),Color3.new(0, 0.666667, 1))
	trail1.LightEmission=1
	trail1.Texture= "rbxassetid://12410500786"
	trail1.TextureLength=3.5
	trail1.TextureMode="Static"
	trail1.Transparency=NumberSequence.new(0,0.5)
	trail1.Attachment0=attachmentTrailPlayerPIzquierdo
	trail1.Attachment1=attachmentTrailPlayerPIzquierdo2
	trail1.Lifetime=2
	trail1.Enabled=true
	
	local attachmentTrailPlayerPDer = Instance.new("Attachment")
	attachmentTrailPlayerPDer.Parent=player.Character.RightUpperLeg		
	local attachmentTrailPlayerPDer2 = Instance.new("Attachment")
	attachmentTrailPlayerPDer2.Parent=player.Character.RightFoot

	local trail2 = Instance.new("Trail")
	trail2.Name="EfectoTrailPDer"
	trail2.Parent = player.Character
	trail2.Brightness=50
	trail2.Color = ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.333333, 1),Color3.new(0, 0.666667, 1))
	trail2.LightEmission=1
	trail2.Texture= "rbxassetid://12410500786"
	trail2.TextureLength=3.5
	trail2.TextureMode="Static"
	trail2.Transparency=NumberSequence.new(0,0.5)
	trail2.Attachment0=attachmentTrailPlayerPDer
	trail2.Attachment1=attachmentTrailPlayerPDer2
	trail2.Lifetime=2
	trail2.Enabled=true
	
	local attachmentTrailPlayerBIzquierdo = Instance.new("Attachment")
	attachmentTrailPlayerBIzquierdo.Parent=player.Character.LeftUpperArm		
	local attachmentTrailPlayerBIzquierdo2 = Instance.new("Attachment")
	attachmentTrailPlayerBIzquierdo2.Parent=player.Character.LeftHand

	local trail3 = Instance.new("Trail")
	trail3.Name="EfectoTrailPIzquierdo"
	trail3.Parent = player.Character
	trail3.Brightness=50
	trail3.Color = ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.333333, 1),Color3.new(0, 0.666667, 1))
	trail3.LightEmission=1
	trail3.Texture= "rbxassetid://12410500786"
	trail3.TextureLength=3.5
	trail3.TextureMode="Static"
	trail3.Transparency=NumberSequence.new(0,0.5)
	trail3.Attachment0=attachmentTrailPlayerBIzquierdo
	trail3.Attachment1=attachmentTrailPlayerBIzquierdo2
	trail3.Lifetime=2
	trail3.Enabled=true
	
	local attachmentTrailPlayerBDer = Instance.new("Attachment")
	attachmentTrailPlayerBDer.Parent=player.Character.RightUpperArm	
	local attachmentTrailPlayerBDer2 = Instance.new("Attachment")
	attachmentTrailPlayerBDer2.Parent=player.Character.RightHand

	local trail4 = Instance.new("Trail")
	trail4.Name="EfectoTrailPDer"
	trail4.Parent = player.Character
	trail4.Brightness=50
	trail4.Color = ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.333333, 1),Color3.new(0, 0.666667, 1))
	trail4.LightEmission=1
	trail4.Texture= "rbxassetid://12410500786"
	trail4.TextureLength=3.5
	trail4.TextureMode="Static"
	trail4.Transparency=NumberSequence.new(0,0.5)
	trail4.Attachment0=attachmentTrailPlayerBDer
	trail4.Attachment1=attachmentTrailPlayerBDer2
	trail4.Lifetime=2
	trail4.Enabled=true
	
	else
		if(checkEfecto(player.Character)==true) then
			LimpiarEfecto(player.Character,"Efecto")
			for _,efecto in player.Character:GetChildren() do
				if(efecto:IsA("Trail")) then
					efecto:Destroy()
				end
			end
			
		end
	end
	
	
end
--Efecto que simula una bala simple brillante que va de A a B, se destruye al llegar al objetivo
--@Params model - Modelo - modelo donde se spawnea la bala que debe tener un primary part, modeloTarget - model- modelo hacia donde se apunta la bala, debe tener un primary part, retardo - numero- tiempo que tarda la bala en ir del punto A al B
function EffectsManager.BasicBullet(modelo,modeloTarget,retardo)
	
		local balaEffect = script.Parent.Effects.Boll:Clone()
		balaEffect.Parent=modelo.PrimaryPart
		balaEffect.CFrame=modelo.PrimaryPart.CFrame
		balaEffect.Name="EfectoBala"
		
		local tweenInfo = TweenInfo.new(
			retardo,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false
		)
		
		local tweenGoal = {
			CFrame = CFrame.new(modeloTarget.PrimaryPart.Position);
		}
		
		local tweenBala = TweenService:Create(balaEffect,tweenInfo,tweenGoal)
		tweenBala:Play()
		tweenBala.Completed:Connect(function()
			balaEffect:Destroy()
		end)
end
--Efecto que simula una bala de fuego que va de A a B, se destruye al llegar al objetivo
--@Params model - Modelo - modelo donde se spawnea la bala que debe tener un primary part, modeloTarget - model- modelo hacia donde se apunta la bala, debe tener un primary part, retardo - numero- tiempo que tarda la bala en ir del punto A al B
function EffectsManager.FireBullet(modelo,modeloTarget,retardo)
		local balaEffect = script.Parent.Effects.FireBoll:Clone()
		balaEffect.Parent=modelo.PrimaryPart
		balaEffect.CFrame=CFrame.lookAt(modelo.PrimaryPart.Position,modeloTarget.PrimaryPart.Position)
		balaEffect.Name="EfectoBalaFuego"
		--balaEffect.ParticleAttachment.CFrame=balaEffect.ParticleAttachment.CFrame*CFrame.Angles(0,math.rad(90),0);
		balaEffect.Attachment.Aura.Rate = 500
		local tweenInfo = TweenInfo.new(
			retardo,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false
		)

		local tweenGoal = {
			CFrame = CFrame.new(modeloTarget.PrimaryPart.Position);
		}

		local tweenBala = TweenService:Create(balaEffect,tweenInfo,tweenGoal)
		tweenBala:Play()
		tweenBala.Completed:Connect(function()
			balaEffect:Destroy()
		end)
end
--Efecto que simula una rayo de energía que va de A a B
--@Params model - Modelo - modelo donde se spawnea la bala que debe tener un primary part, modeloTarget - model- modelo hacia donde se apunta la bala, debe tener un primary part, retardo - numero- tiempo que tarda la bala en ir del punto A al B, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.RayoBeam(modelo,modeloTarget,borrado)
	if((borrado ~=(nil or false)) and checkEfecto(modelo)==false) then
		
		local attachment0 = Instance.new("Attachment")
		attachment0.Parent= modelo.PrimaryPart
		local attachment1 = Instance.new("Attachment")
		attachment1.Parent= modeloTarget.PrimaryPart
		local part = Instance.new("Part")
		part.Parent = modelo.PrimaryPart
		part.CFrame=CFrame.lookAt(modelo.PrimaryPart.Position,modeloTarget.PrimaryPart.Position)
		part.Transparency=1
		part.Size=Vector3.new(2,2,2)
		part.CanTouch=false
		part.CanCollide=false
		part.CanQuery=false
		part.Anchored=true
		
		local beamRayo1= Instance.new("Beam")
		beamRayo1.Name="EfectoBeam"
		beamRayo1.Parent=modelo.PrimaryPart
		beamRayo1.Brightness=10
		beamRayo1.Color=ColorSequence.new(Color3.new(0, 0, 1),Color3.new(0, 0.333333, 1),Color3.new(0.454902, 0.807843, 1))
		beamRayo1.LightEmission=1
		beamRayo1.LightInfluence=0
		beamRayo1.Texture= "rbxassetid://12410500585"
		beamRayo1.TextureLength=1
		beamRayo1.TextureMode="Stretch"
		beamRayo1.TextureSpeed=1
		beamRayo1.Transparency=NumberSequence.new(0)
		beamRayo1.Attachment0=attachment0
		beamRayo1.Attachment1=attachment1
		beamRayo1.FaceCamera=true
		beamRayo1.Segments=50
		beamRayo1.Width0=10
		beamRayo1.Width1=10
		
		local sparkEmitter = Instance.new("ParticleEmitter")
		sparkEmitter.Name="EfectoChispas"
		sparkEmitter.Parent=part
		sparkEmitter.Brightness=3
		sparkEmitter.Color=ColorSequence.new(Color3.new(0, 0.333333, 1),Color3.new(0, 0.333333, 1),Color3.new(0.454902, 0.807843, 1))
		sparkEmitter.LightEmission=1
		sparkEmitter.LightInfluence=0
		sparkEmitter.Orientation="VelocityParallel"
		sparkEmitter.Size=NumberSequence.new(1)
		sparkEmitter.Texture="rbxassetid://12410504736"
		sparkEmitter.EmissionDirection="Front"
		sparkEmitter.Lifetime=NumberRange.new(1,2)
		sparkEmitter.Rate=2.5
		sparkEmitter.Speed=NumberRange.new(10)
		sparkEmitter.SpreadAngle=Vector2.new(40,40)
		sparkEmitter.Shape="Disc"
		sparkEmitter.Drag=10
		
	else
		if(checkEfecto(modelo)==true) then
			LimpiarEfecto(modelo,"Efecto")
			if(modelo.PrimaryPart:FindFirstChildWhichIsA("Part")~=nil) then
				modelo.PrimaryPart:FindFirstChildWhichIsA("Part"):Destroy()
			end
			for _, element in ipairs(modelo.PrimaryPart:GetChildren()) do
				if(element:IsA("Attachment")) then
					element:Destroy()
				end
			
			end
			for _, element in ipairs(modeloTarget.PrimaryPart:GetChildren()) do
				if(element:IsA("Attachment")) then
					element:Destroy()
				end
			
			end
		end
	end
end
--Efecto que simula una bala trazadora que va de A a B, se destruye al llegar al objetivo. se destruye solo al llegar al objetivo
--@Params model - Modelo - modelo donde se spawnea la bala que debe tener un primary part, modeloTarget - model- modelo hacia donde se apunta la bala, debe tener un primary part
function EffectsManager.RayoBala(modelo,modeloTarget)
	
	local partDisparo = Instance.new("Part")
	partDisparo.Parent=modelo.PrimaryPart
	partDisparo.Size=Vector3.new(0.2,0.2,(modelo.PrimaryPart.Position-modeloTarget.PrimaryPart.Position).Magnitude)
	partDisparo.CFrame=CFrame.new(modelo.PrimaryPart.Position, modeloTarget.PrimaryPart.Position) * CFrame.new(0,0,-partDisparo.Size.Z/2)
	partDisparo.Color=Color3.new(1, 0.619608, 0.00392157)
	partDisparo.Material="Neon"
	partDisparo.Anchored=true
	partDisparo.CanCollide=false
	partDisparo.CanTouch=false
	partDisparo.CanQuery=false
	
	local efectoChispas = Instance.new("ParticleEmitter")
	efectoChispas.Parent=modeloTarget.PrimaryPart
	efectoChispas.LightEmission=1
	efectoChispas.LightInfluence=0
	efectoChispas.Brightness=5
	efectoChispas.Color=ColorSequence.new(Color3.new(1, 0.666667, 0),Color3.new(1, 1, 0))
	efectoChispas.Orientation="VelocityParallel"
	efectoChispas.Size=NumberSequence.new(1)
	efectoChispas.Texture="rbxassetid://12410497765"
	efectoChispas.Lifetime=NumberRange.new(2,3)
	efectoChispas.Rate=1000
	efectoChispas.Rotation=NumberRange.new(95)
	efectoChispas.Speed=NumberRange.new(10)
	efectoChispas.Shape="Sphere"
	
	wait(0.2)
	efectoChispas.Enabled=false
	
	local tweenInfo = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)

	local tweenGoal = {
		Transparency=1
	}

	local tweenBala = TweenService:Create(partDisparo,tweenInfo,tweenGoal)
	tweenBala:Play()
	tweenBala.Completed:Connect(function()
		partDisparo:Destroy()
		efectoChispas:Destroy()
	end)
		
end
--Efecto que simula onda de choque, como la que sale al recibir un impacto en MK
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part,colorInicio - color3 - color inicial de la onda, colorFinal - color3 - color final de la onda, duracion - number - duración del efecto
function EffectsManager.GenerarEfectoShockWave(modelo, colorInicio, colorFinal, finalSize, duracion)

	local shockWaveModel = Instance.new("Model")
	shockWaveModel.Parent = workspace
	

	local exteriorWave = efectos.ShockWaveRing:Clone()
	exteriorWave.Parent = shockWaveModel
	exteriorWave.Color = colorInicio
	exteriorWave.Size = Vector3.new(1,1,1)
	exteriorWave.Position = Vector3.new(modelo.PrimaryPart.CFrame.X,modelo.PrimaryPart.CFrame.Y,modelo.PrimaryPart.CFrame.Z)
	exteriorWave.CanCollide = false
	exteriorWave.CanTouch = false
	exteriorWave.CanQuery = false
	exteriorWave.Anchored = false
	exteriorWave.Transparency = 0.5
	exteriorWave.Massless=true


	local tweenInfo = TweenInfo.new(
		duracion,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)

	local tweenGoal = {

		Size = finalSize;
		Color=colorFinal;
		Transparency = 0.7

	}

	local interiorWave = efectos.ShockWaveRing:Clone()
	interiorWave.Parent = shockWaveModel
	interiorWave.Color = colorInicio
	interiorWave.Size = Vector3.new(1,3,1)
	interiorWave.Position = Vector3.new(modelo.PrimaryPart.CFrame.X,modelo.PrimaryPart.CFrame.Y,modelo.PrimaryPart.CFrame.Z)
	interiorWave.CanCollide = false
	interiorWave.CanTouch = false
	interiorWave.CanQuery = false
	interiorWave.Anchored = false
	interiorWave.Transparency = 0.5
	interiorWave.Massless=true

	local tweenGoalVortex = {

		Size = (finalSize)/2;
		Color=colorFinal;
		Transparency = 0.7
		
	}
	
	
	local weld1 = Instance.new("WeldConstraint")
	weld1.Parent=modelo
	weld1.Part0=exteriorWave
	weld1.Part1=modelo.PrimaryPart
	
	local weld2 = Instance.new("WeldConstraint")
	weld2.Parent=modelo
	weld2.Part0=interiorWave
	weld2.Part1=modelo.PrimaryPart
	
	
	local tweenExterior = TweenService:Create(exteriorWave,tweenInfo,tweenGoal)
	local tweenInterior = TweenService:Create(interiorWave,tweenInfo,tweenGoalVortex)
	tweenExterior:Play()
	tweenInterior:Play()
	tweenInterior.Completed:Connect(function()
		shockWaveModel:Destroy()
	end)



end
--Efecto que simula una explosión del kirby
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.EfectoKirbo(modelo)
	local randomizer = Random.new(13)
	
	local modeloAnillo = efectos.CheckAnime.anillo:Clone()
	modeloAnillo.Name="EfectoAnillo"
	modeloAnillo.Parent=modelo.PrimaryPart
	modeloAnillo.CFrame = CFrame.new(modelo.PrimaryPart.Position)
	
	local efectoHumo = Instance.new("ParticleEmitter")
	efectoHumo.Parent=modelo.PrimaryPart
	efectoHumo.Name="EfectoHumo"
	efectoHumo.Color=ColorSequence.new(Color3.new(0.666667, 0, 0.498039),Color3.new(0.666667, 0, 1),Color3.new(0.666667, 0, 1))
	efectoHumo.Size=NumberSequence.new(4)
	efectoHumo.Texture="rbxassetid://12410505669"
	efectoHumo.Lifetime=NumberRange.new(1,1.5)
	efectoHumo.Rate=50
	efectoHumo.Speed=NumberRange.new(10)
	efectoHumo.SpreadAngle=Vector2.new(10,10)
	efectoHumo.Drag=10
	efectoHumo.Shape="Disc"
	efectoHumo.Acceleration=Vector3.new(0,-10,0)
	
	local efectoChispitas = Instance.new("ParticleEmitter")
	efectoChispitas.Parent=modelo.PrimaryPart
	efectoChispitas.Name="EfectoChispitas"
	efectoChispitas.Color=ColorSequence.new(Color3.new(0.666667, 0, 0.498039),Color3.new(0.666667, 0, 1),Color3.new(0.666667, 0, 1))
	efectoChispitas.Size=NumberSequence.new(1)
	efectoChispitas.Texture="rbxassetid://12410499980"
	efectoChispitas.Lifetime=NumberRange.new(0.5,2)
	efectoChispitas.Rate=50
	efectoChispitas.Speed=NumberRange.new(10)
	efectoChispitas.SpreadAngle=Vector2.new(20,20)
	efectoChispitas.Shape="Box"
	efectoChispitas.Acceleration=Vector3.new(0,-10,0)
	local tweenInfo = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)
	
	local tweenGoal = {
		Transparency=1;
		Size = Vector3.new(20,0.5,20);
		CFrame = modeloAnillo.CFrame*CFrame.Angles(0,math.rad(120),0)

	}
	
	local tweenAnillo = TweenService:Create(modeloAnillo,tweenInfo,tweenGoal)
	tweenAnillo:Play()
	tweenAnillo.Completed:Connect(function()
		modeloAnillo:Destroy()
		efectoHumo.Enabled=false
		efectoHumo:Destroy()
		efectoChispitas.Enabled=false
		efectoChispitas:Destroy()
	end)
	
	local modeloEstrella1 = efectos.estrella.star:Clone()
	modeloEstrella1.Name="EfectoEstrella1"
	modeloEstrella1.Parent=modelo.PrimaryPart
	modeloEstrella1.Color= Color3.new(1, 1, 0)
	modeloEstrella1.Material="Neon"
	modeloEstrella1.CFrame = CFrame.new(modelo.PrimaryPart.Position)*CFrame.Angles(math.rad(-90),0,0)
	modeloEstrella1.Anchored = true
	modeloEstrella1.CanCollide=false
	modeloEstrella1.CanTouch=false
	modeloEstrella1.CanQuery = false
	
	local modeloEstrella2 = efectos.estrella.star:Clone()
	modeloEstrella2.Name="EfectoEstrella2"
	modeloEstrella2.Parent=modelo.PrimaryPart
	modeloEstrella2.Color= Color3.new(1, 1, 0)
	modeloEstrella2.Material="Neon"
	modeloEstrella2.CFrame = CFrame.new(modelo.PrimaryPart.Position)*CFrame.Angles(math.rad(-90),0,0)
	modeloEstrella2.Anchored = true
	modeloEstrella2.CanCollide=false
	modeloEstrella2.CanTouch=false
	modeloEstrella2.CanQuery = false
	
	local modeloEstrella3 = efectos.estrella.star:Clone()
	modeloEstrella3.Name="EfectoEstrella3"
	modeloEstrella3.Parent=modelo.PrimaryPart
	modeloEstrella3.Color= Color3.new(1, 1, 0)
	modeloEstrella3.Material="Neon"
	modeloEstrella3.CFrame = CFrame.new(modelo.PrimaryPart.Position)*CFrame.Angles(math.rad(-90),0,0)
	modeloEstrella3.Anchored = true
	modeloEstrella3.CanCollide=false
	modeloEstrella3.CanTouch=false
	modeloEstrella3.CanQuery = false
	
	local tweenInfoEstrella = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)
	
	local randomizer = Random.new(10)
	
	local tweenGoalEstrella1 = {
		--Transparency = 1;
		CFrame =CFrame.new(modeloAnillo.CFrame.Position + Vector3.new(randomizer.NextNumber(randomizer,0,modelo.PrimaryPart.Position.X),5,randomizer.NextNumber(randomizer,0,modelo.PrimaryPart.Position.Z/2)))* CFrame.Angles(math.rad(-90),0,0)

	}
	randomizer = Random.new(20)
	
	local tweenGoalEstrella2 = {
		--Transparency = 1;
		CFrame =CFrame.new(modeloAnillo.CFrame.Position + Vector3.new(randomizer.NextNumber(randomizer,-modelo.PrimaryPart.Position.X/2,modelo.PrimaryPart.Position.X/2),5,0))*CFrame.Angles(math.rad(-90),0,0)
		
	}
	randomizer= Random.new(-20)
	
	local tweenGoalEstrella3 = {
		--Transparency = 1;
		CFrame =CFrame.new(modeloAnillo.CFrame.Position + Vector3.new(0,5,randomizer.NextNumber(randomizer,-modelo.PrimaryPart.Position.Z/2,modelo.PrimaryPart.Position.Z/2)))*CFrame.Angles(math.rad(-90),0,0)

	}
	
	local tweenEstrella1 = TweenService:Create(modeloEstrella1,tweenInfoEstrella,tweenGoalEstrella1)
	local tweenEstrella2 = TweenService:Create(modeloEstrella2,tweenInfoEstrella,tweenGoalEstrella2)
	local tweenEstrella3 = TweenService:Create(modeloEstrella3,tweenInfoEstrella,tweenGoalEstrella3)
	
	tweenEstrella1:Play()
	tweenEstrella1.Completed:Connect(function()
		modeloEstrella1.Anchored = false
	end)
	tweenEstrella2:Play()
	tweenEstrella2.Completed:Connect(function()
		modeloEstrella2.Anchored = false
	end)
	
	tweenEstrella3:Play()
	tweenEstrella3.Completed:Connect(function()
		modeloEstrella3.Anchored = false
	end)
	
	
end
--Efecto que simula el humo de un tubo de escape, el polvo que suelta un vehículo, etc... al moverse
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, color - color3 - color del humo, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.GenerarEfectoHumoCarreras(modelo,color,borrado)
	if(borrado==nil or borrado==false)then
		local polvo = Instance.new("ParticleEmitter")
		polvo.Name="EfectoPolvo"
		polvo.Parent=modelo.PrimaryPart
		polvo.Color= ColorSequence.new(color)
		polvo.Texture="rbxassetid://12410505669"
		polvo.EmissionDirection="Back"
		polvo.Lifetime=NumberRange.new(0.3,1)
		polvo.Rate=55
		polvo.Speed=NumberRange.new(20)
		polvo.Drag=5
	elseif(borrado==true) then
		LimpiarEfecto(modelo, "EfectoPolvo")
	end
	

end
--Efectito que pone unas particulas de color similar al fuego, y se autodestruyen pasados unos 2 segundos. El emitter se mete en el primary part del modelo pasado por parámetros
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.GenerarChispasExperiencia(modelo)
	
		local particulas = Instance.new("ParticleEmitter")
		particulas.Name="EfectoRecogerLlama"
		particulas.Parent=modelo.PrimaryPart
		particulas.Texture="rbxassetid://12410498536"
	particulas.Lifetime=NumberRange.new(0.9)
	local colorFire = {ColorSequenceKeypoint.new(0,Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 0, 0))}
	particulas.Color=ColorSequence.new(colorFire)
	particulas.Speed=NumberRange.new(10)
	particulas.Drag=5
		particulas.Rate=50
		particulas.Shape="Sphere"
	
	spawn(function()
		wait(2)
		particulas.Enabled=false
		wait(1)
		particulas:Destroy()
	end)
	
end
--Efectito que pone unas particulas que simulan líneas de velocidad al ir muy rápido por pisar un speedpad, se destruyen solas pasados unos segundos
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, duración - number - el tiempo que dura el efecto antes de desaparecer
function EffectsManager.SpeedPad(model, duracion)

	local emisorChispas = Instance.new("ParticleEmitter")
	emisorChispas.Parent=model.PrimaryPart
	emisorChispas.Name="EfectoChispas"
	emisorChispas.Brightness=1.5
	emisorChispas.Color=ColorSequence.new(Color3.new(1, 1, 1))
	emisorChispas.Transparency=NumberSequence.new(0.75)
	emisorChispas.LightEmission=1
	emisorChispas.LightInfluence=0
	emisorChispas.Orientation="VelocityParallel"
	emisorChispas.Size=NumberSequence.new(1.8)
	emisorChispas.Squash=NumberSequence.new(0.5)
	emisorChispas.Texture="rbxassetid://12410496582"
	emisorChispas.EmissionDirection="Back"
	emisorChispas.Enabled=true
	emisorChispas.Lifetime=NumberRange.new(2,3)
	emisorChispas.Rate=75
	emisorChispas.Rotation=NumberRange.new(90)
	emisorChispas.Speed=NumberRange.new(50)
	emisorChispas.Shape="Box"
	emisorChispas.ShapeInOut="Outward"
	emisorChispas.ShapeStyle="Volume"

	spawn(function()
		wait(duracion-1)
		emisorChispas.Enabled=false
		wait(1)
		emisorChispas:Destroy()
	end)
	
end
--Efecto que simula el fuego de un tubo de escape al hacer turbo
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.GenerarFuegoCarreras(modelo,borrado)
	if(borrado==nil or borrado==false)then
		local nitro = Instance.new("ParticleEmitter")
		nitro.Name="EfectoNitro"
		nitro.Size=NumberSequence.new(2.5)
		nitro.Parent=modelo.PrimaryPart
		nitro.Color= ColorSequence.new(Color3.new(1, 1, 0),Color3.new(1, 0.333333, 0),Color3.new(1, 0, 0))
		nitro.Texture="rbxassetid://12410509342"
		nitro.EmissionDirection="Back"
		nitro.Lifetime=NumberRange.new(0.3,1)
		nitro.Rate=25
		nitro.Rotation=NumberRange.new(-90)
		nitro.Speed=NumberRange.new(20)
		nitro.Drag=5
		nitro.Orientation="VelocityParallel"
	elseif(borrado==true) then
		LimpiarEfecto(modelo, "EfectoNitro")
	end

end
--Efectito que pone unas particulas circulares irisiadas como las que salen al hacer trucos en MK y desaparecen a los pocos segundos. El emitter se mete en el primary part del modelo pasado por parámetros
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.EfectoBrillosTrucos(modelo)
	
	local colorIris = {ColorSequenceKeypoint.new(0,Color3.new(0.666667, 0.333333, 1)),ColorSequenceKeypoint.new(0.2,Color3.new(0, 0.380392, 0.682353)),ColorSequenceKeypoint.new(0.3,Color3.new(0.403922, 0.807843, 0.968627)),ColorSequenceKeypoint.new(0.45,Color3.new(0.352941, 0.729412, 0.305882)),ColorSequenceKeypoint.new(0.65,Color3.new(0.352941, 0.729412, 0.305882)),ColorSequenceKeypoint.new(0.7,Color3.new(0.960784, 0.929412, 0.368627)),ColorSequenceKeypoint.new(0.8,Color3.new(1, 0.396078, 0.00392157)),ColorSequenceKeypoint.new(1,Color3.new(0.996078, 0, 0))}
	
	
	local particulasDentro= Instance.new("ParticleEmitter")
	particulasDentro.Name="EfectoEstrellas"
	particulasDentro.Parent=modelo.PrimaryPart
	particulasDentro.Brightness=10
	particulasDentro.Color=ColorSequence.new(colorIris)
	particulasDentro.LightEmission=1
	particulasDentro.LightInfluence=0
	particulasDentro.Orientation="FacingCamera"
	particulasDentro.Size=NumberSequence.new(2.61,4.6)
	particulasDentro.Texture="rbxassetid://12410499980"
	particulasDentro.Lifetime=NumberRange.new(0.3)
	particulasDentro.Rate=20
	particulasDentro.Speed=NumberRange.new(1)	
	
	local particulasFuera= Instance.new("ParticleEmitter")
	particulasFuera.Name="EfectoEstrellas"
	particulasFuera.Parent=modelo.PrimaryPart
	particulasFuera.Brightness=10
	particulasFuera.Color=ColorSequence.new(colorIris)
	particulasFuera.LightEmission=1
	particulasFuera.LightInfluence=0
	particulasFuera.Orientation="FacingCamera"
	particulasFuera.Size=NumberSequence.new(2.61,4.6)
	particulasFuera.Texture="rbxassetid://12410499798"
	particulasFuera.Lifetime=NumberRange.new(0.3)
	particulasFuera.Rate=20
	particulasFuera.Speed=NumberRange.new(1)
	
	
	spawn(function()
		wait(1.5)
		particulasDentro.Enabled=false
		particulasFuera.Enabled=false
		wait(1)
		particulasDentro:Destroy()
		particulasFuera:Destroy()
	end)
	
end
--Efectito que pone pequeñas llamitas y brillos con el color del fuego en el jugador para que vea que ha subido de nivel, se destruye solo pasados unos pocos segundos. El emitter se mete en el primary part del modelo pasado por parámetros
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.GenerarFuegoNivel(modelo)
	
		local nitro = Instance.new("ParticleEmitter")
		nitro.Name="EfectoRecogerLlama"
		nitro.Parent=modelo.PrimaryPart
		nitro.Texture="rbxassetid://12410509342"
	nitro.Lifetime=NumberRange.new(0.1,0.3)
	local colorFire = {ColorSequenceKeypoint.new(0,Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 0, 0))}
	nitro.Color=ColorSequence.new(colorFire)
		nitro.Speed=NumberRange.new(10)
		nitro.Drag=5
		nitro.Rate=120
		nitro.Shape="Sphere"
		
		local particulas = Instance.new("ParticleEmitter")
		particulas.Name="EfectoRecogerLlama"
		particulas.Parent=modelo.PrimaryPart
		particulas.Texture="rbxassetid://12410498536"
	particulas.Lifetime=NumberRange.new(0.1,0.3)
	local colorFire = {ColorSequenceKeypoint.new(0,Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 0, 0))}
	particulas.Color=ColorSequence.new(colorFire)
		particulas.Speed=NumberRange.new(10)
		particulas.Drag=5
		particulas.Rate=120
		particulas.Shape="Sphere"
	
	spawn(function()
		wait(1.5)
		particulas.Enabled=false
		nitro.Enabled=false
		wait(1)
		particulas:Destroy()
		nitro:Destroy()
	end)

end
--Efectito que pone un efecto parecido al de super en el jugador para indicar que ha ascendido, se destruye solo pasados unos pocos segundos. El emitter se mete en el primary part del modelo pasado por parámetros y se puede ajustar el color del aura
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, colorSequence - colorSequence - colorSequence con los colores que queremos para el aura
function EffectsManager.EfectoAscension(model, colorSequence)

		local emisorAura = Instance.new("ParticleEmitter")
		emisorAura.Parent=model.PrimaryPart
		emisorAura.Name="EfectoAura"
		emisorAura.Color=colorSequence
		emisorAura.Brightness=1.7
		emisorAura.LightEmission=1
		emisorAura.LightInfluence=0
		emisorAura.Orientation="VelocityParallel"
		emisorAura.Size=NumberSequence.new(10)
		emisorAura.Squash=NumberSequence.new(0)
		emisorAura.Texture="rbxassetid://12410509491"
		emisorAura.Transparency=NumberSequence.new(0.6)
		emisorAura.ZOffset=0
		emisorAura.EmissionDirection="Top"
		emisorAura.Lifetime=NumberRange.new(0.2,0.8)
		emisorAura.Rate=100
		emisorAura.Rotation=NumberRange.new(-90)
		emisorAura.RotSpeed=NumberRange.new(-5,5)
		emisorAura.Speed=NumberRange.new(14,30)
		emisorAura.SpreadAngle=Vector2.new(360,360)
		emisorAura.Shape="Box"
		emisorAura.ShapeInOut="Outward"
		emisorAura.ShapeStyle="Volume"
		emisorAura.Acceleration=Vector3.new(0,80,0)
		emisorAura.Drag=5
		emisorAura.TimeScale=1		

		local emisorPolvo = Instance.new("ParticleEmitter")
		emisorPolvo.Parent=model.PrimaryPart
		emisorPolvo.Name="EfectoPolvo"
		emisorPolvo.Brightness=1
		emisorPolvo.Color=ColorSequence.new(Color3.new(0.666667, 0.666667, 0.498039))
		emisorPolvo.LightEmission=0
		emisorPolvo.LightInfluence=0
		emisorPolvo.Orientation="FacingCamera"
		emisorPolvo.Size=NumberSequence.new(2)
		emisorPolvo.Squash=NumberSequence.new(0)
		emisorPolvo.Texture="rbxassetid://12410506450"
		emisorPolvo.Transparency=NumberSequence.new(0.6)
		emisorPolvo.ZOffset=0
		emisorPolvo.EmissionDirection="Bottom"
		emisorPolvo.Lifetime=NumberRange.new(0.2,1)
		emisorPolvo.Rate=400
		emisorPolvo.Speed=NumberRange.new(20)
		emisorPolvo.SpreadAngle=Vector2.new(90,90)
		emisorPolvo.Shape="Disc"
		emisorPolvo.ShapeInOut="Outward"
		emisorPolvo.ShapePartial=1
		emisorPolvo.ShapeStyle="Volume"
		emisorPolvo.Acceleration=Vector3.new(0,10,0)
	
	spawn(function()
		wait(3)
		emisorAura.Enabled=false
		emisorPolvo.Enabled=false
		wait(1)
		emisorAura:Destroy()
		emisorPolvo:Destroy()
	end)
	
end
--Efectito que pone chispas en los laterales del modelo para indicar que está haciendo drifting. Está hecho de manera que si existiese este efecto ya antes en un modelo, se modifiquen los parámetros del existente, para permitir cambiar el color y la dirección de las chispas en tiempo real sin que se corten.
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, dirección - String - "Left" para que salgan hacia la izquierda, "Right" para que salgan hacia la derecha, color - color3 - color de las chispas, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoChispasDrift(modelo, direccion, color, borrado)
	if(borrado == false or borrado == nil ) then
		if(modelo.PrimaryPart:FindFirstChild("EfectoChispasInterior") or modelo.PrimaryPart:FindFirstChild("EfectoChispasExterior"))then
			for _,element in pairs(modelo.PrimaryPart:GetChildren()) do
				if(element:IsA("ParticleEmitter")) then
					if(element.Name == "EfectoChispasInterior" or element.Name == "EfectoChispasExterior") then
						element.Color=ColorSequence.new(color)
						if(direccion=="Left") then
							element.EmissionDirection="Left"
							element.Rotation=NumberRange.new(70)
						elseif(direccion=="Right") then
							element.EmissionDirection="Right"
							element.Rotation=NumberRange.new(-70)
						end
					end
				end
			end
		else
			local chispasInterior = Instance.new("ParticleEmitter")
			chispasInterior.Name="EfectoChispasInterior"
			chispasInterior.Parent = modelo.PrimaryPart
			chispasInterior.Brightness=10
			chispasInterior.Color=ColorSequence.new(color)
			chispasInterior.LightEmission=1
			chispasInterior.LightInfluence=0
			chispasInterior.Orientation= "FacingCamera"
			chispasInterior.Size=NumberSequence.new(0.8)
			chispasInterior.Squash=NumberSequence.new(0.1)
			chispasInterior.Texture="rbxassetid://12410496730"
			chispasInterior.Transparency=NumberSequence.new(0)
			chispasInterior.Shape="Box"
			chispasInterior.ShapeInOut="Outward"
			chispasInterior.ShapeStyle="Volume"
			chispasInterior.Drag=5

			local chispasExterior = Instance.new("ParticleEmitter")
			chispasExterior.Name="EfectoChispasExterior"
			chispasExterior.Parent=modelo.PrimaryPart
			chispasExterior.Brightness = 10
			chispasExterior.Color=ColorSequence.new(color)
			chispasExterior.LightEmission=1
			chispasExterior.LightInfluence=0
			chispasExterior.Orientation="FacingCamera"
			chispasExterior.Size=NumberSequence.new(0.5)
			chispasExterior.Squash=NumberSequence.new(0.2)
			chispasExterior.Texture="rbxassetid://12410496730"
			chispasExterior.Transparency=NumberSequence.new(0)
			chispasExterior.Shape="Box"
			chispasExterior.ShapeInOut="Outward"
			chispasExterior.ShapeStyle="Volume"
			chispasExterior.Drag=0

			if(direccion=="Left") then

				chispasInterior.EmissionDirection="Left"
				chispasInterior.Lifetime=NumberRange.new(0.2)
				chispasInterior.Rate=100
				chispasInterior.Rotation=NumberRange.new(70)
				chispasInterior.Speed=NumberRange.new(20)
				chispasInterior.SpreadAngle=Vector2.new(10,10)

				chispasExterior.EmissionDirection="Left"
				chispasExterior.Lifetime=NumberRange.new(0.2,0.5)
				chispasExterior.Rate=150
				chispasExterior.Rotation=NumberRange.new(70)
				chispasExterior.Speed=NumberRange.new(20)
				chispasExterior.SpreadAngle=Vector2.new(10,10)

			elseif(direccion=="Right") then

				chispasInterior.EmissionDirection="Right"
				chispasInterior.Lifetime=NumberRange.new(0.2)
				chispasInterior.Rate=100
				chispasInterior.Rotation=NumberRange.new(-70)
				chispasInterior.Speed=NumberRange.new(20)
				chispasInterior.SpreadAngle=Vector2.new(10,10)

				chispasExterior.EmissionDirection="Right"
				chispasExterior.Lifetime=NumberRange.new(0.2,0.5)
				chispasExterior.Rate=150
				chispasExterior.Rotation=NumberRange.new(-70)
				chispasExterior.Speed=NumberRange.new(20)
				chispasExterior.SpreadAngle=Vector2.new(10,10)
			end
		end
	else

		LimpiarEfecto(modelo, "EfectoChispasInterior")
		LimpiarEfecto(modelo, "EfectoChispasExterior")

	end
end
--Efecto que simula salpicaduras en el agua. está diseñado para que el efecto se quede puesto hasta que se indique lo contrario
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.EfectoSalpicadura(modelo,borrado)
	if(borrado == false or borrado == nil ) then
	local emisor = Instance.new("ParticleEmitter")
	emisor.Parent=modelo.PrimaryPart
	emisor.Name="EfectoSalpicaduraAgua"
	emisor.Texture= "rbxassetid://272050333"
	emisor.Color=ColorSequence.new(Color3.new(0.0313725, 0.709804, 1),Color3.new(0, 0.384314, 1))
	emisor.LightEmission=0
	emisor.Size=NumberSequence.new(0.5)
	emisor.Acceleration=Vector3.new(0,-25,0)
	emisor.Lifetime=NumberRange.new(1)
	emisor.Rate=50
	emisor.Speed=NumberRange.new(20)
	emisor.VelocitySpread=7
	emisor.Drag=5
	elseif (borrado == true) then
		LimpiarEfecto(modelo, "EfectoSalpicaduraAgua")
	end
end
--Efecto que simula lineas de aire al hacer hover, como en genshin. está diseñado para que el efecto se quede puesto hasta que se indique lo contrario
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part, borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
function EffectsManager.Hover(model, borrado)
	
	if(borrado == false or borrado == nil ) then
		
		local emisorHover = Instance.new("ParticleEmitter")
		emisorHover.Parent=model.PrimaryPart
		emisorHover.Name="EfectoHover"
		emisorHover.Brightness=1.5
		emisorHover.Color=ColorSequence.new(Color3.new(1, 1, 1))
		emisorHover.Transparency=NumberSequence.new(0.9)
		emisorHover.LightEmission=1
		emisorHover.LightInfluence=0
		emisorHover.Orientation="VelocityParallel"
		emisorHover.Size=NumberSequence.new(1.8)
		emisorHover.Squash=NumberSequence.new(1)
		emisorHover.Texture="rbxassetid://12410496582"
		emisorHover.EmissionDirection="Back"
		emisorHover.Enabled=true
		emisorHover.Lifetime=NumberRange.new(0.25)
		emisorHover.Rate=15
		emisorHover.Rotation=NumberRange.new(90)
		emisorHover.Speed=NumberRange.new(30)
		emisorHover.Shape="Box"
		emisorHover.ShapeInOut="Outward"
		emisorHover.ShapeStyle="Volume"
		emisorHover.Drag=1

	elseif (borrado == true) then
		LimpiarEfecto(model, "EfectoHover")
	end

end
--Efecto que simula las partículas al romper una roca, como polvo y gravilla. Se destruye solo pasados unos pocos segundos.
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.GenerarEfectoRoca(modelo)

	local particulasRoca = Instance.new("ParticleEmitter")
	particulasRoca.Name = "ParticulasRoca"
	particulasRoca.Parent=modelo.PrimaryPart
	particulasRoca.Brightness=1
	particulasRoca.Color=ColorSequence.new(Color3.new(0.392157, 0.333333, 0.239216))
	particulasRoca.LightEmission=0
	particulasRoca.LightInfluence=0
	particulasRoca.Size=NumberSequence.new(2)
	particulasRoca.Texture="rbxassetid://12410517088"
	particulasRoca.Lifetime=NumberRange.new(5,10)
	particulasRoca.Rate=40
	particulasRoca.Speed=NumberRange.new(20)
	particulasRoca.Shape="Sphere"
	particulasRoca.Acceleration=Vector3.new(0,-20,0)
	
	local particulasPolvo = Instance.new("ParticleEmitter")
	particulasPolvo.Name = "ParticulasPolvo"
	particulasPolvo.Parent=modelo.PrimaryPart
	particulasPolvo.Brightness=1
	particulasPolvo.Color=ColorSequence.new(Color3.new(0.392157, 0.333333, 0.239216))
	particulasPolvo.LightEmission=0
	particulasPolvo.LightInfluence=0
	particulasPolvo.Size=NumberSequence.new(2)
	particulasPolvo.Texture="rbxassetid://12410506021"
	particulasPolvo.Lifetime=NumberRange.new(5,10)
	particulasPolvo.Rate=30
	particulasPolvo.Speed=NumberRange.new(10)
	particulasPolvo.Shape="Sphere"
	particulasPolvo.Acceleration=Vector3.new(0,-5,0)


	spawn(function()
		wait(1.5)
		particulasRoca.Enabled=false
		particulasPolvo.Enabled=false
		wait(1)
		particulasRoca:Destroy()
		particulasPolvo:Destroy()
	end)

end
--Efecto similar al de las partículas de roca, pero que simula trocitos de hueso blancos. Se destruye solo pasados unos pocos segundos.
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.GenerarEfectoHueso(modelo)

	local particulasHueso = Instance.new("ParticleEmitter")
	particulasHueso.Name = "ParticulasHueso"
	particulasHueso.Parent=modelo.PrimaryPart
	particulasHueso.Color=ColorSequence.new(Color3.new(1, 1, 1))
	particulasHueso.LightEmission=0
	particulasHueso.LightInfluence=1
	particulasHueso.Size=NumberSequence.new(0.5)
	particulasHueso.Texture="rbxassetid://12410517335"
	particulasHueso.Lifetime=NumberRange.new(5,10)
	particulasHueso.Rate=80
	particulasHueso.Speed=NumberRange.new(15)
	particulasHueso.Shape="Sphere"
	particulasHueso.Acceleration=Vector3.new(0,-15,0)

	spawn(function()
		wait(1)
		particulasHueso.Enabled=false
		wait(1)
		particulasHueso:Destroy()
	end)

end

--Efecto que simula una bala de agua que va de A a B, se destruye al llegar al objetivo
--@Params model - Modelo - modelo donde se spawnea la bala que debe tener un primary part, modeloTarget - model- modelo hacia donde se apunta la bala, debe tener un primary part, retardo - numero- tiempo que tarda la bala en ir del punto A al B
function EffectsManager.WaterBullet(modelo,modeloTarget,retardo)
	local balaEffect = script.Parent.Effects.WaterBoll:Clone()
	balaEffect.Parent=modelo.PrimaryPart
	balaEffect.CFrame=CFrame.lookAt(modelo.PrimaryPart.Position,modeloTarget.PrimaryPart.Position)
	balaEffect.Name="EfectoBalaAgua"
	balaEffect.Attachment.Aura.Rate = 500
	local tweenInfo = TweenInfo.new(
		retardo,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)

	local tweenGoal = {
		CFrame = CFrame.new(modeloTarget.PrimaryPart.Position);
	}

	local tweenBala = TweenService:Create(balaEffect,tweenInfo,tweenGoal)
	tweenBala:Play()
	tweenBala.Completed:Connect(function()
		balaEffect:Destroy()
	end)
end

--Efecto que simula varias balas de tuercas que van de A a B, se destruye al llegar al objetivo
--@Params model - Modelo - modelo donde se spawnea la bala que debe tener un primary part, modeloTarget - model- modelo hacia donde se apunta la bala, debe tener un primary part, retardo - numero- tiempo que tarda cada bala en ir del punto A al B
function EffectsManager.ScrewBullet(modelo,modeloTarget,retardo)
	for _,child in ipairs(efectos.tuerca:GetChildren()) do
		print("Bala")
		local balaEffect = child:Clone()
		balaEffect.Parent=modelo.PrimaryPart
		balaEffect.CFrame=CFrame.lookAt(modelo.PrimaryPart.Position,modeloTarget.PrimaryPart.Position)
		balaEffect.Name="EfectoBalaTornillo"
		balaEffect.attachment.Aura.Rate = 150
		local tweenInfo = TweenInfo.new(
			retardo,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false
		)

		local tweenGoal = {
			CFrame = CFrame.new(modeloTarget.PrimaryPart.Position);
		}

		local tweenBala = TweenService:Create(balaEffect,tweenInfo,tweenGoal)
		tweenBala:Play()
		tweenBala.Completed:Wait()
		balaEffect:Destroy()
		
	end
end
--Efecto similar al gruñido de PK B/N. Se destruye solo pasados unos pocos segundos.
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.GenerarEfectoGrito(modelo)

	local particulasCirculo = Instance.new("ParticleEmitter")
	particulasCirculo.Brightness=1
	particulasCirculo.Color=ColorSequence.new(Color3.new(1, 0, 0),Color3.new(0.666667, 0, 0))
	particulasCirculo.LightEmission=0
	particulasCirculo.LightInfluence=0
	particulasCirculo.Orientation="FacingCamera"
	particulasCirculo.Size=NumberSequence.new(2.5,5)
	particulasCirculo.Texture="rbxassetid://12410514493"
	particulasCirculo.Name="EfectoGritoCirculo"
	particulasCirculo.Parent=modelo.PrimaryPart
	particulasCirculo.Lifetime=NumberRange.new(0.5,1)
	particulasCirculo.Rate=20
	particulasCirculo.Speed=NumberRange.new(2.5)
	particulasCirculo.Shape="Sphere"
	particulasCirculo.Drag=10
	
	local particulasRayo = Instance.new("ParticleEmitter")
	particulasRayo.Brightness=1
	particulasRayo.Color=ColorSequence.new(Color3.new(1, 1, 0),Color3.new(0.568627, 0.568627, 0))
	particulasRayo.LightEmission=0
	particulasRayo.LightInfluence=0
	particulasRayo.Orientation="VelocityParallel"
	particulasRayo.Size=NumberSequence.new(2.5,5)
	particulasRayo.Squash=NumberSequence.new(-1.61,0)
	particulasRayo.Texture="rbxassetid://12410500786"
	particulasRayo.Name="EfectoGritoRayo"
	particulasRayo.Parent=modelo.PrimaryPart
	particulasRayo.Lifetime=NumberRange.new(0.5,1)
	particulasRayo.Rate=40
	particulasRayo.Speed=NumberRange.new(2.5)
	particulasRayo.Shape="Sphere"
	particulasRayo.Drag=10
		
	spawn(function()
		wait(2)
		particulasCirculo.Enabled=false
		particulasRayo.Enabled=false
		wait(1)
		particulasCirculo:Destroy()
		particulasRayo:Destroy()
	end)

end
--Efecto que simula el fogonazo de una bola de fuego al salir de la boca de unn dragón
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarDisparoDragon(modelo)

	local particulasChispas = Instance.new("ParticleEmitter")
	particulasChispas.Name="EfectoChispasDisparo"
	particulasChispas.Parent=modelo.PrimaryPart
	particulasChispas.Brightness=1
	local colorFire = {ColorSequenceKeypoint.new(0,Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 0, 0))}
	particulasChispas.Color=ColorSequence.new(colorFire)
	particulasChispas.LightEmission=1
	particulasChispas.LightInfluence=0
	particulasChispas.Orientation = Enum.ParticleOrientation.VelocityParallel
	particulasChispas.Size=NumberSequence.new(3.2,1)
	particulasChispas.Texture="rbxassetid://12410497765"
	particulasChispas.Lifetime=NumberRange.new(0.2)
	particulasChispas.Rate=500
	particulasChispas.Rotation=NumberRange.new(90)
	particulasChispas.Speed=NumberRange.new(45)
	particulasChispas.SpreadAngle=Vector2.new(30,30)
	particulasChispas.Drag=8
	
	
	local particulasHumo = Instance.new("ParticleEmitter")
	particulasHumo.Name="EfectoHumoArea"
	particulasHumo.Parent=modelo.PrimaryPart
	particulasHumo.Color=ColorSequence.new(Color3.new(0.392157, 0.262745, 0))
	particulasHumo.LightEmission=0
	particulasHumo.LightInfluence=1
	particulasHumo.Orientation = Enum.ParticleOrientation.FacingCamera
	particulasHumo.Size=NumberSequence.new(4)
	particulasHumo.Texture="rbxassetid://12410505486"
	particulasHumo.Transparency=NumberSequence.new(0.8)
	particulasHumo.Lifetime=NumberRange.new(5)
	particulasHumo.Rate=200
	particulasHumo.Speed=NumberRange.new(10)
	particulasHumo.SpreadAngle=Vector2.new(90,90)
	particulasHumo.Shape=Enum.ParticleEmitterShape.Disc
	particulasHumo.Acceleration=Vector3.new(0,-1,0)
	
	local particulasHumoDisparo = Instance.new("ParticleEmitter")
	particulasHumoDisparo.Name="EfectoChispasDisparo"
	particulasHumoDisparo.Parent=modelo.PrimaryPart
	particulasHumoDisparo.Color=ColorSequence.new(Color3.new(0.631373, 0.631373, 0.631373))
	particulasHumoDisparo.LightEmission=0
	particulasHumoDisparo.LightInfluence=1
	particulasHumoDisparo.Size=NumberSequence.new(1)
	particulasHumoDisparo.Texture="rbxassetid://12410505486"
	particulasHumoDisparo.Lifetime=NumberRange.new(0.2)
	particulasHumoDisparo.Rate=300
	particulasHumoDisparo.Speed=NumberRange.new(20)
	particulasHumoDisparo.Drag=8
	
	
	spawn(function()
		wait(0.5)
		particulasChispas.Enabled=false
		particulasHumo.Enabled=false
		particulasHumoDisparo.Enabled=false
		wait(1)
		particulasChispas:Destroy()
		particulasHumo:Destroy()
		particulasHumoDisparo:Destroy()
	end)

end
--Efecto que simula la explosión de una bola de fuego
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.EfectoImpactoDragon(model)

	local explosionEffect = script.Parent.Effects["Meshes/Tutorial VFX_Sphere"]:Clone()
	explosionEffect.Parent=model.PrimaryPart
	explosionEffect.Name="EfectoExplosion"
	explosionEffect.Color= Color3.new(1, 0.537255, 0.0117647)
	explosionEffect.Material="Neon"
	explosionEffect.Reflectance=0
	explosionEffect.Transparency=0.4
	explosionEffect.Size=Vector3.new(0,0,0)
	explosionEffect.CFrame=model.PrimaryPart.CFrame
	explosionEffect.CanCollide=false
	explosionEffect.CanTouch=false
	explosionEffect.CanQuery=false
	explosionEffect.Anchored=true
	explosionEffect.Massless=true
	
	local explosionEffectInner = script.Parent.Effects["Meshes/Tutorial VFX_Sphere"]:Clone()
	explosionEffectInner.Parent=explosionEffect
	explosionEffectInner.Name="EfectoExplosion"
	explosionEffectInner.Color= Color3.new(1, 1, 0)
	explosionEffectInner.Material="Neon"
	explosionEffectInner.Reflectance=0
	explosionEffectInner.Transparency=0.4
	explosionEffectInner.Size=explosionEffect.Size/2
	explosionEffectInner.CFrame=model.PrimaryPart.CFrame
	explosionEffectInner.CanCollide=false
	explosionEffectInner.CanTouch=false
	explosionEffectInner.CanQuery=false
	explosionEffectInner.Anchored=true
	explosionEffectInner.Massless=true


	local  vortex = Instance.new("Part")
	vortex.Parent=explosionEffect
	vortex.Name="EfectoVortex"
	vortex.Shape="Block"
	vortex.CFrame=explosionEffect.CFrame
	vortex.CanCollide=false
	vortex.CanTouch=false
	vortex.CanQuery=false
	vortex.Anchored=true
	vortex.Transparency=1
	vortex.Size=Vector3.new(0,0,0)

	local vortexDecal = Instance.new("Decal")
	vortexDecal.Parent=vortex
	vortexDecal.Face="Top"
	vortexDecal.Texture="rbxassetid://6700005265"
	vortexDecal.Color3=Color3.new(0.666667, 0.666667, 0.498039)


	local emisorPolvo = Instance.new("ParticleEmitter")
	emisorPolvo.Parent= explosionEffect
	emisorPolvo.Name="EfectoPolvo"
	emisorPolvo.Brightness=1
	emisorPolvo.Color=ColorSequence.new(Color3.new(0.666667, 0.666667, 0.498039))
	emisorPolvo.LightEmission=0
	emisorPolvo.LightInfluence=0
	emisorPolvo.Orientation="FacingCamera"
	emisorPolvo.Size=NumberSequence.new(10)
	emisorPolvo.Squash=NumberSequence.new(0)
	emisorPolvo.Texture="rbxassetid://12410506450"
	emisorPolvo.Transparency=NumberSequence.new(0.5)
	emisorPolvo.ZOffset=2.5
	emisorPolvo.EmissionDirection="Bottom"
	emisorPolvo.Lifetime=NumberRange.new(0.2,1)
	emisorPolvo.Rate=1000
	emisorPolvo.Speed=NumberRange.new(50)
	emisorPolvo.SpreadAngle=Vector2.new(90,90)
	emisorPolvo.Shape="Disc"
	emisorPolvo.ShapeInOut="Outward"
	emisorPolvo.ShapePartial=1
	emisorPolvo.ShapeStyle="Volume"
	emisorPolvo.Acceleration=Vector3.new(0,10,0)
	
	local emisorAscuas = Instance.new("ParticleEmitter")
	emisorAscuas.Parent= explosionEffect
	emisorAscuas.Name="EfectoPolvo"
	emisorAscuas.Brightness=1
	emisorAscuas.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.333333, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 0, 0))})
	emisorAscuas.LightEmission=0
	emisorAscuas.LightInfluence=0
	emisorAscuas.Orientation="FacingCamera"
	emisorAscuas.Size=NumberSequence.new(10)
	emisorAscuas.Squash=NumberSequence.new(0)
	emisorAscuas.Texture="rbxassetid://12410508538"
	emisorAscuas.Transparency=NumberSequence.new(0.5)
	emisorAscuas.ZOffset=2.5
	emisorAscuas.EmissionDirection="Bottom"
	emisorAscuas.Lifetime=NumberRange.new(0.2,1)
	emisorAscuas.Rate=1000
	emisorAscuas.Speed=NumberRange.new(50)
	emisorAscuas.SpreadAngle=Vector2.new(90,90)
	emisorAscuas.Shape="Disc"
	emisorAscuas.ShapeInOut="Outward"
	emisorAscuas.ShapePartial=1
	emisorAscuas.ShapeStyle="Volume"
	emisorAscuas.Acceleration=Vector3.new(0,10,0)

	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)

	local tweenGoal = {

		Size = Vector3.new(36,36,36);
		CFrame = explosionEffect.CFrame*CFrame.Angles(0,math.rad(120),0);
		Transparency = 1;
		Color = Color3.new(1, 0, 0)

	}
	
	local tweenGoalInner = {

		Size = tweenGoal.Size/2;
		CFrame = explosionEffect.CFrame*CFrame.Angles(0,math.rad(90),0);
		Transparency = 1;
		Color = Color3.new(1, 0.666667, 0)

	}
	
	
	local tweenGoalVortex = {

		Size = Vector3.new(120,0,120);
		CFrame = explosionEffect.CFrame*CFrame.Angles(0,math.rad(120),0);
		

	}
	
	local tweenGoalVortexDecal={
		Transparency = 1
	}
	
	local tweenExplosion = TweenService:Create(explosionEffect,tweenInfo,tweenGoal)
	local tweenExplosionInner = TweenService:Create(explosionEffectInner,tweenInfo,tweenGoalInner)
	local tweenVortex = TweenService:Create(vortex,tweenInfo,tweenGoalVortex)
	local tweenVortexDecal = TweenService:Create(vortexDecal,tweenInfo,tweenGoalVortexDecal)
	
	tweenVortexDecal:Play()
	tweenExplosion:Play()
	tweenExplosionInner:Play()
	tweenVortex:Play()
	tweenExplosion.Completed:Connect(function()
		explosionEffect:Destroy()
	end)


end
--Efecto que simula un potente chorro de agua
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarDisparoShark(modelo)

	local particulasGotas = Instance.new("ParticleEmitter")
	particulasGotas.Name="EfectoGotasAgua"
	particulasGotas.Parent=modelo.PrimaryPart
	local colorAgua = {ColorSequenceKeypoint.new(0,Color3.new(0.333333, 1, 1)),ColorSequenceKeypoint.new(0.3,Color3.new(0, 0.666667, 1)),ColorSequenceKeypoint.new(1,Color3.new(0, 0, 1))}
	particulasGotas.Color=ColorSequence.new(colorAgua)
	particulasGotas.LightEmission=0
	particulasGotas.LightInfluence=1
	particulasGotas.Orientation = Enum.ParticleOrientation.VelocityParallel
	particulasGotas.Size=NumberSequence.new(3.2,1)
	particulasGotas.Squash=NumberSequence.new(0,2.74)
	particulasGotas.Texture="rbxassetid://13334530208"
	particulasGotas.Lifetime=NumberRange.new(1)
	particulasGotas.Rate=400
	particulasGotas.Rotation=NumberRange.new(90)
	particulasGotas.Speed=NumberRange.new(80)
	particulasGotas.SpreadAngle=Vector2.new(30,30)
	particulasGotas.Drag=4


	local particulasOndas = Instance.new("ParticleEmitter")
	particulasOndas.Name="EfectoOndasAgua"
	particulasOndas.Parent=modelo.PrimaryPart
	local colorAgua = {ColorSequenceKeypoint.new(0,Color3.new(0.333333, 1, 1)),ColorSequenceKeypoint.new(0.3,Color3.new(0, 0.666667, 1)),ColorSequenceKeypoint.new(1,Color3.new(0, 0, 1))}
	particulasOndas.Color=ColorSequence.new(colorAgua)
	particulasOndas.LightEmission=0
	particulasOndas.LightInfluence=1
	particulasOndas.Orientation = Enum.ParticleOrientation.VelocityParallel
	particulasOndas.Size=NumberSequence.new(3.2,1)
	particulasOndas.Squash=NumberSequence.new(0,-1.8)
	particulasOndas.Texture="rbxassetid://13334530208"
	particulasOndas.Lifetime=NumberRange.new(1)
	particulasOndas.Rate=400
	particulasOndas.Rotation=NumberRange.new(90)
	particulasOndas.Speed=NumberRange.new(80)
	particulasOndas.SpreadAngle=Vector2.new(30,30)
	particulasOndas.Drag=4

	local particulasEspuma = Instance.new("ParticleEmitter")
	particulasEspuma.EmissionDirection="Bottom"
	particulasEspuma.Name="EfectoEspumaAgua"
	particulasEspuma.Parent=modelo.PrimaryPart
	particulasEspuma.Color=ColorSequence.new(Color3.new(1, 1, 1))
	particulasEspuma.LightEmission=0
	particulasEspuma.LightInfluence=1
	particulasEspuma.Orientation = Enum.ParticleOrientation.VelocityParallel
	particulasEspuma.Size=NumberSequence.new(3.2,1)
	particulasEspuma.Texture="rbxassetid://12410505669"
	particulasEspuma.Transparency=NumberSequence.new(0.8)
	particulasEspuma.Lifetime=NumberRange.new(1)
	particulasEspuma.Rate=500
	particulasEspuma.Rotation=NumberRange.new(90)
	particulasEspuma.Speed=NumberRange.new(45)
	particulasEspuma.SpreadAngle=Vector2.new(40,40)
	particulasEspuma.Drag=4


	spawn(function()
		wait(0.5)
		particulasGotas.Enabled=false
		particulasOndas.Enabled=false
		particulasEspuma.Enabled=false
		wait(1)
		particulasGotas:Destroy()
		particulasOndas:Destroy()
		particulasEspuma:Destroy()
	end)

end

--Efecto que simula el estado de congelación
--@Params modelo = model = modelo al que se le mete el efecto, tiempo = numero = tiempo que dura el efecto de congelación
function EffectsManager.GenerarImpactoShark(modelo,tiempo)
	
	
	
	local modeloCuboHielo = efectos.cubo_hielo:Clone()
	modeloCuboHielo.Parent = modelo
	modeloCuboHielo:SetPrimaryPartCFrame(CFrame.new(modelo.PrimaryPart.Position))
	modeloCuboHielo.PrimaryPart.Size = Vector3.new(0,0,0)
	
	local emisorPolvo = Instance.new("ParticleEmitter")
	emisorPolvo.Parent= modelo.PrimaryPart
	emisorPolvo.Name="EfectoPolvo"
	emisorPolvo.Color=ColorSequence.new(Color3.new(0.823529, 1, 0.972549),Color3.new(0.333333, 0.666667, 1))
	emisorPolvo.LightEmission=1
	emisorPolvo.LightInfluence=1
	emisorPolvo.Orientation="FacingCamera"
	emisorPolvo.Size=NumberSequence.new(5)
	emisorPolvo.Squash=NumberSequence.new(0)
	emisorPolvo.Texture="rbxassetid://12410506450"
	emisorPolvo.Transparency=NumberSequence.new(0.8,0)
	emisorPolvo.EmissionDirection="Bottom"
	emisorPolvo.Lifetime=NumberRange.new(0.2,0.5)
	emisorPolvo.Rate=400
	emisorPolvo.Speed=NumberRange.new(50)
	emisorPolvo.SpreadAngle=Vector2.new(90,90)
	emisorPolvo.Shape="Disc"
	emisorPolvo.ShapeInOut="Outward"
	emisorPolvo.ShapePartial=1
	emisorPolvo.ShapeStyle="Volume"
	emisorPolvo.Acceleration=Vector3.new(0,-10,0)
	emisorPolvo.Drag=4
	
	local tweenInfo = TweenInfo.new(
		1.5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)

	local tweenGoal = {
		Size = modelo.PrimaryPart.Size*4
	}

	local tweenCubito = TweenService:Create(modeloCuboHielo.PrimaryPart,tweenInfo,tweenGoal)
	tweenCubito:Play()
	tweenCubito.Completed:Connect(function()
		wait(tiempo)
		modeloCuboHielo:Destroy()
		emisorPolvo:Destroy()
	end)
	
end
--Efecto que simula el fogonazo de un proyectil eléctrico
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarDisparoBone(modelo)

	local particulasRayos = Instance.new("ParticleEmitter")
	particulasRayos.Name="EfectoRayos"
	particulasRayos.Parent=modelo.PrimaryPart
	local colorRayos = {ColorSequenceKeypoint.new(0,Color3.new(1, 1, 0.498039)),ColorSequenceKeypoint.new(0.3,Color3.new(1, 1, 0.294118)),ColorSequenceKeypoint.new(1,Color3.new(1, 1, 0))}
	particulasRayos.Color=ColorSequence.new(colorRayos)
	particulasRayos.LightEmission=0
	particulasRayos.LightInfluence=1
	particulasRayos.Orientation = Enum.ParticleOrientation.VelocityParallel
	particulasRayos.Size=NumberSequence.new(3.2,1)
	particulasRayos.Squash=NumberSequence.new(0,-2.59)
	particulasRayos.Texture="rbxassetid://12410500786"
	particulasRayos.Lifetime=NumberRange.new(1)
	particulasRayos.Rate=400
	particulasRayos.Rotation=NumberRange.new(90)
	particulasRayos.Speed=NumberRange.new(80)
	particulasRayos.SpreadAngle=Vector2.new(30,30)
	particulasRayos.Drag=8


	local particulasElectro = Instance.new("ParticleEmitter")
	particulasElectro.Name="EfectoElectro"
	particulasElectro.Parent=modelo.PrimaryPart
	local colorRayos = {ColorSequenceKeypoint.new(0,Color3.new(1, 1, 0.498039)),ColorSequenceKeypoint.new(0.3,Color3.new(1, 1, 0.294118)),ColorSequenceKeypoint.new(1,Color3.new(1, 1, 0))}
	particulasElectro.Color=ColorSequence.new(colorRayos)
	particulasElectro.LightEmission=0
	particulasElectro.LightInfluence=1
	particulasElectro.Orientation = Enum.ParticleOrientation.VelocityParallel
	particulasElectro.Size=NumberSequence.new(3.2,1)
	particulasElectro.Texture="rbxassetid://12410504736"
	particulasElectro.Lifetime=NumberRange.new(1)
	particulasElectro.Rate=400
	particulasElectro.Rotation=NumberRange.new(90)
	particulasElectro.Speed=NumberRange.new(80)
	particulasElectro.SpreadAngle=Vector2.new(30,30)
	particulasElectro.Drag=8



	spawn(function()
		wait(0.5)
		particulasRayos.Enabled=false
		particulasElectro.Enabled=false
		wait(1)
		particulasRayos:Destroy()
		particulasElectro:Destroy()
	end)

end

function EffectsManager.BoneBullet(modelo,modeloTarget,retardo)
	local balaEffect = script.Parent.Effects.hueso:Clone()
	balaEffect.Parent=modelo.PrimaryPart
	balaEffect.hueso.CFrame=CFrame.new(modelo.PrimaryPart.Position,modeloTarget.PrimaryPart.Position)*CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
	balaEffect.Name="EfectoBalaHueso"
	

	
		local tweenInfo = TweenInfo.new(
			retardo,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out,
			0,
			false
		)

	local tweenGoal = {
		Position = modeloTarget.PrimaryPart.Position;
		}

		local tweenBala = TweenService:Create(balaEffect.hueso,tweenInfo,tweenGoal)
		tweenBala:Play()
		tweenBala.Completed:Wait()
		balaEffect:Destroy()

	
end

--Efecto que simula el estado de electrificado
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarImpactoBone(modelo)



	local modeloElectro = efectos.Electro:Clone()
	modeloElectro.Parent = modelo
	modeloElectro:SetPrimaryPartCFrame(CFrame.new(modelo.PrimaryPart.Position))
	modeloElectro.PrimaryPart.Size = Vector3.new(0,0,0)

	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		10,
		true
	)

	local tweenGoal = {
		Size = modelo.PrimaryPart.Size*4;
		CFrame = modeloElectro.bomba_electrica.pSphere.CFrame*CFrame.Angles(0,math.rad(120),0)
	}
	
	local tweenGoal1 = {
		Size = modelo.PrimaryPart.Size*2;
		CFrame = modeloElectro.bomba_electrica1.pSphere1.CFrame*CFrame.Angles(0,math.rad(-120),0)
	}

	local tweenElectro = TweenService:Create(modeloElectro.bomba_electrica.pSphere,tweenInfo,tweenGoal)
	local tweenElectro1 = TweenService:Create(modeloElectro.bomba_electrica1.pSphere1,tweenInfo,tweenGoal1)
	tweenElectro:Play()
	tweenElectro1:Play()
	tweenElectro.Completed:Connect(function()
		modeloElectro:Destroy()
	end)

end
--Efecto que simula el ser golpeado por una serie de tuercas
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarImpactoTuercas(modelo)

	local contador = 0

	while contador<5 do

		local particulasChispas = Instance.new("ParticleEmitter")
		particulasChispas.Name="EfectoChispasImpacto"
		particulasChispas.Parent=modelo.PrimaryPart
		particulasChispas.Color=ColorSequence.new(Color3.new(1, 0.666667, 0),Color3.new(1, 1, 0))
		particulasChispas.LightEmission=0
		particulasChispas.LightInfluence=1
		particulasChispas.Orientation = Enum.ParticleOrientation.FacingCamera
		particulasChispas.Size=NumberSequence.new(1)
		particulasChispas.Texture="rbxassetid://12410499374"
		particulasChispas.Lifetime=NumberRange.new(1)
		particulasChispas.Rate=300
		particulasChispas.Speed=NumberRange.new(10)
		particulasChispas.Shape=Enum.ParticleEmitterShape.Sphere
		particulasChispas.Drag=8

		local ImpactEmitter = Instance.new("ParticleEmitter")
		ImpactEmitter.Parent=modelo.PrimaryPart
		ImpactEmitter.Size = NumberSequence.new(3.5)
		ImpactEmitter.Squash = NumberSequence.new(0,1.31)
		ImpactEmitter.Texture = "rbxassetid://13334677749"
		local transparencySequence = {NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.35,0.09,0),NumberSequenceKeypoint.new(1,0.9,0)}
		ImpactEmitter.Transparency=NumberSequence.new(transparencySequence)
		ImpactEmitter.EmissionDirection = "Bottom"
		ImpactEmitter.Lifetime=NumberRange.new(0.5)
		ImpactEmitter.Rate=500
		ImpactEmitter.RotSpeed=NumberRange.new(50)
		ImpactEmitter.Speed=NumberRange.new(8)
		ImpactEmitter.Shape = Enum.ParticleEmitterShape.Sphere




		wait(0.1)
		particulasChispas.Enabled=false
		ImpactEmitter.Enabled=false
		wait(0.1)
		particulasChispas:Destroy()
		ImpactEmitter:Destroy()
		contador = contador +1
		wait(0.1)

	end



end
--Efecto que simula el ser hipnotizado, inspirado en los bloops de MK
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarEfectoHypno(player)

	local guiHypno = efectos.HypnoEffect:Clone()
	guiHypno.Parent = player.PlayerGui

	local billboard = efectos.SpiralBillboard:Clone()
	billboard.Name = "Billboardo"
	billboard.Parent = player.Character
	billboard.CFrame = player.Character.PrimaryPart.CFrame + Vector3.new(0,10,0)

	local weld = Instance.new("WeldConstraint")
	weld.Parent=player.Character
	weld.Part0=player.Character.PrimaryPart
	weld.Part1=billboard

	local tweenInfoAparecer = TweenInfo.new(
		5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false)
	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		4,
		false)
	local tweenHypnoAparecerEspiral = TweenService:Create(guiHypno.HypnoFrame.Spiral,tweenInfoAparecer,{ImageTransparency = 0})
	local tweenHypnoAparecerOjos = TweenService:Create(guiHypno.HypnoFrame.EyesBG,tweenInfoAparecer,{ImageTransparency = 0})
	local tweenbillboard = TweenService:Create(billboard.BillboardGui.ImageLabel,tweenInfo,{Rotation=180})

	spawn(function()
		tweenHypnoAparecerEspiral:Play()
		tweenHypnoAparecerOjos:Play()
		tweenbillboard:Play()
	end)
	wait(5)
	local tweenHypno = TweenService:Create(guiHypno.HypnoFrame.Spiral,tweenInfo,{Rotation = 180})
	
	spawn(function()
		tweenHypno:Play()
		tweenHypno.Completed:Wait()
		guiHypno:Destroy()
		billboard:Destroy()
	end)
end
--Efecto que genera un anillo psicodélico de hipnosis
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarAreaHypno(modelo)


	local exteriorWave = efectos.HypnoRing:Clone()
	exteriorWave.Parent = modelo
	exteriorWave.HypnoRing_exterior.Size = Vector3.new(1,1,1)
	exteriorWave.HypnoRing_exterior.Position = Vector3.new(modelo.PrimaryPart.CFrame.X,modelo.PrimaryPart.CFrame.Y +1,modelo.PrimaryPart.CFrame.Z)
	exteriorWave.HypnoRing_exterior.CanCollide = false
	exteriorWave.HypnoRing_exterior.CanTouch = false
	exteriorWave.HypnoRing_exterior.CanQuery = false
	exteriorWave.HypnoRing_exterior.Anchored = true
	exteriorWave.HypnoRing_exterior.Transparency = 0.2
	exteriorWave.HypnoRing_exterior.Massless=true
	
	local  vortex = Instance.new("Part")
	vortex.Parent=exteriorWave
	vortex.Name="EfectoVortex"
	vortex.Shape="Block"
	vortex.CFrame=exteriorWave.HypnoRing_exterior.CFrame
	vortex.CanCollide=false
	vortex.CanTouch=false
	vortex.CanQuery=false
	vortex.Anchored=true
	vortex.Transparency=1
	vortex.Size=Vector3.new(0,0,0)

	local vortexDecal = Instance.new("Decal")
	vortexDecal.Parent=vortex
	vortexDecal.Face="Top"
	vortexDecal.Texture="rbxassetid://6700005265"
	vortexDecal.Color3=Color3.new(0.666667, 0, 0.498039)
	
	
	for _,v in pairs(exteriorWave:GetChildren()) do
		if v:IsA("MeshPart")then 
			local WA = Instance.new("WeldConstraint") 
			WA.Parent = v
			WA.Part1 = v
			WA.Part0 = modelo.PrimaryPart
		end
	end

	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)
	
	local tweenInfoSpiral = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		10,
		false
	)

	local tweenGoal = {

		Size = Vector3.new(modelo.PrimaryPart.Size.x*20,modelo.PrimaryPart.Size.Y*4,modelo.PrimaryPart.Size.Z*20);
		

	}
	
	local tweenGoalSpeen = {
		CFrame = exteriorWave.HypnoRing_exterior.CFrame*CFrame.Angles(0,math.rad(120),0);
	}
	
	local tweenGoalVortex = {

		Size = Vector3.new(120,0,120);
		CFrame = exteriorWave.HypnoRing_exterior.CFrame*CFrame.Angles(0,math.rad(120),0);


	}
	

	local tweenGoalVortexDecal={
		
		Transparency = 0.8
	}






	local tweenVortex = TweenService:Create(vortex,tweenInfoSpiral,tweenGoalVortex)
	local tweenVortexDecal = TweenService:Create(vortexDecal,tweenInfoSpiral,tweenGoalVortexDecal)
	local tweenExterior = TweenService:Create(exteriorWave.HypnoRing_exterior,tweenInfo,tweenGoal)
	local tweenExteriorSpeen = TweenService:Create(exteriorWave.HypnoRing_exterior,tweenInfoSpiral,tweenGoalSpeen)
	
	tweenExterior:Play()
	tweenVortex:Play()
	tweenVortexDecal:Play()
	tweenVortex.Completed:Connect(function()
		tweenVortex:Play()
		tweenVortexDecal:Play()
	end)
	tweenExterior.Completed:Connect(function()
		tweenExteriorSpeen:Play()
	end)
	tweenExteriorSpeen.Completed:Connect(function()
		wait(5)
		exteriorWave:Destroy()
	end)


end
--Efecto que genera el impacto de un proyectil o ataque venenoso
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarImpactoSkorpio(modelo)
	
	local ImpactEmitter = Instance.new("ParticleEmitter")
	ImpactEmitter.Parent=modelo.PrimaryPart
	ImpactEmitter.Size = NumberSequence.new(3.5)
	ImpactEmitter.Squash = NumberSequence.new(0,1.31)
	ImpactEmitter.Texture = "rbxassetid://13334677749"
	local transparencySequence = {NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.35,0.09,0),NumberSequenceKeypoint.new(1,0.9,0)}
	ImpactEmitter.Transparency=NumberSequence.new(transparencySequence)
	ImpactEmitter.EmissionDirection = "Bottom"
	ImpactEmitter.Lifetime=NumberRange.new(0.5)
	ImpactEmitter.Rate=50
	ImpactEmitter.RotSpeed=NumberRange.new(50)
	ImpactEmitter.Speed=NumberRange.new(8)
	ImpactEmitter.Shape = Enum.ParticleEmitterShape.Sphere
	
	local SmokeEmitter = Instance.new("ParticleEmitter")
	SmokeEmitter.Parent=modelo.PrimaryPart
	SmokeEmitter.Color = ColorSequence.new(Color3.new(0, 0.333333, 0))
	SmokeEmitter.Size = NumberSequence.new(3.66)
	SmokeEmitter.Rate=500
	SmokeEmitter.Texture = "rbxassetid://12410505669"
	SmokeEmitter.Shape = Enum.ParticleEmitterShape.Sphere
	
	local emisor = Instance.new("ParticleEmitter")
	emisor.Parent=modelo.PrimaryPart
	emisor.Name="EfectoBurbujas"
	emisor.Texture= "rbxassetid://6603835352"
	emisor.Color=ColorSequence.new(Color3.new(0, 0.333333, 0))
	emisor.LightEmission=0
	emisor.Size=NumberSequence.new(0.5)
	emisor.Lifetime=NumberRange.new(1)
	emisor.Rate=30
	emisor.Speed=NumberRange.new(0.25)
	
	spawn(function()
		wait(0.5)
		SmokeEmitter:Destroy()
		ImpactEmitter:Destroy()
		wait(5)
		emisor:Destroy()
		
	end)
end
--Efecto que simula el ataque de un escorpión, siendo el proyectil la punta de la cola y el trail la cola en si
--@Params modelo = model = modelo al que se le mete el efecto
function EffectsManager.GenerarDisparoSkorpio(modelo,modeloTarget)
	local balaEffect = efectos.Boll:Clone()
	balaEffect.Parent=modelo.PrimaryPart
	balaEffect.CFrame=CFrame.lookAt(modelo.PrimaryPart.Position,modeloTarget.PrimaryPart.Position)
	balaEffect.Name="EfectoColaSkorpio"
	
	local colorCola = {ColorSequenceKeypoint.new(0,Color3.new(0.666667, 0, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(0.666667, 0.333333, 0)),ColorSequenceKeypoint.new(1,Color3.new(0.666667, 0, 0))}
	balaEffect.Trail.Color=ColorSequence.new(colorCola)
	balaEffect.Trail.Texture = "rbxassetid://12410517981"
	balaEffect.Trail.TextureMode="Static"
	balaEffect.Trail.Transparency = NumberSequence.new(0)
	balaEffect.Trail.Lifetime = 10
	
	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false
	)

	local tweenGoal = {
		CFrame = CFrame.new(modeloTarget.PrimaryPart.Position);
	}

	local tweenBala = TweenService:Create(balaEffect,tweenInfo,tweenGoal)
	tweenBala:Play()
	tweenBala.Completed:Wait()
	balaEffect:Destroy()
end

function EffectsManager.GenerarLlamaAzulPickup(modelo)
	
	local efectoPickupAzul = Instance.new("ParticleEmitter")
	local ColorSeq =ColorSequence.new ({ColorSequenceKeypoint.new(0,Color3.new(0, 0.333333, 1)),ColorSequenceKeypoint.new(0.5,Color3.new(0, 0, 1)),ColorSequenceKeypoint.new(1,Color3.new(0, 0, 0.498039))})
	efectoPickupAzul.Color=ColorSeq
	efectoPickupAzul.LightEmission=1
	efectoPickupAzul.LightInfluence=1
	efectoPickupAzul.Orientation=Enum.ParticleOrientation.VelocityParallel
	efectoPickupAzul.Size=NumberSequence.new(1)
	local SquashSeq = NumberSequence.new({NumberSequenceKeypoint.new(0,1.5), NumberSequenceKeypoint.new(0.1,0.15),NumberSequenceKeypoint.new(0.2,1.5),NumberSequenceKeypoint.new(0.3,0.15),NumberSequenceKeypoint.new(0.4,1.5),NumberSequenceKeypoint.new(0.5,0.15),NumberSequenceKeypoint.new(0.6,1.5),NumberSequenceKeypoint.new(0.7,0.15),NumberSequenceKeypoint.new(0.8,1.5),NumberSequenceKeypoint.new(0.9,0.15),NumberSequenceKeypoint.new(1,1.5)})
	efectoPickupAzul.Squash=SquashSeq
	efectoPickupAzul.Texture = "rbxassetid://13093128286"
	efectoPickupAzul.Lifetime = NumberRange.new(1)
	efectoPickupAzul.Rate = 100
	efectoPickupAzul.Rotation = NumberRange.new(90)
	efectoPickupAzul.Speed=NumberRange.new(10)
	efectoPickupAzul.Shape=Enum.ParticleEmitterShape.Sphere
	
	efectoPickupAzul.Parent=modelo.PrimaryPart
	
	spawn(function()
		wait(1)
		efectoPickupAzul.Enabled=false
		wait(1)
		efectoPickupAzul:Destroy()
	end)	
	
	
end

function EffectsManager.GenerarLlamaRojaPickup(modelo)

	local efectoPickupRojo = Instance.new("ParticleEmitter")
	local ColorSeq =ColorSequence.new ({ColorSequenceKeypoint.new(0,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.333333, 0)),ColorSequenceKeypoint.new(1,Color3.new(0.333333, 0, 0))})
	efectoPickupRojo.Color=ColorSeq
	efectoPickupRojo.LightEmission=1
	efectoPickupRojo.LightInfluence=1
	efectoPickupRojo.Orientation=Enum.ParticleOrientation.VelocityParallel
	efectoPickupRojo.Size=NumberSequence.new(1)
	local SquashSeq = NumberSequence.new({NumberSequenceKeypoint.new(0,1.5), NumberSequenceKeypoint.new(0.1,0.15),NumberSequenceKeypoint.new(0.2,1.5),NumberSequenceKeypoint.new(0.3,0.15),NumberSequenceKeypoint.new(0.4,1.5),NumberSequenceKeypoint.new(0.5,0.15),NumberSequenceKeypoint.new(0.6,1.5),NumberSequenceKeypoint.new(0.7,0.15),NumberSequenceKeypoint.new(0.8,1.5),NumberSequenceKeypoint.new(0.9,0.15),NumberSequenceKeypoint.new(1,1.5)})
	efectoPickupRojo.Squash=SquashSeq
	efectoPickupRojo.Texture = "rbxassetid://13093128286"
	efectoPickupRojo.Lifetime = NumberRange.new(1)
	efectoPickupRojo.Rate = 100
	efectoPickupRojo.Rotation = NumberRange.new(90)
	efectoPickupRojo.Speed=NumberRange.new(10)
	efectoPickupRojo.Shape=Enum.ParticleEmitterShape.Sphere

	efectoPickupRojo.Parent=modelo.PrimaryPart

	spawn(function()
		wait(1)
		efectoPickupRojo.Enabled=false
		wait(1)
		efectoPickupRojo:Destroy()
	end)	


end

function EffectsManager.JumpEffect(modelo)
	
	local efectoSalto = Instance.new("ParticleEmitter")
	efectoSalto.Parent=modelo.PrimaryPart
	efectoSalto.Size = NumberSequence.new(0.75)
	efectoSalto.Texture = "http://www.roblox.com/asset/?id=301956793"
	efectoSalto.EmissionDirection = "Bottom"
	efectoSalto.Lifetime=NumberRange.new(1)
	efectoSalto.Rate=80
	efectoSalto.Speed=NumberRange.new(10)
	efectoSalto.SpreadAngle=Vector2.new(20,20)
	efectoSalto.Acceleration=Vector3.new(0,10,0)
	
	spawn(function()
		wait(0.5)
		efectoSalto.Enabled=false
		wait(0.5)
		efectoSalto:Destroy()
	end)
	
end

function EffectsManager.FallEffect(modelo)

	local efectoCaer = Instance.new("ParticleEmitter")
	efectoCaer.Parent=modelo.PrimaryPart
	efectoCaer.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(1,1.75)})
	efectoCaer.Texture = "http://www.roblox.com/asset/?id=301956793"
	efectoCaer.EmissionDirection = "Top"
	efectoCaer.Lifetime=NumberRange.new(1)
	efectoCaer.Rate=80
	efectoCaer.Speed=NumberRange.new(10)
	efectoCaer.SpreadAngle=Vector2.new(180,180)
	efectoCaer.Shape=Enum.ParticleEmitterShape.Disc

	spawn(function()
		wait(0.5)
		efectoCaer.Enabled=false
		wait(0.5)
		efectoCaer:Destroy()
	end)

end

function EffectsManager.GenerarLlamaSmallPickup(modelo)

	local efectoPickup = Instance.new("ParticleEmitter")
	local ColorSeq =ColorSequence.new ({ColorSequenceKeypoint.new(0,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(0.5,Color3.new(1, 0.333333, 0)),ColorSequenceKeypoint.new(1,Color3.new(0.333333, 0, 0))})
	efectoPickup.Color=ColorSeq
	efectoPickup.LightEmission=1
	efectoPickup.LightInfluence=1
	efectoPickup.Orientation=Enum.ParticleOrientation.VelocityParallel
	efectoPickup.Size=NumberSequence.new(0.5)
	local SquashSeq = NumberSequence.new({NumberSequenceKeypoint.new(0,1.5), NumberSequenceKeypoint.new(0.1,0.15),NumberSequenceKeypoint.new(0.2,1.5),NumberSequenceKeypoint.new(0.3,0.15),NumberSequenceKeypoint.new(0.4,1.5),NumberSequenceKeypoint.new(0.5,0.15),NumberSequenceKeypoint.new(0.6,1.5),NumberSequenceKeypoint.new(0.7,0.15),NumberSequenceKeypoint.new(0.8,1.5),NumberSequenceKeypoint.new(0.9,0.15),NumberSequenceKeypoint.new(1,1.5)})
	efectoPickup.Squash=SquashSeq
	efectoPickup.Texture = "rbxassetid://13093128286"
	efectoPickup.Lifetime = NumberRange.new(1)
	efectoPickup.Rate = 80
	efectoPickup.Rotation = NumberRange.new(90)
	efectoPickup.Speed=NumberRange.new(10)
	efectoPickup.Shape=Enum.ParticleEmitterShape.Sphere

	efectoPickup.Parent=modelo.PrimaryPart

	spawn(function()
		wait(0.5)
		efectoPickup.Enabled=false
		wait(0.3)
		efectoPickup:Destroy()
	end)	


end

--Efecto que simula salpicaduras en el agua con una textura nuestra.
--@Params model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
function EffectsManager.EfectoSalpicaduraNuestro(modelo)
		local emisor = Instance.new("ParticleEmitter")
		emisor.Parent=modelo.PrimaryPart
		emisor.Name="EfectoSalpicaduraAgua"
		emisor.Texture= "http://www.roblox.com/asset/?id=301956793"
		emisor.Color=ColorSequence.new(Color3.new(0.0313725, 0.709804, 1),Color3.new(0, 0.384314, 1))
		emisor.LightEmission=0
	emisor.Size=NumberSequence.new(0.25)
	emisor.Squash=NumberSequence.new(-1.5,-3)
	emisor.Orientation= Enum.ParticleOrientation.VelocityParallel
		emisor.Acceleration=Vector3.new(0,-25,0)
		emisor.SpreadAngle=Vector2.new(40,40)
		emisor.Lifetime=NumberRange.new(0.4)
		emisor.Rate=80
		emisor.Speed=NumberRange.new(35)
		emisor.VelocitySpread=7
	emisor.Drag=5
	spawn(function()
		wait(0.5)
		emisor.Enabled=false
		wait(0.3)
		emisor:Destroy()
	end)
end

function EffectsManager.EfectoConfeti(modelo)
	
	local efectoConfeti = Instance.new("ParticleEmitter")
	efectoConfeti.Parent=modelo.PrimaryPart
	local ColorSeq =ColorSequence.new ({ColorSequenceKeypoint.new(0,Color3.new(0.666667, 0.333333, 1)),ColorSequenceKeypoint.new(0.15,Color3.new(0.333333, 0, 0.498039)),ColorSequenceKeypoint.new(0.35,Color3.new(0, 0.333333, 1)),ColorSequenceKeypoint.new(0.55,Color3.new(0, 0.666667, 0)),ColorSequenceKeypoint.new(0.75,Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(0.9,Color3.new(1, 0.666667, 0)),ColorSequenceKeypoint.new(1,Color3.new(1, 0, 0))})
	efectoConfeti.Color=ColorSeq
	efectoConfeti.Texture="rbxassetid://13521303755"
	efectoConfeti.Lifetime=NumberRange.new(0.6)
	efectoConfeti.Rate=180
	efectoConfeti.Speed=NumberRange.new(10)
	efectoConfeti.Shape=Enum.ParticleEmitterShape.Sphere
	efectoConfeti.Drag=1

	

	spawn(function()
		wait(0.5)
		efectoConfeti.Enabled=false
		wait(0.3)
		efectoConfeti:Destroy()
	end)	
	
end

function EffectsManager.LimpiarEfectos(modelo)
	local partePrincipal = modelo.PrimaryPart
	for _,child in pairs(partePrincipal:GetChildren()) do
		if(string.find(child.Name,"Efecto")) then
			child:Destroy()
		end
	end
end

function EffectsManager.LimpiarEfectosWorkspace()
	local partePrincipal = workspace
	for _,child in pairs(partePrincipal:GetChildren()) do
		if(string.find(child.Name,"Efecto")) then
			child:Destroy()
		end
	end
end

--TODO: Añadir mas efectos, Tantear tambien los efectos con attachments para direccionar partículas como aqui : https://www.youtube.com/watch?v=-SKNCFqqvT4
--TODO: Echar un ojo a esto a futuro: https://www.youtube.com/watch?v=r9pa_n6r6Kc

return EffectsManager