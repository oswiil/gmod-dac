local STATE = {}
STATE.Name = "mapvote"
STATE.Active = false

function STATE:SetupSounds()
	self.BeatLoop = CreateSound(LocalPlayer(), "hideseek/exp_loop_1.wav")
	self.BeatLoop:Play()
	self.BeatLoop:ChangeVolume(0.7, 0)
end

function STATE:BeginState(endType)
	hook.Add("Move", "HS.MapVote.RestrictMovement", function(ply, mv)
		return true
	end)

	self:SetupSounds()

	self.Votes = {}
end

function STATE:EndState()
	if self.BeatLoop then
		self.BeatLoop:Stop()
		self.BeatLoop = nil
	end

	hook.Remove("Move", "HS.MapVote.RestrictMovement")
end

function STATE:OnReceiveVoteInfo(maps)
	self.VotePanel = vgui.Create("HS.Voting.MapVoteScreen")
	self.VotePanel.EndTime = self.Countdown:EndTime() or 0
	self.VotePanel:SetMaps(maps)
	self.VotePanel.Votes = self.Votes
end

function STATE:OnReceivePlayerVote(ply, ID)
	if IsValid(ply) then
		self.Votes[ply:SteamID()] = ID

		if IsValid(self.VotePanel) then
			self.VotePanel:AddVoter(ply)
		end
	end
end

local function OnCountdownSync(countdown)
	if not STATE.Active then return end
	if countdown:IsActive() and STATE.VotePanel then
		STATE.VotePanel.EndTime = countdown:EndTime()
	end
end

STATE.Countdown = HS.Countdown.New("HS.MapVote.Countdown", OnCountdownSync)

net.Receive("HS.MapVote.VoteInfo", function()
	if not STATE.Active then return end

	local maps = {}

	local num = net.ReadUInt(32)
	for i=1,num do
		table.insert(maps, net.ReadString())
	end

	STATE:OnReceiveVoteInfo(maps)
end)

net.Receive("HS.MapVote.NotifyVote", function()
	if not STATE.Active then return end

	local ply = net.ReadEntity()
	local ID = net.ReadUInt(32)

	STATE:OnReceivePlayerVote(ply, ID)
end)

net.Receive("HS.MapVote.NotifyWinner", function()
	if not STATE.Active then return end

	if IsValid(STATE.VotePanel) then
		STATE.VotePanel:Flash(net.ReadUInt(32))
	end
end)

HS.StateManager.RegisterState(STATE)
