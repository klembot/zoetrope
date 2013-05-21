require 'zoetrope'

Sensor = Fill:extend
{
	alpha = 0,

	onUpdate = function (self, elapsed)
		if self.alpha > 0 then
			self.alpha = math.max(self.alpha - elapsed * 4, 0) 
		end
	end
}

Input = TestApp:extend
{
	onNew = function (self)
		self.released = self:add(Sensor:new{ width = 200, height = 400, fill = { 255, 0, 0 } })
		self.justPressed = self:add(Sensor:new{ x = 200, width = 200, height = 400, fill = { 0, 255, 0 } })
		self.pressed = self:add(Sensor:new{ x = 400, width = 200, height = 400, fill = { 0, 0, 255 } })
		self.justReleased = self:add(Sensor:new{ x = 600, width = 200, height = 400, fill = { 255, 255, 0 } })
		self.leftMouse = self:add(Sensor:new{ y = 400, width = 400, height = 200, fill = { 0, 255, 255 } })
		self.rightMouse = self:add(Sensor:new{ x = 400, y = 400, width = 400, height = 200, fill = { 255, 0, 255 } })

		self.extraLabel = self:add(Text:new
		{
			x = 10, y = 10, width = 200
		})

		self:add(Text:new
		{
			x = 10, y = 540, width = 650, font = 14,
			text = 'The bars above indicate the state of the space bar. Red means it\'s released, ' ..
				   'green means it was just pressed, blue means it is currently pressed, and yellow ' ..
				   'means that it has just been released. Click the left and right mouse buttons to ' ..
				   'see the other two indicators light up.'
		})
	end,

	onUpdate = function (self)
		if the.keys:released(' ') then self.released.alpha = 1 end
		if the.keys:justPressed(' ') then self.justPressed.alpha = 1 end
		if the.keys:pressed(' ') then self.pressed.alpha = 1 end
		if the.keys:justReleased(' ') then self.justReleased.alpha = 1 end
		if the.mouse:pressed('l') then self.leftMouse.alpha = 1 end
		if the.mouse:pressed('r') then self.rightMouse.alpha = 1 end 

		local keys = { the.keys:allPressed() }
		self.extraLabel.text = 'Mouse position: ' .. the.mouse.x .. ', ' .. the.mouse.y .. '\n' ..
							   #keys .. ' keys pressed simultaneously'
	end
}
