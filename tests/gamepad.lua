GamepadApp = App:extend
{
	numGamepads = 1,
	colors = { {0, 255, 0}, {255, 0, 0}, {0, 0, 255}, {255, 255, 0} },
	analog = false,

	onRun = function (self)
		local gp = the.gamepads[1]

		self.gamepadLabel = Text:new{ x = 4, y = 4, width = 800, height = 200 }
		self.gamepadLabel.text = 'Name: ' .. gp.name .. '\n' ..
								 gp.numAxes .. ' axes, ' .. gp.numBalls .. ' balls, ' ..
								 gp.numButtons .. ' buttons, ' .. gp.numHats .. ' hats\n' ..
								 'Press the M key to toggle between analog and digital movement.'
		
		self:add(self.gamepadLabel)

		self.controlLabel = Text:new{ x = 4, y = 200, width = 400, height = 400 }
		self:add(self.controlLabel)


		self.square = Fill:new{ x = 300, y = 300, width = 50, height = 50, fill = {255, 255, 255} }
		self:add(self.square)
	end,

	onUpdate = function (self, elapsed)
		local gp = the.gamepads[1] 

		if the.keys:justPressed('m') then self.analog = not self.analog end

		self.square.velocity.x = 0
		self.square.velocity.y = 0

		if self.analog then
			self.square.velocity.x = gp.axes[1] * 200
			self.square.velocity.y = gp.axes[2] * 200
		else
			if gp:pressed('up') then
				self.square.velocity.y = -200
			elseif gp:pressed('down') then
				self.square.velocity.y = 200
			end

			if gp:pressed('left') then
				self.square.velocity.x = -200
			elseif gp:pressed('right') then
				self.square.velocity.x = 200
			end
		end
		
		for i = 1, #self.colors do
			if gp:pressed(i) then self.square.fill = self.colors[i] end
		end
	end
}
