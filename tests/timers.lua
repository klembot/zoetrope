require 'zoetrope'

Timers = TestApp:extend
{
	onRun = function (self)
		self.red = self:add(Fill:new{ x = 200, y = 250, width = 100, height = 100, fill = { 255, 0, 0 }, visible = false })
		self.green = self.add(Fill:new{ x = 350, y = 250, width = 100, height = 100, fill = { 0, 255, 0 }, visible = false })
		self.blue = self.add(Fill:new{ x = 500, y = 250, width = 100, height = 100, fill = { 0, 0, 255 }, visible = false })
		
		self.view.timer:after(1, bind(self, 'toggle', self.red))
			:andThen(bind(self.view.timer, 'after', 1, bind(self, 'toggle', self.blue)))
			:andThen(bind(self.view.timer, 'after', 1, bind(self, 'toggle', self.red)))
			:andThen(bind(self.view.timer, 'after', 1, bind(self, 'toggle', self.red)))

		self.view.timer:after(0, function() self.view:flash{255, 255, 255} end)
		self.view.timer:every(1, function() self:toggle(self.green) end)

		self:add(Text:new
		{
			x = 10, y = 550, width = 600, font = 14,
			text = 'Function calls can be delayed or repeated in game time, and linked in sequence. ' ..
				   'If you switch to another window, the green square won\'t blink until you bring the window to the top again.'
		})
	end,
	
	toggle = function (self, sprite)
		sprite.visible = not sprite.visible
	end
}
