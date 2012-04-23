-- Class: Cached
-- This helps you re-use assets in your app instead of creating extraneous
-- copies of them. It also hides Love-related calls so that your code is
-- more portable.
--
-- If you're using a built-in sprite class, you do not need to use
-- this class directly. They take care of setting things up for you
-- appropriately. However, if you're rolling your own, you'll want to use
-- this to save memory.
--
-- This class is not meant to be created directly. Instead, call
-- methods on Cached directly, e.g. Cached:sound, Cached:image, and so on.
--
-- Extends:
--		<Class>

Cached = Class:extend({
	-- Property: defaultGlyphs
	-- The default character order of a bitmap font, if none is specified
	-- in a <font> call.
	defaultGlyphs = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`' ..
					'abcdefghijklmnopqrstuvwxyz{|}~',

	-- private property: library
	-- a table to store already-instantiated assets
	library = { image = {}, text = {}, sound = {}, font = {} },

	-- Method: image
	-- Returns a cached image asset.
	--
	-- Arguments:
	--		key - pathname to image file
	--
	-- Returns:
	--		Love image object

	image = function (self, key)
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
	--
	-- Returns:
	--		string

	text = function (self, key)
		if not self.library.text[key] then
			self.library.text[key] = love.filesystem.read(key)
		end

		return self.library.text[key]
	end,

	-- Method: sound
	-- Returns a cached sound asset. Be careful using this method.
	-- A single sound can only be played one at a time.
	--
	-- Arguments:
	--		key - pathname to sound file
	--
	-- Returns:
	--		Love sound object
	--
	-- See Also:
	--		<playSound>

	sound = function (self, key)
		if not self.library.sound[key] then
			self.library.sound[key] = love.audio.newSource(key, 'static')
		end

		return self.library.sound[key]
	end,

	-- Method: font
	-- Returns a cached font asset.
	--
	-- Arguments:
	-- Can be:
	--		* A single number. This uses Love's default outline font at that point size.
	--		* A single string. This uses a bitmap font given by this pathname, and assumes that
	--		  the characters come in
	--		  <printable ASCII order at https://en.wikipedia.org/wiki/ASCII#ASCII_printable_characters>.
	--		* A string, then a number. This uses an outline font whose pathname is the first argument,
	--		  at the point size given in the second argument.
	--		* Two strings. The first is treated as a pathname to a bitmap font, the second
	--		  as the character order in the font.
	--
	-- Returns:
	--		Love font object

	font = function (self, ...)
		local arg = {...}
		local libKey = arg[1]

		if #arg > 1 then libKey = libKey .. arg[2] end

		if not self.library.font[libKey] then
			local font, image

			if #arg == 1 then
				if type(arg[1]) == 'number' then
					font = love.graphics.newFont(arg[1])
				elseif type(arg[1]) == 'string' then
					image = Cached:image(arg[1])
					font = love.graphics.newImageFont(image, self.defaultGlyphs)
				else
					error("don't understand single argument: " .. arg[1])
				end
			elseif #arg == 2 then
				if type(arg[2]) == 'number' then
					font = love.graphics.newFont(arg[1], arg[2])
				elseif type(arg[2]) == 'string' then
					image = Cached:image(arg[1])
					font = love.graphics.newImageFont(image, arg[2])
				else
					error("don't understand arguments: " .. arg[1] .. ", " .. arg[2])
				end
			else
				error("too many arguments; should be at most two")
			end

			self.library.font[libKey] = font
		end

		return self.library.font[libKey]
	end
})
