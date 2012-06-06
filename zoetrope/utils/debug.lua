-- Class: DebugConsole
-- A debug console displays the value of an expression each frame.
-- It can be used to keep track of fps, the position of a sprite,
-- and so on. It only updates when visible.

DebugConsole = Sprite:extend({
	-- Property: toggleKey
	-- What key toggles visibility. By default, this is the tilde key.
	toggleKey = '`',

	-- Property: initWithFPS
	-- If true, the watch will automatically start watching the frames
	-- per second. Changing this value after the DebugWatch object has
	-- been created has no effect.
	initWithFPS = true,

	-- Property: color
	-- Color of the console text.
	color = { 255, 255, 255 },

	-- Property: fill
	-- Background color of the console text.
	fill = { 0, 0, 0, 200 },

	-- Property: font
	-- Font to use for display.
	font = 12,

	-- Property: watchWidth
	-- How wide the sidebar, where watch values are displaed, should be.
	watchWidth = 150,

	-- internal property: _set
	-- Used to track changes in font.
	_set = { font = {} },

	new = function (self, obj)
		obj = self:extend(obj)
		
		obj.visible = false
		obj._consoleText = ''
		obj._watches = {}
		
		if obj.initWithFPS then
			obj:watch('FPS', 'love.timer.getFPS()')
		end

		-- hijack print function
		-- this is nasty to debug if it goes wrong, be careful

		obj._oldPrint = print
		print = function (...)
			local log = obj._consoleText

			for _, value in pairs({...}) do
				log = log .. tostring(value) .. ' '
			end

			log = log .. '\n'

			if obj._fontObj then
				local maxHeight = the.app.height - obj._lineHeight * 1.5
				local width = the.app.width - obj.watchWidth - obj._lineHeight / 2
				local _
				local _, lines = obj._fontObj:getWrap(log, width)
	
				while lines * obj._lineHeight > maxHeight do
					obj._oldPrint(lines)
					log = string.gsub(log, '^.-\n', '') 
					_, lines = obj._fontObj:getWrap(log, width)
				end
			end

			obj._consoleText = log
			obj._oldPrint(...)
		end
		
		the.console = obj
		if obj.onNew then obj.onNew() end
		return obj
	end,

	-- Method: watch
	-- Adds an expression to be watched.
	--
	-- Arguments:
	--		label - string label
	--		expression - expression to evaluate as a string

	watch = function (self, label, expression)
		table.insert(self._watches, { label = label,
									  func = loadstring('return ' .. expression) })
	end,

	--- Toggles visibility and updates watch expressions.

	update = function (self, elapsed)
		if the.keys:justPressed(self.toggleKey) then
			self.visible = not self.visible
		end
		
		if self.visible then
			for _, watch in pairs(self._watches) do
				local ok, value = pcall(watch.func)
				if ok then watch.value = value end
			end
		end

		Sprite.update(self, elapsed)
	end,

	draw = function (self, x, y)
		if self._set.font ~= self.font then
			self:updateFont()
		end

		local width = the.app.width
		local height = the.app.height
		local watchWidth = self.watchWidth
		local inset = self._lineHeight / 4

		-- background

		love.graphics.setColor(self.fill)
		love.graphics.rectangle('fill', 0, 0, width, height)

		-- watches

		love.graphics.setColor(self.color)

		local y = inset 

		for _, watch in pairs(self._watches) do
			love.graphics.print(watch.label .. ': ' .. watch.value, width - watchWidth, y)
			y = y + self._lineHeight
		end

		-- console

		love.graphics.printf(self._consoleText, inset, inset, width - watchWidth - inset * 2)

		love.graphics.setColor(255, 255, 255)
	end,
	
	-- private method: updateFont
	-- Updates the _fontObj property based on self.font.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateFont = function (self)
		if self.font then
			if type(self.font) == 'table' then
				self._fontObj = Cached:font(unpack(self.font))
			else
				self._fontObj = Cached:font(self.font)
			end

			self._lineHeight = self._fontObj:getHeight()
		end
	end
})
