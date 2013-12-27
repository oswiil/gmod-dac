local DeferredCalls = {}
local DoDirectCalls = false

function HS.OnInitPostEntity(func, ...)
	if not DoDirectCalls then
		table.insert(DeferredCalls, { func = func, args = {...} })
	else
		func(...)
	end
end

hook.Add("InitPostEntity", "HS.HandleDeferredCalls", function()
	DoDirectCalls = true
	for _,v in ipairs(DeferredCalls) do
		v.func(unpack(v.args))
	end
end)
