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
		
		-- rotate and scale

		local scaleX = self.scale * self.distort.x
		local scaleY = self.scale * self.distort.y

		if scaleX ~= 1 or scaleY ~= 1 or self.rotation ~= 0 then
			love.graphics.push()
			love.graphics.translate(x + self.width / 2, y + self.height / 2)
			love.graphics.scale(scaleX, scaleY)
			love.graphics.rotate(self.rotation)
			love.graphics.translate(- (x + self.width / 2), - (y + self.height / 2))
		end
		
		-- draw fill and border
		
		if self.fill then
			local fillAlpha = self.fill[4] or 255

			love.graphics.setColor(self.fill[1] * self.tint[1],
								   self.fill[2] * self.tint[2],
								   self.fill[3] * self.tint[3],
								   fillAlpha * self.alpha)
			
			love.graphics.rectangle('fill', x, y, self.width, self.height)
		end
		
		if self.border then
			local borderAlpha = self.border[4] or 255

			love.graphics.setColor(self.border[1] * self.tint[1],
								   self.border[2] * self.tint[2],
								   self.border[3] * self.tint[3],
								   borderAlpha * self.alpha)
			
			love.graphics.rectangle('line', x, y, self.width, self.height)
		end
		
		-- reset color and rotation
		
		love.graphics.setColor(255, 255, 255, 255)
		
		if scaleX ~= 1 or scaleY ~= 1 or self.rotation ~= 0 then
			love.graphics.pop()
		end
		
		Sprite.draw(self, x, y)
	end
})
