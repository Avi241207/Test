-- @ScriptType: Script
function onChange()
script.Parent.Mesh.Scale = script.Parent.Size * 1.4
end
script.Parent.Changed:connect(onChange)