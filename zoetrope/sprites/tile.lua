-- Class: Tile
-- A tile repeats a single image across its dimensions.
--
-- Extends:
--		<Sprite>

Tile = Sprite:extend({
	-- this must be a nonsense value, not nil,
	-- for the tile to see that an image has been set if it
	-- was initially nil
	quadImage = -1,
	
	-- Property: image
	-- The image to tile across the sprite.

	-- Propety: imageOffset
	-- Setting this moves the top-left corner of the tile inside
	-- the sprite's rectangle. To draw as normal, set both x and y
	-- to 0.
	imageOffset = { x = 0, y = 0 },

	draw = function (self, x, y)
		if not (self.visible and self.image) then return end
		x = math.floor(x or self.x)
		y = math.floor(y or self.y)
		
		-- set color if needed

		local colored = self.alpha ~= 1 or self.tint[1] ~= 1 or self.tint[2] ~= 1 or self.tint[3] ~= 1

		if colored then
			love.graphics.setColor(self.tint[1] * 255, self.tint[2] * 255, self.tint[3] * 255, self.alpha * 255)
		end

		-- if the source image has changed,
		-- we need to recreate our quad
		
		if self.image and self.image ~= self.quadImage then	
			self.quad = love.graphics.newQuad(self.imageOffset.x, self.imageOffset.y,
											  self.width, self.height,
											  self.image:getWidth(), self.image:getHeight())
			self.image:setWrap('repeat', 'repeat')
			self.quadImage = self.image
		end
		
		-- draw the quad

		love.graphics.drawq(self.image, self.quad, x + self.width / 2, y + self.height / 2, self.rotation,
							self.scale * self.distort.x, self.scale * self.distort.y,
							self.width / 2, self.height / 2)
		
		-- reset color
		
		if colored then
			love.graphics.setColor(255, 255, 255, 255)
		end
			
		Sprite.draw(self, x, y)
	end
})
