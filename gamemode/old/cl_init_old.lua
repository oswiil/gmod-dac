include('shared.lua')
if not file.Exists("hideandseek/gender.txt","DATA") then
	file.CreateDir("hideandseek")
	file.Write("hideandseek/gender.txt","Male")
end
if not file.Exists("hideandseek/notifsound.txt","DATA") then
	file.Write("hideandseek/notifsound.txt","None")
end
if not file.Exists("hideandseek/staminacol.txt","DATA") then
	file.Write("hideandseek/staminacol.txt","DEFAULT")
end

concommand.Add("has_help",showHelp)
concommand.Add("has_options",editOptions)

ver = "v1.1"
firsthelp = true
COLOR_TEAM_Retr = function()
	if LocalPlayer():Team() == nil then return end
	teamrgb = team.GetColor(LocalPlayer():Team())
	COLOR_TEAM = Color(teamrgb["r"]*2,teamrgb["g"]*2,teamrgb["b"]*2)
end
COLOR_ALL = Color(255,255,255)
sprintpower = 100
InfSta = GetConVarNumber("has_infinitestamina")
RoundTimeSave = 0
RoundTimer = 0
RoundCount = "[ ? ]"
GameEnd = false
ScoBFocus = false
ScoBIsShowing = false
CCFocus = false
function sprintSTART()
	timer.Destroy("has_sprintregen")
	timer.Destroy("has_sprintregendelay")
	timer.Create("has_sprintdrain",0.055,0,function() sprintpower = math.Clamp(sprintpower-1,0,100) end)
end
function sprintEND()
	timer.Destroy("has_sprintdrain")
		timer.Create("has_sprintregendelay",2,1,function() timer.Create("has_sprintregen",0.05,0,function()
			sprintpower = math.Clamp(sprintpower+0.4,0,100)
			if sprintpower >= 100 then timer.Destroy("has_sprintregen") end
	end) end)
end
function chatping()
	timer.Simple(0.05,function()
		if file.Read("hideandseek/notifsound.txt","DATA") != "None" then
			surface.PlaySound(file.Read("hideandseek/notifsound.txt","DATA"))
		end
	end)
end
function ScoBRefreshIt()
	if ScoBBase:IsValid() then ScoBBase:Close() end
	ScoBShow()
end
function ScoBHide()
	timer.Destroy("ScoBRefresh")
	ScoBFocus = false
	ScoBIsShowing = false
	if ScoBBase:IsValid() then ScoBBase:Close() end
end
function ScoBShow()
	local specs = {}
	ScoBIsShowing = true
	ScoBBase = vgui.Create("DFrame")
	ScoBBase:SetPos(0,0)
	ScoBBase:SetSize(ScrW(),ScrH())
	ScoBBase:SetTitle("")
	ScoBBase:ShowCloseButton(false)
	ScoBBase:SetDraggable(false)
	if ScoBFocus then
		ScoBBase:MakePopup()
		ScoBBase:SetKeyBoardInputEnabled(false)
	end
	ScoBBase.Paint = function()
		draw.RoundedBox(0,0,0,ScoBBase:GetWide(),ScoBBase:GetTall(),Color(0,0,0,0))
	end
	ScoBHead = vgui.Create("DFrame",ScoBBase)
	ScoBHead:SetPos(ScrW()/2-400,80)
	ScoBHead:SetSize(800,40)
	ScoBHead:SetTitle("")
	ScoBHead:ShowCloseButton(false)
	ScoBHead:SetDraggable(false)
	ScoBHead.Paint = function()
		draw.RoundedBox(16,0,0,ScoBHead:GetWide(),ScoBHead:GetTall(),Color(0,0,0,200))
	end
	ScoBHeader1 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader1:SetPos(612,6)
	ScoBHeader1:SetColor(Color(255,255,255,255))
	ScoBHeader1:SetFont("DermaLarge")
	ScoBHeader1:SetText("Hide and Seek")
	ScoBHeader1:SizeToContents()
	ScoBHeader2_1 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_1:SetPos(12,5)
	ScoBHeader2_1:SetColor(Color(255,255,255,255))
	ScoBHeader2_1:SetFont("DermaDefault")
	ScoBHeader2_1:SetText(GetHostName())
	ScoBHeader2_1:SizeToContents()
	ScoBHeader2_2 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_2:SetPos(12,20)
	ScoBHeader2_2:SetColor(Color(255,255,255,255))
	ScoBHeader2_2:SetFont("DermaDefault")
	ScoBHeader2_2:SetText(game.GetMap())
	ScoBHeader2_2:SizeToContents()
	ScoBHeader2_3 = vgui.Create("DLabel",ScoBHead)
	ScoBHeader2_3:SetPos(575,20)
	ScoBHeader2_3:SetColor(Color(255,255,255,255))
	ScoBHeader2_3:SetFont("DermaDefault")
	ScoBHeader2_3:SetText(ver)
	ScoBHeader2_3:SizeToContents()
	ScoBHeaderP = vgui.Create("DImage",ScoBHead)
	ScoBHeaderP:SetPos(555,19)
	if game.IsDedicated() then ScoBHeaderP:SetImage("icon16/server_uncompressed.png") else ScoBHeaderP:SetImage("icon16/computer.png") end
	ScoBHeaderP:SizeToContents()
	ScoBHeaderSc = vgui.Create("DButton",ScoBHead)
	ScoBHeaderSc:SetSize(173,26)
	ScoBHeaderSc:SetPos(612,6)
	ScoBHeaderSc:SetText("")
	ScoBHeaderSc.Paint = function()
		draw.RoundedBox(0,0,0,ScoBHeaderSc:GetWide(),ScoBHeaderSc:GetTall(),Color(0,0,0,0))
	end
	ScoBHeaderSc.DoClick = function(DermaButton)
		gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=200233950")
		surface.PlaySound("garrysmod/content_downloaded.wav")
		timer.Simple(0.1,function() ScoBHide() end)
	end
	local size = (team.NumPlayers(3) > 0) and 550 or 700
	local n = 0
	for k,v in pairs(player.GetAll()) do
		if v:Team() != 3 then
			n = n+1
			local ScoBPly = vgui.Create("DFrame",ScoBBase)
			ScoBPly:SetPos(ScrW()/2-350,84+(38*n))
			ScoBPly:SetSize(size,36)
			ScoBPly:SetTitle("")
			ScoBPly:ShowCloseButton(false)
			ScoBPly:SetDraggable(false)
			ScoBPly.Paint = function()
				draw.RoundedBox(4,0,0,ScoBPly:GetWide(),ScoBPly:GetTall(),Color(0,0,0,200))
			end
			local ScoBPlyA = vgui.Create("AvatarImage",ScoBPly)
			ScoBPlyA:SetSize(32,32)
			ScoBPlyA:SetPos(2,2)
			ScoBPlyA:SetPlayer(v,32)
			local ScoBPlyAB = vgui.Create("DButton",ScoBPly)
			ScoBPlyAB:SetSize(32,32)
			ScoBPlyAB:SetPos(2,2)
			ScoBPlyAB:SetText("")
			ScoBPlyAB.Paint = function()
				draw.RoundedBox(0,0,0,ScoBPlyAB:GetWide(),ScoBPlyAB:GetTall(),Color(0,0,0,0))
			end
			ScoBPlyAB.DoClick = function(DermaButton)
				timer.Destroy("ScoBRefresh")
				local ScoBPlyABMenu = vgui.Create("DMenu",ScoBPly)
				if v:IsMuted() then
					ScoBPlyABMenu:AddOption("Unmute",function()
					v:SetMuted(false)
					timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_return.wav")
					end)
				else
					ScoBPlyABMenu:AddOption("Mute",function()
					v:SetMuted(true)
					timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_hover.wav")
					end)
				end
				ScoBPlyABMenu:AddSpacer()
				ScoBPlyABMenu:AddOption("Show Profile",function()
					v:ShowProfile()
					surface.PlaySound("garrysmod/content_downloaded.wav")
					timer.Simple(0.1,function() ScoBHide() end)
				end)
				ScoBPlyABMenu:Open()
				surface.PlaySound("garrysmod/ui_click.wav")
			end
			local ScoBPlyN_1 = vgui.Create("DLabel",ScoBPly)
			ScoBPlyN_1:SetPos(40,4)
			--if v:SteamID() == "STEAM_0:0:33106902" then ScoBPlyN_1:SetColor(Color(245,195,80,255)) else ScoBPlyN_1:SetColor(Color(255,255,255,255)) end
			ScoBPlyN_1:SetColor(Color(255,255,255,255))
			ScoBPlyN_1:SetFont("DermaDefaultBold")
			ScoBPlyN_1:SetText(v:Name())
			ScoBPlyN_1:SizeToContents()
			local ScoBPlyN_2 = vgui.Create("DLabel",ScoBPly)
			ScoBPlyN_2:SetPos(40,18)
			ScoBPlyN_2:SetColor(Color(255,255,255,255))
			ScoBPlyN_2:SetFont("DermaDefault")
			ScoBPlyN_2:SetText("Score: "..v:Frags())
			ScoBPlyN_2:SizeToContents()
			local ScoBPlyN_3 = vgui.Create("DLabel",ScoBPly)
			ScoBPlyN_3:SetPos(ScoBPly:GetWide()-24,11)
			ScoBPlyN_3:SetColor(Color(255,255,255,255))
			ScoBPlyN_3:SetFont("DermaDefault")
			ScoBPlyN_3:SetText(v:Ping())
			ScoBPlyN_3:SizeToContents()
			local ScoBPlyP = vgui.Create("DImage",ScoBPly)
			ScoBPlyP:SetPos(ScoBPly:GetWide()-44,10)
			if v:Ping() > 5 then ScoBPlyP:SetImage("icon16/transmit_blue.png") else ScoBPlyP:SetImage("icon16/server_connect.png") end
			ScoBPlyP:SizeToContents()
			if v:GetFriendStatus() != "none" then
				local ScoBPlyPF = vgui.Create("DImage",ScoBPly)
				ScoBPlyPF:SetPos(ScoBPly:GetWide()-72,10)
				if v:GetFriendStatus() == "blocked" then ScoBPlyPF:SetImage("icon16/exclamation.png") else ScoBPlyPF:SetImage("icon16/user_add.png") end
				ScoBPlyPF:SizeToContents()
			end
			if v == LocalPlayer() then
				local ScoBPlyY = vgui.Create("DImage",ScoBPly)
				ScoBPlyY:SetPos(ScoBPly:GetWide()-72,10)
				ScoBPlyY:SetImage("icon16/asterisk_orange.png")
				ScoBPlyY:SizeToContents()
			end
			if v:IsMuted() then
				local ScoBPlyPM = vgui.Create("DImage",ScoBPly)
				ScoBPlyPM:SetPos(ScoBPly:GetWide()-100,10)
				ScoBPlyPM:SetImage("icon16/sound_mute.png")
				ScoBPlyPM:SizeToContents()
			end
			if LocalPlayer():Team() != 1 then
				local ScoBPlyPT = vgui.Create("DImage",ScoBPly)
				ScoBPlyPT:SetPos(230,10)
				if v:Team() == 1 then ScoBPlyPT:SetImage("icon16/flag_blue.png") end
				if v:Team() == 2 then ScoBPlyPT:SetImage("icon16/flag_red.png") end
				if v:Team() == 4 and LocalPlayer():Team() != 2 then ScoBPlyPT:SetImage("icon16/camera_delete.png") end
				ScoBPlyPT:SizeToContents()
			end
		else
			table.insert(specs,v:Name())
		end
	end
	if team.NumPlayers(3) > 0 then
		local ScoBSpec = vgui.Create("DFrame",ScoBBase)
		ScoBSpec:SetPos(ScrW()/2+202,122)
		ScoBSpec:SetSize(148,150)
		ScoBSpec:SetTitle("")
		ScoBSpec:ShowCloseButton(false)
		ScoBSpec:SetDraggable(false)
		ScoBSpec.Paint = function()
			draw.RoundedBox(4,0,0,ScoBSpec:GetWide(),ScoBSpec:GetTall(),Color(0,0,0,200))
		end
		local ScoBSpecP = vgui.Create("DImage",ScoBSpec)
		ScoBSpecP:SetPos(8,4)
		ScoBSpecP:SetImage("icon16/camera_go.png")
		ScoBSpecP:SizeToContents()
		local ScoBSpecT = vgui.Create("DLabel",ScoBSpec)
		ScoBSpecT:SetPos(30,4)
		ScoBSpecT:SetColor(Color(255,255,255,255))
		ScoBSpecT:SetFont("DermaDefaultBold")
		ScoBSpecT:SetText("Spectators:")
		ScoBSpecT:SizeToContents()
		local ScoBSpecN = vgui.Create("DLabel",ScoBSpec)
		ScoBSpecN:SetPos(10,22)
		ScoBSpecN:SetColor(Color(255,255,255,255))
		ScoBSpecN:SetFont("DermaDefault")
		ScoBSpecN:SetText(table.concat(specs,"\n"))
		ScoBSpecN:SizeToContents()
	end
end

function GM:Tick() --this is probably a really shit way of doing it but oh well
	if sprintpower <= 4 then
		RunConsoleCommand("-speed")
	end
	if InfSta == 1 then sprintpower = 100 end
end

function GM:KeyPress(ply,key)
	if ply == LocalPlayer() and key == IN_ATTACK2 then
		if ply:KeyDown(IN_SCORE) then
			ScoBFocus = true
			ScoBBase:MakePopup()
			ScoBBase:SetKeyBoardInputEnabled(false)
		end
	end
	if ply == LocalPlayer() and key == IN_SPEED then
		if sprintpower <= 4 then return end
		if (InfSta == 1 or (ply:Team() == 3 or ply:Team() == 4)) then return end
		sprintpower = math.Clamp(sprintpower-1,0,100)
		sprintSTART()
	end
end
function GM:KeyRelease(ply,key)
	if ply == LocalPlayer() and key == IN_SPEED then
		sprintEND()
	end
	if ply == LocalPlayer() and (key == IN_ATTACK or key == IN_ATTACK2) and CCFocus then
		DermaPanelX:SetMouseInputEnabled(true)
		DermaPanelX:SetKeyboardInputEnabled(true)
		CCFocus = false
	end
end

function GM:HUDShouldDraw(hud)
	if not (hud == "CHudWeaponSelection" or hud == "CHudHealth" or hud == "CHudBattery" or hud == "CHudPoisonDamageIndicator" or hud == "CHudZoom") then
		return true
	end
end

function GM:HUDPaint()
	--Name and Stamina
	local sta = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and team.GetColor(LocalPlayer():Team()) or string.Explode(",",file.Read("hideandseek/staminacol.txt","DATA"))
	local ent = LocalPlayer():GetEyeTrace().Entity
	local alpha = math.sin(CurTime()*6)*50+100
	local spec1 = (LocalPlayer():Team() == 3 or LocalPlayer():Team() == 4) and 80 or 32
	draw.RoundedBoxEx(16,20,ScrH()-80,200,spec1,Color(0,0,0,200),true,true,false,false)
	draw.SimpleTextOutlined(LocalPlayer():Name(),"DermaDefaultBold",32,ScrH()-70,team.GetColor(LocalPlayer():Team()),0,1,2,Color(10,10,10,100))
	draw.SimpleTextOutlined(team.GetName(LocalPlayer():Team()),"DermaDefault",32,ScrH()-56,team.GetColor(LocalPlayer():Team()),0,1,2,Color(10,10,10,100))
	if not (LocalPlayer():Team() == 3 or LocalPlayer():Team() == 4) then
		draw.RoundedBoxEx(16,20,ScrH()-48,308,32,Color(0,0,0,200),false,true,false,true)
		draw.RoundedBox(12,24,ScrH()-44,300,24,Color(0,0,0,200))
		if sprintpower > 4 then
			if file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT" then
				draw.RoundedBox(12,24,ScrH()-44,sprintpower*3,24,Color(sta.r,sta.g,sta.b,alpha))
			else
				draw.RoundedBox(12,24,ScrH()-44,sprintpower*3,24,Color(sta[1],sta[2],sta[3],alpha))
			end
		end
		if InfSta == 1 then draw.SimpleText("I N F I N I T E","DermaLarge",172,ScrH()-31,Color(10,10,10,180),1,1) end
		draw.RoundedBox(0,20,ScrH()-16,200,16,Color(0,0,0,200))
	end
	if ent:IsPlayer() then
		draw.SimpleTextOutlined(ent:Name(),"DermaLarge",ScrW()/2,ScrH()/2+50,team.GetColor(ent:Team()),1,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(team.GetName(ent:Team()),"DermaDefaultBold",ScrW()/2,ScrH()/2+70,team.GetColor(ent:Team()),1,1,2,Color(10,10,10,100))
	end
	
	--Time and Round
	local TimerColor = (RoundTimer < 1) and Color(100,100,100,255) or Color(255,255,255,255)
	draw.RoundedBoxEx(16,20,0,128,72,Color(0,0,0,200),false,false,true,true)
	draw.SimpleTextOutlined("Round "..RoundCount,"DermaDefault",32,48,Color(255,255,255,255),0,1,2,Color(10,10,10,100))
	if TimeRemaining != nil then draw.SimpleTextOutlined(string.ToMinutesSeconds(math.Clamp(TimeRemaining,0,5999)),"DermaLarge",32,24,TimerColor,0,1,2,Color(10,10,10,100)) else draw.SimpleTextOutlined("00:00","DermaLarge",32,24,Color(100,100,100,255),0,1,2,Color(10,10,10,100)) end
	
	--Blindtime stuffs
	if SeekerBlinded then
		local BlindTime = math.max(TimeRemaining-RoundTimer,1)
		local TCorrect = (BlindTime == 1) and " second" or " seconds"
		local NCorrect = (LocalPlayer():Team() == 2) and "You" or "Seekers"
		draw.RoundedBoxEx(16,ScrW()/2-100,0,200,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined(NCorrect.." will be unblinded in...","DermaDefault",ScrW()/2,24,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined(BlindTime..TCorrect,"DermaDefault",ScrW()/2,40,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
	end
	--Most Score notice (GameEnd)
	if GameEnd then
		local scores = {}
		for k,v in pairs(player.GetAll()) do
			scores[v:Name()] = v:Frags()
		end
		local winner = (table.GetWinningKey(scores) == LocalPlayer():Name()) and table.GetWinningKey(scores).." (You!)" or table.GetWinningKey(scores)
		draw.RoundedBoxEx(16,ScrW()/2-200,0,400,72,Color(0,0,0,200),false,false,true,true)
		draw.SimpleTextOutlined(winner,"DermaLarge",ScrW()/2,24,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
		draw.SimpleTextOutlined("had the most points with "..scores[table.GetWinningKey(scores)].."!","DermaDefaultBold",ScrW()/2,48,Color(255,255,255,255),1,1,2,Color(10,10,10,100))
	end
	
	--Team Markers
	if not (LocalPlayer():Team() == 3 or LocalPlayer():Team() == 4) then
		for k,v in pairs(player.GetAll()) do
			if v != LocalPlayer() and v:Team() == LocalPlayer():Team() then
				local col = team.GetColor(LocalPlayer():Team())
				local alp = -400+math.Clamp(LocalPlayer():GetPos():Distance(v:GetPos()),0,600)
				local arrowpos = (v:LookupBone("ValveBiped.Bip01_Head1") != nil) and v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1"))+Vector(0,0,12+math.Round(LocalPlayer():GetPos():Distance(v:GetPos())/50)) or v:GetPos()+Vector(0,0,78+math.Round(LocalPlayer():GetPos():Distance(v:GetPos())/50))
				local arrowscrpos = arrowpos:ToScreen()
				draw.SimpleTextOutlined("v","DermaLarge",tonumber(arrowscrpos.x),tonumber(arrowscrpos.y),Color(col.r,col.g,col.b,alp),1,1,2,Color(0,0,0,alp/3))
			end
		end
	end
end

function GM:ChatText(plyi,plyn,txt,msg)
	if msg == "joinleave" then
		return true
	end
end
function GM:OnPlayerChat(ply,txt,teamchat,deadchat)
	if ply:IsValid() then
		if teamchat then
			if LocalPlayer():Team() == ply:Team() then
				chat.AddText(team.GetColor(ply:Team()),ply:Name(),COLOR_ALL,": ",COLOR_TEAM,string.Trim(txt))
				chatping()
			end
		else
			chat.AddText(team.GetColor(ply:Team()),ply:Name(),COLOR_ALL,": "..string.Trim(txt))
			chatping()
		end
	else
		chat.AddText(Color(40,40,40,255),"CONSOLE",Color(200,200,200,255),": "..string.Trim(txt))
		chatping()
	end
	return true
end

function GM:ScoreboardShow()
	if not ScoBIsShowing then ScoBShow() end
	timer.Create("ScoBRefresh",0.8,0,ScoBRefreshIt)
	return true
end
function GM:ScoreboardHide()
	ScoBHide()
end

function showHelp()
	if CCFocus then
		surface.PlaySound("buttons/weapon_cant_buy.wav")
		chat.AddText(Color(200,200,200),"Click to gain control back, silly!")
	return end
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(600,400)
	DermaPanel:SetPos(25,ScrH()/4)
	DermaPanel:SetTitle("Hide and Seek - Help")
	DermaPanel:SetScreenLock(true)
	DermaPanel:ShowCloseButton(false)
	DermaPanel:SetMouseInputEnabled(true)
	DermaPanel:SetKeyboardInputEnabled(true)
	DermaPanel:MakePopup()
	local DermaPropSheet = vgui.Create("DPropertySheet",DermaPanel)
	DermaPropSheet:SetSize(580,326)
	DermaPropSheet:SetPos(10,30)
	local DermaButton1 = vgui.Create("DButton",DermaPanel)
	DermaButton1:SetSize(200,30)
	DermaButton1:SetPos(10,360)
	DermaButton1:SetText("Let's play!")
	DermaButton1.DoClick = function(DermaButton)
		DermaPanel:Close()
		if firsthelp then teamSelect() end
		firsthelp = false
		surface.PlaySound("garrysmod/save_load3.wav")
	end
	local DermaButton2 = vgui.Create("DButton",DermaPanel)
	DermaButton2:SetSize(80,30)
	DermaButton2:SetPos(510,360)
	DermaButton2:SetText("Leave")
	DermaButton2.DoClick = function(DermaButton)
		Derma_StringRequest("Leaving...",[[Want a leaving message? ]]..LocalPlayer():Name()..[[ left because...]],"",function(txt)
			net.Start("Leaving")
			net.WriteString(txt)
			net.SendToServer()
			DermaPanel:Close()
			chat.AddText(Color(240,190,190),"Goodbye, ",Color(255,255,255),LocalPlayer():Name(),Color(240,190,190),"!")
			surface.PlaySound("garrysmod/save_load2.wav")
		end,function(txt) surface.PlaySound("garrysmod/ui_return.wav") end)
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaTab1 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab1:SetPos(5,20)
	DermaTab1:SetSize(570,281)
	DermaTab1.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab1:GetWide(),DermaTab1:GetTall())
	end
	local DermaLabel1_1 = vgui.Create("DLabel",DermaTab1)
	DermaLabel1_1:SetPos(10,10)
	DermaLabel1_1:SetColor(Color(255,255,255,255))
	DermaLabel1_1:SetFont("DermaLarge")
	DermaLabel1_1:SetText("Welcome to Hide and Seek!")
	DermaLabel1_1:SizeToContents()
	local DermaLabel1_2 = vgui.Create("DLabel",DermaTab1)
	DermaLabel1_2:SetPos(10,50)
	DermaLabel1_2:SetColor(Color(255,255,255,255))
	DermaLabel1_2:SetFont("DermaDefault")
	DermaLabel1_2:SetText("You've probably heard of the classic game of 'Hide and Seek', right? It's pretty much those very same rules!\n\nThere are two teams, the hiding and the seekers.\nHiding players have to hide away from the seekers and seeking players have to find the hiding players, simple!\nNow go catch some sillys.\n\n\nHide and Seek buttons -\nF1 = Opens this help-box, click other tabs for more help!\nF2 = Opens team select.\nF4 = Opens your player options.\nRELOAD = Taunt.\n\nPossible requirements -\n'Team Fortress 2' to fully hear gamemode audio.\n'Counter-Strike: Source' for maps that servers could host.\n'Left 4 Dead' to have a nice landing sound, not so important.")
	DermaLabel1_2:SizeToContents()
	local DermaTab2 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab2:SetPos(5,20)
	DermaTab2:SetSize(570,281)
	DermaTab2.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab2:GetWide(),DermaTab2:GetTall())
	end
	local DermaLabel2_1 = vgui.Create("DLabel",DermaTab2)
	DermaLabel2_1:SetPos(10,10)
	DermaLabel2_1:SetColor(Color(255,255,255,255))
	DermaLabel2_1:SetFont("DermaLarge")
	DermaLabel2_1:SetText("Hiding!")
	DermaLabel2_1:SizeToContents()
	local DermaLabel2_2 = vgui.Create("DLabel",DermaTab2)
	DermaLabel2_2:SetPos(10,50)
	DermaLabel2_2:SetColor(Color(255,255,255,255))
	DermaLabel2_2:SetFont("DermaDefault")
	DermaLabel2_2:SetText("Hiding players are marked with blue name tags and blue clothes. Fellow hiders\nwill also have blue markers over their heads, so keep track which arrow is your friend!\n\nUse clever spots to keep out of seeker's sights!\nTry not to waste your sprint when escaping seekers!\nWatch teammates' arrows, if one disappears, they could have been caught!\nTry to trick seekers that are chasing you as they can run slightly faster than you!\n\n\nLanding after jumping will cause a short slowdown. But be careful, falling a\ngreat feet will make you let out a yelp, giving seekers an idea of your position!\nFalling from even bigger heights will affect your stamina too!")
	DermaLabel2_2:SizeToContents()
	local DermaModel1 = vgui.Create("DModelPanel",DermaTab2)
	DermaModel1:SetSize(250,250)
	DermaModel1:SetPos(360,8)
	DermaModel1:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
	DermaModel1:SetAnimated(true)
	DermaModel1:SetAnimSpeed(1)
	function DermaModel1:LayoutEntity() self:RunAnimation() end
	function DermaModel1.Entity:GetPlayerColor() return Vector(0,0.2,0.6) end
	local DermaTab3 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab3:SetPos(5,20)
	DermaTab3:SetSize(570,281)
	DermaTab3.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab3:GetWide(),DermaTab3:GetTall())
	end
	local DermaLabel3_1 = vgui.Create("DLabel",DermaTab3)
	DermaLabel3_1:SetPos(10,10)
	DermaLabel3_1:SetColor(Color(255,255,255,255))
	DermaLabel3_1:SetFont("DermaLarge")
	DermaLabel3_1:SetText("Seeking!")
	DermaLabel3_1:SizeToContents()
	local DermaLabel3_2 = vgui.Create("DLabel",DermaTab3)
	DermaLabel3_2:SetPos(10,50)
	DermaLabel3_2:SetColor(Color(255,255,255,255))
	DermaLabel3_2:SetFont("DermaDefault")
	DermaLabel3_2:SetText("Seeking players are marked with red name tags and red clothes.\nFellow seekers will also have red markers over their heads!\nYou can catch hiding by running into them or clicking them while close!\n\nCheck simple hiding spots as well as hard-to-reach places!\nUse your sprint when you're chasing hiders!\nWatch your teammates' arrows, if they are all in one spot,\nthey could be chasing someone! Team up with other seekers to quickly cover an area!\nDon't give up chasing someone, you have a slight speed advantage over hiders!\n\n\nLanding after jumping will cause a short slowdown. But be careful, falling a\ngreat feet will make you let out a yelp, giving seekers an idea of your position!\nFalling from even bigger heights will affect your stamina too!\nYou are also able to use a flashlight to find hiders in dark areas.")
	DermaLabel3_2:SizeToContents()
	local DermaModel2 = vgui.Create("DModelPanel",DermaTab3)
	DermaModel2:SetSize(250,250)
	DermaModel2:SetPos(360,8)
	DermaModel2:SetModel("models/player/group01/male_0"..math.random(1,9)..".mdl")
	DermaModel2:SetAnimated(true)
	DermaModel2:SetAnimSpeed(1)
	function DermaModel2:LayoutEntity() self:RunAnimation() end
	function DermaModel2.Entity:GetPlayerColor() return Vector(0.6,0.2,0) end
	local DermaTab4 = vgui.Create("DPanel",DermaPropSheet)
	DermaTab4:SetPos(5,20)
	DermaTab4:SetSize(570,281)
	DermaTab4.Paint = function()
		surface.SetDrawColor(50,50,50,255)
		surface.DrawRect(0,0,DermaTab4:GetWide(),DermaTab4:GetTall())
	end
	local DermaLabel4_1 = vgui.Create("DLabel",DermaTab4)
	DermaLabel4_1:SetPos(10,10)
	DermaLabel4_1:SetColor(Color(255,255,255,255))
	DermaLabel4_1:SetFont("DermaLarge")
	DermaLabel4_1:SetText("Spectating!")
	DermaLabel4_1:SizeToContents()
	local DermaLabel4_2 = vgui.Create("DLabel",DermaTab4)
	DermaLabel4_2:SetPos(10,50)
	DermaLabel4_2:SetColor(Color(255,255,255,255))
	DermaLabel4_2:SetFont("DermaDefault")
	DermaLabel4_2:SetText("You can't see other players spectating, although that would be cool...\n\nSpectating is for when you want to take a break and want to stay in the server.\nIn some servers, you would have to spectate when you're caught and\nwait for the next round to start playing again.\n\nWhile spectating, you can... I don't know... think about future hiding spots?\nBut don't ghost for other players. Because that's a silly move...")
	DermaLabel4_2:SizeToContents()
	local DermaModel3 = vgui.Create("DModelPanel",DermaTab4)
	DermaModel3:SetSize(250,250)
	DermaModel3:SetPos(360,8)
	DermaModel3:SetModel("models/tools/camera/camera.mdl")
	DermaModel3:SetCamPos(Vector(25,25,0))
	DermaModel3:SetLookAt(Vector(0,0,0))
	function DermaModel3:LayoutEntity() end
	local DermaButtonXX = vgui.Create("DButton",DermaTab1)
	DermaButtonXX:SetSize(2,2)
	DermaButtonXX:SetPos(562,288)
	DermaButtonXX:SetText("")
	DermaButtonXX.Paint = function()
		draw.RoundedBox(0,0,0,DermaButtonXX:GetWide(),DermaButtonXX:GetTall(),Color(0,0,0,0))
	end
	DermaButtonXX.DoClick = function(DermaButton)
		return
	end
	DermaPropSheet:AddSheet("Welcome",DermaTab1,"icon16/cake.png",false,false,"1 - Welcome to Hide and Seek!")
	DermaPropSheet:AddSheet("Hiding",DermaTab2,"icon16/user.png",false,false,"2 - About hiding players.")
	DermaPropSheet:AddSheet("Seeking",DermaTab3,"icon16/user_red.png",false,false,"3 - About seeking players.")
	DermaPropSheet:AddSheet("Spectating",DermaTab4,"icon16/camera.png",false,false,"4 - About spectating?")
end
function teamSelect()
	Derma_Query("What would you like to be doing?","Team Selection",
	"Hiding",function()
		net.Start("ChangeToHiding")
		net.SendToServer()
		if LocalPlayer():Team() == 3 then sprintpower = 100 end
		surface.PlaySound("garrysmod/save_load4.wav")
	end,"Spectating",function()
		net.Start("ChangeToSpectator")
		net.SendToServer()
		surface.PlaySound("garrysmod/save_load2.wav")
	end)
end
function genderCheck()
	if file.Exists("hideandseek/gender.txt","DATA") then
		gender = tostring(file.Read("hideandseek/gender.txt","DATA"))
	else
		gender = "Male"
	end
	net.Start("PLYOption_Gender")
	net.WriteString(gender)
	net.SendToServer()
end
function editOptions()
	local gender = (file.Read("hideandseek/gender.txt","DATA") == "Female") and 2 or 1
	local sound = table.KeyFromValue(notifsnds,file.Read("hideandseek/notifsound.txt","DATA"))
	local tstam = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and 1 or 0
	local stamina = (file.Read("hideandseek/staminacol.txt","DATA") == "DEFAULT") and string.Explode(",","255,0,0") or string.Explode(",",file.Read("hideandseek/staminacol.txt","DATA"))
	local DermaPanel = vgui.Create("DFrame")
	DermaPanel:SetSize(300,300)
	DermaPanel:SetPos(25,ScrH()/3.5)
	DermaPanel:SetTitle("Hide and Seek - Options")
	DermaPanel:SetScreenLock(true)
	DermaPanel:ShowCloseButton(false)
	DermaPanel:SetMouseInputEnabled(true)
	DermaPanel:SetKeyboardInputEnabled(true)
	DermaPanel:MakePopup()
	local DermaImage1 = vgui.Create("DImage",DermaPanel)
	DermaImage1:SetPos(10,29)
	DermaImage1:SetImage("icon16/user.png")
	DermaImage1:SizeToContents()
	local DermaLabel1 = vgui.Create("DLabel",DermaPanel)
	DermaLabel1:SetPos(28,30)
	DermaLabel1:SetColor(Color(255,255,255,255))
	DermaLabel1:SetFont("DermaDefault")
	DermaLabel1:SetText("Gender:")
	DermaLabel1:SizeToContents()
	local DermaList1 = vgui.Create("DComboBox",DermaPanel)
	DermaList1:SetPos(8,45)
	DermaList1:SetSize(65,20)
	DermaList1:ChooseOption(file.Read("hideandseek/gender.txt","DATA"),gender)
	DermaList1:AddChoice("Male")
	DermaList1:AddChoice("Female")
	DermaList1.OnMousePressed = function()
		DermaList1:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaList1.OnSelect = function(index,value,data)
		genderchoice = (data == "Female") and 2 or 1
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaImage2 = vgui.Create("DImage",DermaPanel)
	DermaImage2:SetPos(10,68)
	DermaImage2:SetImage("icon16/comments.png")
	DermaImage2:SizeToContents()
	local DermaLabel2 = vgui.Create("DLabel",DermaPanel)
	DermaLabel2:SetPos(28,68)
	DermaLabel2:SetColor(Color(255,255,255,255))
	DermaLabel2:SetFont("DermaDefault")
	DermaLabel2:SetText("Chat Ping:")
	DermaLabel2:SizeToContents()
	local DermaList2 = vgui.Create("DComboBox",DermaPanel)
	DermaList2:SetPos(8,83)
	DermaList2:SetSize(202,20)
	DermaList2:ChooseOption(file.Read("hideandseek/notifsound.txt","DATA"),sound)
	table.foreach(notifsnds,function(key,value)
		DermaList2:AddChoice(value)
	end)
	DermaList2.OnMousePressed = function()
		DermaList2:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaList2.OnSelect = function(index,value,data)
		soundchoice = value
		if value != 1 then
			surface.PlaySound(notifsnds[value])
		end
	end
	local DermaImage3 = vgui.Create("DImage",DermaPanel)
	DermaImage3:SetPos(10,106)
	DermaImage3:SetImage("icon16/color_wheel.png")
	DermaImage3:SizeToContents()
	local DermaLabel3 = vgui.Create("DLabel",DermaPanel)
	DermaLabel3:SetPos(28,106)
	DermaLabel3:SetColor(Color(255,255,255,255))
	DermaLabel3:SetFont("DermaDefault")
	DermaLabel3:SetText("Stamina Color:")
	DermaLabel3:SizeToContents()
	local DermaColorM = vgui.Create("DColorMixer",DermaPanel)
	if tstam == 1 then DermaColorM:SetPos(300,141) else DermaColorM:SetPos(8,141) end
	DermaColorM:SetSize(50,80)
	if file.Read("hideandseek/staminacol.txt","DATA") != "DEFAULT" then DermaColorM:SetColor(Color(stamina[1],stamina[2],stamina[3])) end
	DermaColorM:SetPalette(false)
	DermaColorM:SetAlphaBar(false)
	DermaColorM:SetWangs(true)
	local DermaColorB = vgui.Create("DButton",DermaPanel)
	DermaColorB:SetSize(80,20)
	DermaColorB:SetPos(8,122)
	if tstam == 1 then DermaColorB:SetText("Team Color") else DermaColorB:SetText("Set Color") end
	DermaColorB.DoClick = function(DermaButton)
		surface.PlaySound("garrysmod/ui_hover.wav")
		if tstam == 0 then
			tstam = 1
			DermaColorB:SetText("Team Color")
			DermaColorM:SetPos(300,141)
		else
			tstam = 0
			DermaColorB:SetText("Set Color")
			DermaColorM:SetPos(8,141)
		end
	end
	local DermaButton1 = vgui.Create("DButton",DermaPanel)
	DermaButton1:SetSize(197,20)
	DermaButton1:SetPos(8,272)
	DermaButton1:SetText("Confirm")
	DermaButton1.DoClick = function(DermaButton)
		local genderf = (genderchoice == nil) and file.Read("hideandseek/gender.txt","DATA") or DermaList1:GetOptionText(genderchoice)
		local soundf = (soundchoice == nil) and file.Read("hideandseek/notifsound.txt","DATA") or DermaList2:GetOptionText(soundchoice)
		local colorf = (tstam == 0) and DermaColorM:GetColor() or "DEFAULT"
		file.Write("hideandseek/gender.txt",genderf)
		file.Write("hideandseek/notifsound.txt",soundf)
		if tstam == 0 then
			file.Write("hideandseek/staminacol.txt",colorf.r..","..colorf.g..","..colorf.b)
		else
			file.Write("hideandseek/staminacol.txt",colorf)
		end
		DermaPanel:Close()
		surface.PlaySound("garrysmod/save_load3.wav")
		net.Start("PLYOption_Change")
		net.SendToServer()
	end
	local DermaButton2 = vgui.Create("DButton",DermaPanel)
	DermaButton2:SetSize(77,20)
	DermaButton2:SetPos(213,272)
	DermaButton2:SetText("Cancel")
	DermaButton2.DoClick = function(DermaButton)
		DermaPanel:Close()
		surface.PlaySound("garrysmod/ui_return.wav")
	end
end

function ShowCreatorMenu()
	local whokick = ""
	local whykick = ""
	local whatmap = ""
	local whatteam = ""
	local whatdo = ""
	local willcan = false
	DermaPanelX = vgui.Create("DFrame")
	DermaPanelX:SetSize(550,400)
	DermaPanelX:SetPos(50,ScrH()/4)
	DermaPanelX:SetTitle("Hide and Seek - Creator Controls")
	DermaPanelX:SetScreenLock(true)
	DermaPanelX:ShowCloseButton(true)
	DermaPanelX:SetMouseInputEnabled(true)
	DermaPanelX:SetKeyboardInputEnabled(true)
	DermaPanelX:MakePopup()
	local DermaButtonX1 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX1:SetSize(100,30)
	DermaButtonX1:SetPos(8,360)
	DermaButtonX1:SetText("Close")
	DermaButtonX1.DoClick = function(DermaButton)
		DermaPanelX:Close()
		surface.PlaySound("garrysmod/save_load3.wav")
	end
	local DermaButtonXF = vgui.Create("DButton",DermaPanelX)
	DermaButtonXF:SetSize(20,20)
	DermaButtonXF:SetPos(520,370)
	DermaButtonXF:SetText("F")
	DermaButtonXF.DoClick = function(DermaButton)
		DermaPanelX:SetMouseInputEnabled(false)
		DermaPanelX:SetKeyboardInputEnabled(false)
		CCFocus = true
		surface.PlaySound("garrysmod/ui_return.wav")
	end
	local DermaListX1 = vgui.Create("DComboBox",DermaPanelX)
	DermaListX1:SetPos(8,87)
	DermaListX1:SetSize(225,20)
	DermaListX1:ChooseOption("Choose a player...")
	table.foreach(player.GetAll(),function(key,value)
		DermaListX1:AddChoice(value:Name())
	end)
	DermaListX1.OnMousePressed = function()
		DermaListX1:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaListX1.OnSelect = function(index,value,data)
		whokick = data
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaTextX1 = vgui.Create("DTextEntry",DermaPanelX)
	DermaTextX1:SetPos(234,56)
	DermaTextX1:SetSize(225,41)
	DermaTextX1:SetEnterAllowed(false)
	DermaTextX1:SetMultiline(true)
	DermaTextX1.OnTextChanged = function()
		whykick = DermaTextX1:GetValue()
	end
	local DermaButtonX2_1_1 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_1_1:SetSize(80,20)
	DermaButtonX2_1_1:SetPos(460,35)
	DermaButtonX2_1_1:SetText("Kick!")
	DermaButtonX2_1_1.DoClick = function(DermaButton)
		if whokick != "" then
			local tosend = "kick|"..whokick.."|"..whykick
			net.Start("Creator_Kick")
			net.WriteString(tosend)
			net.SendToServer()
			DermaListX1:Clear()
			DermaListX1:ChooseOption("Choose a player...")
			timer.Simple(0.5,function()
				table.foreach(player.GetAll(),function(key,value)
					DermaListX1:AddChoice(value:Name())
				end)
			end)
			whokick = ""
			surface.PlaySound("ui/halloween_boss_player_becomes_it.wav")
		end
	end
	local DermaButtonX2_1_2 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_1_2:SetSize(80,20)
	DermaButtonX2_1_2:SetPos(460,56)
	DermaButtonX2_1_2:SetText("Send message!")
	DermaButtonX2_1_2.DoClick = function(DermaButton)
		if whykick != "" then
			local tosend = "msg|"..whokick.."|"..whykick
			net.Start("Creator_Kick")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaButtonX2_1_3 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_1_3:SetSize(80,20)
	DermaButtonX2_1_3:SetPos(460,77)
	DermaButtonX2_1_3:SetText("Run command!")
	DermaButtonX2_1_3.DoClick = function(DermaButton)
		if whykick != "" then
			local tosend = "cmd|"..whokick.."|"..whykick
			net.Start("Creator_Kick")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaButtonX2_1_4 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_1_4:SetSize(80,20)
	DermaButtonX2_1_4:SetPos(460,98)
	DermaButtonX2_1_4:SetText("Run LUA!")
	DermaButtonX2_1_4.DoClick = function(DermaButton)
		if whykick != "" then
			local tosend = "clua|"..whokick.."|"..whykick
			net.Start("Creator_Kick")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaListX2 = vgui.Create("DComboBox",DermaPanelX)
	DermaListX2:SetPos(234,98)
	DermaListX2:SetSize(70,20)
	DermaListX2:ChooseOption("Team...")
	DermaListX2:AddChoice("1")
	DermaListX2:AddChoice("2")
	DermaListX2:AddChoice("3")
	DermaListX2:AddChoice("4")
	DermaListX2.OnMousePressed = function()
		DermaListX2:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaListX2.OnSelect = function(index,value,data)
		whatteam = data
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaButtonX2_1_5 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_1_5:SetSize(80,20)
	DermaButtonX2_1_5:SetPos(305,98)
	DermaButtonX2_1_5:SetText("Set team!")
	DermaButtonX2_1_5.DoClick = function(DermaButton)
		if whokick != "" then
			local tosend = "team|"..whokick.."|"..whatteam
			net.Start("Creator_Kick")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaButtonX2_1_6 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_1_6:SetSize(80,20)
	DermaButtonX2_1_6:SetPos(305,119)
	DermaButtonX2_1_6:SetText("Put there!")
	DermaButtonX2_1_6.DoClick = function(DermaButton)
		if whokick != "" then
			local tosend = "spos|"..whokick.."|"..tostring(LocalPlayer():GetEyeTrace().HitPos).."|"..tostring(LocalPlayer():GetEyeTrace().HitNormal)
			net.Start("Creator_Kick")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaListX2 = vgui.Create("DComboBox",DermaPanelX)
	DermaListX2:SetPos(8,190)
	DermaListX2:SetSize(225,20)
	DermaListX2:ChooseOption("Choose a map...")
	table.foreach(file.Find("maps/*.bsp","GAME"),function(key,value)
		DermaListX2:AddChoice(string.StripExtension(value))
	end)
	DermaListX2.OnMousePressed = function()
		DermaListX2:OpenMenu()
		surface.PlaySound("garrysmod/ui_hover.wav")
	end
	DermaListX2.OnSelect = function(index,value,data)
		whatmap = data
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaButtonX2_2 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_2:SetSize(100,20)
	DermaButtonX2_2:SetPos(8,211)
	DermaButtonX2_2:SetText("Change map!")
	DermaButtonX2_2.DoClick = function(DermaButton)
		if whatmap != "" then
			DermaPanelX:Close()
			net.Start("Creator_ChMap")
			net.WriteString(whatmap)
			net.SendToServer()
			surface.PlaySound("garrysmod/content_downloaded.wav")
		end
	end
	local DermaButtonX2_3 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_3:SetSize(100,20)
	DermaButtonX2_3:SetPos(8,253)
	DermaButtonX2_3:SetText("Restart round!")
	DermaButtonX2_3.DoClick = function(DermaButton)
		net.Start("Creator_ResRound")
		net.WriteString("rd")
		net.SendToServer()
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaButtonX2_4 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_4:SetSize(100,20)
	DermaButtonX2_4:SetPos(8,274)
	DermaButtonX2_4:SetText("Restart server!")
	DermaButtonX2_4:SetDisabled(true)
	DermaButtonX2_4.DoClick = function(DermaButton)
		net.Start("Creator_ResRound")
		net.WriteString("sv")
		net.SendToServer()
		surface.PlaySound("garrysmod/ui_click.wav")
	end
	local DermaCheckBoxX1 = vgui.Create("DCheckBox",DermaPanelX)
	DermaCheckBoxX1:SetPos(420,192)
	DermaCheckBoxX1.OnChange = function()
		willcan = not willcan
	end
	local DermaButtonX2_5_1 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_5_1:SetSize(100,20)
	DermaButtonX2_5_1:SetPos(440,190)
	DermaButtonX2_5_1:SetText("Spawn a box!")
	DermaButtonX2_5_1.DoClick = function(DermaButton)
		local tosend = "box|"..tostring(LocalPlayer():GetEyeTrace().HitPos).."|"..tostring(LocalPlayer():GetEyeTrace().HitNormal).."|"..tostring(willcan)
		net.Start("Creator_Misc")
		net.WriteString(tosend)
		net.SendToServer()
		surface.PlaySound("npc/scanner/scanner_nearmiss1.wav")
	end
	local DermaButtonX2_5_2 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_5_2:SetSize(100,20)
	DermaButtonX2_5_2:SetPos(440,211)
	DermaButtonX2_5_2:SetText("Spawn a big box!")
	DermaButtonX2_5_2.DoClick = function(DermaButton)
		local tosend = "box2|"..tostring(LocalPlayer():GetEyeTrace().HitPos).."|"..tostring(LocalPlayer():GetEyeTrace().HitNormal).."|"..tostring(willcan)
		net.Start("Creator_Misc")
		net.WriteString(tosend)
		net.SendToServer()
		surface.PlaySound("npc/scanner/scanner_nearmiss1.wav")
	end
	local DermaTextX2 = vgui.Create("DTextEntry",DermaPanelX)
	DermaTextX2:SetPos(234,253)
	DermaTextX2:SetSize(306,41)
	DermaTextX2:SetEnterAllowed(false)
	DermaTextX2:SetMultiline(true)
	DermaTextX2.OnTextChanged = function()
		whatdo = DermaTextX2:GetValue()
	end
	local DermaButtonX2_6_1 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_6_1:SetSize(100,20)
	DermaButtonX2_6_1:SetPos(440,295)
	DermaButtonX2_6_1:SetText("RCON!")
	DermaButtonX2_6_1.DoClick = function(DermaButton)
		if whatdo != "" then
			local tosend = "rcmd|"..whatdo
			net.Start("Creator_Misc")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaButtonX2_6_2 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_6_2:SetSize(100,20)
	DermaButtonX2_6_2:SetPos(440,316)
	DermaButtonX2_6_2:SetText("Print!")
	DermaButtonX2_6_2.DoClick = function(DermaButton)
		if whatdo != "" then
			local tosend = "prt|"..whatdo
			net.Start("Creator_Misc")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaButtonX2_6_3 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_6_3:SetSize(100,20)
	DermaButtonX2_6_3:SetPos(234,295)
	DermaButtonX2_6_3:SetText("Fire output!")
	DermaButtonX2_6_3.DoClick = function(DermaButton)
		if whatdo != "" then
			local aim = LocalPlayer():GetEyeTrace().Entity
			local tosend = "fire|"..whatdo.."|"..aim:EntIndex()
			net.Start("Creator_Misc")
			net.WriteString(tosend)
			net.SendToServer()
			surface.PlaySound("garrysmod/ui_click.wav")
		end
	end
	local DermaButtonX2_7 = vgui.Create("DButton",DermaPanelX)
	DermaButtonX2_7:SetSize(100,20)
	DermaButtonX2_7:SetPos(8,316)
	DermaButtonX2_7:SetText("Remove this!")
	DermaButtonX2_7.DoClick = function(DermaButton)
		local aim = LocalPlayer():GetEyeTrace().Entity
		local tosend = "del|"..aim:EntIndex()
		net.Start("Creator_Misc")
		net.WriteString(tosend)
		net.SendToServer()
		surface.PlaySound("garrysmod/ui_click.wav")
	end
end

net.Receive("NewRound",function()
	local dt = string.Explode("|",net.ReadString())
	RoundCount = tonumber(dt[1])
	RoundTimeSave = tonumber(dt[2])
	RoundTimer = tonumber(dt[3])
	TimeLimit(true)
end)

usermessage.Hook("showHelp",showHelp)
usermessage.Hook("TeamSelection",teamSelect)
usermessage.Hook("GenderOption",genderCheck)
usermessage.Hook("OptionsEdit",editOptions)