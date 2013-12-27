local STATE = {}
STATE.Name = "pregame"
STATE.Active = false

function STATE:BeginState()
	self:AddPlayersCount()
end

function STATE:EndState()
	self:RemoveCountdown()
	self:RemovePlayersCount()
end

function STATE:AddPlayersCount()
	hook.Add("HUDPaint", "HS.PreGame.WaitingForPlayers", function()
		draw.RoundedBoxEx(16,20,0,128,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined("Waiting For Players:","DermaDefault",32,16,Color(255,255,255),0,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(math.max(HS.Config.MinPlayers:GetInt() - #player.GetAll(), 0),"DermaLarge",32,48,Color(255,255,255),0,1,2,Color(10,10,10,100))
	end)
end

function STATE:RemovePlayersCount()
	hook.Remove("HUDPaint", "HS.PreGame.WaitingForPlayers")
end

function STATE:ActivateCountdown()
	self:RemovePlayersCount()

	surface.PlaySound("ui/trade_ready.wav")

	hook.Add("HUDPaint", "HS.PreGame.Countdown", function()
		draw.RoundedBoxEx(16,20,0,128,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined("Game Starting In:","DermaDefault",32,16,Color(255,255,255),0,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(self.Countdown:FormatTimeRemaining(),"DermaLarge",32,48,Color(255,255,255),0,1,2,Color(10,10,10,100))
	end)
end

function STATE:RemoveCountdown()
	self.Countdown:SetActive(false)
	hook.Remove("HUDPaint", "HS.PreGame.Countdown")
end

local function OnCountdownSync(countdown)
	if not STATE.Active then return end
	if countdown:IsActive() then
		STATE:ActivateCountdown()
	else
		STATE:RemoveCountdown()
		STATE:AddPlayersCount()
	end
end

local function OnCountdownTick(coutdown, time)
	if time >= 4 then
		surface.PlaySound("hideseek/countdown_tick_" .. (time % 2 == 0 and "high" or "low") .. ".wav")
	elseif time <= 3 and time >= 1 then
		surface.PlaySound("buttons/button17.wav")
	end
end

STATE.Countdown = HS.Countdown.New("HS.PreGame.Countdown", OnCountdownSync, OnCountdownTick)

HS.StateManager.RegisterState(STATE)
