-- Class: Emitter
-- An emitter periodically emits sprites with varying properties --
-- for example, velocity. These are set with the emitter's min and
-- max properties. For example, you could set the x velocity of
-- particles to range between -100 and 100 with these statements:
--
-- > emitter.min.velocity.x = -100
-- > emitter.max.velocity.x = 100
--
-- Properties can descend two levels deep at most.
--
-- You can specify any property in min and max, and it will be set
-- on sprites as they are emitted. Mins and maxes can only be used
-- with numeric properties.
--
-- An emitter typically doesn't have a visual appearance onscreen.
-- Particles when emitted will appear at a random spot inside the
-- rectangle defined by the emitter's x, y, width, and height
-- properties.
--
-- An emitter works like a <Group> in that it passes update and
-- draw-related messages to its particles. Because of this, all
-- particles appear at the same z index onscreen.
--
-- Any sprite may be used as a particle. When a sprite is added as
-- a particle, its die() method is called. When emitted, revive() is
-- called on it. If you want a particle to remain invisible after being
-- emitted, for example, then write an onEmit method on your sprite to do so.
--
-- Extends:
--		<Sprite>
--
-- Event: onEmit
-- Called on both the parent emitter and the emitted sprite
-- when it is emitted. If multiple particles are emitted at once, the
-- emitter will receive multiple onEmit events.

require 'zoetrope.core.sprite'

Emitter = Sprite:extend({
	solid = false,

	-- Property: emitting
	-- Boolean whether this emitter is actually emitting particles.
	emitting = true,
	
	-- Property: period
	-- How long, in seconds, the emitter should wait before emitting.
	period = math.huge,

	-- Property: emitCount
	-- How many particles to emit at once.
	emitCount = 1,

	-- Property: min
	-- Minimum numeric properties for particles.
	min = {},

	-- Property: max
	-- Maximum numeric properties for particles.
	max = {},

	-- Property: particles
	-- Sprites to be used as particles.
	particles = {},

	-- Property: emitTimer
	-- Used to keep track of when the next emit should take place.
	-- To restart the timer, set it to 0. To immediately force a particle
	-- to be emitted, set it to the emitter's period property. (Although
	-- you should probably call emit() instead.)
	emitTimer = 0,

	-- which particle to emit next
	emitIndex = 1,

	-- Method: add
	-- Adds a sprite to the list of particles.
	-- 
	-- Arguments:
	--		sprite - sprite to add
	--
	-- Returns:
	--		nothing

	add = function (self, sprite)
		sprite:die()
		table.insert(self.particles, sprite)
	end,

	-- Method: loadParticles
	-- Creates a number of particles to use based on a class.
	-- This calls new() on the class with no arguments.
	--
	-- Arguments:
	--		class - class object to instantiate
	--		count - number of particles to create
	--
	-- Returns:
	--		nothing

	loadParticles = function (self, class, count)
		for i = 1, count do
			self:add(class:new())
		end
	end,

	-- Method: emit
	-- Emits one or more particles. This ignores the emitting property.
	-- If no particles are ready to be emitted, this does nothing. 
	--
	-- Arguments:
	--		count - how many particles to emit, default 1
	--
	-- Returns:
	--		emitted particle

	emit = function (self, count)
		count = count or 1

		if #self.particles == 0 then return end

		for i = 1, count do
			local emitted = self.particles[self.emitIndex]
			self.emitIndex = self.emitIndex + 1
			
			if self.emitIndex > #self.particles then self.emitIndex = 1 end

			-- revive it and set properties

			emitted:revive()
			emitted.x = math.random(self.x, self.x + self.width)
			emitted.y = math.random(self.y, self.y + self.height)

			for key, _ in pairs(self.min) do
				if self.max[key] then
					-- simple case, single value
					
					if type(self.min[key]) == 'number' then
						emitted[key] = math.random(self.min[key], self.max[key])
					end

					-- complicated case, table

					if type(self.min[key]) == 'table' then
						for subkey, _ in pairs(self.min[key]) do
							if type(self.min[key][subkey]) == 'number' then
								emitted[key][subkey] = math.random(self.min[key][subkey], self.max[key][subkey])
							end
						end
					end
				end
			end

			if self.onEmit then self:onEmit(emitted) end
		end
	end,

	-- Method: explode
	-- This emits many particles simultaneously then immediately stops any further
	-- emissions. If you want to keep the emitter going, call emitter.emit(#emitter.particles).
	--
	-- Arguments:
	--		count - number of particles to emit, defaults to all of them
	--
	-- Returns:
	--		nothing

	explode = function (self, count)
		count = count or #self.particles

		self:emit(count)
		self.emitting = false
	end,

	update = function (self, elapsed)
		if self.emitting then
			self.emitTimer = self.emitTimer + elapsed

			if self.emitTimer > self.period then
				self:emit(self.emitCount)
				self.emitTimer = self.emitTimer - self.period
			end
		end

		for _, spr in pairs(self.particles) do
			if spr.active and spr.update then
				spr:update(elapsed)
			end
		end

		Sprite.update(self, elapsed)
	end,

	beginFrame = function (self, elapsed)
		for _, spr in pairs(self.particles) do
			if spr.active and spr.beginFrame then
				spr:beginFrame(elapsed)
			end
		end

		Sprite.beginFrame(self, elapsed)
	end,

	endFrame = function (self, elapsed)
		for _, spr in pairs(self.particles) do
			if spr.active and spr.endFrame then
				spr:endFrame(elapsed)
			end
		end

		Sprite.endFrame(self, elapsed)
	end,

	draw = function (self, x, y)
		for _, spr in pairs(self.particles) do
			if spr.visible then
				spr:draw(spr.x, spr.y)
			end
		end

		Sprite.draw(self, x, y)
	end
})
