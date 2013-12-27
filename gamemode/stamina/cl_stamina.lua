include("sh_stamina.lua")

local TEAM_HIDING = HS.TeamManager.TEAM_HIDING
local TEAM_SEEKING = HS.TeamManager.TEAM_SEEKING

hook.Add("Think", "HS.Stamina.Update", function()
	local state = HS.StateManager.CurrentState()
	if not state or not (state.Name == "inround" or state.Name == "hidingtime") then return end

	local ply = LocalPlayer()

	if state.Name == "hidingtime" and ply:Team() == TEAM_SEEKING then return end

	-- Make sure the player should actually be receiving a stamina update
	if not ((ply:Team() == TEAM_HIDING or ply:Team() == TEAM_SEEKING) and ply:Alive()) then return end

	if ply:KeyDown(IN_SPEED) and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) then
		-- Drain stamina if sprinting
		ply:SetStamina(ply:GetStamina() - ply:GetStaminaDrain())
	else
		-- Stamina regen
		ply:SetStamina(ply:GetStamina() + ply:GetStaminaRegen())
	end
end)

local function SyncStamina(val)
	LocalPlayer():SetStamina(val)
end

net.Receive("HS.Stamina.Sync", function()
	HS.OnInitPostEntity(SyncStamina, net.ReadFloat())
end)
