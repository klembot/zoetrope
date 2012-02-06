-- Class: Map
-- A map saves memory and CPU time by acting as if it were a grid of sprites.
-- Each different type of sprite in the grid is represented via a single
-- object. Each sprite must have the same size, however.
-- 
-- This works very similarly to a tilemap, but there is additional flexibility
-- in using a sprite, e.g. animation and other display effects. (If you want it
-- to act like a tilemap, use its loadTiles method.) However, changing a sprite's
-- x or y position has no effect. Changing the scale will have weird effects as
-- a map expects every sprite to be the same size.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.globals'
require 'zoetrope.core.group'
require 'zoetrope.core.sprite'
require 'zoetrope.sprites.tile'

Map = Sprite:extend({
	-- Constant: NO_SPRITE
	-- Represents a map entry with no sprite.
	NO_SPRITE = -1,

	-- Property: sprites
	-- An ordered table of <Sprite> objects to be used in conjunction with the map property.
	sprites = {},

	-- Property: map
	-- A two-dimensional table of values, each corresponding to an entry in the sprites property.
	map = {},

	-- Method: empty
	-- Creates an empty map.
	--
	-- Arguments:
	--		width - width of the map in sprites
	--		height - height of the map in sprites
	-- 
	-- Returns:
	--		self, for chaining

	empty = function (self, width, height)
		local x, y
		
		-- empty the map

		for x = 1, width do
			self.map[x] = {}
			
			for y = 1, height do
				self.map[x][y] = Map.NO_SPRITE
			end
		end
		
		-- set bounds
		
		self.width = width * self.spriteWidth
		self.height = height * self.spriteHeight
		
		return self
	end,

	-- Method: loadMap
	-- Loads map data from a file, typically comma-separated values.
	-- Each entry corresponds to an index in self.sprites, and all rows
	-- must have the same number of columns.
	--
	-- Arguments:
	--		source - source text to use, probably comma-separated text
	--		colSeparator - character to use as separator of columns, default ','
	--		rowSeparator - character to use as separator of rows, default newline
	--
	-- Returns:
	--		self, for chaining

	loadMap = function (self, source, colSeparator, rowSeparator)
		colSeparator = colSeparator or ','
		rowSeparator = rowSeparator or '\n'
		
		-- load data
		
		local x, y
		local rows = split(source, rowSeparator)
		
		for y = 1, #rows do
			local cols = split(rows[y], colSeparator)
			
			for x = 1, #cols do
				if not self.map[x] then self.map[x] = {} end
				self.map[x][y] = tonumber(cols[x])
			end
		end
		
		-- set bounds
		
		self.width = #self.map[1] * self.spriteWidth
		self.height = #self.map * self.spriteHeight
		
		return self
	end,

	-- Method: loadTiles
	--- Loads the sprites group with slices of a source image.
	--  By default, this uses the Tile class for sprites, but you
	--  may pass as replacement class.
	--
	--  Arguments:
	--		image - source image to use for tiles
	--		class - class to create objects with; constructor
	--				  will be called with properties: image, width,
	--				  height, imageOffset (with x and y sub-properties)
	--		startIndex - starting index of tiles in self.sprites, default 0
	--
	--  Returns:
	--		self, for chaining

	loadTiles = function (self, image, class, startIndex)
		assert(self.spriteWidth and self.spriteHeight, 'sprite size must be set before loading tiles')
		if type(startIndex) ~= 'number' then startIndex = 0 end
		
		class = class or Tile
		self.sprites = {}
		
		local imageWidth = image:getWidth()
		local imageHeight = image:getHeight()
		 
		local i = startIndex
		
		for y = 0, imageHeight - self.spriteHeight, self.spriteHeight do
			for x = 0, imageWidth - self.spriteWidth, self.spriteWidth do
				self.sprites[i] = class:new({ image = image, width = self.spriteWidth,
											  height = self.spriteHeight,
											  imageOffset = { x = x, y = y }})
				i = i + 1
			end
		end
		
		return self
	end,

	-- Method: subdisplace
	-- This acts as a wrapper to multiple displace() calls, as if
	-- there really were all the sprites in their particular positions.
	-- This is much more useful than Map:displace(), which pushes a sprite
	-- so that it does not touch the map in its entirety. 
	--
	-- Arguments:
	--		other - other graphic, group, or table of sprites to displace
	--		xHint - force horizontal displacement in one direction, uses direction constants
	--		yHint - force vertical displacement in one direction, uses direction constants

	subdisplace = function (self, other, xHint, yHint)	
		local otherList = coerceToTable(other)
		local other

		for _, other in pairs(otherList) do
			if other.solid then
				local startX, startY = self:pixelToMap(other.x - self.x, other.y - self.y)
				local endX, endY = self:pixelToMap(other.x + other.width - self.x,
												   other.y + other.height - self.y)
				local x, y
				
				for x = startX, endX do
					for y = startY, endY do
						local spr = self.sprites[self.map[x][y]]
						
						if spr and spr.solid then
							-- position it as if it were onscreen
							
							spr.x = self.x + (x - 1) * self.spriteWidth
							spr.y = self.y + (y - 1) * self.spriteHeight
							spr:displace(other, xHint, yHint)
						end
					end
				end
			end
		end
	end,

	-- Method: collide
	-- This acts as a wrapper to multiple collide() calls, as if
	-- there really were all the sprites in their particular positions.
	-- This is much more useful than Map:collide(), which simply checks
	-- if a sprite is touching the map at all. 
	--
	-- Arguments:
	--		other - either other sprite, group, or table of sprites
	--
	-- Returns:
	--		boolean, whether any collision was detected

	subcollide = function (self, other)
		local otherList = coerceToTable(other)
		local hit = false
		
		for _, spr in pairs(otherList) do
			local startX, startY = self:pixelToMap(spr.x - self.x, spr.y - self.y)
			local endX, endY = self:pixelToMap(spr.x + spr.width - self.x,
											   spr.y + spr.height - self.y)
			local x, y
			
			for x = startX, endX do
				for y = startY, endY do
					local spr = self.sprites[self.map[x][y]]
					
					if spr and spr.solid then
						-- position it as if it were onscreen
						
						spr.x = self.x + (x - 1) * self.spriteWidth
						spr.y = self.y + (y - 1) * self.spriteHeight
						
						hit = spr:collide(other) or hit
					end
				end
			end
		end
		
		return hit
	end,

	-- Method: getMapSize
	-- Returns the size of the map in sprites.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		width and height in integers

	getMapSize = function (self)
		if #self.map == 0 then
			return 0, 0
		else
			return #self.map, #self.map[1]
		end
	end,

	draw = function (self, x, y)
		-- lock our x/y coordinates to integers
		-- to avoid gaps in the tiles
	
		x = math.floor(x or self.x)
		y = math.floor(y or self.y)
		if not self.visible then return end
		if not self.spriteWidth or not self.spriteHeight then return end
		
		-- determine drawing bounds
		-- we draw to fill the entire app windoow
		
		local startX, startY = self:pixelToMap(-x, -y)
		local endX, endY = self:pixelToMap(Current.app.width - x, Current.app.height - y)
		
		-- queue each sprite drawing operation
		
		local toDraw = {}
		
		for drawY = startY, endY do
			for drawX = startX, endX do
				local sprite = self.sprites[self.map[drawX][drawY]]
				
				if sprite and sprite.visible then
					if not toDraw[sprite] then
						toDraw[sprite] = {}
					end
					
					table.insert(toDraw[sprite], { x + (drawX - 1) * self.spriteWidth,
												   y + (drawY - 1) * self.spriteHeight })
				end
			end
		end
		
		-- draw each sprite in turn
		-- if a sprite has a quad, and image, we handle drawing right here;
		-- otherwise we punt to its draw method
		
		for sprite, list in pairs(toDraw) do
			local coords
				
			if sprite.quad and sprite.image then
				if sprite.color then
					love.graphics.setColor(sprite.color)
				else
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				if sprite.rotation == 0 and sprite.scale.x == 1
				   and sprite.scale.y == 1 then
					for _, coords in pairs(list) do
						love.graphics.drawq(sprite.image, sprite.quad,
											coords[1], coords[2])
					end
				else
					for _, coords in pairs(list) do
						love.graphics.drawq(sprite.image, sprite.quad, coords[1],
											coords[2], sprite.rotation,
											sprite.scale.x, sprite.scale.y,
											sprite.width / 2, sprite.height / 2)
					end
				end
				
				if sprite.color then
					love.graphics.setColor(255, 255, 255, 255)
				end
			else			
				for _, coords in pairs(list) do
					sprite:draw(coords[1], coords[2])
				end
			end
		end
		
		Sprite.draw(self)
	end,

	-- Method: pixelToMap
	-- Converts pixels to map coordinates.
	--
	-- Arguments:
	--		x - x coordinate in pixels
	--		y - y coordinate in pixels
	--		clamp - clamp to map bounds? defaults to true
	--
	-- Returns:
	--		x, y map coordinates

	pixelToMap = function (self, x, y, clamp)
		if type(clamp) == 'nil' then clamp = true end

		-- remember, Lua tables start at index 1

		local mapX = math.floor(x / self.spriteWidth) + 1
		local mapY = math.floor(y / self.spriteHeight) + 1
		
		-- clamp to map bounds
		
		if clamp then
			if mapX < 1 then mapX = 1 end
			if mapY < 1 then mapY = 1 end
			if mapX > #self.map then mapX = #self.map end
			if mapY > #self.map[1] then mapY = #self.map[1] end
		end

		return mapX, mapY
	end,

	-- makes sure all sprites receive startFrame messages

	startFrame = function (self, elapsed)
		for _, spr in pairs(self.sprites) do
			spr:startFrame(elapsed)
		end

		Sprite.startFrame(self, elapsed)
	end,

	-- makes sure all sprites receive update messages

	update = function (self, elapsed)
		for _, spr in pairs(self.sprites) do
			spr:update(elapsed)
		end

		Sprite.update(self, elapsed)
	end,

	-- makes sure all sprites receive endFrame messages

	endFrame = function (self, elapsed)
		for _, spr in pairs(self.sprites) do
			spr:endFrame(elapsed)
		end

		Sprite.endFrame(self, elapsed)
	end
})
