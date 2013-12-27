util.AddNetworkString("HS.Logging.ChatPrint")

function HS.Log(format, ...)
	print(string.format("[HS] " .. format, ...))
end

local function WriteNetChatArgs(...)
	local args = {...}
	net.WriteUInt(#args, 8)
	for _,v in ipairs(args) do
		if type(v) == "table" then -- It's a color
			net.WriteBit(false)
			net.WriteUInt(v.r, 8)
			net.WriteUInt(v.g, 8)
			net.WriteUInt(v.b, 8)
			net.WriteUInt(v.a, 8)
		else
			net.WriteBit(true)
			net.WriteString(tostring(v))
		end
	end
end

function HS.ChatPrintAll(...)
	net.Start("HS.Logging.ChatPrint")
	WriteNetChatArgs(...)
	net.Broadcast()

	local newMessage = ""
	for _,v in ipairs({...}) do
		if type(v) ~= "table" then
			newMessage = newMessage .. tostring(v)
		end
	end

	HS.Log("[ALL] %s", newMessage)
end

function HS.ChatPrintPlayer(ply, ...)
	net.Start("HS.Logging.ChatPrint")
	WriteNetChatArgs(...)
	net.Send(ply)
end
