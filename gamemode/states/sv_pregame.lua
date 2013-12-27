local STATE = {}
STATE.Name = "pregame"
STATE.Active = false

function STATE:BeginState()
	-- Move all players to waiting team and spawn them
	for _,ply in ipairs(HS.TeamManager.GetActivePlayers()) do
		self:SetupPlayer(ply)
	end

	-- Are we ready to go again?
	self:PlayerCountCheck()
end

function STATE:EndState()
	-- Reset everyone's kills/deaths
	for _,ply in ipairs(player.GetAll()) do
		ply:SetFrags(0)
		ply:SetDeaths(0)
	end
	
	self.Countdown:Stop()
end

function STATE:NewPlayerSync(ply)
	self.Countdown:ClientSync(ply)
end

function STATE:SetupPlayer(ply)
	ply:MakeWaiting()
	ply:Spawn()
end

STATE.Countdown = HS.Countdown.New("HS.PreGame.Countdown", function()
	HS.StateManager.ChangeState("hidingtime")
end)

function STATE:PlayerCountCheck()
	-- If we now have enough players, wait PreGameTime seconds then start the round
	if (not self.Countdown:IsActive()) and HS.TeamManager.NumActive() >= HS.Config.MinPlayers:GetInt() then
		HS.Log("Player requirement met - starting countdown")

		self.Countdown:Start(HS.Config.PreGameTime:GetInt())

		HS.ChatPrintAll(
			Color(255,255,255), "The game will start in ",
			Color(231,76,60), HS.Config.PreGameTime:GetInt(),
			Color(255,255,255), " seconds"
		)
	end
end

function STATE:PlayerInitialSpawn(ply)
	self:SetupPlayer(ply)
	self:PlayerCountCheck()
end

function STATE:PlayerDisconnected(ply)
	-- If someone disconnects while the countdown is active, and there are no
	-- longer enough players, stop the countdown.
	-- (Take 1 from player count since the count will include the player that's disconnected)
	
	if self.Countdown:IsActive() and HS.TeamManager.NumActiveExcluding(ply) < HS.Config.MinPlayers:GetInt() then
		HS.Log("Player disconnected during countdown - not enough players to continue.")
		HS.ChatPrintAll(
			Color(255,255,255), "There are not enough players to start the game (",
			Color(231,76,60), HS.Config.MinPlayers:GetInt(),
			Color(255,255,255), " required)"
		)
		self.Countdown:Stop()
	end
end

cvars.AddChangeCallback(HS.Config.MinPlayers:GetName(), function()
	if STATE.Active then
		STATE:PlayerCountCheck()
	end
end)

HS.StateManager.RegisterState(STATE)
