local class = require("misc.class")

local command = class("command")

function command.new(proto)
	return {
		__subscribers = {},
		canExecuteImpl = proto.canExecute or function() return true end,
		executeImpl = proto.execute
	}
end

function command:register(func, obj)
	table.insert(self.__subscribers, { func = func, obj = obj })
end

function command:unregister(func, obj)
	for index, subscriber in pairs(self.__subscribers) do
		if subscriber.func == func and subscriber.obj == v.obj then
			table.remove(self.__subscribers, index)
			return
		end
	end
end

function command:raiseCanExecuteChanged()
	for _, subscriber in pairs(self.__subscribers) do
		if subscriber.obj then
			subscriber.func(subscriber.obj, self)
		else
			subscriber.func(self)
		end
	end
end

function command:canExecute(param)
	return self.canExecuteImpl(param)
end

function command:execute(param)
	self.executeImpl(param)
end

return command