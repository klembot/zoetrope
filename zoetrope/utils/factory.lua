-- Class: Factory
-- A factory allows for simple object pooling; that is,
-- reusing object instances instead of creating them and deleting
-- them as needed. This approach saves CPU and memory.
--
-- If you only want a certain number of instances of a class ever
-- created, first call preload() to create as many instances as you want,
-- then freeze() to prevent any new instances from being created.
-- If a factory is ever asked to make a new instance of a frozen class
-- but none are available for recycling, it returns nil.
--
-- Event: onReset
-- Called not on the factory, but the object is creates whenever
-- it is either initially created or recycled via create(). 
--
-- Extends:
--		<Class>

Factory = Class:extend({
	-- objects ready to be recycled, stored by prototype
	recycled = {},

	-- Property: frozen
	-- Tracks which pools cannot be added to, stored by prototype.
	frozen = {},

	-- Method: create
	-- Creates a fresh object, either by reusing a previously
	-- recycled one or creating a new instance. If the object is
	-- a <Sprite> instance, then this function calls <Sprite.revive> on it.
	--
	-- Arguments:
	--		prototype - <Class> object
	--		props - table of properties to mix into the class
	--
	-- Returns:
	-- 		fresh object

	create = function (self, prototype, props)
		local newObj
		
		if (self.recycled[prototype] and #self.recycled[prototype] > 0) then
			newObj = table.remove(self.recycled[prototype])
			newObj:mixin(props)
		else
			-- create a new instance if we're allowed to

			if not self.frozen[prototype] then
				newObj = prototype:new(props)
			else
				return nil
			end
		end

		if newObj:instanceOf(Sprite) then
			newObj:revive()
		end

		if newObj.onReset then newObj:onReset() end
		return newObj
	end,

	-- Method: recycle
	-- Marks an object as ready to be recycled. If the object
	-- is a <Sprite> instance, then this function calls die() on it.
	--
	-- Arguments:
	-- 		object - object to recycle
	--
	-- Returns:
	--		nothing

	recycle = function (self, object)
		if not self.recycled[object.prototype] then
			self.recycled[object.prototype] = {}
		end

		table.insert(self.recycled[object.prototype], object)

		if object:instanceOf(Sprite) then
			object:die()
		end
	end,

	-- Method: preload
	-- Preloads the factory with a certain number of instances of a class.
	--
	-- Arguments:
	--		prototype - class object
	--		count - number of objects to create
	--
	-- Returns:
	--		nothing

	preload = function (self, prototype, count)
		if not self.recycled[prototype] then
			self.recycled[prototype] = {}
		end

		local i

		for i = 1, count do
			table.insert(self.recycled[prototype], prototype:new())
		end
	end,

	-- Method: freeze
	-- Prevents any new instances of a class from being created via create().
	--
	-- Arguments:
	-- 		prototype - class object
	--
	-- Returns:
	--		nothing

	freeze = function (self, prototype)
		self.frozen[prototype] = true
	end,

	-- Method: unfreeze
	-- Allows new instances of a class to be created via create().
	--
	-- Arguments:
	--		prototype - class object
	--
	-- Returns:
	--		nothing

	unfreeze = function (self, prototype)
		self.frozen[prototype] = false
	end
})
