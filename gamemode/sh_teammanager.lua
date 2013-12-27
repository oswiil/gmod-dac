local TeamManager = {}
TeamManager.TEAM_HIDING = 1
TeamManager.TEAM_SEEKING = 2
TeamManager.TEAM_SPECTATOR = 3
TeamManager.TEAM_WAITING = 4

team.SetUp(TeamManager.TEAM_HIDING, "Hiding", Color(60, 128, 255))
team.SetUp(TeamManager.TEAM_SEEKING, "Seeking", Color(220, 80, 80))
team.SetUp(TeamManager.TEAM_SPECTATOR, "Spectating", Color(80, 155, 80))
team.SetUp(TeamManager.TEAM_WAITING, "Waiting", Color(39, 174, 96))

function TeamManager.NumSeeking()
	return team.NumPlayers(TeamManager.TEAM_SEEKING)
end

function TeamManager.NumHiding()
	return team.NumPlayers(TeamManager.TEAM_HIDING)
end

function TeamManager.NumWaiting()
	return team.NumPlayers(TeamManager.TEAM_WAITING)
end

function TeamManager.NumSpectators()
	return team.NumPlayers(TeamManager.TEAM_SPECTATOR)
end

function TeamManager.NumPlaying()
	return TeamManager.NumHiding() + TeamManager.NumSeeking()
end

local function CountPlayersExcluding(playerTable, excludePlayer)
	local count = 0

	for _,ply in ipairs(playerTable) do
		if ply ~= excludePlayer then
			count = count + 1
		end
	end

	return count
end

TeamManager.CountPlayersExcluding = CountPlayersExcluding

function TeamManager.NumActive()
	return TeamManager.NumHiding() + TeamManager.NumSeeking() + TeamManager.NumWaiting()
end

function TeamManager.NumActiveExcluding(ply)
	return CountPlayersExcluding(TeamManager.GetWaitingPlayers(), ply)
	       + CountPlayersExcluding(TeamManager.GetHidingPlayers(), ply)
	       + CountPlayersExcluding(TeamManager.GetSeekingPlayers(), ply)
end

function TeamManager.GetWaitingPlayers()
	return team.GetPlayers(TeamManager.TEAM_WAITING)
end

function TeamManager.GetHidingPlayers()
	return team.GetPlayers(TeamManager.TEAM_HIDING)
end

function TeamManager.GetSeekingPlayers()
	return team.GetPlayers(TeamManager.TEAM_SEEKING)
end

function TeamManager.GetActivePlayers()
	local activePlayers = {}

	for _,ply in ipairs(player.GetAll()) do
		if ply:Team() == TeamManager.TEAM_SEEKING
		   or ply:Team() == TeamManager.TEAM_HIDING
		   or ply:Team() == TeamManager.TEAM_WAITING
		then
			table.insert(activePlayers, ply)
		end
	end

	return activePlayers
end

HS.TeamManager = TeamManager
