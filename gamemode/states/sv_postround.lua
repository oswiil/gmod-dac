local STATE = {}
STATE.Name = "postround"
STATE.Active = false

function STATE:HandleDraw()
	HS.ChatPrintAll(
		Color(255,255,255), "The round was a ",
		Color(231,76,60), "DRAW",
		Color(255,255,255), "! Everyone's a loser!"
	)
end

function STATE:HandleHidersLose(originalSeeker)
	HS.ChatPrintAll(
		Color(255,255,255), "========= ",
		Color(231,76,60), "HIDERS LOSE",
		Color(255,255,255), " ========="
	)

	for _,ply in ipairs(HS.TeamManager.GetSeekingPlayers()) do
		if ply == originalSeeker then
			ply:AddFrags(2)
			ply:AttachEffect("superrare_confetti_green")
		else
			ply:AttachEffect("unusual_storm")
		end
	end
end

function STATE:HandleHidersWin()
	HS.ChatPrintAll(
		Color(255,255,255), "========= ",
		Color(41,128,185), "HIDERS WIN",
		Color(255,255,255), " ========="
	)

	for _,ply in ipairs(HS.TeamManager.GetHidingPlayers()) do
		ply:AddFrags(2)
		ply:AttachEffect("superrare_confetti_green")
	end

	for _,ply in ipairs(HS.TeamManager.GetSeekingPlayers()) do
		ply:AttachEffect("unusual_storm")
	end
end

function STATE:BeginState(endType, originalSeeker)
	if endType == "draw" then
		self:HandleDraw()
	elseif endType == "hiderswin" then
		self:HandleHidersWin()
	elseif endType == "hiderslose" then
		self:HandleHidersLose(originalSeeker)
	end

	-- Set everyone's stamina to max
	for _,ply in ipairs(HS.TeamManager.GetActivePlayers()) do
		ply:SetStamina(ply:GetMaxStamina())
		ply:SyncStamina()
	end

	self.Countdown:Start(HS.Config.PostRoundTime:GetInt())
end

function STATE:EndState()
	self.Countdown:Stop()

	for _,ply in ipairs(player.GetAll()) do
		ply:StopParticles()
	end
end

function STATE:NewPlayerSync(ply)
	self.Countdown:ClientSync(ply)
end

function STATE:PlayerInitialSpawn(ply)
	ply:MakeWaiting()
	ply:Spectate(OBS_MODE_ROAMING)
end

-- Copy the death funcs from inround
STATE.DoPlayerDeath = HS.StateManager.States["inround"].DoPlayerDeath
STATE.PlayerDeathThink = HS.StateManager.States["inround"].PlayerDeathThink

STATE.Countdown = HS.Countdown.New("HS.PostRound.Countdown", function()
	-- First let's check if we've reached the round limit
	if HS.Globals.RoundCount >= HS.Config.RoundLimit:GetInt() then
		HS.Log("[PostRound] Round limit reached, starting map vote")
		HS.StateManager.ChangeState("mapvote")
		return
	end

	if HS.TeamManager.NumActive() < HS.Config.MinPlayers:GetInt() then
		HS.Log("Not enough players to start new round")

		HS.ChatPrintAll(
			Color(255,255,255), "There are not enough players to start the next round (",
			Color(231,76,60), HS.Config.MinPlayers:GetInt(),
			Color(255,255,255), " required)"
		)

		HS.StateManager.ChangeState("pregame")
		return
	end

	HS.StateManager.ChangeState("hidingtime")
end)

HS.StateManager.RegisterState(STATE)
