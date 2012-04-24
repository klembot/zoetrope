-- Class: Sound
-- A sound is an instance of a source audio file, e.g. an mp3.
-- A sound *must* be added somewhere either in your app's
-- view or meta view in order for it to work properly. A sound
-- that is not added to a view will still play, but changing
-- its properties will not work.
--
--
-- Extends:
--		<Sprite>

Sound = Sprite:extend({
	visible = false,
	solid = false,

	-- Property: source
	-- The audio source to use. See https://love2d.org/wiki/Source
	-- for details. This cannot be shared with any other Sound object.
	
	-- Property: volume
	-- 0 to 1, where 0 is totally silent and 1 is full volume.
	volume = 1,

	-- Property: loops
	-- Whether the sound should loop.
	loops = false,

	-- watches our source to see if it's changed, or if one of our
	-- properties has fallen out of sync with the source
	set = {},

	-- Method: play
	-- Starts playing the source sound.
	--
	-- Arguments:
	--		* volume - volume from 0 to 1, default 1
	--		* force - force the source to restart if it's already playing?
	--				  default false
	-- Returns:
	--		nothing

	play = function (self, volume, force)
		assert(type(self.source) == 'string', 'source property must be a string, is ' .. type(self.source))

		-- if our source has changed, force all properties to be sync'd

		if self.set.source ~= self.source then
			self.set = { source = self.source }
			self.sourceObj = love.audio.newSource(self.source)
		end

		if volume then
			assert(type(volume) == 'number', 'sound volume must be a number')
			self.set.volume = volume
			self.volume = volume
			self.sourceObj:setVolume(volume)
		end

		if force then
			self.sourceObj:stop()
		end

		self.sourceObj:play()
	end,

	-- Method: pause
	-- Pauses the source sound.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	pause = function (self)
		-- if our source has changed, force all properties to be sync'd

		if self.set.source ~= self.source then
			self.set = { source = self.source }
			self.sourceObj = love.audio.newSource(self.source)
		end

		self.sourceObj:pause()
	end,

	-- Method: resume
	-- Resumes the source sound after being paused.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	resume = function (self)
		-- if our source has changed, force all properties to be sync'd

		if self.set.source ~= self.source then
			self.set = { source = self.source }
			self.sourceObj = love.audio.newSource(self.source)
		end

		self.sourceObj:resume()
	end,

	-- Method: isPlaying
	-- Checks whether the source sound is currently playing.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	isPlaying = function (self)
		return not (self.sourceObj:isStopped() or self.sourceObj:isPaused())
	end,

	update = function (self, elapsed)
		-- if our source has changed, force all properties to be sync'd

		if self.set.source ~= self.source then
			self.set = { source = self.source }
			self.sourceObj = love.audio.newSource(self.source)
		end

		-- sync all set properties with the source

		if self.set.volume ~= self.volume then
			self.sourceObj:setVolume(self.volume)
			self.set.volume = self.volume
		end

		if self.set.loops ~= self.loops then
			self.sourceObj:setLooping(self.loops)
			self.set.loops = self.loops
		end

		Sprite.update(self, elapsed)
	end
})
