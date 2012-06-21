require 'zoetrope'

Scrolling = App:extend
{
	onRun = function (self)
		local x
		
		local layer1 = Group:new()
		layer1.translateScale.x = 0.25
		layer1.translateScale.y = 0.25
		self:add(layer1)
		
		for x = 16, self.width * 5, 64 do
			layer1:add(Fill:new{ x = x, y = 100, width = 8, height = 8,
								  fill = {255, 0, 0} }
		end
		
		local layer2 = Group:new()
		layer2.translateScale.x = 0.5
		layer2.translateScale.y = 0.5
		self:add(layer2)
		
		for x = 16, self.width * 5, 64 do
			layer2:add(Fill:new{ x = x, y = 200, width = 16, height = 16,
								  fill = {0, 255, 0} }
		end
		
		local layer3 = Group:new()
		self:add(layer3)
		
		for x = 16, self.width * 5, 64 do
			layer3:add(Fill:new{ x = x, y = 300, width = 32, height = 32,
								  fill = {0, 0, 255} }
		end
		
		local layer4 = Group:new()
		layer4.translateScale.x = 0
		layer4.translateScale.y = 0
		self:add(layer4)
		
		for x = 16, self.width * 5, 64 do
			layer4:add(Fill:new{ x = x, y = 400, width = 32, height = 32,
								  fill = {255, 255, 255} }
		end
		
		self.view.tween:start{ target = self.view.translate, prop = 'x',
								  to = self.width * -4, duration = 10,
								  ease = 'quadInOut', onComplete = Tween.reverse }
	end
}
