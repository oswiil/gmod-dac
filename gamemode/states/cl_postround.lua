local STATE = {}
STATE.Name = "postround"
STATE.Active = false

function STATE:SetupSounds()
	self.BeatLoop = CreateSound(LocalPlayer(), "hideseek/exp_loop_1.wav")
	self.BeatLoop:Play()
	self.BeatLoop:ChangeVolume(0.7, 0)
end

function STATE:BeginState(endType)
	self:SetupSounds()
end

function STATE:EndState()
	if self.BeatLoop then
		self.BeatLoop:Stop()
		self.BeatLoop = nil
	end
end

HS.StateManager.RegisterState(STATE)
