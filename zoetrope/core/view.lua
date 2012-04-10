-- Class: View
-- A view is a group that packages several useful objects with it.
-- It's helpful to use, but not required. When a view is created, it
-- automatically sets the.view for itself. the.view should be considered
-- a read-only reference. If you want to switch views, you *must* set
-- the app's view property instead.
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

	-- private property: fx
	-- used to perform fades and flashes.

	new = function (self, obj)
		obj = self:extend(obj)

		obj.timer = Timer:new()
		obj:add(obj.timer)
		obj.tweener = Tweener:new()
		obj:add(obj.tweener)
		obj.factory = Factory:new()

		obj.fx = Fill:new({ visible = false })

		-- set the.view briefly, so that during the onNew() handler
		-- we appear to be the current view
	
		local oldView = the.view

		the.view = obj
		if obj.onNew then obj:onNew() end

		-- then reset it so that nothing breaks for the remainder
		-- of the frame for the old, outgoing view members.
		-- our parent app will restore us into the.view at the top of the next frame

		the.view = oldView
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
		
		if sprite.x + sprite.width > the.app.width then
			self.maxVisible.x = sprite.x + sprite.width
		else
			self.maxVisible.x = the.app.width
		end
		
		self.minVisible.y = sprite.y
		
		if sprite.y + sprite.height > the.app.height then
			self.maxVisible.y = sprite.y + sprite.height
		else
			self.maxVisible.y = the.app.height
		end
	end,

	-- Method: fade
	-- Fades out to a specified color over a period of time.
	--
	-- Arguments:
	--		color - color table to fade to, e.g. { 0, 0, 0 }
	--		duration - how long to fade out in seconds, default 1
	--		onComplete - function to call when done, passed the tween related to this
	-- Returns:
	--		nothing

	fade = function (self, color, duration, onComplete)
		self.fx.visible = true
		self.fx.fill = color
		self.fx.alpha = 0
		self.tweener:start({ target = self.fx, prop = 'alpha', to = 1, duration = duration or 1,
							 ease = 'quadIn', force = true, onComplete = onComplete })
	end,

	-- Method: flash
	-- Immediately flashes the screen to a specific color, then fades out.
	--
	-- Arguments:
	--		color - color table to flash, e.g. { 0, 0, 0 }
	--		duration - how long to restore normal view in seconds, default 1
	--		onComplete - function to call when done, passed the tween related to this
	--
	-- Returns:
	--		nothing

	flash = function (self, color, duration)
		local s = self
		local done = function (t)
			s.fx.visible = false
			if onComplete then onComplete(t) end
		end

		self.fx.visible = true
		self.fx.fill = color
		self.fx.alpha = 1
		self.tweener:start({ target = self.fx, prop = 'alpha', to = 0, duration = duration or 1,
							 ease = 'quadOut', force = true, onComplete = done })
	end,

	-- Method: tint
	-- Immediately tints the screen a color. To restore normal viewing,
	-- call this method again with no arguments.
	--
	-- Arguments:
	--		color - color table to tint with, e.g. { 0, 0, 0 }
	--		alpha - how intense the color should be, defaults to 1
	--
	-- Returns:
	--		nothing

	tint = function (self, color, alpha)
		alpha = alpha or 1

		if color and alpha > 0 then
			self.fx.visible = true
			self.fx.fill = color
			self.fx.alpha = alpha or 1
		else
			self.fx.visible = false
		end
	end,

	shake = function (self, intensity, duration)

	end,

	update = function (self, elapsed)
		local screenWidth = the.app.width
		local screenHeight = the.app.height

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
	end,

	draw = function (self, x, y)
		Group.draw(self, x, y)

		-- draw our fx layer on top of everything

		if self.fx.visible then
			self.fx.width = the.app.width
			self.fx.height = the.app.height
			self.fx:draw(x, y)
		end
	end
})
