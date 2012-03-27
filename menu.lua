-- Lets the user choose a test to run.

MenuButton = Button:extend({
	onNew = function (self)
		self.background = Fill:new({ width = 100, height = 24,
									 fill = { 64, 64, 64 }, border = { 255, 255, 255 } })
		self.label = OutlineText:new({ x = 4, y = 6, align = 'center',
									   width = 92, height = 16, text = self.label })
	end,


	onMouseUp = function (self)
		Current.app = self.app:new()
		Current.app:run()
	end
})

Menu = App:extend({
	apps =
	{
		'Benchmark', Benchmark,
		'Collisions', Collisions,
		'Emitters', Emitters,
		'Files', Files,
		'Focus', Focus,
		'Hello World', HelloWorld,
		'Input', Input,
		'Maps', Maps,
		'Recording', Recording,
		'Scrolling', Scrolling,
		'Sounds', Sounds,
		'Sprite Types', SpriteTypes,
		'Timers', Timers,
		'Tweens', Tweens,
		'UI', UI
	},

	onNew = function (self)
		local x = 16
		local y = 16

		for i = 1, #self.apps, 2 do
			self:add(MenuButton:new({ x = x, y = y, label = self.apps[i], app = self.apps[i + 1] }))

			x = x + 136

			if x > Current.app.width - 100 then
				x = 16
				y = y + 30
			end
		end
	end,

	onUpdate = function (self, elapsed)
		if Current.keys:justPressed('escape') then self:quit() end

		if Current.keys:justPressed('f') then
			self:toggleFullscreen()
		end
	end
})
