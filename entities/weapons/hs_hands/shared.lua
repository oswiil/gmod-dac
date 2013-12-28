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

	if not IsValid(self.Owner) then return end
	self.Owner:LagCompensation(true)

	if SERVER then self:ServerHandleAttack() end

	self.Owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
