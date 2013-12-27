function HS.Log(format, ...)
	print(string.format("[HS] " .. format, ...))
end

HS.ChatPrint = chat.AddText

net.Receive("HS.Logging.ChatPrint", function()
	local chatArgs = {}

	local numArgs = net.ReadUInt(8)
	for i=1,numArgs do
		if net.ReadBit() == 1 then -- it's a string
			table.insert(chatArgs, net.ReadString())
		else
			table.insert(chatArgs, Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)))
		end
	end

	chat.AddText(unpack(chatArgs))
end)
