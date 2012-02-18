require 'zoetrope'

Recording = App:extend({
	onNew = function (self)
		self.recorder = Recorder:new()
		self.meta:add(self.recorder)

		self.player = Fill:new({ x = 100, y = 100, width = 16, height = 16, fill = { 255, 255, 255 } })
		self:add(self.player)
	end,

	onUpdate = function (self, elapsed)
		-- recorder

		if Current.keys:justPressed('r') then
			if Current.keys:pressed('lshift') or Current.keys:pressed('rshift') then
				if self.recorder.state == Recorder.RECORDING then
					self.recorder:stopRecording()
					print('Recording stopped, ' .. #self.recorder.record .. ' events recorded')
				end
			else
				print('Recording started')
				self.recorder:startRecording()
			end
		end

		if Current.keys:justPressed('p') then
			self.recorder:startPlaying()
			print('Playing back recording')
		end

		-- player movement

		self.player.velocity.x = 0
		self.player.velocity.y = 0

		if Current.keys:pressed('up') then
			self.player.velocity.y = -100
		elseif Current.keys:pressed('down') then
			self.player.velocity.y = 100
		elseif Current.keys:pressed('left') then
			self.player.velocity.x = -100
		elseif Current.keys:pressed('right') then
			self.player.velocity.x = 100
		end
	end
})
