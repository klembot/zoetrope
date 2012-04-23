-- Class: Text
-- Shows text onscreen using an outline (e.g. TrueType) or bitmap font. 
-- You can control the width of the text but the height is ignored; it
-- will always draw the entirety of its text property.
--
-- By default, an outline font will display as white. To change its color,
-- change its <Sprite.tint> property.
--
-- Extends:
--		<Sprite>

Text = Sprite:extend({
	-- Property: text
	-- Text string to draw.

	-- Property: font
	-- Font to use to draw. See <Cached.font> for possible values here; if
	-- you need more than one value, use table notation. Some example values:
	-- 		* 12 (default font, size 12)
	--		* 'fonts/bitmapfont.png' (bitmap font, default character order)
	--		* { 'fonts/outlinefont.ttf', 12 } (outline font, font size)
	--		* { 'fonts/bitmapfont.ttf', 'ABCDEF' } (bitmap font, custom character order)
	font = 12,

	-- Property: align
	-- Horizontal alignment, see http://love2d.org/wiki/AlignMode.
	-- This affects how lines wrap relative to each other, not how
	-- a single line will wrap relative to the sprite's width and height.
	align = 'left',

	-- private property: used to check whether our font has changed
	set = { font = {} },

	-- Method: getSize
	-- Returns the width and height of the text onscreen as line-wrapped
	-- to the sprite's boundaries. This disregards the sprite's height property.
	--
	-- Arguments:
	--		none
	-- 
	-- Returns:
	--		width, height in pixels
	
	getSize = function (self)
		if self.text == '' then return 0, 0 end

		-- did our font change on us?

		if type(self.font) == 'table' then
			for key, value in pairs(self.font) do
				if self.set.font[key] ~= self.font[key] then
					self:updateFont()
					break
				end
			end
		else
			if self.font ~= self.set.font then
				self:updateFont()
			end
		end

		local width = self.fontObj:getWidth(self.text)
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

	-- private method: updateFont
	-- Updates the fontObj property based on self.font.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateFont = function (self)
		if type(self.font) == 'table' then
			self.fontObj = Cached:font(unpack(self.font))
		else
			self.fontObj = Cached:font(self.font)
		end
	end,

	draw = function (self, x, y)
		if STRICT then
			if not self.text then error('visible text sprite has no text property') end
			if not self.font then error('visible text sprite has no font property') end
		end

		if not self.visible or not self.text or not self.font then return end

		x = math.floor(x or self.x)
		y = math.floor(y or self.y)

		-- did our font change on us?

		if type(self.font) == 'table' then
			for key, value in pairs(self.font) do
				if self.set.font[key] ~= self.font[key] then
					self:updateFont()
					break
				end
			end
		else
			if self.font ~= self.set.font then
				self:updateFont()
			end
		end
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

		-- set color if needed

		local colored = self.alpha ~= 1 or self.tint[1] ~= 1 or self.tint[2] ~= 1 or self.tint[3] ~= 1

		if colored then
			love.graphics.setColor(self.tint[1] * 255, self.tint[2] * 255, self.tint[3] * 255, self.alpha * 255)
		end
		
		love.graphics.setFont(self.fontObj)
		love.graphics.printf(self.text, x, y, self.width, self.align)

		-- reset color and rotation
	
		if colored then love.graphics.setColor(255, 255, 255, 255) end

		if scaleX ~= 1 or scaleY ~= 1 or self.rotation ~= 0 then
			love.graphics.pop()
		end
		
		Sprite.draw(self, x, y)
	end
})
