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

require 'zoetrope.core.sprite'

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
		assert(self.source, "can't play a sound without a source set")

		if volume then
			self.set.volume = volume
			self.volume = volume
			self.source:setVolume(volume)
		end

		if force then
			self.source:stop()
		end

		self.source:play()
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
		self.source:pause()
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
		self.source.resume()
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
		return not (self.source:isStopped() or self.source:isPaused())
	end,

	update = function (self, elapsed)
		-- if our source has changed, force all properties to be sync'd

		if self.set.source ~= self.source then
			self.set = { source = self.source }
		end

		-- sync all set properties with the source

		if self.set.volume ~= self.volume then
			self.source:setVolume(self.volume)
			self.set.volume = self.volume
		end

		if self.set.loops ~= self.loops then
			self.source:setLooping(self.loops)
			self.set.loops = self.loops
		end

		Sprite.update(self, elapsed)
	end
})
