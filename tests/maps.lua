require 'zoetrope'

Maps = App:extend({
	onRun = function (self)	
		-- programmatically created map
	
		local map = Map:new({ spriteWidth = 16, spriteHeight = 16 })
		map:empty(16, 16)
		
		local x, y
		
		for x = 1, 16 do
			for y = 1, 16 do
				map.map[x][y] = math.random(1, 4)
			end
		end
		
		local mario = Cached:image('tests/assets/mario.png')
		
		map.sprites[1] = Fill:new({ width = 16, height = 16, fill = {255, 0, 0} })
		map.sprites[2] = Fill:new({ width = 16, height = 16, fill = {0, 255, 0} })
		map.sprites[3] = Fill:new({ width = 16, height = 16, fill = {0, 0, 255} })
		map.sprites[4] = Tile:new({ width = 16, height = 16, image = mario })
		self:add(map)
		
		-- map loaded from CSV
		
		self.map2 = Map:new({ x = 300, y = 100, spriteWidth = 24, spriteHeight = 24 })
		self.map2:loadMap(Cached:text('tests/assets/map.csv'))
		self.map2.sprites[1] = Fill:new({ width = 24, height = 24, fill = {0, 0, 255} })
		self:add(self.map2)
		
		-- map with loadTiles() used
		
		local map3 = Map:new({ x = 0, y = 300, spriteWidth = 16, spriteHeight = 16 })
		map3:loadTiles(Cached:image('tests/assets/tiles.png'))
		map3:empty(16, 16)
		
		for x = 1, 16 do
			for y = 1, 16 do
				map3.map[x][y] = math.random(1, 2)
			end
		end
		
		self:add(map3)
		
		-- player for testing collisions
		
		self.player = Fill:new({ x = 300, y = 50, width = 16, height = 16 })
		self:add(self.player)
		Current.watch:addWatch('player x', 'Current.app.player.x')
		Current.watch:addWatch('player y', 'Current.app.player.y')
	end,
	
	onUpdate = function (self, elapsed)
		if (self.map2:subcollide(self.player)) then
			print('collided')
			self.map2:subdisplace(self.player)
		end
	
		self.player.velocity.x = 0
		self.player.velocity.y = 0
		self.player.fill = { 255, 255, 255 }
		
		if self.keys:pressed('left') then
			self.player.velocity.x = -150
		end
		
		if self.keys:pressed('right') then
			self.player.velocity.x = 150
		end
		
		if self.keys:pressed('up') then
			self.player.velocity.y = -150
		end
		
		if self.keys:pressed('down') then
			self.player.velocity.y = 150
		end
	end
})
