-- Class: OutlineText
-- An OutlineText shows text onscreen using an outline (or .ttf)
-- font. You can control the width of the text but height is ignored.
-- The rotation property also has no effect on display onscreen (sorry).
--
-- Extends:
--		<Sprite>

OutlineText = Sprite:extend({
	defaultFont = love.graphics.newFont(12),
	
	-- Property: color
	-- The color of the text drawn.
	color = { 255, 255, 255, 255 },

	-- Property: align
	-- Horizontal alignment, see http://love2d.org/wiki/AlignMode.
	-- This affects how lines wrap relative to each other, not how
	-- a single line will wrap relative to the sprite's width and height.
	align = 'left',

	-- Method: getSize
	-- Returns the width and height of the text onscreen
	-- as line-wrapped to the sprite's boundaries. If the text needs
	-- more space than the sprite's boundaries, that it returns the
	-- exact size needed.
	--
	-- Arguments:
	--		none
	-- 
	-- Returns:
	--		width, height in pixels
	
	getSize = function (self)
		if self.text == '' then return 0, 0 end

		local font = self.font or self.defaultFont
		local width = font:getWidth(self.text)
		local lineHeight = font:getHeight()

		if not self.width or self.width <= 0 or width < self.width then
			return width, lineHeight
		else
			return self.width, math.floor(width / self.width) 
		end
	end,

	-- Method: centerAround
	-- Centers the text around a position onscreen.
	--
	-- Arguments:
	--		x - center's x coordinate
	--		y - center's y coordinate
	--		centering - can be either 'horizontal', 'vertical', or 'both';
	--					default 'both'
	
	centerAround = function (self, x, y, centering)
		centering = centering or 'both'
		local width, height = self:getSize()

		if width == 0 then return end

		if centering == 'both' or centering == 'horizontal' then
			self.x = x - width / 2
		end

		if centering == 'both' or centering == 'vertical' then
			self.y = y - height / 2
		end
	end,

	draw = function (self, x, y)
		if not self.visible or not self.text then return end
		assert(not self.font or type(self.font) == 'userdata', "font property is set to a non-font")

		x = math.floor(x or self.x)
		y = math.floor(y or self.y)
		local width = self.width
		if width == 0 then width = math.huge end

		-- set color if needed
		
		if self:isColorTransformed() then
			love.graphics.setColor(self:filterColor(self.color))
		else
			love.graphics.setColor(self.color)
		end
		
		love.graphics.setFont(self.font or self.defaultFont)
		love.graphics.printf(self.text, x, y, width, self.align)

		-- reset color
		
		love.graphics.setColor(255, 255, 255, 255)
		Sprite.draw(self, x, y)
	end
})
