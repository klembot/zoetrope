require 'zoetrope'

SpriteTypes = App:extend({
	title = 'Sprite Types',
	blueGem = 'tests/assets/bluegem.png',
	chestAnim = 'tests/assets/animation.png',
	
	onNew = function (self)
		print 'This demonstrates the different types of sprites available in Zoetrope.'
	end,
	
	onRun = function (self)
		self.font = BitmapFont:new({ image = 'tests/assets/press-start.png' })
		
		self:add(Fill:new({
			x = 16, y = 16, width = 32, height = 32,
			fill = { 0, 0, 255 }, border = { 0, 255, 0 }
		}))	
	
		self:add(Fill:new({
			x = 64, y = 16, width = 32, height = 32,
			fill = { 0, 0, 255 }, border = { 0, 255, 0 },
			tint = { 0, 0, 1 }, alpha = 0.5, rotation = math.rad(45), scale = 2 
		}))
		
		self:add(Tile:new({ x = 16, y = 144, width = 32, height = 32, image = self.blueGem }))
		
		self:add(Tile:new({
			x = 72, y = 144, width = 32, height = 32, image = self.blueGem,
			tint = { 0.5, 1, 0.5 }, alpha = 0.5, rotation = math.rad(45),
		}))
		
		local anim = Animation:new({ x = 150, y = 25, width = 16, height = 24, image = self.chestAnim })
		anim.sequences.open = { frames = { 1, 2, 3, 4, 5, 4, 3, 2 }, fps = 10 }
		anim:play('open')
		self:add(anim)

		local anim2 = Animation:new({ x = 200, y = 25, width = 16, height = 24, image = self.chestAnim,
									  fill = { 0, 0, 255 }, border = { 0, 255, 0 },
									  tint = { 0.5, 1, 0.5 }, alpha = 0.5, rotation = math.rad(45),
									  scale = 2
		})
		anim2.sequences.open = { frames = { 1, 2, 3, 4, 5, 4, 3, 2 }, fps = 10 }
		anim2:play('open')
		self:add(anim2)
		
		self:add(OutlineText:new({ x = 16, y = 250, text = 'This is an outline (TrueType) font.',
								   width = 150, color = {0, 0, 255} }))
		self:add(OutlineText:new({ x = 316, y = 250, text = 'This is an outline (TrueType) font.',
								   width = 150, color = {0, 0, 255}, align = 'center' }))
		self:add(OutlineText:new({ x = 516, y = 250, text = 'This is an outline (TrueType) font.',
								   width = 150, color = {0, 0, 255}, align = 'right' }))

		self:add(BitmapText:new({ x = 16, y = 350, text = 'This is a bitmap font.',
								   width = 150, font = self.font }))
		self:add(BitmapText:new({ x = 316, y = 350, text = 'This is a bitmap font.',
								   width = 150, font = self.font, align = 'center' }))
		self:add(BitmapText:new({ x = 516, y = 350, text = 'This is a bitmap font.',
								   width = 150, font = self.font, align = 'right' }))
	end
})
