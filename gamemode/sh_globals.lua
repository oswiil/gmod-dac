if SERVER then
	util.AddNetworkString("HS.Globals.Update")
end

local Globals = {}
local GlobalsByName = {}
local GlobalsByID = {}

local GlobalsMT = {}
function GlobalsMT:__index(k)
	if GlobalsByName[k] ~= nil then
		return GlobalsByName[k].val
	else
		error("Attempt to access unregistered global '" .. tostring(k) .. "'")
	end
end

function GlobalsMT:__newindex(k, v)
	local global = GlobalsByName[k]
	if global == nil then
		error("Attempt to set unregistered global '" .. tostring(k) .. "'")
	end

	if CLIENT and global.replicate then
		error("Attempt to set a replicated global '" .. tostring(k) .. "' from client")
	end

	global.val = v

	if SERVER and global.replicate then
		global:UpdateAll()
	end
end

local GlobalEntryMT = { __index = {} }
function GlobalEntryMT.__index:UpdateClient(ply)
	net.Start("HS.Globals.Update")
		net.WriteDouble(self.id)
		net.WriteType(self.val)
	net.Send(ply)
end

function GlobalEntryMT.__index:UpdateAll()
	net.Start("HS.Globals.Update")
		net.WriteDouble(self.id)
		net.WriteType(self.val)
	net.Broadcast()
end

function Globals.Register(name, default, replicate)
	if GlobalsByName[name] ~= nil then
		error("Global '" .. name .. "' is already registered")
	end

	local ID = util.CRC(name)
	local data = { name = name, id = ID, val = default, replicate = replicate }
	setmetatable(data, GlobalEntryMT)

	GlobalsByName[name] = data
	GlobalsByID[ID] = data

	HS.Log("[Globals] %q registered, ID = %s %s", name, ID, replicate and "(Replicated)" or "")
end

function Globals.RegisterReplicated(name, default)
	Globals.Register(name, default, true)
end

if SERVER then
	hook.Add("PlayerInitialSpawn", "HS.Globals.SyncClient", function(ply)
		for _,global in pairs(GlobalsByID) do
			if global.replicate then
				global:UpdateClient(ply)
			end
		end
	end)
end

if CLIENT then
	local function UpdateGlobal(ID, value)
		local data = GlobalsByID[tostring(ID)]
		if data == nil then
			error("Attempt to update an unregistered global (ID = " .. tostring(ID) .. ")")
		end

		data.val = value
		
		HS.Log("[Globals] %q updated to: %s", data.name, tostring(data.val))
	end

	net.Receive("HS.Globals.Update", function()
		local ID = net.ReadDouble()
		local value = net.ReadType(net.ReadUInt(8))

		HS.OnInitPostEntity(UpdateGlobal, ID, value)
	end)
end

setmetatable(Globals, GlobalsMT)

HS.Globals = Globals
