local STATE = {}
STATE.Name = "mapvote"
STATE.Active = false

util.AddNetworkString("HS.MapVote.VoteInfo")
util.AddNetworkString("HS.MapVote.MapOpinion")
util.AddNetworkString("HS.MapVote.ClientUpdateVote")
util.AddNetworkString("HS.MapVote.NotifyVote")
util.AddNetworkString("HS.MapVote.NotifyWinner")

function STATE:BeginState()
	self.Votes = {}

	self.Countdown:Start(HS.Config.MapVoteTime:GetInt())

	hook.Add("Move", "HS.MapVote.RestrictMovement", function(ply, mv)
		return true
	end)
end

function STATE:EndState()
	hook.Remove("Move", "HS.MapVote.RestrictMovement")
	timer.Destroy("HS.MapVote.ChangeMap")
	self.Countdown:Stop()
end

function STATE:NewPlayerSync(ply)
	self.Countdown:ClientSync(ply)

	net.Start("HS.MapVote.VoteInfo")
		net.WriteUInt(#HS.MapList, 32)
		for _,v in ipairs(HS.MapList) do
			net.WriteString(v)
		end
	net.Send(ply)

	for _,data in pairs(self.Votes) do
		net.Start("HS.MapVote.NotifyVote")
			net.WriteEntity(data.Player)
			net.WriteUInt(data.ID, 32)
		net.Send(ply)
	end

	-- TODO: If player joins as the map as just been selected, they
	-- aren't going to see it.
end

function STATE:PlayerInitialSpawn(ply)
	ply:MakeWaiting()
	ply:Spectate(OBS_MODE_ROAMING)
end

STATE.Countdown = HS.Countdown.New("HS.MapVote.Countdown", function()
	-- Find the winning map
	local counts = {}
	for steamID, data in pairs(STATE.Votes) do
		local ID = data.ID

		if not counts[ID] then counts[ID] = 0 end
		counts[ID] = counts[ID] + 1
	end

	local winningID = table.GetWinningKey(counts)

	-- Notify everyone about the winner
	net.Start("HS.MapVote.NotifyWinner")
		net.WriteUInt(winningID, 32)
	net.Broadcast()

	HS.Log("[MapVote] %q won the vote - changing in 2 seconds", HS.MapList[winningID])

	timer.Create("HS.MapVote.ChangeMap", 2, 1, function()
		HS.Log("[MapVote] Changing to new map")
		HS.ChatPrintAll(Color(255,255,255), "(Would change map now)")
	end)
end)

net.Receive("HS.MapVote.MapOpinion", function(len, ply)
	if not STATE.Active then return end

	local liked = net.ReadBit() == 1
	if liked then
		HS.Log("[MapVote] %s liked the map", ply:Nick())
	else
		HS.Log("[MapVote] %s didn't like the map", ply:Nick())
	end
end)

net.Receive("HS.MapVote.ClientUpdateVote", function(len, ply)
	if not STATE.Active then return end
	if not STATE.Countdown:IsActive() then return end

	local ID = net.ReadUInt(32)

	-- Check the ID is actually a valid map
	if not HS.MapList[ID] then 
		HS.Log("[MapVote] %s attempted to vote for an invalid map ID '%d'", ply:Nick(), ID)
		return
	end

	-- Add the vote to our list
	STATE.Votes[ply:SteamID()] = { Player = ply, ID = ID }

	-- It's valid, so tell everyone else about the vote
	net.Start("HS.MapVote.NotifyVote")
		net.WriteEntity(ply)
		net.WriteUInt(ID, 32)
	net.Broadcast()
end)

HS.StateManager.RegisterState(STATE)
