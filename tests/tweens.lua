require 'zoetrope'

Tweens = App:extend({
	onRun = function (self)
		local y = 16
		
		for name, _ in pairs(Tweener.easers) do
			local block = Fill:new({ x = 16, y = y, width = 32, height = 32 })
			self:add(block)
			self.view.tweener:start({ target = block, property = 'x',
									  destination = 116, ease = name,
									  onComplete = Tweener.reverse })
									 
			y = y + 32
		end
		
		local alphaBlock = Fill:new({ x = 200, y = 16, width = 32, height = 32 })
		self:add(alphaBlock)
		self.view.tweener:start({ target = alphaBlock, getter = alphaBlock.getAlpha,
								  setter = alphaBlock.setAlpha, destination = 0,
								  onComplete = Tweener.reverse})
		
		local colorBlock = Fill:new({ x = 300, y = 16, width = 32, height = 32,
									  fill = { 255, 0, 0 } })
		self:add(colorBlock)
		self.view.tweener:start({ target = colorBlock, property = 'fill',
								  destination = { 0, 0, 255 },
								  onComplete = Tweener.reverse })
	end
})