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

FireworkParticle = Fill:extend
{
	width = 2, height = 2,
	length = 3,
	trail = {}, trailPointer = 1,
	behavior = 'none',

	onEmit = function (self)
		self.alpha = 1
	end,

	onUpdate = function (self, elapsed)
		self.trail[self.trailPointer] = { self.x, self.y }
		self.trailPointer = (self.trailPointer + 1) % 10
		self.alpha = self.alpha - elapsed / self.length

		if self.alpha < 0 then self:die() end
	end,

	onDraw = function (self)
		love.graphics.setColor(self.fill[1], self.fill[2], self.fill[3], 32 * self.alpha)

		for _, pos in pairs(self.trail) do
			love.graphics.rectangle('fill', pos[1], pos[2], self.width, self.height)
		end
	end
}

FireworkLaunch = FireworkParticle:extend
{
	length = 3,

	onEmit = function (self)
		the.view.timer:start{ func = self.explode, bind = self, delay = math.random() + 1 } 
	end,

	explode = function (self)
		the.view.factory:create(FireworkBurst, { x = self.x, y = self.y })
		self:die()
	end
}

FireworkBurst = Emitter:extend
{
	width = 0, height = 0,
	min = { velocity = { x = -300, y = -300 }, acceleration = { y = 300 } },
	max = { velocity = { x = 300, y = 300 }, acceleration = { y = 300 } },
	colors =
	{
		{16, 206, 255},
		{255, 200, 4},
		{5, 231, 3},
		{98, 3, 231},
		{255, 0, 96}
	},

	onNew = function (self)
		self:loadParticles(FireworkParticle, 100)
		the.app.fireworks:add(self)
	end,

	onReset = function (self)
		local color = self.colors[math.random(#self.colors)]
		
		for _, spr in pairs(self.sprites) do
			spr.fill = color
		end

		self:explode()
		color[4] = 64
		the.view:flash(color, 0.25)
	end
}

Fireworks = Emitter:extend
{
	x = 600, y = 600,
	width = 50, height = 0,
	period = 5,
	min = { velocity = { x = -100, y = -600 }, acceleration = { y = 300 } },
	max = { velocity = { x = 25, y = -500 }, acceleration = { y = 300 } },

	onNew = function (self)
		self:loadParticles(FireworkLaunch, 5)
		self:emit()
	end,

	onEmit = function (self)
		if math.random() < 0.25 then self:emit() end
	end
}

the.app = App:new
{
	apps =
	{
		'Sprite Benchmark', SpriteBenchmark,
		'Collision Benchmark', CollisionBenchmark,
		'Sprites', SpriteTypes,
		'Collision Checking', Collisions,
		'Keyboard and Mouse Input', Input,
		'Gamepad Input', GamepadSupport,
		'Object Reuse', Reuse,
		'Maps', Maps,
		'Tiled Map Support', Tiled,
		'Emitters', Emitters,
		'Sounds', Sounds,
		'Files', Files,
		'UI', UI,
		'Parallax Scrolling', Scrolling,
		'Pixel Effects', Effects,
		'Timers', Timers,
		'Tweens', Tweens,
		'Input Recording', Recording,
		'Debugging', Debugging
	},

	onNew = function (self)
		DEBUG = true
		STRICT = true

		self.fireworks = Group:new()
		self.fireworks:add(Fireworks:new())
		self:add(self.fireworks)

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
		self:add(Text:new{ x = 10, y = 580, font = 11, tint = { 0.75, 0.75, 0.75}, text = 'http://tinyurl.com/libzoetrope' })
		self:add(Text:new{ x = 10, y = 440, font = 14, width = 400, text =
						   'Click a heading above to see a demo.\nPress the Escape key at any time to return to this menu.' })
		self:useSysCursor(true)
	end
}
