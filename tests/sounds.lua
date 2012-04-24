require 'zoetrope'

Sounds = App:extend({
	onNew = function (self)
		self.timer = Timer:new()
		self:add(self.timer)
		self.testSound = Sound:new({ source = 'tests/assets/tone.mp3' })
		self.testSound:play(1)
		self.testSound.volume = 0.25
		
		self.signal = Fill:new({ x = 100, y = 100, width = 100, height = 100, fill = { 0, 0, 255 } })
		self:add(self.signal)

		self.timer:start({ func = self.testSound.play, delay = 1, bind = self.testSound })
	end,

	onUpdate = function (self, elapsed)
		if the.keys:justPressed(' ') then
			playSound('tests/assets/beep.mp3')
		end

		self.signal.visible = self.testSound:isPlaying()
	end
})
