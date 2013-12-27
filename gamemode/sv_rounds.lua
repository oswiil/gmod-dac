local RoundManager = {}
RoundManager.StartTime = nil
RoundManager.EndTime = nil
RoundManager.LastRoundSeeker = nil

RoundManager.END_NO_PLAYERS = 1
RoundManager.END_TIME = 2
RoundManager.END_ALL_FOUND = 3
RoundManager.END_NO_SEEKERS = 4

RoundManager.STATE_IN_ROUND = 1
RoundManager.STATE_POST_ROUND = 2
RoundManager.STATE_MAP_VOTE = 3
RoundManager.STATE_PRE_GAME = 4

RoundManager.Handlers = {}

RoundManager.Handlers[END_NO_PLAYERS] = function()
	HS.Log("Round End: Not enough players")
end

RoundManager.Handlers[END_TIME] = function()
	HS.Log("Round End: Time limit exceeded")
end

RoundManager.Handlers[END_ALL_FOUND] = function()
	HS.Log("Round End: All hiders found")
end

RoundManager.Handlers[END_NO_SEEKERS] = function()
	HS.Log("Round End: No seekers left")
end

function RoundManager.EndRound(reason)
	hook.Call("HS.RoundEnd", nil, reason)

	local handler = RoundManager.Handlers[reason]
	if not handler then
		error(string.format("Round end handler not specified for reason %d", reason))
	end

	handler()
	RoundManager.RoundActive = false
end

function RoundManager.ShouldEndRound()
	if not RoundManager.RoundActive then return false end

	-- If there's only 1 person left playing on the server, end the round
	if HS.TeamManager.NumPlaying() <= 1 then
		return true, END_NO_PLAYERS
	end

	-- If there are no hiders left, end the round
	if HS.TeamManager.NumHiding() == 0 then
		return true, END_ALL_FOUND
	end

	-- If there are no seekers left, end the round
	if HS.TeamManager.NumSeeking() == 0 then
		return true, END_NO_SEEKERS
	end

	return false
end

function RoundManager.ShouldStartRound()
	if RoundManager.RoundActive then return false end

	return true
end

function RoundManager.TimeExpired()
	if not RoundManager.RoundActive then return end
	RoundManager.EndRound(RoundManager.END_TIME)
end

function RoundManager.PickRandomSeeker()
	-- Create a list of candidate players - not including the person
	-- picked last time.
	local candidates = {}

	for _, ply in pairs(player.GetAll()) do
		if not ply:IsSpectator() 
		   and RoundManager.LastRoundSeeker ~= ply and 
			table.insert(candidates, ply)
		end
	end

	local chosenIndex = math.random(#candidates)
	return candidates[chosenIndex]
end

function RoundManager.PickNewSeeker()
	local selectionType = HS.Config.SeekerSelectType:GetString()

	if selectionType == "random" then
		return RoundManager.PickRandomSeeker()
	end

	error("Seeker selection type is invalid")
end

function RoundManager.StartRound()
	local seeker = RoundManager.PickNewSeeker()
	HS.Log("The new seeker is " .. tostring(seeker))
	RoundManager.LastRoundSeeker = seeker
	game.CleanUpMap(false)

	timer.Create("HS.RoundTimer", HS.Config.RoundTime:GetInt(), 1, RoundManager.TimeExpired)
end

HS.RoundManager = RoundManager

-- Disconnect

-- Fully connect
hook.Add("PlayerInitialSpawn", "HS.CheckRoundStart", function(ply)
	
end)