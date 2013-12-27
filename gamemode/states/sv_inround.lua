local STATE = {}
STATE.Name = "inround"
STATE.Active = false
STATE.OriginalSeeker = nil

function STATE:BeginState(originalSeeker)
	self.OriginalSeeker = originalSeeker

	HS.ChatPrintAll( 
		Color(255,255,255), "The ",
		Color(231,76,60), "seeker",
		Color(255,255,255), " has been released!"
	)

	-- If a player is dead because they didn't respawn in the hiding time,
	-- then run through the normal death stuff.
	for _,ply in ipairs(HS.TeamManager.GetActivePlayers()) do
		if not ply:Alive() then
			self:DoPlayerDeath(ply)
		end
	end

	self.Countdown:Start(HS.Config.RoundTime:GetInt())
end

function STATE:EndState()
	self.Countdown:Stop()
end

function STATE:NewPlayerSync(ply)
	self.Countdown:ClientSync(ply)
end

function STATE:PlayerInitialSpawn(ply)
	ply:MakeWaiting()
	ply:Spawn() -- That'll make them a spectator
end

local COUNT_OK = 1
local COUNT_NO_SEEKERS = 2
local COUNT_NO_HIDERS = 3

function STATE:PlayerCountCheck(excludePly)
	-- Check we've still got a seeker
	local seekerCount = HS.TeamManager.CountPlayersExcluding(HS.TeamManager.GetSeekingPlayers(), excludePly)
	if seekerCount < 1 then
		return COUNT_NO_SEEKERS
	end

	-- Check we've still got a hider
	local hiderCount = HS.TeamManager.CountPlayersExcluding(HS.TeamManager.GetHidingPlayers(), excludePly)
	if hiderCount < 1 then
		return COUNT_NO_HIDERS
	end

	-- Otherwise we're OK!
	return COUNT_OK
end

function STATE:HandleCaught(seeker, hider)
	seeker:AddFrags(1)
	hider:MakeSeeker()
	hider:EmitSound("hideseek/local_exo_target_hit.wav", 100, 100)

	-- Spawn confetti effect
	hider:SpawnConfetti()
	
	-- Check to see if this lost the game
	local checkResult = self:PlayerCountCheck()
	if checkResult == COUNT_NO_HIDERS then
		HS.StateManager.ChangeState("postround", "hiderslose", self.OriginalSeeker)
	elseif checkResult == COUNT_NO_SEEKERS then
		error("Something has gone terribly wrong - there were no seekers")
	end
end

function STATE:DoPlayerDeath(ply)
	HS.ChatPrintPlayer(ply, 
		Color(255,255,255), "You will respawn at the start of the next round."
	)
	ply:MakeWaiting()

	local countCheck = self:PlayerCountCheck()

	if countCheck == COUNT_NO_SEEKERS then
		HS.StateManager.ChangeState("postround", "hiderswin", self.OriginalSeeker)
	elseif countCheck == COUNT_NO_HIDERS then
		HS.StateManager.ChangeState("postround", "hiderslose", self.OriginalSeeker)
	end
end

function STATE:PlayerDeathThink(ply)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return end
	ply:Spawn() -- This will call PlayerSpawn and they will be made a spectator
end

function STATE:PlayerDisconnected(ply)
	local result = self:PlayerCountCheck(ply)
	if result > COUNT_OK then
		HS.StateManager.ChangeState("postround", "draw")
	end
end

function STATE:PlayerSpawn(ply)
	if ply:Team() == HS.TeamManager.TEAM_WAITING then
		ply:Spectate(OBS_MODE_ROAMING)
		return
	end
	
	HS.StateManager.CallDefaultFunction("PlayerSpawn", ply)
end

STATE.Countdown = HS.Countdown.New("HS.InRound.Countdown", function()
	-- If the countdown ends, the hiders have won
	HS.StateManager.ChangeState("postround", "hiderswin", STATE.OriginalSeeker)
end)

HS.StateManager.RegisterState(STATE)
