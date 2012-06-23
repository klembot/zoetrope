STRICT = true
DEBUG = true

require 'tests'

MenuButton = Button:extend
{
	onNew = function (self)
		self.background = Fill:new{ width = 200, height = 24,
									 fill = { 64, 64, 64 }, border = { 255, 255, 255 } }
		self.label = Text:new{ x = 4, y = 6, align = 'center',
							    width = 192, height = 16, text = self.label }
	end,

	onMouseEnter = function (self)
		self.background.fill = {128, 128, 128}
	end,

	onMouseExit = function (self)
		self.background.fill = {64, 64, 64}
	end,

	onMouseUp = function (self)
		the.app = self.app:new()
		the.app:run()
	end
}

Menu = App:extend
{
	apps =
	{
		'Performance Benchmark', Benchmark,
		'Sprites', SpriteTypes,
		'Keyboard and Mouse Input', Input,
		'Gamepad Input', GamepadSupport,
		'Collision Checking', Collisions,
		'Object Reuse', Reuse,
		'Maps', Maps,
		'Emitters', Emitters,
		'Sounds', Sounds,
		'Files', Files,
		'Tinting and Fading', ViewFx,
		'UI', UI,
		'Tiled Map Support', Loading,
		'Parallax Scrolling', Scrolling,
		'Timers', Timers,
		'Tweens', Tweens,
		'Input Recording', Recording
	},

	onNew = function (self)
		local x = 10
		local y = 50

		for i = 1, #self.apps, 2 do
			self:add(MenuButton:new{ x = x, y = y, label = self.apps[i], app = self.apps[i + 1] })

			x = x + 250

			if x > 400 then
				x = 10
				y = y + 40
			end
		end

		print('Welcome to the Zoetrope test suite.')

		self:add(Text:new{ x = 10, y = 470, font = 100, width = 780, tint = {0.5, 0.5, 0.5}, text = 'Zoetrope' })
		self:add(Text:new{ x = 10, y = 440, font = 14, width = 500, text =
						   'Click a heading above to see a demo. Press Control-Alt-M (Control-Option-M on a Mac) at '..
						   'any time to return to this menu.' })
	end
}

function love.load()
	testApp = Menu:new()
	testApp:run()
end
