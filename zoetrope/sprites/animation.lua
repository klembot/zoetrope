-- Class: Animation
-- An animation displays a sequence of frames.
--
--
-- Event: onEndSequence
-- Called whenever an animation sequence ends. It is passed the name
-- of the sequence that just ended.
-- 
-- Extends:
--		<Sprite>

require 'zoetrope.core.sprite'

Animation = Sprite:extend({
	-- Property: paused
	-- Set this to true to freeze the animation on the current frame.
	paused = false,

	-- Property: sequences
	-- A lookup table of sequences. Each one is stored by name and has
	-- the following properties:
	-- * name - string name for the sequence.
	-- * frames - table of frames to display. The first frame in the sheet is at index 1.
	-- * fps - frames per second.
	-- * loops - does the animation loop? defaults to true
	sequences = {},

	-- Property: currentSequence
	-- A reference to the current animation sequence table.

	-- Property: currentName
	-- The name of the current animation sequence.

	-- Property: currentFrame
	-- The current frame being displayed; starts at 1.

	-- Property: frameIndex
	-- Numeric index of the current frame in the current sequence; starts at 1.

	-- Property: frameTimer
	-- Time left before the animation changes to the next frame in seconds.
	-- Normally you shouldn't need to change this directly.

	-- private property: used to check whether the source image
	-- for our quad is up-to-date
	set = {},

	-- Method: play 
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
	--				  If there is no current frame, this freezes on the first frame.
	--
	-- Returns:
	--		nothing

	freeze = function (self, index)
		if self.currentSequence then
			index = index or self.currentSequence[self.frameIndex]
		end
		
		index = index or 1

		if self.set.image ~= self.image then
			self:updateQuad()
		end

		self.currentFrame = index
		self:updateFrame(index)
		self.paused = true
	end,

	-- private method: updateQuad
	-- sets up the sprite's quad property based on the image;
	-- needs to be called whenever the sprite's image property changes.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateQuad = function (self)
		if self.set.image == self.image then return end

		self.quad = love.graphics.newQuad(0, 0, self.width, self.height,
										  self.image:getWidth(), self.image:getHeight())
		self.imageWidth = self.image:getWidth()
		self.set.image = self.image
	end,

	-- private method: updateFrame
	-- changes the sprite's quad property based on the current frame;
	-- needs to be called whenever the sprite's currentFrame property changes.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateFrame = function (self)
		assert(type(self.currentFrame) == 'number', "current frame is not a number")
		assert(self.image, "asked to set the frame of a nil image")

		if self.set.image ~= self.image then
			self:updateQuad()
		end

		local frameX = (self.currentFrame - 1) * self.width
		local viewportX = frameX % self.imageWidth
		local viewportY = math.floor(frameX / self.imageWidth)
		self.quad:setViewport(viewportX, viewportY, self.width, self.height)
	end,

	update = function (self, elapsed)
		-- move the animation frame forward

		if self.currentSequence and not self.paused then
			self.frameTimer = self.frameTimer - elapsed
			
			if self.frameTimer <= 0 then
				self.frameIndex = self.frameIndex + 1

				if self.frameIndex > #self.currentSequence.frames then
					if self.onEndSequence then self:onEndSequence(self.currentName) end

					if self.currentSequence.loops ~= false then
						self.frameIndex = 1
					else
						self.frameIndex = self.frameIndex - 1
						self.paused = true
					end
				end

				self.currentFrame = self.currentSequence.frames[self.frameIndex]
				self:updateFrame()
				self.frameTimer = 1 / self.currentSequence.fps
			end
		end

		Sprite.update(self, elapsed)
	end,

	draw = function (self, x, y)
		x = x or self.x
		y = y or self.y
		if not self.visible and self.image then return end
		
		-- if our image changed, update the quad
		
		if self.set.image ~= self.image then
			self:updateQuad()
		end
		
		-- set color if needed
		local colored = self:isColorTransformed()

		if colored then
			love.graphics.setColor(self:filterColor(255, 255, 255, 255))
		end
		
		-- draw the quad
			
		love.graphics.drawq(self.image, self.quad, x + self.width / 2, y + self.height / 2, self.rotation,
							self.scale.x, self.scale.y, self.width / 2, self.height / 2)
		
		-- reset color
		
		if colored then
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		Sprite.draw(self, x, y)
	end
})
