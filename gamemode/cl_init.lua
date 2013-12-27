game.AddParticles("particles/explosion.pcf")
game.AddParticles("particles/item_fx.pcf")
game.AddParticles("particles/cig_smoke.pcf")

HS = {}

include("cl_logging.lua")
include("shared.lua")

include("gui/toggleimage.lua")
include("gui/mapvote.lua")

include("cl_deferfunc.lua")
include("cl_countdown.lua")
include("cl_statemanager.lua")

function GM:Initialize()
end

function GM:HUDShouldDraw(name)
	local res = not (name == "CHudWeaponSelection" 
		        or name == "CHudHealth" 
		        or name == "CHudBattery" 
		        or name == "CHudPoisonDamageIndicator" 
		        or name == "CHudZoom")
	return res
	--return true
end

function GM:HUDPaint()
	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)
end

function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	if (trace.Entity:IsPlayer()) and not (LocalPlayer():Team() == HS.TeamManager.TEAM_SEEKING and trace.Entity:Team() ~= HS.TeamManager.TEAM_SEEKING) then
		text = trace.Entity:Nick()
	else
		return
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30
	
	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = team.GetName(trace.Entity:Team())
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2
	
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
end

net.Receive("HS.SpawnEffect", function()
	ParticleEffect(net.ReadString(), net.ReadVector(), net.ReadAngle(), nil)
end)

net.Receive("HS.AttachEffect", function()
	ParticleEffectAttach(net.ReadString(), net.ReadInt(8), net.ReadEntity(), net.ReadInt(8))
end)

function net.Incoming( len, client )
	local i = net.ReadHeader()
	local strName = util.NetworkIDToString( i )
	
	if ( !strName ) then return end
	
	print("net message: " .. strName)

	local func = net.Receivers[ strName:lower() ]
	if ( !func ) then return end

	--
	-- len includes the 16 byte int which told us the message name
	--
	len = len - 16
	
	func( len, client )
end

-- Test Global
HS.Globals.RegisterReplicated("boobs")
