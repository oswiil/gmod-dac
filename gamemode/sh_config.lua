local Config = {}

if SERVER then
	include("sv_config.lua")
end

local convarFlags = {FCVAR_NOTIFY, FCVAR_REPLICATED}

Config.RoundTime        = CreateConVar("hs_roundtime", "180", convarFlags) -- Time for the seekers to find the hiders
Config.PreGameTime      = CreateConVar("hs_pregametime", "10", convarFlags) -- Time to wait after the map changes until starting the game
Config.HidingTime       = CreateConVar("hs_hidingtime", "30", convarFlags) -- Time at the start of the round that seekers are blinded
Config.PostRoundTime    = CreateConVar("hs_postroundtime", "10", convarFlags) -- Time at the end of the round to wait until starting the next one
Config.MinPlayers       = CreateConVar("hs_minplayers", "2", convarFlags) -- Minimum number of active players to start a round
Config.RoundLimit       = CreateConVar("hs_roundlimit", "12", convarFlags) -- Maximum number of rounds before changing map
Config.SeekerSelectType = CreateConVar("hs_seekerselect", "random", convarFlags)
Config.MapVoteTime      = CreateConVar("hs_mapvotetime", "15", convarFlags) -- Time for people to vote for the next map

HS.Config = Config
