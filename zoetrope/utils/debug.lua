-- Class: DebugConsole
-- It can be used to keep track of fps, the position of a sprite,
-- and so on. It only updates when visible. After being created, it
-- is accessible via <the>.console.
--
-- This also allows debugging hotkeys -- e.g. you could set it so that
-- pressing Control-Alt-I toggles invincibility of the player sprite.
-- Out of the box:
--		- Control-Alt-F toggles fullscreen
--		- Control-Alt-Q quits the app.
--		- Control-Alt-P deactivates the view.
-- 		- Control-Alt-R reloads all app code from on disk.
--		- Control-Alt-S saves a screenshot to the app's directory --
--		  see https://love2d.org/wiki/love.filesystem for where this is.

DebugConsole = Group:extend
{
	-- Property: toggleKey
	-- What key toggles visibility. By default, this is the tab key.
	toggleKey = 'tab',

	-- Property: hotkeyModifiers
	-- A table of modifier keys that must be held in order to activate
	-- a debugging hotkey (set via <addHotkey()>). If you want hotkeys to
	-- activate without having to hold any keys down, set this to nil.
	hotkeyModifiers = {'ctrl', 'alt'},

	-- Property: watchBasics
	-- If true, the console will automatically start watching the frames
	-- per second and memory usage. Changing this value after the object has
	-- been created has no effect.
	watchBasics = true,

	-- Property: watchWidth
	-- How wide the sidebar, where watch values are displayed, should be.
	watchWidth = 150,

	-- Property: inputHistory
	-- A table of previously-entered commands.
	inputHistory = {},

	-- Property: inputHistoryIndex
	-- Which history entry, if any, we are displaying.
	inputHistoryIndex = 1,

	-- Property: bg
	-- The background <Fill> used to darken the view.

	-- Property: log
	-- The <Text> sprite showing recent lines in the log.

	-- Property: watchList
	-- The <Text> sprite showing the state of all watched variables.

	-- Property: input
	-- The <TextInput> that the user types into to enter commands.

	-- Property: prompt
	-- The <Text> sprite that shows a > in front of commands.

	-- internal property: _bindings
	-- Keeps track of debugging hotkeys.

	new = function (self, obj)
		local width = the.app.width
		local height = the.app.height

		obj = self:extend(obj)
		
		obj.visible = false
		obj._watches = {}
		obj._hotkeys = {}

		obj.fill = Fill:new{ x = 0, y = 0, width = width, height = height, fill = {0, 0, 0, 200} }
		obj:add(obj.fill)

		obj.log = Text:new{ x = 4, y = 4, width = width - self.watchWidth - 8, height = height - 8, text = '' }
		obj:add(obj.log)

		obj.watchList = Text:new{ x = width - self.watchWidth - 4, y = 4,
								   width = self.watchWidth - 8, height = height - 8, text = '', wordWrap = false }
		obj:add(obj.watchList)

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

		-- some default behavior

		obj:addHotkey('f', function() the.app:toggleFullscreen() end)
		obj:addHotkey('p', function()
			the.view.active = not the.view.active
			if the.view.active then
				the.view:tint()
			else
				the.view:tint(0, 0, 0, 200)
			end
		end)
		obj:addHotkey('q', love.event.quit)
		if debugger then obj:addHotkey('r', debugger.reload) end
		obj:addHotkey('s', function() the.app:saveScreenshot('screenshot.png') end)
		
		if obj.watchBasics then
			obj:watch('FPS', 'love.timer.getFPS()')
			obj:watch('Memory', 'math.floor(collectgarbage("count") / 1024) .. "M"')
		end

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

	-- Method: addHotkey
	-- Adds a hotkey to execute a function. This hotkey will require
	-- holding down whatever modifiers are set in <hotkeyModifiers>.
	--
	-- Arguments:
	--		key - key to trigger the hotkey
	--		func - function to run. This will receive the key that
	--			   was pressed, so you can re-use functions (i.e. 
	--			   the 1 key loads level 1, the 2 key loads level 2).
	--
	-- Returns:
	--		nothing

	addHotkey = function (self, key, func)
		table.insert(self._hotkeys, { key = key, func = func })
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
		self.input.active = true
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
		self.input.active = false
	end,

	update = function (self, elapsed)
		-- listen for visibility key

		if the.keys:justPressed(self.toggleKey) then
			self.visible = not self.visible
			self.input.active = self.visible
		end

		-- listen for hotkeys

		local modifiers = (self.hotkeyModifiers == nil)

		if not modifiers then
			modifiers = true

			for _, key in pairs(self.hotkeyModifiers) do
				if not the.keys:pressed(key) then
					modifiers = false
					break
				end
			end
		end

		if modifiers then
			for _, hotkey in pairs(self._hotkeys) do
				if the.keys:justPressed(hotkey.key) then
					hotkey.func(hotkey.key)
				end
			end
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

if debugger then

	-- Function: debugger.reload
	-- Resets the entire app and forces all code to be reloaded from 
	-- on disk. via https://love2d.org/forums/viewtopic.php?f=3&t=7965
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	debugger.reload = function()
		if DEBUG then
			love.audio.stop()

			-- create local references to needed variables
			-- because we're about to blow the global scope away

			local initialGlobals = debugger._initialGlobals
			local initialPackages = debugger._initialPackages
			
			-- reset global scope

			for key, _ in pairs(_G) do
				_G[key] = initialGlobals[key]
			end

			-- reload main file and restart

			for key, _ in pairs(package.loaded) do
				if not initialPackages[key] then
					package.loaded[key] = nil
				end
			end

			require('main')
			love.load()
		end
	end
	
	debugger.breakpt = function()
		local print = the.console._unsourcedPrint or print
		local caller = debug.getinfo(2, 'S')

		debugger._sourceFiles = {}
		debugger._breakControls = Group:new()

		debugger._breakControls:add(Button:new
		{
			x = 200, y = the.app.height - 20,
			width = 100, height = 20,
			label = Text:new{ text = 'Step', width = 100, align = 'center' },
			background = Fill:new{ width = 100, height = 20, fill = {0, 0, 0}, border = {255, 255, 255} },
			onMouseUp = function(self)
				debugger._stepCommand = 'next'
			end
		})

		debugger._breakControls:add(Button:new
		{
			x = 400, y = the.app.height - 20,
			width = 100, height = 20,
			label = Text:new{ text = 'Continue', width = 100, align = 'center' },
			background = Fill:new{ width = 100, height = 20, fill = {0, 0, 0}, border = {255, 255, 255} },
			onMouseUp = function(self)
				debugger._stepCommand = 'continue'
			end
		})

		the.console:add(debugger._breakControls)

		the.console:show()
		print(string.rep('=', 40))
		print('\nBreakpoint, ' .. caller.short_src .. ', ' .. caller.linedefined .. '\n')
		print(string.rep('=', 40))
		debug.sethook(debugger._stepLine, 'l')
	end

	debugger._stepLine = function (_, line)
		local state = debug.getinfo(2, 'S')

		for key, _ in pairs(debugger) do
			print('skipping debugger statement')
			if state.func == debugger[key] then return end
		end

		for key, _ in pairs(the.console) do
			print('skipping console statement')
			if state.func == the.console[key] then return end
		end

		local print = the.console._unsourcedPrint or print
		local file = string.match(state.source, '^@(.*)')
		local sourceLine

		if file then
			if not debugger._sourceFiles[file] then
				debugger._sourceFiles[file] = {}

				for line in love.filesystem.lines(file) do
					table.insert(debugger._sourceFiles[file], line)
				end
			end

			sourceLine = debugger._sourceFiles[file][line]
		end

		print(state.short_src .. ', ' .. line .. ':\t' .. (sourceLine or '(source not available)'))

		debugger._stepPaused = true

		while debugger._stepPaused do
			debugger._miniEventLoop()

			if debugger._stepCommand == 'next' then
				debugger._stepPaused = false
			elseif debugger._stepCommand == 'continue' then
				debugger._stepPaused = false
				the.console:hide()
				debug.sethook()
			end
		end
	end

	-- internal function: debugger._handleCrash
	-- This replaces the default love.errhand() method, displaying
	-- a stack trace and allowing inspection of the state of things.
	-- 
	-- Arguments:
	--		message - string error message to display
	--
	-- Returns:
	--		nothing

	debugger._handleCrash = function (message)
		if debugger._crashed then
			debugger._originalErrhand(message)
			return
		end

		if the.console and the.keys then
			debugger._crashed = true
			local print = the.console._unsourcedPrint
			setmetatable(_G, nil)

			print(string.rep('=', 40))
			print('\nCrash, ' .. message)
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

			print('\n' .. string.rep('=', 40) .. '\n')
			the.console:show()
			love.audio.stop()

			if debugger._miniEventLoop then debugger._miniEventLoop(true) end
		else
			debugger._originalErrhand(message)
		end
	end

	-- internal function: debugger._miniEventLoop
	-- This replicates the entire LOVE event loop, but only updates/draws
	-- the debug console, keyboard, and mouse. This is so that after a crash or
	-- during a break, drawing and updates still continue to happen.
	--
	-- Arguments:
	--		forever - run indefinitely, or just for a single frame?
	--
	-- Returns:
	--		nothing

	debugger._miniEventLoop = function (forever)
		local elapsed = 0

		repeat
			if love.event then
				love.event.pump()
				
				for e, a, b, c, d in love.event.poll() do
					if e == 'quit' then
						if not love.quit or not love.quit() then return end
					end

					love.handlers[e](a, b, c, d)
				end
			end

			if love.timer then
				love.timer.step()
				elapsed = love.timer.getDelta()
			end

			the.keys:startFrame(elapsed)
			the.mouse:startFrame(elapsed)
			the.console:startFrame(elapsed)
			the.keys:update(elapsed)
			the.mouse:update(elapsed)
			the.console:update(elapsed)
			the.keys:endFrame(elapsed)
			the.mouse:endFrame(elapsed)
			the.console:endFrame(elapsed)

			if the.keys:pressed('escape') then
				if not love.quit or not love.quit() then return end
			end

			if love.graphics then
				love.graphics.clear()
				if love.draw then
					the.console:draw()
				end
			end

			if love.timer then love.timer.sleep(0.03) end
			if love.graphics then love.graphics.present() end
		until not forever 
	end
end
