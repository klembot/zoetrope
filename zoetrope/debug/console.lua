-- Class: DebugConsole
-- It can be used to keep track of fps, the position of a sprite,
-- and so on. It only updates when visible. After being created, it
-- is accessible via <the>.console. All debugging instruments, even
-- <DebugHotkeys>, are children of this group.

DebugConsole = Group:extend
{
	-- Property: toggleKey
	-- What key toggles visibility. By default, this is the tab key.
	toggleKey = 'tab',

	-- Property: sidebarWidth
	-- How much space to reserve on the right side, for watches and stack traces.
	sidebarWidth = 300,

	-- Property: inputHistory
	-- A table of previously-entered commands.
	inputHistory = {},

	-- Property: inputHistoryIndex
	-- Which history entry, if any, we are displaying.
	inputHistoryIndex = 1,

	visible = false,

	-- Property: bg
	-- The background <Fill> used to darken the view.

	-- Property: log
	-- The <Text> sprite showing recent lines in the log.

	-- Property: input
	-- The <TextInput> that the user types into to enter commands.

	-- Property: prompt
	-- The <Text> sprite that shows a > in front of commands.

	new = function (self, obj)
		local width = the.app.width
		local height = the.app.height

		obj = self:extend(obj)
		
		obj.fill = Fill:new{ x = 0, y = 0, width = width, height = height, fill = {0, 0, 0, 200} }
		obj:add(obj.fill)

		obj.log = Text:new{ x = 4, y = 4, width = width - self.sidebarWidth - 8, height = height - 8, text = '' }
		obj:add(obj.log)

		obj.prompt = Text:new{ x = 4, y = 0, width = 100, text = '>' }
		obj:add(obj.prompt)

		local inputIndent = obj.log._fontObj:getWidth('>') + 4
		obj.input = TextInput:new
		{
			x = inputIndent, y = 0, width = the.app.width,
			active = false,
			onType = function (self, char)
				return char ~= the.console.toggleKey
			end
		}
		obj:add(obj.input)

		-- hijack print function
		-- this is nasty to debug if it goes wrong, be careful

		obj._oldPrint = print

		print = function (...)
			local caller = debug.getinfo(2)

			if caller.linedefined ~= 0 then
				obj.log.text = obj.log.text .. '(' .. caller.short_src .. ':' .. caller.linedefined .. ') '
			end

			for _, value in pairs{...} do
				obj.log.text = obj.log.text .. tostring(value) .. ' '
			end

			obj.log.text = obj.log.text .. '\n'
			obj._updateLog = true
			obj._oldPrint(...)
		end

		obj._unsourcedPrint = function (...)
			for _, value in pairs{...} do
				obj.log.text = obj.log.text .. tostring(value) .. ' '
			end

			obj.log.text = obj.log.text .. '\n'
			obj._updateLog = true
			obj._oldPrint(...)
		end

		-- add other instruments

		the.console = obj

		obj.watch = DebugWatch:new()
		obj:add(obj.watch)
		obj.hotkeys = DebugHotkeys:new()
		obj:add(obj.hotkeys)
		obj.stepper = DebugStepper:new()
		obj:add(obj.stepper)

		if obj.onNew then obj.onNew() end
		return obj
	end,

	-- Method: show
	-- Shows the debug console.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	show = function (self)
		self.visible = true
		self.input.active = self.visible

		for _, spr in pairs(self.sprites) do
			spr.visible = self.visible
		end
	end,

	-- Method: hide
	-- Hides the debug console.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	hide = function (self)
		self.visible = false
		self.input.active = self.visible

		for _, spr in pairs(self.sprites) do
			spr.visible = self.visible
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
			code = 'the.console._unsourcedPrint (' .. string.sub(code, 2) .. ')'
		end

		local func, err = loadstring(code)

		if func then
			local ok, result = pcall(func)

			if not ok then
				the.console._unsourcedPrint('Error, ' .. tostring(result) .. '\n')
			else
				the.console._unsourcedPrint('')
			end

			return tostring(result)
		else
			the.console._unsourcedPrint('Syntax error, ' .. string.gsub(tostring(err), '^.*:', '') .. '\n')
		end
	end,

	update = function (self, elapsed)
		-- listen for visibility key

		if the.keys:justPressed(self.toggleKey) then
			if self.visible then
				self:hide()
			else
				self:show()
			end
		end

		if self.visible then
			-- update log

			if self._updateLog then
				local lineHeight = self.log._fontObj:getHeight()
				local _, height = self.log:getSize()
				local linesToDelete = math.ceil((height - the.app.height - 20) / lineHeight)
				
				if linesToDelete > 0 then
					self.log.text = string.gsub(self.log.text, '.-\n', '', linesToDelete) 
					height = height - linesToDelete * lineHeight
				end

				self.prompt.y = height + 4
				self.input.y = height + 4
				self._updateLog = false
			end

			-- handle special keys at the console

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
				the.console._unsourcedPrint('>' .. self.input.text)
				self:execute(self.input.text)
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
}
