-- Class: Keys
-- This tracks the state of the keyboard, i.e. if a key
-- was just pressed or released this frame. You can look
-- up a key either by its name or its Unicode number.
-- Not all keys sensed have Unicode equivalents (e.g. modifiers
-- like control or alt).
--
-- Only one Keys object can be active at one time. The one currently
-- listening to the keyboard can be accessed globally via <the>.keys.
--
-- See http://love2d.org/wiki/KeyConstant for a list of key names.
-- This class aliases modifiers for you, so that if you want to check
-- whether either the left or right Control key is pressed, you can check
-- on 'ctrl' instead of both 'lctrl' and 'rctrl'.
--
-- Extends:
--		<Sprite>

Keys = Sprite:extend({
	visible = false,

	-- Property: frameString
	-- A string of what keys have been pressed this frame, in order.
	
	frameString = '',

	-- private property: what keys are pressed this frame
	_thisFrame = {},

	-- private property: what keys were pressed last frame
	_lastFrame = {},
	
	new = function (self, obj)
		obj = self:extend(obj)
		the.keys = obj
		love.keypressed = function (key, unicode) obj:keyPressed(key, unicode) end
		love.keyreleased = function (key, unicode) obj:keyReleased(key, unicode) end
		if obj.onNew then obj:onNew() end
		return obj
	end,
	
	-- Method: pressed
	-- Are *any* of the keys passed held down this frame?
	--
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	pressed = function (self, ...)
		local keys = {...}
		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: justPressed
	-- Are *any* of the keys passed pressed for the first time this frame?
	--
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	justPressed = function (self, ...)
		local keys = {...}

		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] and not self._lastFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: released
	-- Are *all* of the keys passed not held down this frame?
	-- 
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	released = function (self, ...)
		local keys = {...}

		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] then
				return false
			end
		end
		
		return true
	end,

	-- Method: justReleased
	-- Are *any* of the keys passed released after being held last frame?
	--
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	justReleased = function (self, ...)
		local keys = {...}

		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._lastFrame[value] and not self._thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Connects to the love.keypressed callback

	keyPressed = function (self, key, unicode)
		self._thisFrame[key] = true

		-- aliases for modifiers
		if key == 'rshift' or key == 'lshift' or
		   key == 'rctrl' or key == 'lctrl' or
		   key == 'ralt' or key == 'lalt' or
		   key == 'rmeta' or key == 'lmeta' or
		   key == 'rsuper' or key == 'lsuper' then
			self._thisFrame[string.sub(key, 2)] = true
		end

		if unicode then self._thisFrame[unicode] = true end

		-- add to frameString if it's printable
		if unicode > 31 and unicode < 127 then
			self.frameString = self.frameString .. key
		end
	end,

	-- Connects to the love.keyreleased callback

	keyReleased = function (self, key, unicode)
		self._thisFrame[key] = false

		-- aliases for modifiers
		if key == 'rshift' or key == 'lshift' or
		   key == 'rctrl' or key == 'lctrl' or
		   key == 'ralt' or key == 'lalt' or
		   key == 'rmeta' or key == 'lmeta' or
		   key == 'rsuper' or key == 'lsuper' then
			self._thisFrame[string.sub(key, 2)] = true
		end

		if unicode then self._thisFrame[unicode] = false end
	end,

	endFrame = function (self, elapsed)
		for key, value in pairs(self._thisFrame) do
			self._lastFrame[key] = value
		end

		self.frameString = ''
		
		Sprite.endFrame(self, elapsed)
	end,

	update = function() end
})
