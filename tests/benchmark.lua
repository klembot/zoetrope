require 'zoetrope'

Block = Tile:extend
{
	width = 16,
	height = 16,

	blueGem = 'tests/assets/bluegem.png',
	greenGem = 'tests/assets/greengem.png',

	onNew = function (self)
		if (math.random() > 0.5) then
			self.image = self.blueGem
		else
			self.image = self.greenGem
		end
	
		self.velocity.x = math.random(-100, 100)
		self.velocity.rotation = math.random(math.pi / 2, 4 * math.pi)
		self.acceleration.y = math.random(500, 1000)
		self.rotation = math.random(0, math.pi * 4)
		self.scale = math.random(0.25, 2)
		self.alpha = math.random()
	end,
	
	onUpdate = function (self)
		if self.y > the.app.height and self.velocity.y > 0 then
			self.velocity.y = self.velocity.y * -1
		end
		
		if (self.x < 0 and self.velocity.x < 0) or
		   (self.x > the.app.width and self.velocity.x > 0) then
		   self.velocity.x = self.velocity.x * -1
		end
	end
}

-- The app adds a block every frame so long as
-- the FPS doesn't drop below a certain number

Benchmark = App:extend
{
	name = 'Sprite Benchmark',
	count = 0,
	fps = 999,
	minFPS = 55,
	currentFPS = 0,
	
	onRun = function (self)
		print('This benchmarks how many sprites can be displayed onscreen ' ..
			  'without significant loss of FPS.')	
	end,
	
	onUpdate = function (self, elapsed)
		self.currentFPS = math.floor(1 / elapsed)
	
		if self.currentFPS >= self.minFPS then
			self:add(Block:new{ x = math.random(0, 800), y = math.random(0, 600) })
			self.count = self.count + 1
		end

		if the.keys:justPressed('f') then
			self:toggleFullscreen()
		end
	end,
	
	onDraw = function (self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(self.currentFPS .. ' fps', 0, 0)
		love.graphics.print(self.count .. ' sprites', 0, 16)
	end
}
