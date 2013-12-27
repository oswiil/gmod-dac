surface.CreateFont("HS.Voting.VoteFont", {
	font = "Trebuchet MS",
	size = 19,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("HS.Voting.CountdownFont", {
	font = "Tahoma",
	size = 32,
	weight = 700,
	antialias = true,
	shadow = true
})

local PANEL = {}

function PANEL:Init()
	self:ParentToHUD()
	
	self.Canvas = vgui.Create("Panel", self)
	self.Canvas:MakePopup()
	self.Canvas:SetKeyboardInputEnabled(false)
	
	self.CountDown = vgui.Create("DLabel", self.Canvas)
	self.CountDown:SetTextColor(color_white)
	self.CountDown:SetFont("HS.Voting.CountdownFont")
	self.CountDown:SetText("")
	self.CountDown:SetPos(0, 14)
	
	self.LikeMapQ = vgui.Create("DLabel", self.Canvas)
	self.LikeMapQ:SetTextColor(color_white)
	self.LikeMapQ:SetFont("HS.Voting.CountdownFont")
	self.LikeMapQ:SetText("Did you like this map?")
	self.LikeMapQ:SetPos(0, 60)

	self.LikeContainer = vgui.Create("DIconLayout", self.Canvas)
	self.LikeContainer:SetSpaceX(30)
	self.LikeContainer:SetSize(300, 128)
	self.LikeContainer:SetPos(0, 110)

	self.LikeButton = vgui.Create("HS.ToggleImageOutlined", self.Canvas)
	self.LikeButton:SetSize(128, 128)
	self.LikeButton:SetImage("hideseek/maplike.png")
	self.LikeButton:SetSelectedColor(Color(49,219,121))
	self.LikeButton.DoClick = function()
		net.Start("HS.MapVote.MapOpinion")
			net.WriteBit(true)
		net.SendToServer()
		self.DislikeButton:SetSelected(false)
	end
	self.LikeContainer:Add(self.LikeButton)

	self.DislikeButton = vgui.Create("HS.ToggleImageOutlined", self.Canvas)
	self.DislikeButton:SetSize(128, 128)
	self.DislikeButton:SetImage("hideseek/mapdislike.png")
	self.DislikeButton:SetSelectedColor(Color(231,76,60))
	self.DislikeButton.DoClick = function()
		net.Start("HS.MapVote.MapOpinion")
			net.WriteBit(false)
		net.SendToServer()
		self.LikeButton:SetSelected(false)
	end
	self.LikeContainer:Add(self.DislikeButton)

	self.MapList = vgui.Create("DPanelList", self.Canvas)
	self.MapList:SetDrawBackground(false)
	self.MapList:SetSpacing(4)
	self.MapList:SetPadding(4)
	self.MapList:EnableHorizontal(true)
	self.MapList:EnableVerticalScrollbar()

	self.Voters = {}
	self.Votes = {}
	self.EndTime = 0
end

function PANEL:PerformLayout()
	local cx, cy = chat.GetChatBoxPos()
	
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
	
	local extra = math.Clamp(300, 0, ScrW() - 640)
	self.Canvas:StretchToParent(0, 0, 0, 0)
	self.Canvas:SetWide(640 + extra)
	self.Canvas:SetTall(cy -60)
	self.Canvas:SetPos(0, 0)
	self.Canvas:CenterHorizontal()
	self.Canvas:SetZPos(0)
	
	self.MapList:StretchToParent(0, 250, 0, 0)

	self.LikeMapQ:SizeToContents()
	self.LikeMapQ:CenterHorizontal()

	self.LikeContainer:CenterHorizontal()
end

function PANEL:AddVoter(voter)
	for _,v in pairs(self.Voters) do
		if v.Player and v.Player == voter then
			return false
		end
	end

	local iconContainer = vgui.Create("Panel", self.MapList:GetCanvas())
	local icon = vgui.Create("AvatarImage", iconContainer)
	icon:SetSize(16, 16)
	icon:SetZPos(1000)
	icon:SetTooltip(voter:Name())
	iconContainer.Player = voter
	iconContainer:SetTooltip(voter:Name())
	icon:SetPlayer(voter, 16)

	iconContainer:SetSize(20, 20)
	icon:SetPos(2, 2)
	
	iconContainer.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 80))
		
		if iconContainer.img then
			surface.SetMaterial(iconContainer.img)
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(2, 2, 16, 16)
		end
	end
	
	table.insert(self.Voters, iconContainer)
end

function PANEL:Think()
	for k,v in pairs(self.MapList:GetItems()) do
		v.NumVotes = 0
	end
	
	for k, v in pairs(self.Voters) do
		if not IsValid(v.Player) then
			v:Remove()
		else
			if not self.Votes[v.Player:SteamID()] then
				v:Remove()
			else
				local bar = self:GetMapButton(self.Votes[v.Player:SteamID()])
				
				bar.NumVotes = bar.NumVotes + 1
				
				if IsValid(bar) then
					local CurrentPos = Vector(v.x, v.y, 0)
					local NewPos = Vector((bar.x + bar:GetWide()) - 21 * bar.NumVotes - 2, bar.y + (bar:GetTall() * 0.5 - 10), 0)
					
					if not v.CurPos or v.CurPos ~= NewPos then
						v:MoveTo(NewPos.x, NewPos.y, 0.3)
						v.CurPos = NewPos
					end
				end
			end
		end
		
	end
	
	local timeLeft = math.Round(math.Clamp(self.EndTime - CurTime(), 0, math.huge))
	
	self.CountDown:SetText(tostring(timeLeft or 0).." seconds")
	self.CountDown:SizeToContents()
	self.CountDown:CenterHorizontal()
end

function PANEL:SetMaps(maps)
	self.MapList:Clear()
	
	for k, v in RandomPairs(maps) do
		local button = vgui.Create("DButton", self.mapList)
		button.ID = k
		button:SetText(v)
		
		button.DoClick = function()
			net.Start("HS.MapVote.ClientUpdateVote")
				net.WriteUInt(button.ID, 32)
			net.SendToServer()
		end
		
		do
			local Paint = button.Paint
			button.Paint = function(s, w, h)
				local col = Color(255, 255, 255, 10)
				
				if(button.bgColor) then
					col = button.bgColor
				end
				
				draw.RoundedBox(4, 0, 0, w, h, col)
				Paint(s, w, h)
			end
		end
		
		button:SetTextColor(color_white)
		button:SetContentAlignment(4)
		button:SetTextInset(8, 0)
		button:SetFont("HS.Voting.VoteFont")
		
		local extra = math.Clamp(300, 0, ScrW() - 640)
		
		button:SetDrawBackground(false)
		button:SetTall(24)
		button:SetWide(285 + (extra / 2) + 25)
		button.NumVotes = 0

		self.MapList:AddItem(button)
	end
end

function PANEL:GetMapButton(id)
	for k, v in pairs(self.MapList:GetItems()) do
		if v.ID == id then return v end
	end
	
	return false
end

function PANEL:Paint()
	Derma_DrawBackgroundBlur(self)
	
	local CenterY = ScrH() / 2
	local CenterX = ScrW() / 2
	
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function PANEL:Flash(id)
	self:SetVisible(true)

	local bar = self:GetMapButton(id)
	
	if(IsValid(bar)) then
		timer.Simple( 0.0, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
		timer.Simple( 0.2, function() bar.bgColor = nil end )
		timer.Simple( 0.4, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
		timer.Simple( 0.6, function() bar.bgColor = nil end )
		timer.Simple( 0.8, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
		timer.Simple( 1.0, function() bar.bgColor = Color( 100, 100, 100 ) end )
	end
end

derma.DefineControl("HS.Voting.MapVoteScreen", "", PANEL, "DPanel")
