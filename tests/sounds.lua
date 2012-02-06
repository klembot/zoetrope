require 'zoetrope'

Sounds = App:extend({
	tonePath = 'tests/assets/tone.mp3',

	onNew = function (self)
		self.timer = Timer:new()
		self:add(self.timer)
		self.tone = love.audio.newSource(self.tonePath, 'static')
		self.testSound = Sound:new({ source = self.tone })
		self.testSound:play(1)
		self.testSound.volume = 0.25
		self.timer:start({ func = self.testSound.play, delay = 1, arg = { self.testSound, 0.25 } })
	end,

	onUpdate = function (self, elapsed)
		if Current.keys:justPressed(' ') then
			self.view.sounds:play(self.tonePath, math.random())
		end
	end
})
