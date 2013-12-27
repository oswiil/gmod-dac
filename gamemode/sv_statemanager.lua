local StateManager = {}

local States = {}
StateManager.States = States
local CurrentState = nil
local DefaultGMFunctions = {}

util.AddNetworkString("HS.StateManager.SetClientState")

function StateManager.RegisterState(state)
	States[state.Name] = state
	HS.Log("[State] State %q registered", state.Name)
end

function StateManager.ChangeState(newStateName, ...)
	local newState = States[newStateName]
	if not newState then
		error(string.format("Cannot change to state %q: state does not exist", newStateName))
	end

	if CurrentState then
		HS.Log("[State] Ending state %q", CurrentState.Name)
		CurrentState:EndState()
		CurrentState.Active = false
	end

	HS.Log("[State] Starting state %q", newState.Name)

	newState:BeginState(...)

	for _,ply in ipairs(player.GetAll()) do
		StateManager.SetClientState(ply, newState, ...)
	end
	
	newState.Active = true
	CurrentState = newState
end

function StateManager.CurrentState()
	return CurrentState
end

function StateManager.SetClientState(ply, state, ...)
	local args = {...}
	net.Start("HS.StateManager.SetClientState")
		net.WriteString(state.Name)
		net.WriteUInt(#args, 8)
		for _,v in ipairs(args) do
			net.WriteType(v)
		end
	net.Send(ply)

	state:NewPlayerSync(ply)
end

function StateManager.CallFunction(name, ...)
	if CurrentState and CurrentState[name] then
		return CurrentState[name](CurrentState, ...)
	elseif DefaultGMFunctions[name] then
		return DefaultGMFunctions[name](GAMEMODE, ...)
	else
		return GAMEMODE.BaseClass[name](GAMEMODE.BaseClass, ...)
	end
end

function StateManager.CallDefaultFunction(name, ...)
	if DefaultGMFunctions[name] then
		return DefaultGMFunctions[name](GAMEMODE, ...)
	else
		return GAMEMODE.BaseClass[name](GAMEMODE.BaseClass, ...)
	end
end

function StateManager.AddDefaultFunction(name, func)
	DefaultGMFunctions[name] = func
end

function StateManager.RegisterGMHook(name)
	GM[name] = function(self, ...)
		return StateManager.CallFunction(name, ...)
	end
end

StateManager.RegisterGMHook("PlayerDeathThink")
StateManager.RegisterGMHook("PlayerSpawn")
StateManager.RegisterGMHook("PlayerDisconnected")
StateManager.RegisterGMHook("GetFallDamage")
StateManager.RegisterGMHook("DoPlayerDeath")
StateManager.RegisterGMHook("OnPlayerChangedTeam")

function GM:PlayerInitialSpawn(ply)
	if CurrentState then
		StateManager.SetClientState(ply, CurrentState)
	end

	return StateManager.CallFunction("PlayerInitialSpawn", ply)
end

HS.StateManager = StateManager

AddCSLuaFile("states/cl_pregame.lua")
include("states/sv_pregame.lua")

AddCSLuaFile("states/cl_hidingtime.lua")
include("states/sv_hidingtime.lua")

AddCSLuaFile("states/cl_inround.lua")
include("states/sv_inround.lua")

AddCSLuaFile("states/cl_postround.lua")
include("states/sv_postround.lua")

AddCSLuaFile("states/cl_mapvote.lua")
include("states/sv_mapvote.lua")
