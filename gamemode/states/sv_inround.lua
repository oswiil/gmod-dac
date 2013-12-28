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

function STATE:GetFallDamage(ply, spd)
	local time = math.Round(spd / 666, 1)
	local jmp = ply:GetJumpPower()
	if spd >= 600 then
		ply:EmitSound("player/pl_fleshbreak.wav", 75, math.random(80, 90))
		ply:EmitSound("vo/npc/male01/pain0"..math.random(1,9)..".wav",80,math.random(98,102))
		ply:ViewPunch(Angle(0,math.random(-spd/45,spd/45),0))
		ply:SetJumpPower(85)

		-- Lose 20% stamina for each multiple of 666 speed
		ply:SetStamina(ply:GetStamina() - (0.2 * ply:GetMaxStamina() * time))
		ply:SyncStamina()

		timer.Simple(time,function() ply:SetJumpPower(jmp) end)
	end
	if spd >= 760 then
		ply:EmitSound("physics/cardboard/cardboard_box_strain1.wav",75,math.random(100,110))
		timer.Simple(math.random(2, 4),function()
			local which = math.random(1, 5)
			local how = math.random(98, 102)
			ply:EmitSound("vo/npc/male01/moan0"..which..".wav", 76, how)
		end)
	end

	return 0
end

STATE.Countdown = HS.Countdown.New("HS.InRound.Countdown", function()
	-- If the countdown ends, the hiders have won
	HS.StateManager.ChangeState("postround", "hiderswin", STATE.OriginalSeeker)
end)

HS.StateManager.RegisterState(STATE)
