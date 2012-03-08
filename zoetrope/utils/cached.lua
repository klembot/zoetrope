-- Class: Cached
-- This helps you re-use assets in your app instead of
-- creating extraneous copies of them. It also hides Love-related
-- calls so that your code is more portable.
--
-- This class is not meant to be created directly. Instead, call
-- methods on Cached directly, e.g. Cached:sound, Cached:image, and so on.
--
-- Extends:
--		<Class>

Cached = Class:extend({
	-- a table to store already-instantiated assets
	library = { image = {}, text = {}, sound = {} },

	-- Method: image
	-- Returns a cached image asset.
	--
	-- Arguments:
	--		key - pathname to image file or alias previously set
	--		alias - alias to remember a path by
	--
	-- Returns:
	--		Image asset ready for use

	image = function (self, key, alias)
		if not self.library.image[key] then
			self.library.image[key] = love.graphics.newImage(key)
		end

		if alias then
			self.library.image[alias] = self.library.image[key]
		end

		return self.library.image[key]
	end,

	-- Method: text
	-- Returns a cached text asset.
	--
	-- Arguments:
	--		key - pathname to text file or alias previously set
	--		alias - alias to remember a path by
	--
	-- Returns:
	--		string

	text = function (self, key, alias)
		if not self.library.text[key] then
			self.library.text[key] = love.filesystem.read(key)
		end

		if alias then
			self.library.text[alias] = self.library.text[key]
		end

		return self.library.text[key]
	end,

	-- Method: sound
	-- Returns a cached sound asset. Be careful using this method.
	-- A single sound can only be played one at a time, so if you need to
	-- be able to play the same sound simultaneously, you'll need
	-- to set up separate entries for it via the alias property.
	--
	-- Really, you are probably better served by using the <Jukebox>
	-- class to manage your sounds for you if you are worried about
	-- multiple simultaneous sounds.
	--
	-- Arguments:
	--		key - pathname to text file or alias previously set
	--		alias - alias to remember a path by
	--
	-- Returns:
	--		string

	sound = function (self, key, alias)
		if not self.library.sound[key] then
			self.library.sound[key] = love.audio.newSource(key, 'static')
		end

		if alias then
			self.library.sound[alias] = self.library.sound[key]
		end

		return self.library.sound[key]
	end
})
