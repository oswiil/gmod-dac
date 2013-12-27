local Countdown = {}
local CountdownMT = { __index = Countdown }

function Countdown.New(name, onFinish)
	util.AddNetworkString(name)

	return setmetatable({ 
		name = name, 
		active = false, 
		endTime = nil, 
		onFinish = onFinish
	}, CountdownMT)
end

function Countdown:Start(time)
	timer.Create(self.name, time, 1, function() self.active = false self.onFinish() end)

	self.active = true
	self.endTime = CurTime() + time

	for _, ply in ipairs(player.GetAll()) do
		self:ClientSync(ply)
	end
end

function Countdown:Stop()
	if self.active then
		timer.Destroy(self.name)
		self.active = false

		for _, ply in ipairs(player.GetAll()) do
			self:ClientSync(ply)
		end
	end
end

Countdown.Reset = Countdown.Stop

function Countdown:ClientSync(ply)
	net.Start(self.name)
		net.WriteBit(self.active)
		if self.active then
			net.WriteDouble(self.endTime - CurTime())
		end
	net.Send(ply)
end

function Countdown:IsActive()
	return self.active
end

HS.Countdown = Countdown
