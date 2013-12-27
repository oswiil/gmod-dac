AddCSLuaFile("cl_stamina.lua")
AddCSLuaFile("sh_stamina.lua")
include("sh_stamina.lua")

local TEAM_HIDING = HS.TeamManager.TEAM_HIDING
local TEAM_SEEKING = HS.TeamManager.TEAM_SEEKING

util.AddNetworkString("HS.Stamina.Sync")

hook.Add("Think", "HS.Stamina.Update", function()
	local state = HS.StateManager.CurrentState().Name
	if not (state == "inround" or state == "hidingtime") then return end

	for _,ply in ipairs(player.GetAll()) do
		-- Make sure the player should actually be receiving a stamina update.
		if not ((ply:Team() == TEAM_HIDING or ply:Team() == TEAM_SEEKING) and ply:Alive()) then continue end

		-- If the player is a seeker in hiding time, they can't move, so don't change stamina.
		if state == "hidingtime" and ply:Team() == TEAM_SEEKING then continue end

		if ply:KeyDown(IN_SPEED) and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) then
			-- Drain stamina if sprinting
			ply:SetStamina(ply:GetStamina() - ply:GetStaminaDrain())
		else
			-- Stamina regen
			ply:SetStamina(ply:GetStamina() + ply:GetStaminaRegen())
		end
	end
end)
