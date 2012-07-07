-- Class: Timer
-- A timer allows delayed or periodic execution of a function according
-- to elapsed time in an app. In order for it to work properly, it must
-- receive update events, so it must be added somewhere in the current
-- view or app. If you are using the <View> class, then this is already
-- done for you; one is created as the View's timer property.

Timer = Sprite:extend{
	timers = {},
	visible = false,
	active = false,
	solid = false,

	-- Method: start
	-- Adds a timer to be tracked. All arguments are passed as properties
	-- of a single object as follows:
	--
	-- Arguments:
	--		* func - function to call
	--		* delay - how long to wait to call it, in seconds
	--		* repeats - if true, then the function is called periodically, not once
	--		* bind - first argument to pass to the function, imitates bind:func()
	--		* arg - a table of arguments to pass to the function when called
	--
	-- Returns:
	--		nothing

	start = function (self, timer)
		assert(type(timer.func) == 'function', 'func property of timer must be a function')
		assert(type(timer.delay) == 'number', 'delay property of timer must be a number')
		assert(not timer.arg or type(timer.arg) == 'table', 'arg property of timer, if specified, must be a table')

		if STRICT and timer.delay <= 0 then
			io.stderr:write('Warning: timer delay is ' .. timer.delay .. ', will be triggered immediately')
		end
		
		self.active = true
		timer.timeLeft = timer.delay
		table.insert(self.timers, timer)
	end,
	
	-- Method: stop
	-- Stops a timer from executing. If there is no function associated
	-- with this timer, then this has no effect.
	--
	-- Arguments:
	--		func - function to stop; if omitted, stops all timers
	--		bind - bind to stop; if omitted, stops all function calls of func argument
	--
	-- Returns:
	--		nothing

	stop = function (self, func, bind)
		local found = false

		for i, timer in ipairs(self.timers) do
			if not func or (timer.func == func and (not bind or timer.bind == bind)) then
				table.remove(self.timers, i)
				found = true
			end
		end

		if STRICT and not found then
			print('Warning: asked to stop a timer on a function that was not queued')
		end
	end,

	update = function (self, elapsed)
		for i, timer in ipairs(self.timers) do
			timer.timeLeft = timer.timeLeft - elapsed
			
			if timer.timeLeft <= 0 then
				if timer.arg then
					if timer.bind then
						timer.func(timer.bind, unpack(timer.arg))
					else
						timer.func(unpack(timer.arg))
					end
				else
					if timer.bind then
						timer.func(timer.bind)
					else
						timer.func()
					end
				end
				
				if timer.repeats then
					timer.timeLeft = timer.delay
					keepActive = true
				else
					table.remove(self.timers, i)
				end
			else
				keepActive = true
			end
		end
		
		self.active = (#self.timers > 0)
	end
}
