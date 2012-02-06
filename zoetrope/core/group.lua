-- Class: Group
-- A group is a set of sprites. Groups can be used to
-- implement layers or keep categories of sprites together.
--
-- Extends:
--		<Class>
--
-- Event: onDraw
-- Called after all member sprites are drawn onscreen.
--
-- Event: onUpdate
-- Called once each frame, with the elapsed time since the last frame in seconds.
--
-- Event: onBeginFrame
-- Called once each frame like onUpdate, but guaranteed to fire before any others' onUpdate handlers.
--
-- Event: onEndFrame
-- Called once each frame like onUpdate, but guaranteed to fire after all others' onUpdate handlers.

require 'zoetrope.core.class'

Group = Class:extend({
	-- Property: active
	-- If false, none of its member sprites will receive update-related events.
	active = true,

	-- Property: visible
	-- If false, none of its member sprites will be drawn.
	visible = true,

	-- Property: sprites
	-- A table of member sprites, in drawing order.
	sprites = {},

	-- Property: translate
	-- This table's x and y properties shift member sprites' positions when drawn.
	-- To draw sprites at their normal position, set both x and y to 0.
	translate = { x = 0, y = 0 },
	
	-- Property: translateMultiplier
	-- This table's x and y properties multiply member sprites'
	-- positions, which you can use to simulate parallax scrolling. To draw
	-- sprites at their normal position, set both x and y to 1.
	translateMultiplier = { x = 1, y = 1 },

	-- Method: add
	-- Adds a sprite to the group.
	--
	-- Arguments:
	--		sprite - <Sprite> to add
	--
	-- Returns:
	--		nothing

	add = function (self, sprite)
		assert(sprite, 'asked to add nil to a group')
		assert(sprite ~= self, "can't add a group to itself")
		table.insert(self.sprites, sprite)
	end,

	-- Method: remove
	-- Removes a sprite from the group. If the sprite is
	-- not in the group, this does nothing.
	-- 
	-- Arguments:
	-- 		sprite - <Sprite> to remove
	-- 
	-- Returns:
	-- 		nothing

	remove = function (self, sprite)
		for i, spr in ipairs(self.sprites) do
			if spr == sprite then
				table.remove(self.sprites, i)
			end
		end
	end,

	-- Method: collide
	-- Collides all solid sprites in the group with another
	-- sprite, group, or table of sprites.
	--
	-- Arguments:
	-- 		other - sprite, group, or table of sprites to collide with
	-- 
	-- Returns:
	--		boolean, whether any collision was detected
	--
	-- See Also:
	--		<Sprite.collide>

	collide = function (self, other)
		local hit = false

		for _, spr in pairs(self.sprites) do
			if spr.solid then
				hit = spr:collide(other) or hit
			end
		end
		
		return hit
	end,

	-- Method: count
	-- Counts how many sprites are in this group.
	-- 
	-- Arguments:
	--		none
	-- 
	-- Returns:
	--		integer count

	count = function (self)
		return #self.sprites
	end,

	-- passes startFrame events to member sprites

	startFrame = function (self, elapsed)
		if not self.active then return end
		if self.onStartFrame then self:onStartFrame(elapsed) end
		
		for _, spr in pairs(self.sprites) do
			if spr.active and spr.startFrame then
				spr:startFrame(elapsed)
			end
		end
	end,

	-- passes update events to member sprites

	update = function (self, elapsed)
		if not self.active then return end
		if self.onUpdate then self:onUpdate(elapsed) end

		for _, spr in pairs(self.sprites) do
			if spr.active and spr.update then
				spr:update(elapsed)
			end
		end
	end,

	-- passes endFrame events to member sprites

	endFrame = function (self, elapsed)
		if not self.active then return end
		if self.onEndFrame then self.onEndFrame(elapsed) end

		for _, spr in pairs(self.sprites) do
			if spr.active and spr.endFrame then
				spr:endFrame(elapsed)
			end
		end
	end,

	-- Method: draw
	-- Draws all visible member sprites onscreen.
	--
	-- Arguments:
	--		x - x offset in pixels
	--		y - y offset in pixels

	draw = function (self, x, y)
		if not self.visible then return end
		x = x or self.translate.x
		y = y or self.translate.y
		
		local scrollX = x * self.translateMultiplier.x
		local scrollY = y * self.translateMultiplier.y
		
		for _, spr in pairs(self.sprites) do	
			if spr.visible and spr.draw then
				if spr.x and spr.y then
					spr:draw(spr.x + scrollX, spr.y + scrollY)
				elseif spr.translate then
					spr:draw(spr.translate.x + scrollX, spr.translate.y + scrollY)
				end
			end
		end
			
		if self.onDraw then self:onDraw() end
	end
})
