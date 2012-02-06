-- Class: Tile
-- A tile repeats a single image across its dimensions.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.sprite'

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
		x = x or self.x
		y = y or self.y
		local colored = self:isColorTransformed()
		
		-- if the source image has changed,
		-- we need to recreate our quad
		
		if self.image and self.image ~= self.quadImage then	
			self.quad = love.graphics.newQuad(self.imageOffset.x, self.imageOffset.y,
											  self.width, self.height,
											  self.image:getWidth(), self.image:getHeight())
			self.image:setWrap('repeat', 'repeat')
			self.quadImage = self.image
		end
		
		-- set color if needed
		
		if colored then
			love.graphics.setColor(self:filterColor(255, 255, 255, 255))
		end
		
		-- draw the quad

		love.graphics.drawq(self.image, self.quad, x + self.width / 2, y + self.height / 2, self.rotation,
							self.scale.x, self.scale.y,	self.width / 2, self.height / 2)
		
		-- reset color
		
		if colored then
			love.graphics.setColor(255, 255, 255, 255)
		end
			
		Sprite.draw(self, x, y)
	end
})
