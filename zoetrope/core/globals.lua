-- Section: Globals

-- Variable: the
-- This is a repository table for the current app, view, keys, and mouse.
-- You can use this for other objects that are useful to track. This should
-- be considered read-only; references here are for convenience and changing
-- things here will have no effect.
the = {}

-- Constant: NEARLY_ZERO
-- Any number less than this is considered 0 by Zoetrope.
NEARLY_ZERO = 0.0001

-- Constant: UP
-- Directional constant corresponding to up.
UP = 'up'

-- Constant: DOWN
-- Directional constant corresponding to down.
DOWN = 'down'

-- Constant: LEFT
-- Directional constant corresponding to left.
LEFT = 'left'

-- Constant: RIGHT
-- Directional constant corresponding to right.
RIGHT = 'right'


-- Function: trim
-- trim() implementation for strings via http://lua-users.org/wiki/stringtrim
-- 
-- Arguments:
-- 		source - source string
--
-- Returns:
-- 		string trimmed of leading and trailing whitespace

function trim (source)
	return source:gsub("^%s*(.-)%s*$", "%1")
end

-- Function: split
-- split() implementation for strings via http://lua-users.org/wiki/splitjoin
--
-- Arguments:
--		source - source string
--		pattern - Lua pattern to split on, see http://www.lua.org/pil/20.1.html
--
-- Returns:
-- 		table of split strings	

function split (source, pattern)
	assert(type(source) == 'string', 'source must be a string')
	assert(type(pattern) == 'string', 'pattern must be a string')
	
	local result = {}
	local searchStart = 1
	local splitStart, splitEnd = string.find(source, pattern, searchStart)
	
	while splitStart do
		table.insert(result, string.sub(source, searchStart, splitStart - 1))
		searchStart = splitEnd + 1
		splitStart, splitEnd = string.find(source, pattern, searchStart)
	end
	
	table.insert(result, string.sub(source, searchStart))
	return result
end

-- Function: playSound
-- Plays a sound once. This is the easiest way to play a sound. It's important
-- to use the hint property appropriately; if set incorrectly, it can cause sound
-- playback to stutter or lag.
--
-- Arguments:
--		path - string pathname to sound
--		volume - volume to play at, from 0 to 1; default 1
--		hint - either 'short' or 'long', depending on length of sound; default 'short'

function playSound (path, volume, hint)
	volume = volume or 1
	local sourceType = 'static'
	if hint == 'long' then sourceType = 'stream' end

	local source = love.audio.newSource(path, sourceType)
	source:setVolume(volume)
	source:play()
	return source
end

-- Function: coerceToTable
-- Coerces any type of object possible to a table of sprites.
-- If a single sprite is passed, it is boxed into a new table.
-- If a group is passed, its sprites property is returned.
-- A table of sprites is left as-is.
--
-- Arguments:
--		other - sprite, group, or table of sprites
--
-- Returns:
--		table of sprites equivalent to passed argument

function coerceToTable (other)
	assert(other, "can't coerce a nil value to a table")

	if type(other.sprites) == 'table' then
		return other.sprites
	elseif #other > 1 then
		return other
	else
		return { other }
	end
end

-- Function: searchTable
-- Returns the index of a value in a table. If the value
-- does not exist in the table, this returns nil.
--
-- Arguments:
--		table - table to search
--		search - value to search for
--
-- Returns:
--		integer index or nil

function searchTable (table, search)
	for i, value in ipairs(table) do
		if value == search then return i end
	end

	return nil
end

-- Function: copyTable
-- Returns a superficial copy of a table. If it contains a 
-- reference to another table in one of its properties, that
-- reference will be copied shallowly. 
--
-- Arguments:
-- 		source - source table
--
-- Returns:
-- 		new table

function copyTable (source)
	assert(type(source) == 'table', "asked to copy a non-table")

	local result = {}
	setmetatable(result, getmetatable(source))
	
	for key, value in pairs(source) do
		result[key] = value
	end
	
	return result
end

-- Function: dumpTable
-- Returns a string representation of an entire table's contents.
--
-- Arguments:
--		source - table to describe
--		recurse - recurse into subtables? defaults to true
--		hideFuns - don't print functions? defaults to false
--		indent - how many spaces to place in front of each line
--
-- Returns:
--		string description

function dumpTable (source, recurse, hideFuncs, indent)
	if not source then
		return 'nil'
	end

	assert(type(source) == 'table',
		   "source argument to dumpTable() must be a table")

	-- defaults
	
	if type(recurse) == 'nil' then recurse = true end
	indent = indent or 0
	local prefix = string.rep(' ', indent)
	local result = ''
	
	for key, value in pairs(source) do
		local valueType = type(value)
		
		if not hideFuncs or valueType ~= 'function' then
			local line = prefix .. key .. ' (' .. valueType .. ')'
			
			if valueType == 'string' or valueType == 'number'
			   or valueType == 'boolean' then
				line = line .. ': ' .. tostring(value)
			end
			
			if valueType == 'table' and recurse then
				line = line .. ': \n' .. dumpTable(value, true, hideFuncs,
												   indent + 2)
			end
		
			result = result .. line .. '\n'
		end
	end
	
	return result
end
