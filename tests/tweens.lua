require 'zoetrope'

Tweens = App:extend
{
	onRun = function (self)
		local y = 16
		
		for name, _ in pairs(Tween.easers) do
			local block = Fill:new{ x = 16, y = y, width = 32, height = 32 }
			self:add(block)
			self.view.tween:start{ target = block, prop = 'x', to = 116, ease = name,
									onComplete = Tween.reverse }
									 
			y = y + 32
		end
		
		local alphaBlock = Fill:new{ x = 200, y = 16, width = 32, height = 32 }
		self:add(alphaBlock)
		self.view.tween:start{ target = alphaBlock, prop = 'alpha', to = 0,
								onComplete = Tween.reverse}
		
		local colorBlock = Fill:new{ x = 300, y = 16, width = 32, height = 32,
									  fill = { 255, 0, 0 } }
		self:add(colorBlock)
		self.view.tween:start{ target = colorBlock, prop = 'fill',
								to = { 0, 0, 255 }, onComplete = Tween.reverse }
	end
}
