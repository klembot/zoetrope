-- Class: Timer
-- A timer allows delayed or periodic execution of a function according
-- to elapsed time in an app. In order for it to work properly, it must
-- receive update events, so it must be added somewhere in the current
-- view or app. If you are using the <View> class, then this is already
-- done for you; one is created as the View's timer property.

Timer = Sprite:extend({
	timers = {},
	visible = false,
	active = false,

	-- Method: start
	-- Adds a timer to be tracked. All arguments are passed as properties
	-- of a single object as follows:
	--
	-- Arguments:
	--		* func - function to call
	--		* delay - how long to wait to call it, in seconds
	--		* repeats - if true, then the function is called periodically, not once
	--		* arg - a table of arguments to pass to the function when called
	--
	-- Returns:
	--		nothing

	start = function (self, timer)
		assert(type(timer.func) == 'function', 'func property of timer must be a function')
		assert(type(timer.delay) == 'number', 'delay property of timer must be a number')
		
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

	stop = function (self, func)
		for i, timer in ipairs(self.timers) do
			if not func or timer.func == func then
				table.remove(self.timers, i)
			end
		end
	end,

	update = function (self, elapsed)
		for i, timer in ipairs(self.timers) do
			timer.timeLeft = timer.timeLeft - elapsed
			
			if timer.timeLeft <= 0 then
				if timer.arg then
					timer.func(unpack(timer.arg))
				else
					timer.func()
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
})
