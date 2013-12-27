local Countdown = {}
local CountdownMT = { __index = Countdown }

local AllCountdowns = {}

function Countdown.New(name, onServerUpdate, onSecondTick)
	local obj = setmetatable({ 
		name = name, 
		active = false, 
		endTime = nil, 
		onServerUpdate = onServerUpdate,
		lastTick = -1,
		onSecondTick = onSecondTick
	}, CountdownMT)

	net.Receive(name, function()
		local active = net.ReadBit() == 1

		if active then
			HS.OnInitPostEntity(Countdown.Setup, obj, true, CurTime() + net.ReadDouble())
		else
			HS.OnInitPostEntity(Countdown.Setup, obj, false)
		end
	end)

	table.insert(AllCountdowns, obj)

	return obj
end

function Countdown:Setup(active, endTime)
	self.active = active

	if active then
		self.endTime = endTime
	end

	if self.onServerUpdate then
		self:onServerUpdate()
	end
end

function Countdown:TimeRemaining()
	if self.active then
		return math.max(self.endTime - CurTime(), 0)
	else
		return 0
	end
end

function Countdown:FormatTimeRemaining()
	return string.ToMinutesSeconds(math.ceil(self:TimeRemaining()))
end

function Countdown:SetActive(b)
	self.active = b
end

function Countdown:IsActive()
	return self.active
end

function Countdown:EndTime()
	return self.endTime
end

function Countdown:TickCheck()
	if self.active and self.onSecondTick then
		local time = math.ceil(self:TimeRemaining())
		if time ~= self.lastTick then
			self:onSecondTick(time)
			self.lastTick = time
		end
	end
end

hook.Add("Think", "HS.Countdown.TickCheck", function()
	for _,v in ipairs(AllCountdowns) do
		v:TickCheck()
	end
end)

HS.Countdown = Countdown
