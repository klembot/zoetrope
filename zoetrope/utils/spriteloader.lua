-- Class: SpriteLoader
-- This facilitates creating sprite at predetermined positions based on text files.
-- This has two components: a library table, which maps string IDs to sprite data,
-- and a loadSprite() function, which you need to define yourself to do the actual
-- work of loading the sprites into play.
--
-- Event: onLoadSprite
-- Called repeatedly as a load occurs. This function is passed the target to
-- load into, usually a <View>, then the text fields as separate arguments.
--
-- Extends:
--		<Class>

SpriteLoader = Class:extend({
	-- Property: lineSeparator
	-- The character the loader should understand as separating lines.
	-- Defaults to a newline.
	lineSeparator = '\n',

	-- Property: fieldSeparator
	-- The character the loader should understand as separating
	-- fields in a line. Defaults to a comma.
	fieldSeparator = ',',

	-- Property: library
	-- Used to associate data files with IDs.
	library = {},

	-- Method: addFileToLibrary
	-- Adds the content of a file to the library. If data is already
	-- associated with the id passed, then it is silently overwritten.
	--
	-- Arguments:
	--		filename - filename to data
	--		id - id to store it under
	--
	-- Returns:
	--		nothing

	addFileToLibrary = function (self, filename, id)
		self.library[id] = love.filesystem.read(filename)
	end,

	-- Method: load
	-- Loads data by library id and calls self:onLoadSprite() for each line.
	--
	-- Arguments:
	-- 		id - id to load
	--		target - target to load sprites into, often a <View>
	--
	-- Returns:
	--		nothing

	load = function (self, id, target)
		assert(type(self.library[id]) == 'string', 'no library entry with id ' .. tostring(id))
		assert(type(self.onLoadSprite) == 'function', 'you must define a onLoadSprite() function')

		local lines = split(self.library[id], self.lineSeparator)
		local i

		for i = 1, #lines do
			if lines[i] ~= '' then
				self:onLoadSprite(target, unpack(split(lines[i], self.fieldSeparator)))
			end
		end
	end
})
