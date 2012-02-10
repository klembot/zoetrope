require 'zoetrope'

Sounds = App:extend({
	beepPath = 'tests/assets/beep.mp3',
	tonePath = 'tests/assets/tone.mp3',

	onNew = function (self)
		self.timer = Timer:new()
		self:add(self.timer)
		self.tone = Cached:sound(self.tonePath)
		self.testSound = Sound:new({ source = self.tone })
		self.testSound:play(1)
		self.testSound.volume = 0.25
		
		self.signal = Fill:new({ x = 100, y = 100, width = 100, height = 100, fill = { 0, 0, 255 } })
		self:add(self.signal)

		self.jukeboxLabel = OutlineText:new({ x = 16, y = 16, width = 300 })
		self:add(self.jukeboxLabel)

		self.timer:start({ func = self.testSound.play, delay = 1, arg = { self.testSound, 0.25 } })
	end,

	onUpdate = function (self, elapsed)
		if Current.keys:justPressed(' ') then
			self.view.sounds:play(self.beepPath)
		end

		self.jukeboxLabel.text = #Current.view.sounds.sounds .. ' sounds active in jukebox'
		self.signal.visible = self.testSound:isPlaying()
	end
})
