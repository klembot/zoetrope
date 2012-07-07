-- Class: Tween
-- A tween transitions a property from one state to another
-- in in-game time. A tween instance is designed to manage
-- many of these transitions at once, in fact. In order for it
-- to work properly, it must receive update events, so it must
-- be added somewhere in the current view or app. If you are using
-- the <View> class, this is already done for you.

Tween = Sprite:extend{
	tweens = {},
	visible = false,
	active = false,
	solid = false,

	-- Property: easers
	-- These are different methods of easing a tween, and
	-- can be set via the ease property of an individual tween.
	-- They should be referred to by their key name, not the property
	-- (e.g. 'linear', no Tweener.easers.linear).
	-- See http://www.gizma.com/easing/ for details.
	
	easers =
	{
		linear = function (elapsed, start, change, duration)
			return change * elapsed / duration + start
		end,
		
		quadIn = function (elapsed, start, change, duration)
			elapsed = elapsed / duration
			return change * elapsed * elapsed + start
		end,
		
		quadOut = function (elapsed, start, change, duration)
			elapsed = elapsed / duration
			return - change * elapsed * (elapsed - 2) + start
		end,
		
		quadInOut = function (elapsed, start, change, duration)
			elapsed = elapsed / (duration / 2)
			
			if (elapsed < 1) then
				return change / 2 * elapsed * elapsed + start
			else
				elapsed = elapsed - 1
				return - change / 2 * (elapsed * (elapsed - 2) - 1) + start
			end
		end
	},
	
	-- Method: reverse
	-- A utility function; if set as an onComplete handler for an individual
	-- tween, it reverses the tween that just happened. Use this to get a tween
	-- to repeat back and forth indefinitely (e.g. to have something glow).
	
	reverse = function (tween, tweener)
		tween.to = tween.from
		tweener:start(tween)
	end,

	-- Method: reverseOnce
	-- A utility function; if set as as an onComplete handler for an individual
	-- tween, it reverses the tween that just happened-- then stops the tween after that.
	
	reverseOnce = function (tween, tweener)
		tween.to = tween.from
		tween.onComplete = nil
		tweener:start(tween)	
	end,

	-- Method: start
	-- Begins a tweened transition. *All* arguments are passed via
	-- properties of a single object as follows:
	--
	-- Arguments:
	--		target - target object
	--		prop - name of property of the target object to tween;
	--             can be either a number or a table of numbers (e.g. a color)
	--		to - destination value, either number or color table
	--		getter - getter function for the property; overrides property
	--		setter - setter function for the property; overrides property
	--		duration - how long the tween should last in seconds, default 1
	--		force - override any pre-existing tweens on this object/property?
	--		ease - function name (in Tweener.easers) to use to control how the value changes
	--		onComplete - function to call when the tween finishes; is passed the individual tween object 
	--
	-- Returns:
	--		nothing

	start = function (self, tween)
		tween.duration = tween.duration or 1
		tween.ease = tween.ease or 'linear'
		
		assert(type(tween.target) == 'table' or type(tween.target) == 'userdata',
			   'tween target must be a table or userdata')
		assert(tween.prop or tween.getter, 'neither tween prop (property) nor getter are defined')
		assert(not tween.prop or tween.target[tween.prop],
			   'no such property ' .. tostring(tween.prop) .. ' on target') 
		assert(type(tween.duration) == 'number', 'tween duration must be a number')
		assert(self.easers[tween.ease], 'easer ' .. tween.ease .. ' is not defined')
			
		-- check for an existing tween for this target and property
		
		for i, otherTweener in ipairs(self.tweens) do
			if tween.target == otherTweener.target and
			   tween.prop == otherTweener.prop then
				if tween.force then
					table.remove(self.tweens, i)
				else
					if STRICT then
						print('Warning: asked to tween a value that\'s already being tweened, ' ..
							  'giving up (use force = true to override this)')
					end

					return
				end
			end
		end
		
		-- add it
		tween.from = self:getTweenValue(tween)
		tween.type = type(tween.from)
		
		-- calculate change; if it's trivial, skip the tween
		
		if tween.type == 'number' then
			tween.change = tween.to - tween.from
			if math.abs(tween.change) < NEARLY_ZERO then
				if STRICT then
					print('Warning: asked to tween a value to its current state, giving up')
				end

				return
			end
		elseif tween.type == 'table' then
			tween.change = {}
			
			local skip = true
			
			for i, value in ipairs(tween.from) do
				tween.change[i] = tween.to[i] - tween.from[i]
				
				if math.abs(tween.change[i]) > NEARLY_ZERO then
					skip = false
				end
			end
			
			if skip then
				if STRICT then
					print('Warning: asked to tween a value to its current state, giving up')
				end

				return
			end
		else
			error('tweened property must either be a number or a table of numbers, is ' .. tween.type)
		end
			
		tween.elapsed = 0
		table.insert(self.tweens, tween)
		self.active = true
	end,

	-- Method: stop
	-- Stops a tween.
	--
	-- Arguments:
	--		target - tween target
	-- 		prop - name of property being tweened; if omitted, stops all tweens on the target
	--
	-- Returns:
	--		nothing

	stop = function (self, target, prop)
		local found = false

		for i, tween in ipairs(self.tweens) do
			if tween.target == target and (not prop or tween.prop == prop) then
			   	found = true
				table.remove(self.tweens, i)
			end
		end

		if STRICT and not found then
			print('Warning: asked to stop a tween, but no active tweens match it')
		end
	end,

	update = function (self, elapsed)	
		for i, tween in ipairs(self.tweens) do
			self.active = true
			tween.elapsed = tween.elapsed + elapsed
			
			if tween.elapsed >= tween.duration then
				-- tween is completed
				
				self:setTweenValue(tween, tween.to)
				table.remove(self.tweens, i)
				
				-- this must happen after the tween is removed
				-- so that it doesn't appear that it is still running
				-- to the callback
				
				if tween.onComplete then tween.onComplete(tween, self) end
			else
				-- move tween towards finished state
				
				if tween.type == 'number' then
					self:setTweenValue(tween, self.easers[tween.ease](tween.elapsed,
									   tween.from, tween.change, tween.duration))
				elseif tween.type == 'table' then
					local now = {}
					
					for i, value in ipairs(tween.from) do
						now[i] = self.easers[tween.ease](tween.elapsed, tween.from[i],
														 tween.change[i], tween.duration)
					end
					
					self:setTweenValue(tween, now)
				end
			end
		end
		
		self.active = (#self.tweens > 0)
	end,

	getTweenValue = function (self, tween)
		if tween.getter then
			return tween.getter(tween.target)
		else
			return tween.target[tween.prop]
		end
	end,

	setTweenValue = function (self, tween, value)
		if tween.setter then
			tween.setter(tween.target, value)
		else
			tween.target[tween.prop] = value
		end
	end
}
