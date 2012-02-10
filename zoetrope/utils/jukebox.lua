-- Class: Jukebox
-- This helps manage playing one-off sounds. It's great if you don't
-- need to do anything to a sound except play it.

Jukebox = Sprite:extend({
	visible = false,
	solid = false,
	
	sounds = {},

	-- Method: play
	-- Plays a sound.
	--
	-- Arguments:
	--		* source - either a <Sound> object or string path. If you use a
	--		  string path, then repeated play() calls will cause simultaneous
	--		  sounds to play. If you pass a <Sound> object directly, it will
	--		  cause the sound to restart.
	--		* volume - volume, from 0 to 1
	--
	-- Returns:
	--		<Sound> object that just began playing

	play = function (self, source, volume)
		assert(source, "asked to play a nil source sound")
		local sourceObj

		if type(source) == 'string' then
			sourceObj = love.audio.newSource(source)
		else
			sourceObj = source
		end

		volume = volume or 1
		local sound
		
		for i, value in ipairs(self.sounds) do
			if not value:isPlaying() then
				sound = value
				sound.source = sourceObj
			end
		end

		if not sound then
			sound = Sound:new({ source = sourceObj })
			table.insert(self.sounds, sound)
		end
	
		sound:play(volume)
		return sound
	end,

	beginFrame = function (self, elapsed)
		for _, spr in pairs(self.sounds) do
			if spr.active and spr.beginFrame then
				spr:beginFrame(elapsed)
			end
		end

		Sprite.beginFrame(self, elapsed)
	end,

	update = function (self, elapsed)
		for i, spr in ipairs(self.sounds) do
			if spr.active and spr.update then
				spr:update(elapsed)
			end

			if not spr:isPlaying() then
				table.remove(self.sounds, i)
			end
		end

		Sprite.update(self, elapsed)
	end,
	
	endFrame = function (self, elapsed)
		for _, spr in pairs(self.sounds) do
			if spr.active and spr.endFrame then
				spr:endFrame(elapsed)
			end
		end

		Sprite.endFrame(self, elapsed)
	end,
})
