-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Esto coloca el moduleScript en su sitio
local managerScript = script.Parent.EffectsManager:Clone()
managerScript.Parent=ReplicatedStorage
local effectsFolder = script.Parent.Effects:Clone()
effectsFolder.Parent=ReplicatedStorage