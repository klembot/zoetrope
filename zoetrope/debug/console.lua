-- Class: DebugConsole
-- Displays a running log of output that is print()ed, and allows
-- interactive execution of Lua This adds a debugger.unsourcedPrint
-- function that allows output of text without the usual source
-- attribution.

DebugConsole = DebugInstrument:extend
{
	-- Property: inputHistory
	-- A table of previously-entered commands.
	inputHistory = {},

	-- Property: inputHistoryIndex
	-- Which history entry, if any, we are displaying.
	inputHistoryIndex = 1,

	width = 'wide',
	contentHeight = '*',

	-- Property: log
	-- The <Text> sprite showing recent lines in the log.

	-- Property: input
	-- The <TextInput> that the user types into to enter commands.

	-- Property: prompt
	-- The <Text> sprite that shows a > in front of commands.

	onNew = function (self)
		self.title.text = 'Console'

		self.log = Text:new{ font = self.font }
		self:add(self.log)

		self.prompt = Text:new{ font = self.font, text = '>' }
		self:add(self.prompt)

		local w = self.prompt:getSize()
		self.inputIndent = w
		self.lineHeight = self.log._fontObj:getHeight()

		self.input = TextInput:new
		{
			font = self.font,
			onType = function (self, char)
				return char ~= debugger.consoleKey
			end
		}
		self:add(self.input)

		-- hijack print function
		-- this is nasty to debug if it goes wrong, be careful

		self._oldPrint = print

		print = function (...)
			local caller = debug.getinfo(2)

			if caller.linedefined ~= 0 then
				self.log.text = self.log.text .. '(' .. caller.short_src .. ':' .. caller.linedefined .. ') '
			end

			for _, value in pairs{...} do
				self.log.text = self.log.text .. tostring(value) .. ' '
			end

			self.log.text = self.log.text .. '\n'
			self._updateLog = true
			self._oldPrint(...)
		end

		debugger.unsourcedPrint = function (...)
			for _, value in pairs{...} do
				self.log.text = self.log.text .. tostring(value) .. ' '
			end

			self.log.text = self.log.text .. '\n'
			self._updateLog = true
			self._oldPrint(...)
		end

		-- This replaces the default love.errhand() method, displaying
		-- a stack trace and allowing inspection of the state of things.

		debugger._handleCrash = function (message)
			if debugger._crashed then
				debugger._originalErrhand(message)
				return
			end

			debugger._crashed = true
			local print = debugger.unsourcedPrint or print
			debug.sethook()
			setmetatable(_G, nil)
			love.audio.stop()

			print(string.rep('=', 40))
			print('Crash, ' .. message)
			print(debug.traceback('', 3))
			print('\nlocal variables:')

			-- http://www.lua.org/pil/23.1.1.html

			local i = 1
			local localVars = {}

			while true do
				local name, value = debug.getlocal(4, i)
				if not name then break end

				if (not string.find(name, ' ')) then
					table.insert(localVars, name)
					_G[name] = value
				end
				 
				i = i + 1
			end

			table.sort(localVars)

			for _, name in pairs(localVars) do
				local val

				if type(_G[name]) == 'string' then
					val = "'" .. string.gsub(_G[name], "'", "\\'") .. "'"
				elseif type(_G[name]) == 'table' then
					val = tostring(_G[name]) .. ' (' .. props(_G[name]) .. ')'
				else
					val = tostring(_G[name])
				end

				print(name .. ': ' .. val)
			end

			print(string.rep('=', 40) .. '\n')
			debugger.showConsole()

			if debugger._miniEventLoop then debugger._miniEventLoop(true) end
		end
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
		if string.sub(code, 1, 1) == '=' then
			code = 'debugger.unsourcedPrint (' .. string.sub(code, 2) .. ')'
		end

		local func, err = loadstring(code)

		if func then
			local ok, result = pcall(func)

			if not ok then
				debugger.unsourcedPrint('Error, ' .. tostring(result) .. '\n')
			else
				debugger.unsourcedPrint('')
			end

			return tostring(result)
		else
			debugger.unsourcedPrint('Syntax error, ' .. string.gsub(tostring(err), '^.*:', '') .. '\n')
		end
	end,

	onUpdate = function (self, elapsed)
		-- update the log contents if output is waiting

		if self._updateLog then
			local _, height = self.log:getSize()
			local linesToDelete = math.ceil((height - self.log.height) / self.lineHeight)
			
			if linesToDelete > 0 then
				self.log.text = string.gsub(self.log.text, '.-\n', '', linesToDelete) 
			end
			
			_, height = self.log:getSize()

			self.prompt.y = self.log.y + height
			self.input.y = self.log.y + height
			self._updateLog = false
		end

		-- control keys to jump to different sides and erase everything

		if the.keys:pressed('ctrl') and the.keys:justPressed('a') then
			self.input.caret = 0
		end

		if the.keys:pressed('ctrl') and the.keys:justPressed('e') then
			self.input.caret = string.len(self.input.text)
		end

		if the.keys:pressed('ctrl') and the.keys:justPressed('k') then
			self.input.caret = 0
			self.input.text = ''
		end

		-- up and down arrows cycle through history

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

		-- return executes

		if the.keys:justPressed('return') then
			debugger.unsourcedPrint('>' .. self.input.text)
			self:execute(self.input.text)
			table.insert(self.inputHistory, self.inputHistoryIndex, self.input.text)

			while #self.inputHistory > self.inputHistoryIndex do
				table.remove(self.inputHistory)
			end

			self.inputHistoryIndex = self.inputHistoryIndex + 1
			self.input.text = ''
			self.input.caret = 0
		end
	end,

	onResize = function (self, x, y, width, height)
		self.log.x = x + self.spacing
		self.log.y = y + self.spacing
		self.log.width = width - self.spacing * 2
		self.log.height = height - self.spacing * 2

		self.prompt.x = self.log.x
		self.input.x = self.prompt.x + self.inputIndent
		self.input.width = width - self.inputIndent

		self._updateLog = true
	end
}
