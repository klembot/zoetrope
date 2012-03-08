-- Class: Fill
-- A fill paints a rectangle of a solid color and border.
-- Either fill or border are optional.
--
-- Extends:
--		<Sprite>

Fill = Sprite:extend({
	-- Property: fill
	-- A table of color values in RGBA order. Each value should fall
	-- between 0 and 255. The fill sprite fills this color in its bounds
	-- onscreen.
	fill = { 255, 255, 255, 255 },

	-- Property: border
	-- A table of color values in RGBA order. Each value should fall
	-- between 0 and 255. The fill sprite draws the border in this color
	-- after filling in a color (if any).
	border = nil,

	draw = function (self, x, y)
		x = math.floor(x or self.x)
		y = math.floor(y or self.y)
		if not self.visible then return end
		
		-- color transforms
		
		local needsFilter = self:isColorTransformed()
		
		-- rotate and scale
		
		if self.scale.x ~= 1 or self.scale.y ~= 1 or self.rotation ~= 0 then
			love.graphics.push()
			love.graphics.translate(x + self.width / 2, y + self.height / 2)
			love.graphics.scale(self.scale.x, self.scale.y)
			love.graphics.rotate(self.rotation)
			love.graphics.translate(- (x + self.width / 2), - (y + self.height / 2))
		end
		
		-- draw fill and border
		
		if self.fill then
			if needsFilter then
				love.graphics.setColor(self:filterColor(self.fill))
			else
				love.graphics.setColor(self.fill)
			end
			
			love.graphics.rectangle('fill', x, y, self.width, self.height)
		end
		
		if self.border then
			if needsFilter then
				love.graphics.setColor(self:filterColor(self.border))
			else
				love.graphics.setColor(self.border)
			end
			
			love.graphics.rectangle('line', x, y, self.width, self.height)
		end
		
		-- pass up the chain, restore state
		
		Sprite.draw(self, x, y)
		
		-- reset color
		
		love.graphics.setColor(255, 255, 255, 255)
		
		if self.scale.x ~= 1 or self.scale.y ~= 1 or self.rotation ~= 0 then
			love.graphics.pop()
		end
	end
})
