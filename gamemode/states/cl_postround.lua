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
	self:RemoveCountdown()

	if self.BeatLoop then
		self.BeatLoop:Stop()
		self.BeatLoop = nil
	end
end

function STATE:ActivateCountdown()
	hook.Add("HUDPaint", "HS.PostRound.Countdown", function()
		draw.RoundedBoxEx(16,20,0,128,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined("Next Round In:","DermaDefault",32,16,Color(255,255,255),0,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(self.Countdown:FormatTimeRemaining(),"DermaLarge",32,48,Color(255,255,255),0,1,2,Color(10,10,10,100))
	end)
end

function STATE:RemoveCountdown()
	self.Countdown:SetActive(false)
	hook.Remove("HUDPaint", "HS.PostRound.Countdown")
end

local function OnCountdownSync(countdown)
	if not STATE.Active then return end
	if countdown:IsActive() then
		STATE:ActivateCountdown()
	else
		STATE:RemoveCountdown()
	end
end

STATE.Countdown = HS.Countdown.New("HS.PostRound.Countdown", OnCountdownSync)

HS.StateManager.RegisterState(STATE)
