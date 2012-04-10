-- Class: BitmapFont
-- This represents a proportional bitmap font, where each letter may be
-- a different width. The source image has to be formatted in a specific
-- manner, with a sentinel row above a run of glyphs. Each glyph is
-- separated by a pixel in the columns to the left and the right of the sentinel
-- row above. The color of these pixels must be the exact color at (0, 0)
-- in the image. A source image can contain any number of sentinel row/glyph row pairs.
-- 
-- An ASCII art demonstration of a tiny capital A and C:
-- 
-- (begin code)
-- x.....x...x  <--- sentinel row
-- ...x...xxx.  <--- glyph data
-- ..x.x..x...
-- .xxxxx.x...
-- .x...x.xxx.
-- (end code)
-- 
-- Any extra glyph data after the last sentinel pixel is ignored.
--
-- Once created, a BitmapFont doesn't have much in the way of user-serviceable parts.
-- Connect it to a <BitmapText> object to display some text onscreen. Creating a BitmapFont
-- can be an expensive operation. It's best to avoid doing this during your app's onRun
-- handler, before anything has been drawn.
--
-- TODO: should be able to rotate/scale
--
-- This class is based heavily on FlxBitmapFont by Brandon Cash - http://www.brandoncash.net/.
--
-- Extends:
--		<Class>

BitmapFont = Class:extend({
	-- Property: image
	-- The filename to the source image to use. Once a bitmap font is created, 
	-- this property may not be changed.
	
	-- Property: height
	-- The height of a single row of glyphs in the source image. This is calculated for
	-- you based on the source image, and you should not change this value. Every glyph
	-- must have the same height.

	-- Property: alphabet
	-- A string listing the order of glyphs' appearance in the source image.
	-- By default, it uses ASCII order.
	alphabet = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~',

	-- Constant: tracking
	-- The amount of tracking (space between glyphs in pixels) used when drawing 
	-- text to the screen. You can also specify it when calling <drawText()>.
	tracking = 2,

	-- four private properties:
	-- image - the image property coerced to an Image object 
	-- imageData - an ImageData copy of the image property, see https://love2d.org/wiki/ImageData
	-- quads - a table of quads suitable for drawing via a sprite batch, indexed by glyph
	-- batch - a sprite batch used for drawing calls

	new = function (self, obj)
		obj = self:extend(obj)
		assert(type(obj.image) == 'string', 'bitmap font images must be a string pathname')
		obj:loadImage()

		if obj.onNew then obj:onNew() end	
		return obj
	end,

	-- Method: textWidth
	-- Returns how many pixels wide a given string would be.
	--
	-- Arguments:
	--		text - string to measure
	--		tracking - how many pixels to leave between each glyph, optional
	--
	-- Returns:
	--		width in pixels

	textWidth = function (self, text, tracking)
		assert(type(text) == 'string', 'text to measure is ' .. type(text) .. ', not a string')
		tracking = tracking or self.tracking
		local width = 0

		for i = 1, #text do
			local c = string.sub(text, i, i)
			assert(self.quads[c], 'no glyph found for character "' .. c .. '"')
			local x, y, w, h = self.quads[c]:getViewport()
			width = width + w + tracking
		end

		return width
	end,

	-- Method: drawText
	-- Draws a text string onscreen. This does no line wrapping.
	--
	-- Arguments:
	--		text - string to draw
	--		x - x coordinate in pixels
	--		y - y coordinate in pixels
	--		tracking - how many pixels to leave between each glyph, optional
	--
	-- Returns:
	--		nothing

	drawText = function (self, text, x, y, tracking)
		tracking = tracking or self.tracking
		self.batch:clear()

		local charX = 0

		for i = 1, #text do
			local c = string.sub(text, i, i)
			assert(self.quads[c], 'this font has no glyph for character "' .. c .. '"')
			self.batch:addq(self.quads[c], charX, 0)
			local x, y, w, h = self.quads[c]:getViewport()

			charX = charX + w + tracking
		end

		love.graphics.draw(self.batch, x, y)
	end,

	-- private method: loadImage
	-- sets up the quads property by scanning the image for sentinels.
	-- this is called by the constructor.
	--
	-- arguments:
	--		none
	--
	-- returns:
	--		nothing

	loadImage = function (self)
		-- initialize quads and convert image to imagedata
		self.quads = {}
		self.imageData = love.image.newImageData(self.image)

		-- initialize image and batch
		self.image = love.graphics.newImage(self.image)
		self.batch = love.graphics.newSpriteBatch(self.image)

		-- locally cache info we'll be using a lot in our loop
		local imageData = self.imageData
		local imageHeight = self.imageData:getHeight()
		local imageWidth = self.imageData:getWidth()
		local alphabetLength = #self.alphabet

		-- convert pixels into a table
		local pixels = {}

		imageData:mapPixel(function (x, y, r, g, b, a)
			if not pixels[x] then
				pixels[x] = {}
			end

			pixels[x][y] = { r, g, b, a }
			return r, g, b, a
		end)

		-- sentinel color is always at (0, 0)
		local sentinel = pixels[0][0]

		-- scan downward to find height
		for y = 1, imageHeight - 1 do
			if pixels[0][y][1] == sentinel[1] and pixels[0][y][2] == sentinel[2] and
		 	   pixels[0][y][3] == sentinel[3] then
				self.height = y 
				break
			end
		end

		-- if we didn't find another sentinel, assume a single row

		if not self.height then
			self.height = imageHeight - 1
		end

		-- which character in the alphabet are we determining bounds for?
		local currentChar = 1

		-- loop through the image

		for y = 0, imageHeight - 1, self.height do
			-- starting x position of the current character's rect
			local startX = 1

			for x = 1, imageWidth - 1 do
				local color = pixels[x][y]

				if color and color[1] == sentinel[1] and color[2] == sentinel[2] and
				   color[3] == sentinel[3] and color[4] == sentinel[4] then

				    -- set up quad for the current character
					self.quads[string.sub(self.alphabet, currentChar, currentChar)] = love.graphics.newQuad(startX, y, x - startX, self.height, imageWidth, imageHeight)

					-- if we're done looking for characters, bug out
					if currentChar == alphabetLength then
						return
					else
						-- move onto to the next character
						currentChar = currentChar + 1
						startX = x + 1
					end
				end
			end
		end
	end
})
