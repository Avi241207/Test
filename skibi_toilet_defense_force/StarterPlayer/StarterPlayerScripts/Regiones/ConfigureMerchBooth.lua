-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MerchBooth = require(ReplicatedStorage:WaitForChild("MerchBooth"))

local myParticleEmitter = Instance.new("ParticleEmitter")
myParticleEmitter.SpreadAngle = Vector2.new(22, 22)
myParticleEmitter.Lifetime = NumberRange.new(0.5, 1.5)
myParticleEmitter.Shape = Enum.ParticleEmitterShape.Sphere
myParticleEmitter.Transparency = NumberSequence.new(0, 1)
myParticleEmitter.RotSpeed = NumberRange.new(200, 200)

MerchBooth.configure({
	particleEmitterTemplate = myParticleEmitter
})