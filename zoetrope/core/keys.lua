-- Class: Keys
-- This tracks the state of the keyboard, i.e. if a key
-- was just pressed or released this frame. You can look
-- up a key either by its name or its Unicode number.
-- Not all keys sensed have Unicode equivalents (e.g. modifiers
-- like control or alt).
--
-- Only one Keys object can be active at one time. The one currently
-- listening to the keyboard can be accessed globally via <Current>.keys.
--
-- See http://love2d.org/wiki/KeyConstant for a list of key names.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.globals'
require 'zoetrope.core.sprite'

Keys = Sprite:extend({
	visible = false,

	-- Property: frameString
	-- A string of what keys have been pressed this frame, in order.
	
	frameString = '',

	-- what keys are pressed this frame
	thisFrame = {},

	-- what keys were pressed last frame
	lastFrame = {},
	
	new = function (self, obj)
		obj = self:extend(obj)
		Current.keys = obj
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
		for _, value in pairs(arg) do
			if self.thisFrame[value] then
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
		for _, value in pairs(arg) do
			if self.thisFrame[value] and not self.lastFrame[value] then
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
		for _, value in pairs(arg) do
			if self.thisFrame[value] then
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
		for _, value in pairs(arg) do
			if self.lastFrame[value] and not self.thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Connects to the love.keypressed callback

	keyPressed = function (self, key, unicode)
		self.thisFrame[key] = true

		-- FIXME: only append if the key is in printable range
		self.frameString = self.frameString .. key
		if unicode then self.thisFrame[unicode] = true end
	end,

	-- Connects to the love.keyreleased callback

	keyReleased = function (self, key, unicode)
		self.thisFrame[key] = false
		if unicode then self.thisFrame[unicode] = false end
	end,

	endFrame = function (self, elapsed)
		for key, value in pairs(self.thisFrame) do
			self.lastFrame[key] = value
		end

		self.frameString = ''
		
		Sprite.endFrame(self, elapsed)
	end,
})
