require 'zoetrope'

Collisions = App:extend({
	onRun = function (self)
		self.player = Fill:new({ x = 16, y = 16, width = 16, height = 16 })
		
		self.player.onCollide = function (self, other, vertOverlap, horizOverlap)
			if vertOverlap > 8 and horizOverlap > 8 then
				self.fill = { 255, 255, 0 }
			end
		end
		
		self.obstacle = Fill:new({ x = 200, y = 200, width = 96, height = 96,
								   fill = {255, 0, 0} })
								   
		self.pushable = Fill:new({ x = 100, y = 100, width = 48, height = 48,
								   fill = {0, 0, 255} })
							
		self.collidable = Fill:new({ x = 20, y = 20, width = 32, height = 32,
									 fill = {0, 255, 0} })
		
		self:add(self.collidable)		
		self:add(self.obstacle)
		self:add(self.pushable)
		self:add(self.player)
	end,
	
	onUpdate = function (self, elapsed)
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
		
		self.player:collide(self.collidable)
		self.obstacle:displace(self.player)
		self.obstacle:displace(self.pushable)
		self.player:displace(self.pushable)
	end
})