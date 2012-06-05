require 'zoetrope'

Player = Fill:extend({
	width = 16, height = 16, fill = { 0, 0, 255 },

	onUpdate = function (self)
		self.velocity.x = 0
		self.velocity.y = 0
		
		if the.keys:pressed(UP) then self.velocity.y = -200 end
		if the.keys:pressed(DOWN) then self.velocity.y = 200 end
		if the.keys:pressed(LEFT) then self.velocity.x = -200 end
		if the.keys:pressed(RIGHT) then self.velocity.x = 200 end
	end
})

Loading = App:extend({
	onRun = function (self)
		self.view:loadFromLua('tests/assets/map.lua')
		self.view.map.sprites[1].solid = false
		self.view.map.sprites[2].solid = false
		self.view:clampTo(self.view.map)
		self.view.focus = the.player
	end,

	onUpdate = function (self)
		self.view.map:subdisplace(the.player)
	end
})
