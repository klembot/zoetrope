-- Class: Class
-- This is a simple OOP single-inheritance implementation based
-- on the one suggested by <Programming in Lua at http://www.lua.org/pil/16.html>.
--
-- Event: onNew
-- 		Called once, when a new object is created via <new()>.

Class = {
	-- Method: extend
	-- Creates a subclass of a class object, replacing any class properties
	-- with those in the object passed. It also sets the subclass's prototype
	-- property to this class. This alters the passed table in-place.
	--
	-- Arguments:
	-- 		obj - table of properties
	--
	-- Returns:
	-- 		subclassed table

	extend = function (self, obj)
		obj = obj or {}
	
		-- copy any table properties into the subclass, so that
		-- it does not accidentally overwrite them
				
		for key, value in pairs(self) do
			if key ~= '__index' and not obj[key] and type(value) == 'table' then
				obj[key] = copyTable(self[key])
			end
		end
		
		-- __index work to set up inheritance and getters/setters

		obj = obj or {}
		setmetatable(obj, self)
		self.__index = self
		obj.prototype = self
		return obj
	end,

	-- Method: new
	-- Extends an object and calls its onNew() handler if it is defined.
	-- This handler is meant for object-specific initialization,
	-- not class-wide work.
	--
	-- Arguments:
	--		obj - table of properties that the new object starts with,
	--			  overriding anything set in the class
	-- 
	-- Returns:
	-- 		new instance
	
	new = function (self, obj)
		obj = self:extend(obj)
		if obj.onNew then obj:onNew() end
		return obj
	end,
	
	-- Method: mixin
	-- Mixes all properties passed into the current object, overwriting any
	-- pre-existing values.
	--
	-- Arguments:
	--		obj - table of properties to mix into the object
	--
	-- Returns:
	--		current object
	
	mixin = function (self, obj)
		for key, value in pairs(obj) do
			self[key] = obj[key]
		end
	end,
	
	-- Function: instanceOf
	-- Checks whether a certain object is anywhere in its inheritance chain.
	--
	-- Arguments:
	-- 		class - table to check against
	--
	-- Returns:
	-- 		boolean

	instanceOf = function (self, class)
		local proto = self.prototype
		
		while proto do
			if proto == class then
				return true
			end
			
			proto = proto.prototype
		end
		
		return false
	end
}
