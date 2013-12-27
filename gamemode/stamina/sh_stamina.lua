local PlyMeta = FindMetaTable("Player")

function PlyMeta:GetStamina()
	if not self.Stamina then
		self.Stamina = 0
	end

	return self.Stamina
end

function PlyMeta:SetStamina(val)
	self.Stamina = math.Clamp(val, 0, self:GetMaxStamina())

	if SERVER then
		local newStamina = self.Stamina
		if newStamina <= 0 then
			self:SetRunSpeed(self:GetWalkSpeed())
		else
			self:SetRunSpeed(self:GetRunSpeed())
		end

		-- Sync the player every x seconds
		if not self.LastStaminaUpdate or self.LastStaminaUpdate < (CurTime() - 3) then
			self:SyncStamina()
		end
	end
end

function PlyMeta:GetStaminaDrain()
	return FrameTime() * (self:GetMaxStamina()/4)
end

function PlyMeta:GetStaminaRegen()
	return FrameTime() * (self:GetMaxStamina()/8)
end

function PlyMeta:GetMaxStamina()
	return 100
end

if SERVER then
	function PlyMeta:SyncStamina()
		net.Start("HS.Stamina.Sync")
			net.WriteFloat(self:GetStamina())
		net.Send(self)

		self.LastStaminaUpdate = CurTime()
	end
end

hook.Add("PlayerInitialSpawn", "HS.Stamina.Setup", function(ply)
	ply:SetStamina(ply:GetMaxStamina())
end)
