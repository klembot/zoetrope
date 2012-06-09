-- Class: DebugConsole
-- A debug console displays the value of an expression each frame.
-- It can be used to keep track of fps, the position of a sprite,
-- and so on. It only updates when visible.

DebugConsole = Group:extend({
	-- Property: toggleKey
	-- What key toggles visibility. By default, this is the tilde key.
	toggleKey = '`',

	-- Property: initWithFPS
	-- If true, the watch will automatically start watching the frames
	-- per second. Changing this value after the DebugWatch object has
	-- been created has no effect.
	initWithFPS = true,

	-- Property: watchWidth
	-- How wide the sidebar, where watch values are displaed, should be.
	watchWidth = 150,

	-- Property: inputHistory
	-- A table of previously-entered commands.
	inputHistory = {},

	-- Property: inputHistoryIndex
	-- Which history entry, if any, we are displaying.
	inputHistoryIndex = 1,

	-- Property: bg
	-- The background used to darken the view.

	-- Property: log
	-- Text showing recent lines in the log.

	-- Property: watchList
	-- Text showing the state of all watched variables.

	-- Property: input
	-- What the user types into to enter commands.

	-- Property: prompt
	-- The > in front of commands.

	new = function (self, obj)
		local width = the.app.width
		local height = the.app.height

		obj = self:extend(obj)
		
		obj.visible = false
		obj._watches = {}

		obj.fill = Fill:new({ x = 0, y = 0, width = width, height = height, fill = {0, 0, 0, 200} })
		obj:add(obj.fill)

		obj.log = Text:new({ x = 4, y = 4, width = width - self.watchWidth - 8, height = height - 8, text = '' })
		obj:add(obj.log)

		obj.watchList = Text:new({ x = width - self.watchWidth - 4, y = 4,
								   width = self.watchWidth - 8, height = height - 8, text = '', wordWrap = false })
		obj:add(obj.watchList)

		obj.prompt = Text:new({ x = 4, y = 0, width = '100', text = '>' })
		obj:add(obj.prompt)

		local inputIndent = obj.log._fontObj:getWidth('>') + 4
		obj.input = TextInput:new({
			x = inputIndent, y = 0, width = the.app.width,
			onType = function (self, char)
				return char ~= the.console.toggleKey
			end
		})
		obj:add(obj.input)
		
		if obj.initWithFPS then
			obj:watch('FPS', 'love.timer.getFPS()')
		end

		-- hijack print function
		-- this is nasty to debug if it goes wrong, be careful

		obj._oldPrint = print
		print = function (...)
			for _, value in pairs({...}) do
				obj.log.text = obj.log.text .. tostring(value) .. ' '
			end

			obj.log.text = obj.log.text .. '\n'
			obj._updateLog = true
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

	-- Method: execute
	-- Safely executes a string of code and prints the result.
	--
	-- Arguments:
	--		code - string code to execute
	--
	-- Returns:
	--		string result

	execute = function (self, code)
		local func, err = loadstring(code)

		if func then
			local ok, result = pcall(func)

			if ok then
				print(tostring(result) .. '\n')
			else
				print('Error, ' .. tostring(result) .. '\n')
			end
		else
			print('Syntax error, ' .. tostring(err) .. '\n')
		end

		return tostring(result)
	end,

	update = function (self, elapsed)
		-- listen for visibility key

		if the.keys:justPressed(self.toggleKey) then
			self.visible = not self.visible
		end

		if self.visible then
			-- update watches

			self.watchList.text = ''
			
			for _, watch in pairs(self._watches) do
				local ok, value = pcall(watch.func)
				if not ok then value = nil end

				self.watchList.text = self.watchList.text .. watch.label .. ': ' .. tostring(value) .. '\n'
			end

			-- update log

			if self._updateLog then
				local maxHeight = the.app.height - 20
				local _, height = self.log:getSize()

				while height > maxHeight do
					self.log.text = string.gsub(self.log.text, '^.-\n', '') 
					_, height = self.log:getSize()
				end

				self.prompt.y = height + 4
				self.input.y = height + 4
				self._updateLog = false
			end

			if the.keys:justPressed('up') and self.inputHistoryIndex > 1 then
				-- save what the user was in the middle of typing

				self.inputHistory[self.inputHistoryIndex] = self.input.text

				self.input.text = self.inputHistory[self.inputHistoryIndex - 1]
				self.input.caret = string.len(self.input.text)
				self.inputHistoryIndex = self.inputHistoryIndex - 1
			end

			if the.keys:justPressed('down') and self.inputHistoryIndex < #self.inputHistory then
				self.input.text = self.inputHistory[self.inputHistoryIndex + 1]
				self.input.caret = string.len(self.input.text)
				self.inputHistoryIndex = self.inputHistoryIndex + 1
			end

			if the.keys:justPressed('return') then
				print('>' .. self.input.text)
				self:execute('return ' .. self.input.text)
				table.insert(self.inputHistory, self.inputHistoryIndex, self.input.text)

				while #self.inputHistory > self.inputHistoryIndex do
					table.remove(self.inputHistory)
				end

				self.inputHistoryIndex = self.inputHistoryIndex + 1
				self.input.text = ''
				self.input.caret = 0
			end
		end

		Group.update(self, elapsed)
	end
})
