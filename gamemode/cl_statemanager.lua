local StateManager = {}

local States = {}
local CurrentState = nil

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
	newState.Active = true
	CurrentState = newState
end

function StateManager.CurrentState()
	return CurrentState
end

function StateManager.CallFunction(name, ...)
	if CurrentState and CurrentState[name] then
		return CurrentState[name](CurrentState, ...)
	else
		return GAMEMODE.BaseClass[name](GAMEMODE.BaseClass, ...)
	end
end

net.Receive("HS.StateManager.SetClientState", function()
	local stateName = net.ReadString()

	local numArgs = net.ReadUInt(8)
	local args = {}
	for i=1,numArgs do
		table.insert(args, net.ReadType(net.ReadUInt(8)))
	end
	HS.OnInitPostEntity(StateManager.ChangeState, stateName, unpack(args))
end)

HS.StateManager = StateManager

include("states/cl_pregame.lua")
include("states/cl_hidingtime.lua")
include("states/cl_inround.lua")
include("states/cl_postround.lua")
include("states/cl_mapvote.lua")
