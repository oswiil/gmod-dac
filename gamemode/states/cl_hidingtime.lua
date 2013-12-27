local STATE = {}
STATE.Name = "hidingtime"
STATE.Active = false

local BlindColorMod = {}
BlindColorMod["$pp_colour_addr"] = 0
BlindColorMod["$pp_colour_addg"] = 0
BlindColorMod["$pp_colour_addb"] = 0
BlindColorMod["$pp_colour_brightness"] = -0.92
BlindColorMod["$pp_colour_contrast"] = 1.4
BlindColorMod["$pp_colour_colour"] = 0
BlindColorMod["$pp_colour_mulr"] = 0
BlindColorMod["$pp_colour_mulg"] = 0
BlindColorMod["$pp_colour_mulb"] = 0

local function BlindEffect()
	if LocalPlayer():Team() == HS.TeamManager.TEAM_SEEKING then
		DrawColorModify(BlindColorMod)
	end
end

function STATE:BeginState()
	hook.Add("Move", "HS.HidingTime.RestrictMovement", function(ply, mv)
		if ply:Team() == HS.TeamManager.TEAM_SEEKING then return true end
	end)

	timer.Destroy("HS.HidingTime.FadeOutBeat1")
	timer.Destroy("HS.HidingTime.FadeOutBeat2")
	hook.Add("RenderScreenspaceEffects", "HS.HidingTime.Blindness", BlindEffect)
end

function STATE:EndState()
	self:RemoveCountdown()

	if self.BeatLoop1 then
		self.BeatLoop1:FadeOut(3)

		timer.Create("HS.HidingTime.FadeOutBeat1", 4, 1, function()
			self.BeatLoop1:Stop()
			self.BeatLoop1 = nil
		end)
	end

	if self.BeatLoop2 then
		self.BeatLoop2:FadeOut(3)

		timer.Create("HS.HidingTime.FadeOutBeat2", 4, 1, function()
			self.BeatLoop2:Stop()
			self.BeatLoop2 = nil
		end)
	end

	surface.PlaySound("hideseek/exp_game_transit_1.mp3")

	timer.Destroy("HS.HidingTime.FadeInBeat")
	timer.Destroy("HS.HidingTime.ChangeBeat")
	hook.Remove("RenderScreenspaceEffects", "HS.HidingTime.Blindness")
	hook.Remove("Move", "HS.HidingTime.RestrictMovement")
end

function STATE:SetupSounds()
	-- Phat beats
	self.BeatLoop2 = CreateSound(LocalPlayer(), "hideseek/exp_loop_2.wav")
	self.BeatLoop2:Play()
	self.BeatLoop2:ChangeVolume(0.1, 0)

	self.BeatLoop1 = CreateSound(LocalPlayer(), "hideseek/exp_loop_1.wav")
	self.BeatLoop1:Play()
	self.BeatLoop1:ChangeVolume(0.1, 0)

	local timeLeft = self.Countdown:TimeRemaining()
	if timeLeft > 2.5 then
		surface.PlaySound("hideseek/exp_game_new_" .. math.random(1,5) .. ".mp3")

		if timeLeft > 12 then
			-- exp_game_new_* goes for 2.5 seconds
			timer.Create("HS.HidingTime.FadeInBeat", 2.5 * 0.7, 1, function()
				self.BeatLoop2:ChangeVolume(0.7, 0)
			end)

			timer.Create("HS.HidingTime.ChangeBeat", 12, 1, function()
				self.BeatLoop2:Stop()
				self.BeatLoop1:ChangeVolume(0.7, 0)
			end)
		else
			timer.Create("HS.HidingTime.FadeInBeat", 2.5 * 0.7, 1, function()
				self.BeatLoop1:ChangeVolume(0.7, 0)
			end)
		end
	else
		self.BeatLoop2:Stop()
		self.BeatLoop1:ChangeVolume(0.7, 0)
	end
end

function STATE:ActivateCountdown()
	self:SetupSounds()

	hook.Add("HUDPaint", "HS.HidingTime.Countdown", function()
		draw.RoundedBoxEx(16,20,0,128,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined("Seeker Released In:","DermaDefault",32,16,Color(255,255,255),0,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(self.Countdown:FormatTimeRemaining(),"DermaLarge",32,48,Color(255,255,255),0,1,2,Color(10,10,10,100))
	end)
end

function STATE:RemoveCountdown()
	self.Countdown:SetActive(false)
	hook.Remove("HUDPaint", "HS.HidingTime.Countdown")
end

local function OnCountdownSync(countdown)
	if not STATE.Active then return end
	if countdown:IsActive() then
		STATE:ActivateCountdown()
	else
		STATE:RemoveCountdown()
	end
end

STATE.Countdown = HS.Countdown.New("HS.HidingTime.Countdown", OnCountdownSync)

HS.StateManager.RegisterState(STATE)
