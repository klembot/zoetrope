-- Class: Tile
-- A tile repeats a single image across its dimensions. If you do
-- not specify a width and height, the sprite will size itself so
-- that it's exactly as big as its source image.
--
-- Extends:
--		<Sprite>

Tile = Sprite:extend
{
	-- Property: image
	-- The image to tile across the sprite.

	-- Property: imageOffset
	-- Setting this moves the top-left corner of the tile inside
	-- the sprite's rectangle. To draw as normal, set both x and y
	-- to 0.
	imageOffset = { x = 0, y = 0 },

	-- private property: keeps track of properties that need action
	-- to be taken when they are changed
	-- image must be a nonsense value, not nil,
	-- for the tile to see that an image has been set if it
	-- was initially nil
	_set = { image = -1 },

	-- private property imageObj: actual Image instance used to draw
	-- this is normally set via the image property, but you may set it directly
	-- so long as you never change that image property afterwards.

	new = function (self, obj)
		obj = obj or {}
		self:extend(obj)
		
		if obj.image then obj:updateQuad() end
		if obj.onNew then obj:onNew() end
		return obj
	end,

	updateQuad = function (self)
		if self.image then
			self._imageObj = Cached:image(self.image)
			if not self.width then self.width = self._imageObj:getWidth() end
			if not self.height then self.height = self._imageObj:getHeight() end

			self.quad = love.graphics.newQuad(self.imageOffset.x, self.imageOffset.y,
											  self.width, self.height,
											  self._imageObj:getWidth(), self._imageObj:getHeight())
			self._imageObj:setWrap('repeat', 'repeat')
			self._set.image = self.image
		end
	end,

	draw = function (self, x, y)
		if not self.visible then return end

		x = math.floor(x or self.x)
		y = math.floor(y or self.y)
	
		if STRICT then
			assert(type(x) == 'number', 'visible fill does not have a numeric x property')
			assert(type(y) == 'number', 'visible fill does not have a numeric y property')
			assert(type(self.width) == 'number', 'visible fill does not have a numeric width property')
			assert(type(self.height) == 'number', 'visible fill does not have a numeric height property')
		end

		if not self.image then return end
		
		-- set color if needed

		local colored = self.alpha ~= 1 or self.tint[1] ~= 1 or self.tint[2] ~= 1 or self.tint[3] ~= 1

		if colored then
			love.graphics.setColor(self.tint[1] * 255, self.tint[2] * 255, self.tint[3] * 255, self.alpha * 255)
		end

		-- if the source image has changed,
		-- we need to recreate our quad
		
		if self.image and self.image ~= self._set.image then self:updateQuad() end
		
		-- draw the quad

		love.graphics.drawq(self._imageObj, self.quad, x + self.width / 2, y + self.height / 2, self.rotation,
							self.scale * self.distort.x, self.scale * self.distort.y,
							self.width / 2, self.height / 2)
		
		-- reset color
		
		if colored then
			love.graphics.setColor(255, 255, 255, 255)
		end
			
		Sprite.draw(self, x, y)
	end
}
