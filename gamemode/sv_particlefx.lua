util.AddNetworkString("HS.SpawnEffect")
util.AddNetworkString("HS.AttachEffect")

function HS.SpawnEffect(effectName, pos, angle)
	net.Start("HS.SpawnEffect")
		net.WriteString(effectName)
		net.WriteVector(pos)
		net.WriteAngle(angle)
	net.Broadcast()
end

function HS.AttachEffect(effectName, attachType, ent, attachmentID)
	net.Start("HS.AttachEffect")
		net.WriteString(effectName)
		net.WriteInt(attachType, 8)
		net.WriteEntity(ent)
		net.WriteInt(attachmentID, 8)
	net.Broadcast()
end
