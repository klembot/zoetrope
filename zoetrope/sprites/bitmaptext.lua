-- Class: BitmapText
-- This displays text using a <BitmapFont>. 
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.sprite'

BitmapText = Sprite:extend({
	-- Property: font
	-- What <BitmapFont> to use.

	-- Property: text
	-- What text to display.

	-- Property: leading
	-- Space between lines, in pixels.
	leading = 4,

	-- Property: tracking
	-- Space between characters, in pixels.
	tracking = 2,

	-- Property: wordWrap
	-- Word wrap the text to fit the sprite boundaries?
	wordWrap = true,

	layoutLines = function (self)
		local textLines = split(this.text, '\n')
		local lineLength = #textLines

		for i = 1, lineLength do
			local width = this.font:textWidth(textLines[i], this.tracking)

			-- if word wrap is enabled, keep pushing words off the
			-- end of the line until the width is less than sprite width

			if self.wordWrap and width > self.width then
				lineLength = lineLength + 1

				-- if we are on the final line, add a new one

				if i + 1 > lineLength then
					table.insert(textLines, '')
				end

				-- if the next line is blank (e.g. just a newline)
				-- preserve the space by adding a line above it

				if (

			end
		end
	end,

	draw = function (self, x, y)
		if not self.font then return end
		if not self.text then return end
		x = x or self.x
		y = y or self.y

		-- do we need to redo layout?
		if not self.lines then
			self:layoutLines()
		end

		for _, line in pairs(self.lines) do
			self.font:drawText(line.text, line.inset, y, self.tracking)
			y = y + self.font.height + self.leading
		end
	end
})
