require("cvar3")
local oldCreateCvar = CreateConVar
local replicatedVars = {}

function CreateConVar(name, value, flags, help)
	local cvar = oldCreateCvar(name, value, flags, help)

	if type(flags) == "table" then
		if table.HasValue(flags, FCVAR_REPLICATED) then
			table.insert(replicatedVars, cvar)
		end
	elseif type(flags) == "number" then
		if bit.band(flags, FCVAR_REPLICATED) > 0 then
			table.insert(replicatedVars, cvar)
		end
	end
	
	return cvar
end

hook.Add("PlayerAuthed", "HS.Config.ReplicateConvars", function(ply, steamid, unique)
	for _,cvar in pairs(replicatedVars) do
		ply:ReplicateData(cvar:GetName(), cvar:GetString())
	end
end)

RunConsoleCommand("sv_alltalk", 1)

include("sv_maplist.lua")
