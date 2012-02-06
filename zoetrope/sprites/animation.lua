-- Class: Animation
-- An animation displays a sequence of frames.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.sprite'

Animation = Sprite:extend({
	-- Property: paused
	-- Set this to true to freeze the animation on the current frame.
	paused = false,

	-- Property: sequences
	-- A lookup table of sequences -- see <Animation.addSequence>.
	sequences = {},

	-- Property: currentSequence
	-- A reference to the current animation sequence table.

	-- Property: currentName
	-- The name of the current animation sequence.

	-- Property: frameIndex
	-- Numeric index of the current frame in the current sequence; starts at 1.

	-- Property: frameTimer
	-- Time left before the animation changes to the next frame in seconds.
	-- Normally you shouldn't need to change this directly.

	-- Method: addSequence
	-- Adds an animation to the sprite's library. All arguments are
	-- passed as a single object as follows:
	--
	-- Arguments:
	--		* name - name to store the animation under
	--		* frames - table of frames, starting at 1
	--		* fps - frames per second to run the animation
	--		* looped	loop the animation? defaults to true
	--
	-- Returns:
	--		nothing

	addSequence = function (self, seq)
		if type(seq.looped) == 'nil' then seq.looped = true end
		
		self.sequences[seq.name] = seq
	end,

	-- Method: 
	-- Begins playing an animation in the sprite's library.
	-- If the animation is already playing, this has no effect.
	--
	-- Arguments:
	--		name - name of the animation
	--
	-- Returns:
	--		nothing

	play = function (self, name)
		if self.currentName == name and not self.paused then
			return
		end
		
		assert(self.sequences[name], 'no animation sequence named "' .. name .. '"')
		
		self.currentName = name
		self.currentSequence = self.sequences[name]
		self.frameIndex = 0
		self.frameTimer = 0
		self.paused = false
	end,

	-- Method: freeze
	-- Freezes the animation on the specified frame.
	--
	-- Arguments:
	--		* index - integer frame index relative to the entire sprite sheet,
	--				  starts at 1. If omitted, this freezes the current frame.
	--
	-- Returns:
	--		nothing

	freeze = function (self, index)
		index = index or self.currentSequence[self.frameIndex]

		if not self.imageWidth then
			self:updateQuad()
		end

		local frameX = index * self.width
		local viewportX = frameX % self.imageWidth
		local viewportY = math.floor(frameX / self.imageWidth)
		self.quad:setViewport(viewportX, viewportY, self.width, self.height)
		self.paused = true
	end,

	-- sets up the sprite's quad property; you should not need to call this directly

	updateQuad = function (self)
		if self.quadImage == self.image then return end

		self.quad = love.graphics.newQuad(0, 0, self.width, self.height,
										  self.image:getWidth(), self.image:getHeight())
		self.imageWidth = self.image:getWidth()
		self.quadImage = self.image
	end,

	update = function (self, elapsed)
		-- if the sprite's image changed, create a new quad
		
		if self.quadImage ~= self.image then
			self:updateQuad()
		end
		
		-- move the animation frame forward

		if self.currentSequence and not self.paused then
			self.frameTimer = self.frameTimer - elapsed
			
			if self.frameTimer <= 0 then
				self.frameIndex = self.frameIndex + 1
				
				if self.frameIndex > #self.currentSequence.frames then
					if self.currentSequence.looped then
						self.frameIndex = 1
					else
						self.frameIndex = self.frameIndex - 1
						self.paused = true
					end
				end
					
				self.frameTimer = 1 / self.currentSequence.fps
				local frameX = self.currentSequence.frames[self.frameIndex] * self.width
				local viewportX = frameX % self.imageWidth
				local viewportY = math.floor(frameX / self.imageWidth)
				self.quad:setViewport(viewportX, viewportY, self.width, self.height)
			end
		end

		Sprite.update(self, elapsed)
	end,

	draw = function (self, x, y)
		x = x or self.x
		y = y or self.y
		if not self.visible and self.image then return end
		
		-- set color if needed
		
		if self:isColorTransformed() then
			love.graphics.setColor(self:filterColor(255, 255, 255, 255))
		end
		
		-- draw the quad
			
		love.graphics.drawq(self.image, self.quad, x + self.width / 2, y + self.height / 2, self.rotation,
							self.scale.x, self.scale.y, self.width / 2, self.height / 2)
		
		-- reset color
		
		if self:isColorTransformed() then
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		Sprite.draw(self, x, y)
	end
})
