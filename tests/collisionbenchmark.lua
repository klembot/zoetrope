require 'zoetrope'

CollisionBenchmark = App:extend
{
	name = 'Collision Benchmark',
	minFPS = 55,
	count = 0,

	onNew = function (self)
		DEBUG = false
		STRICT = false

		self.blocks = Group:new()
		self:add(self.blocks)
		self.countText = Text:new{ x = 10, y = 440, font = 144, width = 200 }
		self:add(self.countText)
		self:add(Fill:new{ x = 0, y = 580, width = 800, height = 20, fill = {0, 0, 0, 200} })
		self:add(Text:new{ x = 10, y = 582, font = 14, width = 600,
				 text = 'sprites onscreen while maintaining roughly 60 frames per second.' })
	end,

	onUpdate = function (self, elapsed)
		self.blocks:collide(self.blocks)

		self.currentFPS = math.floor(1 / elapsed)
	
		if self.currentFPS >= self.minFPS then
			self.blocks:add(Fill:new{ x = math.random(0, 800), y = math.random(0, 600),
									  width = 16, height = 16, fill = {0, 0, 255, 64} })
			self.count = self.count + 1
			self.countText.text = self.count
		end
	end
}
