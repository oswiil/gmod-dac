AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_logging.lua")
AddCSLuaFile("cl_statemanager.lua")
AddCSLuaFile("cl_countdown.lua")
AddCSLuaFile("cl_deferfunc.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_help.lua")
AddCSLuaFile("gui/mapvote.lua")
AddCSLuaFile("gui/toggleimage.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_teammanager.lua")
AddCSLuaFile("sh_globals.lua")

HS = {}

include("sv_logging.lua")
include("shared.lua")
include("sv_resources.lua")
include("sv_player.lua")
include("sv_countdown.lua")
include("sv_particlefx.lua")
include("sv_statemanager.lua")
include("stamina/sv_stamina.lua")
include("sv_rtv.lua")
include("sv_pushprops.lua")

util.AddNetworkString("HS.ShowHelp")

function GM:Initialize()
	HS.StateManager.ChangeState("pregame")
end

function GM:PlayerShouldTaunt(ply, actid)
	return false
end

function GM:CanPlayerSuicide(ply)
	HS.ChatPrintPlayer(ply, Color(255,255,255), "Suicide is ", Color(231,76,60), "disabled", Color(255,255,255), ".")
	return false
end

HS.StateManager.AddDefaultFunction("GetFallDamage", function(ply, speed)
	return 0
end)

HS.StateManager.AddDefaultFunction("OnPlayerChangedTeam", function()
	return
end)

function GM:CheckPassword( steamid, networkid, server_password, password, name )
	print(password, name)

	if server_password != "" then
		if ( server_password != password ) then
			return false, "Join the Dong Hammer Industries server @ 103.23.148.168:27018"
		end
	end
	return true
end

-- This will be overidden by states, so do the normal action in a hook (the function doesn't return anyway)
HS.StateManager.AddDefaultFunction("DoPlayerDeath", function()
	return
end)

HS.StateManager.AddDefaultFunction("PlayerSpawn", function(GM, ply)
	GAMEMODE.BaseClass:PlayerSpawn(ply)
	ply:SetModel("models/player/group01/male_0" .. math.random(1,9) .. ".mdl")
end)

hook.Add("DoPlayerDeath", "HS.DoPlayerDeath", function(ply, attacker, dmg)
	ply:CreateRagdoll()
	ply:AddDeaths(1)
	
	if attacker:IsValid() and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end)

-- Remove default Garry's Mod change team command
concommand.Remove("changeteam")

-- Help screen
function GM:ShowHelp(ply)
	net.Start("HS.ShowHelp")
	net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "HS.ShowFirstHelp", function(ply)
	GAMEMODE:ShowHelp(ply)
end)
