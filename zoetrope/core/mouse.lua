-- Class: Mouse
-- This tracks the state of the mouse, i.e. its coordinates onscreen
-- and if a button was just pressed or released this frame.
--
-- See http://love2d.org/wiki/MouseConstant for a list of mouse button names.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.globals'
require 'zoetrope.core.sprite'

Mouse = Sprite:extend({
	visible = false,

	-- private property: thisFrame
	-- what mouse buttons are pressed this frame
	thisFrame = {},

	-- private property: lastFrame
	-- what mouse buttons were pressed last frame
	lastFrame = {},
	
	new = function (self, obj)
		obj = self:extend(obj)
		Current.mouse = obj
		love.mousepressed = function (x, y, button) obj:mousePressed(button) end
		love.mousereleased = function (x, y, button) obj:mouseReleased(button) end
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: pressed
	-- Are *any* of the buttons passed held down this frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	pressed = function (self, ...)
		if #arg == 0 then arg[1] = 'l' end
	
		for _, value in pairs(arg) do
			if self.thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: justPressed
	-- Are *any* of the buttons passed pressed for the first time this frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	justPressed = function (self, ...)
		if #arg == 0 then arg[1] = 'l' end
	
		for _, value in pairs(arg) do
			if self.thisFrame[value] and not self.lastFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: released
	-- Are *all* of the buttons passed not held down this frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	released = function (self, ...)
		if #arg == 0 then arg[1] = 'l' end
	
		for _, value in pairs(arg) do
			if self.thisFrame[value] then
				return false
			end
		end
		
		return true
	end,

	-- Method: justReleased
	-- Are *any* of the buttons passed released after being held last frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	justReleased = function (self, ...)
		if #arg == 0 then arg[1] = 'l' end	
	
		for _, value in pairs(arg) do
			if self.lastFrame[value] and not self.thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	mousePressed = function (self, button)
		self.thisFrame[button] = true
	end,

	mouseReleased = function (self, button)
		self.thisFrame[button] = false
	end,

	endFrame = function (self, elapsed)
		for key, value in pairs(self.thisFrame) do
			self.lastFrame[key] = value
		end
	
		self.x = love.mouse.getX()
		self.y = love.mouse.getY()

		Sprite.endFrame(self)
	end,

	update = function() end
})
