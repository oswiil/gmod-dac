hook.Add("PlayerUse", "HS.PushProps.HandleUse", function(ply, ent)
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
end)
