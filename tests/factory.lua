FactoryParticle = Fill:extend({
	width = 16,
	height = 16,

	onNew = function (self)
		the.app:add(self)
	end,

	onReset = function (self)
		self.x = (the.app.width - self.width) / 2
		self.y = (the.app.height - self.height) / 2
	end,

	onUpdate = function (self)
		if self.x < - self.width or self.y < - self.height or self.x > the.app.width then
			the.view.factory:recycle(self)
		end
	end
})

FactoryApp = App:extend({
	onNew = function (self)
		self.label = Text:new({ x = 4, y = 4, width = 200, text = '0 sprites' })
		self:add(self.label)
	end,

	onUpdate = function (self, elapsed)
		if the.keys:justPressed('r') then
			self.view.factory:create(FactoryParticle,
									{ fill = { 255, 0, 0 },
									  velocity = { x = -200, y = 0, rotation = 0 } })
		elseif the.keys:justPressed('g') then
			self.view.factory:create(FactoryParticle,
									{ fill = { 0, 255, 0 },
									  velocity = { x = 0, y = -200, rotation = 0 } })
		elseif the.keys:justPressed('b') then
			self.view.factory:create(FactoryParticle,
									{ fill = { 0, 0, 255 },
									  velocity = { x = 200, y = 0, rotation = 0 } })
		end

		self.label.text = #self.view.sprites .. ' sprites'
	end
})
