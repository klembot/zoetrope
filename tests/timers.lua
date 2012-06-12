require 'zoetrope'

Timers = App:extend({
	onRun = function (self)
		self.red = Fill:new({ x = 16, y = 16, width = 64, height = 64, fill = { 255, 0, 0 }, visible = false })
		self:add(self.red)
		
		self.green = Fill:new({ x = 108, y = 16, width = 64, height = 64, fill = { 0, 255, 0 }, visible = false })
		self:add(self.green)
		
		self.blue = Fill:new({ x = 200, y = 16, width = 64, height = 64, fill = { 0, 0, 255 }, visible = false })
		self:add(self.blue)
		
		self.view.timer:start({ delay = 0.5, func = self.toggle, arg = { self.red } })
		self.view.timer:start({ delay = 1, func = self.toggle, arg = { self.green }, repeats = true })
		self.view.timer:start({ delay = 1.5, func = self.toggle, arg = { self.blue } })
		self.view.timer:start({ delay = 0, func = self.view.flash, bind = self.view, arg = { {255, 255, 255} } })
	end,
	
	toggle = function (sprite)
		sprite.visible = not sprite.visible
	end
})
