-- Class: Sprite
-- A sprite receives all update-related events and draws
-- itself onscreen with its draw() method. It is defined
-- by a rectangle; nothing it draws should be outside that
-- rectangle.
--
-- In most cases, you don't want to create a sprite directly.
-- Instead, you'd want to use a subclass tailored to your needs.
-- Create a new subclass if you need to heavily customize how a 
-- sprite is drawn onscreen.
--
-- If you don't need something to display onscreen, just
-- to listen to updates, set the sprite's visible property to false.
--
-- Extends:
--		<Class>
--
-- Event: onDraw
-- Called after drawing takes place.
--
-- Event: onUpdate
-- Called once each frame, with the elapsed time since the last frame in seconds.
--
-- Event: onBeginFrame
-- Called once each frame like onUpdate, but guaranteed to fire before any others' onUpdate handlers.
--
-- Event: onEndFrame
-- Called once each frame like onUpdate, but guaranteed to fire after all others' onUpdate handlers.

Sprite = Class:extend({
	-- Property: active
	-- If false, the sprite will not receive an update-related events.
	active = true,

	-- Property: visible
	-- If false, the sprite will not draw itself onscreen.
	visible = true,

	-- Property: solid
	-- If false, the sprite will never be eligible to collide with another one.
	solid = true,

	-- Property: x
	-- Horizontal position in pixels. 0 is the left edge of the window.
	x = 0,

	-- Property: y
	-- Vertical position in pixels. 0 is the top edge of the window.
	y = 0,

	-- Property: width
	-- Width in pixels.
	width = 0,

	-- Property: height
	-- Height in pixels.
	height = 0,

	-- Property: rotation
	-- Rotation of drawn sprite in radians. This does not affect the bounds
	-- used during collision checking.
	rotation = 0,

	-- Property: velocity
	-- Motion either along the x or y axes, or rotation about its center, in
	-- pixels per second.
	velocity = { x = 0, y = 0, rotation = 0 },

	-- Property: minVelocity
	-- No matter what else may affect this sprite's velocity, it
	-- will never go below these numbers.
	minVelocity = { x = - math.huge, y = - math.huge, rotation = - math.huge },

	-- Property: maxVelocity
	-- No matter what else may affect this sprite's velocity, it will
	-- never go above these numbers.
	maxVelocity = { x = math.huge, y = math.huge, rotation = math.huge },
	acceleration = { x = 0, y = 0, rotation = 0 },
	drag = { x = 0, y = 0, rotation = 0 },
	scale = 1,
	distort = { x = 1, y = 1 },
	alpha = 1,
	tint = { 1, 1, 1 },

	-- Method: die
	-- Makes the sprite totally inert. It will not receive
	-- update events, draw anything, or be collided.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	-- 		nothing

	die = function (self)
		self.active = false
		self.visible = false
		self.solid = false
	end,

	-- Method: revive
	-- Makes this sprite completely active. It will receive
	-- update events, draw itself, and be collided.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	-- 		nothing

	revive = function (self)
		self.active = true
		self.visible = true
		self.solid = true
	end,

	-- Method: collide
	-- Checks whether sprites collide by checking rectangles.
	-- There's leeway in the arguments below. If you collide a group, this will
	-- collide the members of all subgroups. You may also pass a table of sprites.
	-- If a collision is detected, onCollide() is called on both this sprite and
	-- the one it collides with, passing the amount of horizontal and vertical
	-- overlap between the sprites in pixels.
	--
	-- Arguments:
	--		other - another sprite, group or table of sprites
	--
	-- Returns:
	--		boolean, whether any collision was detected

	collide = function (self, other)
		if not self.solid or self == other then return false end

		local hit = false	
		local otherList = coerceToTable(other)
				
		for _, spr in pairs(otherList) do
			-- recurse into subgroups
			-- order is important here to avoid short-circuiting inappopriately
			
			if type(spr.sprites) == 'table' then
				hit = self:collide(spr.sprites) or hit
			end
			
			if spr ~= self and spr.solid and
			   spr.x and spr.y and spr.width and spr.height then
				-- this is cribbed from
				-- http://frey.co.nz/old/2007/11/area-of-two-rectangles-algorithm/

				local right = self.x + self.width
				local bottom = self.y + self.height
				local sprRight = spr.x + spr.width
				local sprBottom = spr.y + spr.height
					
				-- is there an overlap at all?
				
				if self.x < sprRight and right > spr.x and
				   self.y < sprBottom and bottom > spr.y then
				   
					-- calculate overlaps and call onCollide()
					
					hit = true
					local horizOverlap = math.min(right, sprRight) - math.max(self.x, spr.x)
					local vertOverlap = math.min(bottom, sprBottom)- math.max(self.y, spr.y)
				
					if self.onCollide then
						self:onCollide(spr, horizOverlap, vertOverlap)
					end
					
					if spr.onCollide then
						spr:onCollide(self, horizOverlap, vertOverlap)
					end
				end
			end
		end
		
		return hit
	end,

	-- Method: displace
	-- Displaces another sprite so that it no longer overlaps this one.
	-- This by default seeks to move the other sprite the least amount possible.
	-- You can give this function a hint about which way it ought to move the other
	-- sprite (e.g. by consulting its current motion) through the two optional
	-- arguments. A single displace() call will *either* move the other sprite
	-- horizontally or vertically, not along both axes.
	--
	-- Just as with collide(), you may call this with either a single sprite, a
	-- single group, or a table of sprites.
	--
	-- Arguments:
	--		other - sprite, group, or table of sprites to be moved
	-- 		xHint - force horizontal displacement in one direction, uses direction constants, optional
	--		yHint - force vertical displacement in one direction, uses direction constants, optional

	displace = function (self, other, xHint, yHint)	
		if not self.solid or self == other then return false end
			
		local hit = false
		local otherList = coerceToTable(other)
		
		for _, spr in pairs(otherList) do
			local left = self.x
			local right = self.x + self.width
			local top = self.y
			local bottom = self.y + self.height
			local sprLeft = spr.x
			local sprRight = spr.x + other.width
			local sprTop = spr.y
			local sprBottom = spr.y + other.height
			local xChange = 0
			local yChange = 0
			
			-- resolve horizontal overlap
			
			if (sprLeft >= left and sprLeft <= right) or
			   (sprRight >= left and sprRight <= right) or
			   (left >= sprLeft and left <= sprRight) or
			   (right >= sprLeft and right <= sprRight) then
				local leftMove = (sprLeft - left) + spr.width
				local rightMove = right - sprLeft
				
				if xHint == LEFT then
					xChange = - leftMove
				elseif xHint == RIGHT then
					xChange = rightMove
				else
					if leftMove < rightMove then
						xChange = - leftMove
					else
						xChange = rightMove
					end
				end
			end
			
			-- resolve vertical overlap

			if (sprTop >= top and sprTop <= bottom) or
			   (sprBottom >= top and sprBottom <= bottom) or
			   (top >= sprTop and top <= sprBottom) or
			   (bottom >= sprTop and bottom <= sprBottom) then
				local upMove = (sprTop - top) + spr.height
				local downMove = bottom - sprTop
				
				if yHint == UP then
					yChange = - upMove
				elseif yHint == DOWN then
					yChange = downMove
				else
					if upMove < downMove then
						yChange = - upMove
					else
						yChange = downMove
					end
				end
			end
			
			-- choose the option that moves the other sprite the least
			
			if math.abs(xChange) > math.abs(yChange) then
				spr.y = spr.y + yChange
			else
				spr.x = spr.x + xChange
			end
		end
	end,

	-- Method: push
	-- Moves another sprite as if it had the same motion properties as this one.
	--
	-- Arguments:
	--		other - other sprite to push
	--		elapsed - elapsed time to simulate, in seconds

	push = function (self, other, elapsed)
		other.x = other.x + self.velocity.x * elapsed
		other.y = other.y + self.velocity.y * elapsed
	end,

	startFrame = function (self, elapsed)
		if self.onStartFrame then self:onStartFrame(elapsed) end
	end,

	update = function (self, elapsed)
		local vel = self.velocity
		local acc = self.acceleration
		local drag = self.drag
		local minVel = self.minVelocity
		local maxVel = self.maxVelocity

		-- physics
			
		if vel.x ~= 0 then self.x = self.x + vel.x * elapsed end
		if vel.y ~= 0 then self.y = self.y + vel.y * elapsed end
		if vel.rotation ~= 0 then self.rotation = self.rotation + vel.rotation * elapsed end
		
		if acc.x ~= 0 then
			vel.x = vel.x + acc.x * elapsed
		else
			if drag.x ~= 0 then
				if vel.x > 0 then
					vel.x = vel.x - drag.x * elapsed
				elseif vel.x < 0 then
					vel.x = vel.x + drag.x * elapsed
				end
			end
		end
		
		if acc.y ~= 0 then
			vel.y = vel.y + acc.y * elapsed
		else
			if drag.y ~= 0 then
				if vel.y > 0 then
					vel.y = vel.y - drag.y * elapsed
				elseif vel.y < 0 then
					vel.y = vel.y + drag.y * elapsed
				end
			end
		end
		
		if acc.rotation ~= 0 then
			vel.rotation = vel.rotation + acc.rotation * elapsed
		else
			if drag.rotation ~= 0 then
				if vel.rotation > 0 then
					vel.rotation = vel.rotation - drag.rotation * elapsed
				elseif vel.rotation < 0 then
					vel.rotation = vel.rotation + drag.rotation * elapsed
				end
			end
		end

		if minVel.x and vel.x < minVel.x then vel.x = minVel.x end
		if maxVel.x and vel.x > maxVel.x then vel.x = maxVel.x end
		if minVel.y and vel.y < minVel.y then vel.y = minVel.y end
		if maxVel.y and vel.y > maxVel.y then vel.y = maxVel.y end
		if minVel.rotation and vel.rotation < minVel.rotation then vel.rotation = minVel.rotation end
		if maxVel.rotation and vel.rotation > maxVel.rotation then vel.rotation = maxVel.rotation end
		
		if self.onUpdate then self:onUpdate(elapsed) end
	end,

	endFrame = function (self, elapsed)
		if self.onEndFrame then self:onEndFrame(elapsed) end
	end,

	draw = function (self, x, y)
		if self.onDraw then self:onDraw(x, y) end
	end
})
