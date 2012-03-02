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
	text = '',

	-- Propert: align
	-- Can be either 'left', 'center' or 'right'.
	align = 'left',

	-- Property: leading
	-- Space between lines, in pixels.
	leading = 0,

	-- Property: tracking
	-- Space between characters, in pixels. If omitted, uses the font's tracking.

	-- Property: wordWrap
	-- Word wrap the text to fit the sprite boundaries?
	wordWrap = true,

	-- private property: set
	-- tracks whether we need to re-layout our lines
	-- because one of our display properties has changed
	set = {},

	layoutLines = function (self)
		local textLines = split(self.text, '\n')
		local lineLength = #textLines

		self.lines = {}

		-- this is a while loop because lineLength will
		-- probably change inside the loop

		local i = 1

		while i <= lineLength do
			local width = self.font:textWidth(textLines[i], self.tracking)

			-- if word wrap is enabled, keep pushing words off the
			-- end of the line until the width is less than sprite width

			if self.wordWrap and width > self.width then
				lineLength = lineLength + 1

				-- if the next line is blank (e.g. just a newline)
				-- preserve the space by adding a line above it

				if textLines[i + 1] == '' then
					table.insert(textLines, i + 1, '')
				end

				-- if we are on the final line, add a new one

				if i + 1 > lineLength - 1 then
					table.insert(textLines, '')
				end

				-- start shifting words until we're below the width 

				while width > self.width do
					spaceIndex = string.find(textLines[i], '%s%S+$')
					if not spaceIndex then break end

					textLines[i + 1] = string.sub(textLines[i], spaceIndex) .. textLines[i + 1] 
					textLines[i] = string.sub(textLines[i], 1, spaceIndex - 1)
					width = self.font:textWidth(textLines[i], self.tracking)
				end

				-- we always end up with a leading space on the following line
				textLines[i + 1] = string.sub(textLines[i + 1], 2)
			end

			self.lines[i] = { text = textLines[i], inset = 0 }

			if self.align == 'center' then
				self.lines[i].inset = math.floor((self.width - width) / 2)
			elseif self.align == 'right' then
				self.lines[i].inset = self.width - width
			end

			i = i + 1
		end

		-- signal we've redone layout
		self.set.text = self.text
		self.set.align = self.align
		self.set.tracking = self.tracking
		self.set.leading = self.leading
	end,

	draw = function (self, x, y)
		if not self.font then return end
		if not self.text then return end
		x = x or self.x
		y = y or self.y
		local tracking = self.tracking or self.font.tracking

		-- do we need to redo layout?
		if not self.lines or self.set.text ~= self.text or self.set.align ~= self.align or
		   self.set.leading ~= self.leading or self.set.tracking ~= self.tracking then
			self:layoutLines()
		end

		for _, line in pairs(self.lines) do
			self.font:drawText(line.text, self.x + line.inset, y, tracking)
			y = y + self.font.height + self.leading
		end
	end
})
