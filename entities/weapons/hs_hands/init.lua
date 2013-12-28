AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function SetupHiderTaunts(gender)
	return {
		"vo/npc/" .. gender .. "01/answer20.wav",
		"vo/npc/" .. gender .. "01/gordead_ans05.wav",
		"vo/npc/" .. gender .. "01/gordead_ans06.wav",
		"vo/npc/" .. gender .. "01/behindyou01.wav",
		"vo/npc/" .. gender .. "01/hi01.wav",
		"vo/npc/" .. gender .. "01/hi02.wav",
		"vo/npc/" .. gender .. "01/illstayhere01.wav",
		"vo/npc/" .. gender .. "01/littlecorner01.wav",
		"vo/npc/" .. gender .. "01/runforyourlife01.wav",
		"vo/npc/" .. gender .. "01/question30.wav",
		"vo/npc/" .. gender .. "01/waitingsomebody.wav",
		"vo/npc/" .. gender .. "01/uhoh.wav",
		"vo/npc/" .. gender .. "01/incoming02.wav",
		"vo/npc/" .. gender .. "01/yougotit02.wav",
		"vo/npc/" .. gender .. "01/gethellout.wav",
		"vo/npc/" .. gender .. "01/strider_run.wav",
		"vo/npc/" .. gender .. "01/overhere01.wav",
		"vo/canals/" .. gender .. "01/stn6_go_nag02.wav",
		"vo/trainyard/" .. gender .. "01/cit_window_use01.wav",
		"vo/trainyard/" .. gender .. "01/cit_window_use02.wav",
		"vo/trainyard/" .. gender .. "01/cit_window_use03.wav",
		"vo/coast/barn/" .. gender ..  "01/youmadeit.wav",
		"ambient/voices/cough2.wav",
		"ambient/voices/cough3.wav"
	}
end

local function SetupSeekerTaunts(gender)
	return {
		"vo/npc/" .. gender .. "01/readywhenyouare01.wav",
		"vo/npc/" .. gender .. "01/readywhenyouare02.wav",
		"vo/npc/" .. gender .. "01/squad_approach02.wav",
		"vo/npc/" .. gender .. "01/squad_away01.wav",
		"vo/npc/" .. gender .. "01/squad_away02.wav",
		"vo/npc/" .. gender .. "01/upthere01.wav",
		"vo/npc/" .. gender .. "01/upthere02.wav",
		"vo/npc/" .. gender .. "01/gotone01.wav",
		"vo/npc/" .. gender .. "01/gotone02.wav",
		"vo/npc/" .. gender .. "01/overthere01.wav",
		"vo/npc/" .. gender .. "01/overthere02.wav",
		"vo/npc/" .. gender .. "01/hi01.wav",
		"vo/npc/" .. gender .. "01/hi02.wav",
		"vo/coast/odessa/" .. gender .. "01/stairman_follow01.wav",
		"ambient/voices/cough2.wav",
		"ambient/voices/cough3.wav"
	}
end

local function SetupPostRoundTaunts(gender)
	return {
		"vo/npc/" .. gender .. "01/yeah02.wav",
		"vo/coast/odessa/" .. gender .. "01/nlo_cheer01.wav",
		"vo/coast/odessa/" .. gender .. "01/nlo_cheer02.wav",
		"vo/coast/odessa/" .. gender .. "01/nlo_cheer03.wav"
	}
end

local FemaleSeekerTaunts = SetupSeekerTaunts("female")
local MaleSeekerTaunts = SetupSeekerTaunts("male")

local FemaleHiderTaunts = SetupHiderTaunts("female")
local MaleHiderTaunts = SetupHiderTaunts("male")

local FemalePostRoundTaunts = SetupPostRoundTaunts("female")
local MalePostRoundTaunts = SetupPostRoundTaunts("male")

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)
	self.NextTaunt = 0
end

-- Reloading plays a taunt
function SWEP:Reload()
	if self.NextTaunt > CurTime() then return end

	local currentStateName = HS.StateManager.CurrentState().Name

	self.NextTaunt = CurTime() + 2.5

	-- TODO: Female/male models
	local tauntTable
	if currentStateName == "inround" or currentStateName == "hidingtime" then
		if self.Owner:Team() == HS.TeamManager.TEAM_SEEKING then
			tauntTable = MaleSeekerTaunts
		elseif self.Owner:Team() == HS.TeamManager.TEAM_HIDING then
			tauntTable = MaleHiderTaunts
		else
			error("Player is not a seeker or hider (" .. tostring(ply) .. ")")
		end
	else
		tauntTable = MalePostRoundTaunts
	end

	self.Owner:EmitSound(table.Random(tauntTable), 89, math.random(98,102))
end

function SWEP:GetTrace(range)
	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * range)

	local kmins = Vector(1,1,1) * -10
	local kmaxs = Vector(1,1,1) * 10

	local tr = util.TraceHull({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

	-- Hull might hit environment stuff that line does not hit
	if not IsValid(tr.Entity) then
		tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
	end

	return tr
end

function SWEP:ServerHandleAttack()
	local currentStateName = HS.StateManager.CurrentState().Name

	-- Seekers can't do anything in the hiding time time
	if self.Owner:Team() == HS.TeamManager.TEAM_SEEKING and currentStateName == "hidingtime" then return end

	-- If we're in the post round, do the sounds
	if currentStateName == "postround" then
		self.Owner:EmitSound("misc/happy_birthday_tf_" .. math.random(10,29) .. ".wav", 75, math.random(97,103))
	end

	self.Owner:ViewPunch(Angle(-1,0,0))

	-- Tagging/damage stuff
	local tr = self:GetTrace(110)

	local hitEnt = tr.Entity

	if tr.Hit and tr.HitNonWorld and IsValid(hitEnt) then
		if hitEnt:IsPlayer() 
		   and hitEnt:Team() == HS.TeamManager.TEAM_HIDING 
		   and self.Owner:Team() == HS.TeamManager.TEAM_SEEKING
		   and currentStateName == "inround" then

			hitEnt:ViewPunch(Angle(8,math.random(-16,16),0))
			HS.StateManager.CurrentState():HandleCaught(self.Owner, hitEnt)

		elseif hitEnt:GetClass() == "func_breakable_surf" or hitEnt:GetClass() == "func_breakable" then

			hitEnt:Fire("RemoveHealth", 25)
			self.Owner:EmitSound("physics/body/body_medium_impact_hard" .. math.random(2,3) .. ".wav", 78, math.random(98,102))

		end
	end
end

function SWEP:Think()
	if not IsValid(self.Owner) then return end
	if self.Owner:Team() ~= HS.TeamManager.TEAM_SEEKING then return end
	if HS.StateManager.CurrentState().Name ~= "inround" then return end

	local tr = self:GetTrace(80)
	local hitEnt = tr.Entity

	if tr.Hit and tr.HitNonWorld and IsValid(hitEnt) then
		if hitEnt:IsPlayer() and hitEnt:Team() == HS.TeamManager.TEAM_HIDING then
			hitEnt:ViewPunch(Angle(8,math.random(-16,16),0))
			HS.StateManager.CurrentState():HandleCaught(self.Owner, hitEnt)
		end
	end
end
