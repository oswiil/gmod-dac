local STATE = {}
STATE.Name = "hidingtime"
STATE.Active = false
STATE.PreviousSeeker = nil

STATE.Countdown = HS.Countdown.New("HS.HidingTime.Countdown", function()
	HS.StateManager.ChangeState("inround", STATE.PreviousSeeker) -- PreviousSeeker here is the original seeker
end)

function STATE:BeginState()
	HS.ChatPrintAll(Color(255, 255, 255), "The round is now starting")

	-- Cleanup the map
	game.CleanUpMap()

	-- Increment the round count
	HS.Globals.RoundCount = HS.Globals.RoundCount + 1

	-- Make everyone a hider for simplicity
	for _,ply in ipairs(HS.TeamManager.GetActivePlayers()) do
		ply:MakeHider()
	end

	-- Pick a seeker and change their team
	local seeker = self:SetupSeeker(HS.TeamManager.GetActivePlayers())
	HS.ChatPrintPlayer(seeker, Color(255,255,255), "You have been made a ", Color(231,76,60), "seeker", Color(255,255,255), "!")

	-- No movement for seekers during hiding time
	hook.Add("Move", "HS.HidingTime.RestrictMovement", function(ply, mv)
		if ply:Team() == HS.TeamManager.TEAM_SEEKING then return true end
	end)

	-- Spawn everyone
	for _,ply in ipairs(HS.TeamManager.GetHidingPlayers()) do
		ply:Spawn()
	end

	-- Start the countdown
	self.Countdown:Start(HS.Config.HidingTime:GetInt())
end

function STATE:EndState()
	for _,ply in ipairs(HS.TeamManager.GetSeekingPlayers()) do
		ply:GodDisable()
		ply:AllowFlashlight(true)
	end

	hook.Remove("Move", "HS.HidingTime.RestrictMovement")
	
	self.Countdown:Stop()
end

function STATE:NewPlayerSync(ply)
	self.Countdown:ClientSync(ply)
end

function STATE:PickRandomSeeker(playerPool)
	-- Create a list of candidate players - not including the person
	-- picked last time.
	local candidates = {}

	for _, ply in ipairs(playerPool) do
		if self.PreviousSeeker ~= ply then
			table.insert(candidates, ply)
		end
	end

	if #candidates == 0 then
		error("Not enough candidates for seeker")
	end

	local chosenIndex = math.random(#candidates)
	return candidates[chosenIndex]
end

function STATE:PickNewSeeker(playerPool)
	local selectionType = HS.Config.SeekerSelectType:GetString()

	if selectionType == "random" then
		return self:PickRandomSeeker(playerPool)
	end

	error("Seeker selection type is invalid")
end

function STATE:SetupSeeker(playerPool)
	-- Select a seeker, set their team
	local seeker = self:PickNewSeeker(playerPool)
	self.PreviousSeeker = seeker
	seeker:MakeSeeker()
	seeker:GodEnable()
	seeker:AllowFlashlight(false)
	seeker:Spawn()

	return seeker
end

function STATE:PlayerInitialSpawn(ply)
	-- Change player to hiding team
	ply:MakeHider()
	ply:Spawn()
end

function STATE:PlayerDisconnected(ply)
	-- Not enough players to continue
	if HS.TeamManager.NumActiveExcluding(ply) < HS.Config.MinPlayers:GetInt() then
		HS.StateManager.ChangeState("postround", "draw")
	elseif ply:Team() == HS.TeamManager.TEAM_SEEKING then
		local seeker = self:SetupSeeker(HS.TeamManager.GetHidingPlayers())

		HS.ChatPrintPlayer(seeker, 
			Color(255,255,255), "You have been made a ",
			Color(231,76,60), "seeker",
			Color(255,255,255), " because the previous seeker disconnected!"
		)
	end
end

HS.StateManager.RegisterState(STATE)
