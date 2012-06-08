-- Class: TextInput
-- This is like a <Text> object, only it listens to user input and
-- adjusts its text property accordingly.
--
-- Extends:
--		<Text>

TextInput = Text:extend({
	text = '',

	-- Property: listening
	-- Whether the input is currently listening to input.
	listening = true,

	-- Property: caret
	-- This shows the current insert position.
	caret = 0,

	-- Property: blinkRate
	-- How quickly the caret blinks, in seconds.
	blinkRate = 0.5,

	-- internal property: _blinkTimer
	-- Used to keep track of caret blinking.
	_blinkTimer = 0,

	-- internal property: _caretHeight
	-- How tall the caret is onscreen, based on the font.

	-- internal property: _caretX
	-- Where to draw the caret, relative to the sprite's x position.

	update = function (self, elapsed)
		if self.listening then
			if the.keys.typed ~= '' then
				self.text = string.sub(self.text, 1, self.caret) .. the.keys.typed
							.. string.sub(self.text, self.caret + 1)
				self.caret = self.caret + string.len(the.keys.typed)
			end

			if the.keys:justPressed('backspace') and self.caret > 0 then
				self.text = string.sub(self.text, 1, self.caret - 1) .. string.sub(self.text, self.caret + 1)
				self.caret = self.caret - 1
			end

			if the.keys:justPressed('delete') and self.caret < string.len(self.text) then
				self.text = string.sub(self.text, 1, self.caret) .. string.sub(self.text, self.caret + 2)
			end

			if the.keys:justPressed('left') and self.caret > 0 then
				self.caret = self.caret - 1
			end

			if the.keys:justPressed('right') and self.caret < string.len(self.text) then
				self.caret = self.caret + 1
			end

			if the.keys:justPressed('home') then
				self.caret = 0
			end

			if the.keys:justPressed('end') then
				self.caret = string.len(self.text)
			end
		end

		if self._set.caret ~= self.caret and self._fontObj then
			self._caretX = self._fontObj:getWidth(string.sub(self.text, 1, self.caret))
			self._caretHeight = self._fontObj:getHeight()
			self._set.caret = self.caret
		end

		self._blinkTimer = self._blinkTimer + elapsed
		if self._blinkTimer > self.blinkRate * 2 then self._blinkTimer = 0 end

		Text.update(self, elapsed)
	end,

	draw = function (self, x, y)
		if self.visible then
			x = x or self.x
			y = y or self.y

			Text.draw(self, x, y)

			-- draw caret
			
			if self._blinkTimer < self.blinkRate and self._caretX and self._caretHeight then
				love.graphics.setLineWidth(1)
				love.graphics.line(x + self._caretX, y, x + self._caretX, y + self._caretHeight)
			end
		end
	end
})
