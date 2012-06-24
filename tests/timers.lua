require 'zoetrope'

Timers = TestApp:extend
{
	onRun = function (self)
		self.red = Fill:new{ x = 200, y = 250, width = 100, height = 100, fill = { 255, 0, 0 }, visible = false }
		self:add(self.red)
		
		self.green = Fill:new{ x = 350, y = 250, width = 100, height = 100, fill = { 0, 255, 0 }, visible = false }
		self:add(self.green)
		
		self.blue = Fill:new{ x = 500, y = 250, width = 100, height = 100, fill = { 0, 0, 255 }, visible = false }
		self:add(self.blue)
		
		self.view.timer:start{ delay = 0.5, func = self.toggle, arg = { self.red } }
		self.view.timer:start{ delay = 1, func = self.toggle, arg = { self.green }, repeats = true }
		self.view.timer:start{ delay = 1.5, func = self.toggle, arg = { self.blue } }
		self.view.timer:start{ delay = 0, func = self.view.flash, bind = self.view, arg = { {255, 255, 255} } }

		self:add(Text:new
		{
			x = 10, y = 550, width = 600, font = 14,
			text = 'Function calls can be delayed or repeated in game time. If you switch to another ' ..
				   'window, the green square won\'t blink until you bring the window to the top again.'
		})
	end,
	
	toggle = function (sprite)
		sprite.visible = not sprite.visible
	end
}
