require 'zoetrope'

Input = App:extend({
	onNew = function (self)
		self.released = Fill:new({ width = 200, height = 400, fill = { 255, 0, 0 } })
		self:add(self.released)
		
		self.justPressed = Fill:new({ x = 200, width = 200, height = 400, fill = { 0, 255, 0 } })
		self:add(self.justPressed)
		
		self.pressed = Fill:new({ x = 400, width = 200, height = 400, fill = { 0, 0, 255 } })
		self:add(self.pressed)
		
		self.justReleased = Fill:new({ x = 600, width = 200, height = 400, fill = { 255, 255, 0 } })
		self:add(self.justReleased)
		
		self.leftMouse = Fill:new({ y = 400, width = 400, height = 200 })
		self:add(self.leftMouse)
		
		self.rightMouse = Fill:new({ x = 400, y = 400, width = 400, height = 200 })
		self:add(self.rightMouse)
	end,

	onRun = function (self)
		print('This tests input via mouse and keyboard, and someday ' ..
			  'might handle joysticks.')
	end,
	
	onUpdate = function (self)
		self.released.visible = self.keys:released(' ')
		self.justPressed.visible = self.keys:justPressed(' ')
		self.pressed.visible = self.keys:pressed(' ')
		self.justReleased.visible = self.keys:justReleased(' ')
		self.leftMouse.visible = self.mouse:pressed('l')
		self.rightMouse.visible = self.mouse:pressed('r')

		if the.keys.frameString ~= '' then
			print('Keyboard entry |' .. the.keys.frameString .. '|')
		end
	end
})
