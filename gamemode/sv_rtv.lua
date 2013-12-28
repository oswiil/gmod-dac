local RTVCount = 0

-- Need 1 more than half the players
local function GetNeededPlayers(excluding)
	local numPlayers = HS.TeamManager.NumActiveExcluding(excluding)

	if numPlayers % 2 == 0 then
		return (numPlayers / 2) + 1
	else
		return math.ceil(numPlayers / 2)
	end
end

local function EnoughVotes()
	HS.ChatPrintAll(Color(230,126,34), "RTV", Color(255,255,255), ": Enough votes obtained, starting map vote")
	HS.StateManager.ChangeState("mapvote")
end

hook.Add("PlayerSay", "HS.RTV.OnPlayerSay", function(ply, txt, teamchat)
	if HS.StateManager.CurrentState().Name == "mapvote" then return end

	if string.match(string.lower(txt),"^([!/]rtv)$") then
		if not ply.RTV then
			ply.RTV = true
			RTVCount = RTVCount + 1

			HS.ChatPrintAll(Color(230,126,34), "RTV", Color(255,255,255), ": " .. tostring(RTVCount) .. "/" .. tostring(GetNeededPlayers()) .. " want to change map.")
			
			if RTVCount >= GetNeededPlayers() then
				EnoughVotes()
			end
		else
			HS.ChatPrintPlayer(ply, Color(230,126,34), "RTV", Color(255,255,255), ": You've already voted to change the map. (" .. tostring(RTVCount) .. "/" .. tostring(GetNeededPlayers()) .. ")")
		end
	end
end)

hook.Add("PlayerDisconnect", "HS.RTV.OnDisconnect", function(ply)
	if ply.RTV then RTVCount = RTVCount - 1 end

	if RTVCount >= GetNeededPlayers(ply) then
		EnoughVotes()
	end
end)
