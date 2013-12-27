local PANEL = {}

function PANEL:Init(...)
	self.BaseClass.Init(self, ...)

	self:SetCursor("hand")
	self:SetDrawBackground( false )
	self:SetDrawBorder( false )

	self.SelectedColor = Color(255,255,255)
	self.Image = vgui.Create("DImage", self)
end

function PANEL:PerformLayout()
	self.Image:SetPos(0, 0)
	self.Image:SetSize(self:GetSize())
end

function PANEL:SetDisabled(bDisabled)
	self.BaseClass.SetDisabled(self, bDisabled)
end

function PANEL:SetImage(name)
	self.Image:SetImage(name)
end

function PANEL:SetSelected(selected)
	self.Selected = selected

	-- Disable the button after it's been clicked
	if self.Selected == nil then
		self:SetDisabled(false)
	else
		self:SetDisabled(true)
	end
end

function PANEL:SetSelectedColor(color)
	self.SelectedColor = color
end

function PANEL:PaintOver(w, h)
	surface.SetDrawColor(Color(255,255,255))
	surface.DrawOutlinedRect(0, 0, w, h)

	-- I explicity say true and false because nil means neutral
	if self.Selected == true then
		surface.SetDrawColor(self.SelectedColor)
		surface.DrawOutlinedRect(0, 0, w, h)
	elseif self.Selected == false then
		surface.SetDrawColor(Color(0,0,0,220))
		surface.DrawRect(0, 0, w, h)
	end
end

function PANEL:DoClickInternal()
	if self.Selected == nil then
		self:SetSelected(true)
	end
end

derma.DefineControl("HS.ToggleImageOutlined", "", PANEL, "DButton")
