local PlyMeta = FindMetaTable("Player")

function PlyMeta:MakeSeeker()
	self:SetTeam(HS.TeamManager.TEAM_SEEKING)
	self:AllowFlashlight(true)
	self:SetWalkSpeed(200)
	self.WalkSpeed = 200
	self:SetRunSpeed(360)
	self.RunSpeed = 360
	self:StripWeapons()

	if self:FlashlightIsOn() then
		self:Flashlight(false)
	end

	self:SetPlayerColor(Vector(0.6,0.2,0))

	self:Give("hs_hands")
end

function PlyMeta:MakeHider()
	self:SetTeam(HS.TeamManager.TEAM_HIDING)
	self:AllowFlashlight(false)
	self:SetWalkSpeed(190)
	self.WalkSpeed = 190
	self:SetRunSpeed(320)
	self.RunSpeed = 320
	self:StripWeapons()

	if self:FlashlightIsOn() then
		self:Flashlight(false)
	end

	self:SetPlayerColor(Vector(0,0.2,0.6))

	self:Give("hs_hands")
end

function PlyMeta:MakeWaiting()
	self:SetTeam(HS.TeamManager.TEAM_WAITING)
	self:AllowFlashlight(true)
	self:SetWalkSpeed(200)
	self.WalkSpeed = 200
	self:SetRunSpeed(360)
	self.RunSpeed = 360
	self:StripWeapons()

	self:SetPlayerColor(Vector(0,0.6,0.2))
end

function PlyMeta:SpawnConfetti()
	local headIndex = self:LookupBone("ValveBiped.Bip01_Head1")
	local headPos, headAng = self:GetBonePosition(headIndex)
	HS.SpawnEffect("bday_confetti", headPos, headAng)
end

function PlyMeta:AttachEffect(name)
	HS.AttachEffect(name, PATTACH_POINT_FOLLOW, self, self:LookupAttachment("anim_attachment_head"))
end

local oldSetTeam = PlyMeta.SetTeam
function PlyMeta:SetTeam(newTeamID)
	GAMEMODE:OnPlayerChangedTeam(self, self:Team(), newTeamID)
	oldSetTeam(self, newTeamID)
end

function PlyMeta:GetWalkSpeed()
	return self.WalkSpeed or 200
end

function PlyMeta:GetRunSpeed()
	return self.RunSpeed or 360
end
