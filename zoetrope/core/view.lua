-- Class: View
-- A view is a group that packages several useful objects with it.
-- It's helpful to use, but not required. When a view is created, it
-- automatically sets Current.view for itself.
--
-- Extends:
--		<Group>

View = Group:extend({
	-- Property: timer
	-- A built-in <Timer> object for use as needed.

	-- Property: tweener
	-- A built-in <Tweener> object for use as needed.

	-- Property: factory
	-- A built-in <Factory> object for use as needed.

	-- Property: focus
	-- A <Sprite> to keep centered onscreen.

	-- Property: focusOffset
	-- This shifts the view of the focus, if one is set. If both
	-- x and y properties are set to 0, then the view keeps the focus
	-- centered onscreen.
	focusOffset = { x = 0, y = 0 },

	-- Property: minVisible
	-- The view clamps its scrolling so that nothing above or to the left
	-- of these x and y coordinates is visible.
	minVisible = { x = -math.huge, y = -math.huge },

	-- Property: maxVisible
	-- This view clamps its scrolling so that nothing below or to the right
	-- of these x and y coordinates is visible.
	maxVisible = { x = math.huge, y = math.huge },

	new = function (self, obj)
		obj = self:extend(obj)

		obj.timer = Timer:new()
		obj:add(obj.timer)
		obj.tweener = Tweener:new()
		obj:add(obj.tweener)
		obj.factory = Factory:new()
		Current.view = obj
		
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: clampTo
	-- Clamps the view so that it never scrolls past a sprite's boundaries.
	-- This only looks at the sprite's position at this instant in time,
	-- not afterwards.
	--
	-- Arguments:
	--		sprite - sprite to clamp to
	--
	-- Returns:
	--		nothing

	clampTo = function (self, sprite)
		self.minVisible.x = sprite.x
		
		if sprite.x + sprite.width > Current.app.width then
			self.maxVisible.x = sprite.x + sprite.width
		else
			self.maxVisible.x = Current.app.width
		end
		
		self.minVisible.y = sprite.y
		
		if sprite.y + sprite.height > Current.app.height then
			self.maxVisible.y = sprite.y + sprite.height
		else
			self.maxVisible.y = Current.app.height
		end
	end,

	update = function (self, elapsed)
		local screenWidth = Current.app.width
		local screenHeight = Current.app.height

		-- follow the focused sprite
		
		if self.focus and self.focus.width < screenWidth
		   and self.focus.height < screenHeight then
			self.translate.x = - (self.focus.x + self.focusOffset.x) +
							   (screenWidth - self.focus.width) / 2
			self.translate.y = - (self.focus.y + self.focusOffset.y) +
							   (screenHeight - self.focus.height) / 2
		end
		
		-- clamp translation to min and max visible
		
		if self.translate.x > - self.minVisible.x then
			self.translate.x = - self.minVisible.x
		end

		if self.translate.y > - self.minVisible.y then
			self.translate.y = - self.minVisible.y
		end
		
		if self.translate.x < screenWidth - self.maxVisible.x then
			self.translate.x = screenWidth - self.maxVisible.x
		end
		
		if self.translate.y < screenHeight - self.maxVisible.y then
			self.translate.y = screenHeight - self.maxVisible.y
		end

		Group.update(self, elapsed)
	end
})
