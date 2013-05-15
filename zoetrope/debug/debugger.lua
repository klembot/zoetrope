debugger = debugger or {}

-- Property: debugger.consoleKey
-- What key toggles visibility. By default, this is the tab key.
debugger.consoleKey = 'tab'

-- Function: debugger.init()
-- Adds debug instruments to the app. Must be called *after*
-- an app has started running, i.e. in its <App.onRun> event
-- handler.
--
-- Arguments:
--		Instrument classes to add, defaults to all available
--
-- Returns:
--		nothing

debugger.init = function()
	debugger.console = Group:new
	{
		visible = false,
		spacing = 10,
		instruments = { narrow = Group:new(), wide = Group:new() },
		widths = { wide = 0.7, narrow = 0.3 },

		_instrumentHeights = {},

		onNew = function (self)
			self:add(self.instruments.narrow)
			self:add(self.instruments.wide)
		end,

		onUpdate = function (self)
			if the.keys:justPressed(debugger.consoleKey) then
				if self.visible then
					debugger.hideConsole()
				else
					debugger.showConsole()
				end
			end

			if debugger.console.visible then
				for spr, height in pairs(debugger.console._instrumentHeights) do
					if height ~= spr.contentHeight then
						debugger._resizeInstruments()
					end
				end
			end
		end
	}

	the.app.meta:add(debugger.console)

	debugger.addInstrument(DebugWatch:new())
	debugger.addInstrument(DebugConsole:new())
	debugger.addInstrument(DebugStepper:new())
end

-- Function: debugger.showConsole()
-- Makes the console visible.
--
-- Arguments:
--		none
--
-- Returns:
--		nothing

debugger.showConsole = function()
	debugger.console.visible = true
end

-- Function: debugger.hideConsole
-- Makes the console invisible.
--
-- Arguments:
--		none
--
-- Returns:
--		nothing

debugger.hideConsole = function()
	debugger.console.visible = false
end

-- Function: debugger.addInstrument
-- Adds an instrument to the console, creating a container and
-- tab to select it.
--
-- Arguments:
--		instrument - <Group> enclosing the entire instrument
--
-- Returns:
--		nothing

debugger.addInstrument = function (instrument)
	local console = debugger.console
	assert(instrument.width == 'narrow' or instrument.width == 'wide',
	       "debug instrument's width property must be either 'wide' or 'narrow'")

	console.instruments[instrument.width]:add(instrument)
	debugger._resizeInstruments()
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

debugger._resizeInstruments = function()
	local console = debugger.console

	-- wide instruments

	local x = console.spacing
	local y = console.spacing
	local width = the.app.width * console.widths.wide
	local expandables = {}
	
	for _, spr in pairs(console.instruments.wide.sprites) do
		if spr.visible then
			local height = spr:totalHeight()
			console._instrumentHeights[spr] = height

			if height == '*' then
				table.insert(expandables, spr)
			else
				spr:resize(x, y, width - console.spacing, height)
				y = y + height + console.spacing
			end
		end
	end

	if #expandables > 0 then
		local height = (the.app.height - y) / #expandables

		for i, spr in ipairs(expandables) do
			spr:resize(x, y + height * (i - 1), width - console.spacing, height - console.spacing)
		end
	end

	-- narrow instruments

	x = x + width
	y = console.spacing
	width = the.app.width * console.widths.narrow
	expandables = {}

	for _, spr in pairs(console.instruments.narrow.sprites) do
		local height = spr:totalHeight()
		console._instrumentHeights[spr] = height

		if height == '*' then
			table.insert(expandables, spr)
		else
			spr:resize(x, y, width - 2 * console.spacing, height)
			y = y + height + console.spacing
		end
	end

	if #expandables > 0 then
		local height = (the.app.height - y) / #expandables

		for i, spr in ipairs(expandables) do
			spr:resize(x, y + height * (i - 1), width - console.spacing, height - console.spacing)
		end
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
		debugger.console:startFrame(elapsed)
		the.keys:update(elapsed)
		the.mouse:update(elapsed)
		debugger.console:update(elapsed)
		the.keys:endFrame(elapsed)
		the.mouse:endFrame(elapsed)
		debugger.console:endFrame(elapsed)

		if the.keys:pressed('escape') then
			if not love.quit or not love.quit() then return end
		end

		if love.graphics then
			love.graphics.clear()
			if love.draw then
				debugger.console:draw()
			end
		end

		if love.timer then love.timer.sleep(0.03) end
		if love.graphics then love.graphics.present() end
	until not forever 
end
