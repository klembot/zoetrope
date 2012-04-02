require 'zoetrope'

Recording = App:extend({
	onNew = function (self)
		self.recorder = Recorder:new()--{ mousePosInterval = 0.01 })
		self.meta:add(self.recorder)

		local cursor = Cursor:new()
		cursor:add(Fill:new({ width = 8, height = 8, fill = { 255, 0, 0 } }))
		self:useSysCursor(false)

		self.player = Fill:new({ x = 100, y = 100, width = 16, height = 16, fill = { 255, 255, 255 } })

		self:add(self.player)

		self:add(cursor)
		self:add(OutlineText:new({ x = 4, y = 4, text = 'Arrow keys move, clicks create new sprites. R key starts/stops recording. P key plays back recorded input.' }))
	end,

	onUpdate = function (self, elapsed)
		-- recorder

		if the.keys:justPressed('r') then
			if self.recorder.state == Recorder.IDLE then
				print('Recording started')
				self.recorder:startRecording()
			elseif self.recorder.state == Recorder.RECORDING then
				self.recorder:stopRecording()
				print('Recording stopped, ' .. #self.recorder.record .. ' events recorded')
			end
		end

		if the.keys:justPressed('p') then
			self.player.x = 100
			self.player.y = 100
			self.recorder:startPlaying()
			print('Playing back recording')
		end

		-- keyboard events

		self.player.velocity.x = 0
		self.player.velocity.y = 0

		if the.keys:pressed('up') then
			self.player.velocity.y = -100
		elseif the.keys:pressed('down') then
			self.player.velocity.y = 100
		elseif the.keys:pressed('left') then
			self.player.velocity.x = -100
		elseif the.keys:pressed('right') then
			self.player.velocity.x = 100
		end

		-- mouse events

		if the.mouse:justPressed() then
			self:add(Fill:new({ x = the.mouse.x - 8, y = the.mouse.y - 8, width = 16, height = 16,
								velocity = { x = 0, y = 200, rotation = math.pi } }))
		end
	end
})
