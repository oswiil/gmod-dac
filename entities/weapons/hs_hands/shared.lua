SWEP.Author = "McSimp"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = "Tagging weapon for Hide and Seek"

SWEP.IconLetter = ""
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.25)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.25)

	local currentStateName = HS.StateManager.CurrentState().Name

	-- Seekers can't do anything in the hiding time time
	if self.Owner:Team() == HS.TeamManager.TEAM_SEEKING and currentStateName == "hidingtime" then return end

	if CLIENT then return end

	-- If we're in the post round, do the sounds
	if currentStateName == "postround" then
		self.Owner:EmitSound("misc/happy_birthday_tf_" .. math.random(10,29) .. ".wav", 75, math.random(97,103))
	end

	local ent = self.Owner:GetEyeTrace()
	local entply = ent.Entity
	local entdis = self.Owner:EyePos():Distance(ent.HitPos)
	self.Owner:ViewPunch(Angle(-1,0,0))
	
	if (entply:GetClass() == "func_breakable_surf" or entply:GetClass() == "func_breakable") and entdis <= 100 then
		entply:Fire("RemoveHealth", 25)
		self.Owner:EmitSound("physics/body/body_medium_impact_hard"..math.random(2,3)..".wav",78,math.random(98,102))
	end

	-- Only allow seekers to catch people
	if self.Owner:Team() ~= HS.TeamManager.TEAM_SEEKING or currentStateName ~= "inround" then return end
	
	if entply:IsPlayer() and entdis <= 120 and entply:Team() == HS.TeamManager.TEAM_HIDING then
		entply:ViewPunch(Angle(8,math.random(-16,16),0))
		HS.StateManager.CurrentState():HandleCaught(self.Owner, entply)
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
