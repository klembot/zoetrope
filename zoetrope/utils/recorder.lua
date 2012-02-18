-- Class: Recorder
-- This records the user's inputs for playback at a later time,
-- or saving to a file. You must start recording *after* all input
-- devices are set up, and you should only run one recorder at a time.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.sprite'

Recorder = Sprite:extend({
	elapsed = 0,

	IDLE = 'idle',
	RECORDING = 'recording',
	PLAYING = 'playing',

	new = function (self, obj)
		obj = self:extend(obj)
		obj.state = Recorder.IDLE

		Sprite.new(obj)
		return obj
	end,

	startRecording = function (self, record)
		if self.state == Recorder.RECORDING then return end

		-- set up properties
		self.record = record or {}
		self.state = Recorder.RECORDING
		self.elapsed = 0

		-- insert ourselves into event handlers
		local this = self

		self.origKeyPressed = love.keypressed
		love.keypressed = function (key, code) this:keyPressed(key, code) end
		self.origKeyReleased = love.keyreleased
		love.keyreleased = function (key, code) this:keyReleased(key, code) end
	end,

	stopRecording = function (self)
		if self.state ~= Recorder.RECORDING then return end

		self.state = Recorder.IDLE
		love.keypressed = self.origKeyPressed
		love.keyreleased = self.origKeyReleased
	end,

	startPlaying = function (self, record)
		record = record or self.record
		self.state = Recorder.PLAYING 

		self.elapsed = 0
		self.playbackIndex = 1
	end,

	stopPlaying = function (self)
		self.state = Recorder.IDLE
	end,

	keyPressed = function (self, key, unicode)
		table.insert(self.record, { self.elapsed, 'kp', key, unicode })

		if self.origKeyPressed then
			self.origKeyPressed(key, unicode)
		end
	end,

	keyReleased = function (self, key, unicode)
		table.insert(self.record, { self.elapsed, 'kr', key, unicode })

		if self.origKeyReleased then
			self.origKeyReleased(key, unicode)
		end
	end,

	update = function (self, elapsed)
		if self.state ~= Recorder.IDLE then
			self.elapsed = self.elapsed + elapsed
		end

		if self.state == Recorder.PLAYING and self.elapsed > self.record[self.playbackIndex][1] then
			local event = self.record[self.playbackIndex]
			love.event.push(event[2], event[3], event[4], event[5])
			
			self.playbackIndex = self.playbackIndex + 1

			if self.playbackIndex > #self.record then
				self:stopPlaying()
			end
		end
	end
})
