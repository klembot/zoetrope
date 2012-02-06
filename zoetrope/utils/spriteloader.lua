--- This facilitates creating sprite at predetermined positions based on text files.
--  This has two components: a library table, which maps string IDs to sprite data,
--  and a loadSprite() function, which you need to define yourself to do the actual
--  work of loading the sprites into play.

require 'zoetrope.core.class'
require 'zoetrope.core.globals'

SpriteLoader = Class:extend({
	lineSeparator = '\n',
	fieldSeparator = ',',
	library = {},

	--- Adds the content of a file to the library. If data is already
	--  associated with the id passed, then it is silently overwritten.
	--  @param	filename	filename to data
	--  @param	id			id to store it under

	addFileToLibrary = function (self, filename, id)
		self.library[id] = love.filesystem.read(filename)
	end,

	--- Loads data by library id and calls self:loadSprite() for each line.
	--  @param	id		id to load
	--  @param	view	view to load sprites into

	load = function (self, id, view)
		assert(type(self.library[id]) == 'string', 'no library entry with id ' .. tostring(id))
		assert(type(self.onLoadSprite) == 'function', 'you must define a onLoadSprite() function')

		local lines = split(self.library[id], self.lineSeparator)
		local i

		for i = 1, #lines do
			if lines[i] ~= '' then
				self:onLoadSprite(view, unpack(split(lines[i], self.fieldSeparator)))
			end
		end
	end
})
