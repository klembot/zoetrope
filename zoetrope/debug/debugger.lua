debugger = debugger or {}

-- Function: debugger.watch
-- Watches an expression.
--
-- Arguments:
--		expression - string expression to watch
--		label - label to use, defaults to expression

debugger.watch = function (expression, label)
	if the.console and the.console.watch then
		the.console.watch:addExpression(expression, label)
	end
end

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

	the.console:show()
	the.console.stepper:show()

	print(string.rep('=', 40))
	print('\nBreakpoint, ' .. caller.short_src .. ', ' .. caller.linedefined .. '\n')
	print(string.rep('=', 40))
	debug.sethook(debugger._stepLine, 'l')
end

debugger._stepLine = function (_, line)
	local state = debug.getinfo(2, 'S')

	for key, _ in pairs(debugger) do
		if state.func == debugger[key] then return end
	end

	for key, _ in pairs(the.console) do
		if state.func == the.console[key] then return end
	end

	local file = string.match(state.source, '^@(.*)')
	the.console.stepper:showLine(file, line)

	debugger._stepPaused = true

	while debugger._stepPaused do
		debugger._stepCommand = nil
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
		debug.sethook()
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
