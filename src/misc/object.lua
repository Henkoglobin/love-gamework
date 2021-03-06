local object = {}
object.__index = object
object.__type = "object"

function object:getClass()
	return getmetatable(self)
end

function object:instanceOf(other)
	return self == other or (self:getClass() and self:getClass():instanceOf(other))
end

function object.isObject(obj)
	return type(obj) == "table" and obj.instanceOf and obj:instanceOf(object) and not rawget(obj, "__type")
end

function object.isInstanceOf(obj, class)
	return object.isObject(obj) and obj:instanceOf(class)
end

return object