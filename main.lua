STRICT = true
DEBUG = true

require 'tests'

MenuButton = Button:extend({
	onNew = function (self)
		self.background = Fill:new({ width = 100, height = 24,
									 fill = { 64, 64, 64 }, border = { 255, 255, 255 } })
		self.label = Text:new({ x = 4, y = 6, align = 'center',
							    width = 92, height = 16, text = self.label })
	end,

	onMouseUp = function (self)
		the.app = self.app:new()
		the.app:run()
	end
})

Menu = App:extend({
	apps =
	{
		'Benchmark', Benchmark,
		'Collisions', Collisions,
		'Emitters', Emitters,
		'Files', Files,
		'Factory', FactoryApp,
		'Focus', Focus,
		'Gamepad', GamepadApp,
		'Hello World', HelloWorld,
		'Input', Input,
		'Loading', Loading,
		'Maps', Maps,
		'Recording', Recording,
		'Scrolling', Scrolling,
		'Sounds', Sounds,
		'Sprite Types', SpriteTypes,
		'Timers', Timers,
		'Tweens', Tweens,
		'UI', UI,
		'ViewFx', ViewFx
	},

	onNew = function (self)
		local x = 16
		local y = 16

		for i = 1, #self.apps, 2 do
			self:add(MenuButton:new({ x = x, y = y, label = self.apps[i], app = self.apps[i + 1] }))

			x = x + 136

			if x > the.app.width - 100 then
				x = 16
				y = y + 30
			end
		end

		print('Welcome to the Zoetrope test suite.')
	end
})


function love.load()
	testApp = Menu:new()
	testApp:run()
end
