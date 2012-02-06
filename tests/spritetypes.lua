require 'zoetrope'

SpriteTypes = App:extend({
	title = 'Sprite Types',
	mario = love.graphics.newImage('tests/assets/mario.png'),
	samus = love.graphics.newImage('tests/assets/samus.png'),
	
	onNew = function (self)
		print 'This demonstrates the different types of sprites available in Zoetrope.'
	end,
	
	onRun = function (self)
		self.font = BitmapFont:new({ imagePath = 'tests/assets/barwood.png', height = 23,
									 alphabet = ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ' ..
												 '0123456789!@#$%/&*()-,.;:?\'"[]{}<>+=~\\|') })
		self:add(Fill:new({
			x = 16, y = 16, width = 32, height = 32,
			fill = { 0, 0, 255 }, border = { 0, 255, 0 }
		}))	
	
		self:add(Fill:new({
			x = 64, y = 16, width = 32, height = 32,
			fill = { 0, 0, 255 }, border = { 0, 255, 0 },
			colorMultiplier = { 1, 1, 1, 0.5 }, rotation = math.rad(45),
			scale = { x = 2, y = 2 }
		}))
		
		self:add(Tile:new({ x = 16, y = 144, width = 32, height = 32, image = self.mario }))
		
		self:add(Tile:new({
			x = 72, y = 144, width = 32, height = 32, image = self.mario,
			colorMultiplier = { 0.5, 1, 0.5, 1 }, rotation = math.rad(45),
			scale = { x = 2, y = 2 }
		}))
		
		local anim = Animation:new({ x = 150, y = 25, width = 32, height = 32, image = self.samus })
		anim:addSequence({ name = 'run', frames = { 0, 1, 2 }, fps = 10 })
		anim:play('run')
		self:add(anim)

		local anim2 = Animation:new({ x = 200, y = 25, width = 32, height = 32, image = self.samus,
									  fill = { 0, 0, 255 }, border = { 0, 255, 0 },
									  colorMultiplier = { 1, 1, 1, 0.5 }, rotation = math.rad(45),
									  scale = { x = 2, y = 2 }
		})
		anim2:addSequence({ name = 'run', frames = { 0, 1, 2 }, fps = 10 })
		anim2:play('run')
		self:add(anim2)
		
		self:add(OutlineText:new({ x = 16, y = 250, text = 'This is an outline (TrueType) font.',
								   width = 150, color = {0, 0, 255} }))
	end,

	onDraw = function (self)
		self.font:drawText('Hello, world.', 0, 0, 0)
	end
})
