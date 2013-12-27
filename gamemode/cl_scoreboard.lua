function ScoBRefreshIt()
	if IsValid(ScoBBase) then ScoBBase:Close() end
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
	ScoBHeader2_3:SetText("v2")
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
	local size = (HS.TeamManager.NumSpectators() > 0) and 550 or 700
	local n = 0
	for k,v in pairs(player.GetAll()) do
		if v:Team() != HS.TeamManager.TEAM_SPECTATOR then
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
					timer.Create("ScoBRefresh",0.2,0,ScoBRefreshIt)
					surface.PlaySound("garrysmod/ui_return.wav")
					end)
				else
					ScoBPlyABMenu:AddOption("Mute",function()
					v:SetMuted(true)
					timer.Create("ScoBRefresh",0.2,0,ScoBRefreshIt)
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
			--if LocalPlayer():Team() != HS.TeamManager.TEAM_HIDING then
				local ScoBPlyPT = vgui.Create("DImage",ScoBPly)
				ScoBPlyPT:SetPos(230,10)
				if v:Team() == HS.TeamManager.TEAM_HIDING then ScoBPlyPT:SetImage("icon16/flag_blue.png") end
				if v:Team() == HS.TeamManager.TEAM_SEEKING then ScoBPlyPT:SetImage("icon16/flag_red.png") end
				if v:Team() == HS.TeamManager.TEAM_WAITING then ScoBPlyPT:SetImage("icon16/flag_green.png") end
				--if v:Team() == 4 and LocalPlayer():Team() != 2 then ScoBPlyPT:SetImage("icon16/camera_delete.png") end
				ScoBPlyPT:SizeToContents()
			--end
		else
			table.insert(specs,v:Name())
		end
	end
	if HS.TeamManager.NumSpectators(3) > 0 then
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

function GM:ScoreboardShow()
	if not ScoBIsShowing then ScoBShow() end
	timer.Create("ScoBRefresh",0.2,0,ScoBRefreshIt)
	return true
end

function GM:ScoreboardHide()
	ScoBHide()
end

hook.Add("KeyPress", "HS.Scoreboard.Focus", function(ply, key)
	if key == IN_ATTACK2 then
		if ply:KeyDown(IN_SCORE) then
			ScoBFocus = true
			ScoBBase:MakePopup()
			ScoBBase:SetKeyBoardInputEnabled(false)
		end
	end
end)
