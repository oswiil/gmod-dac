local STATE = {}
STATE.Name = "inround"
STATE.Active = false

function STATE:BeginState()

end

function STATE:EndState()
	self:RemoveCountdown()
end

function STATE:ActivateCountdown()
	hook.Add("HUDPaint", "HS.InRound.Countdown", function()
		draw.RoundedBoxEx(16,20,0,128,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined("Time Remaining:","DermaDefault",32,16,Color(255,255,255),0,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(self.Countdown:FormatTimeRemaining(),"DermaLarge",32,48,Color(255,255,255),0,1,2,Color(10,10,10,100))
	end)
end

function STATE:RemoveCountdown()
	self.Countdown:SetActive(false)
	hook.Remove("HUDPaint", "HS.InRound.Countdown")
end

local function OnCountdownSync(countdown)
	if not STATE.Active then return end
	if countdown:IsActive() then
		STATE:ActivateCountdown()
	else
		STATE:RemoveCountdown()
	end
end

STATE.Countdown = HS.Countdown.New("HS.InRound.Countdown", OnCountdownSync)

HS.StateManager.RegisterState(STATE)
