-- Class: Recorder
-- This records the user's inputs for playback at a later time,
-- or saving to a file. You must start recording *after* all input
-- objects are set up, and you should only run one recorder at a time.
--
-- Extends:
--		<Sprite>

require 'zoetrope.core.sprite'

Recorder = Sprite:extend({
	-- private property: elapsed
	-- either time elapsed while recording or playing back, in seconds
	elapsed = 0,

	-- Constant: IDLE
	-- The recorder is currently doing nothing.
	IDLE = 'idle',

	-- Constant: RECORDING
	-- The recorder is currently recording user input.
	RECORDING = 'recording',

	-- Constant: PLAYING
	-- The recorder is currently playing back user input.
	PLAYING = 'playing',

	-- Property: state
	-- One of the state constants, indicates what the recorder is currently doing.

	-- Property: record
	-- A table of inputs with timing information.

	new = function (self, obj)
		obj = self:extend(obj)
		obj.state = Recorder.IDLE

		Sprite.new(obj)
		return obj
	end,

	-- Method: startRecording
	-- Begins recording user inputs. If the recorder is already recording,
	-- this has no effect.
	--
	-- Arguments:
	--		record - Record to use. Any existing data is appended to.
	--				 If omitted, the current record is used. If the current
	--				 record is unset, this creates a new record.
	--
	-- Returns:
	--		nothing

	startRecording = function (self, record)
		if self.state == Recorder.RECORDING then return end

		-- set up properties
		self.record = record or self.record or {}
		self.state = Recorder.RECORDING
		self.elapsed = 0

		-- insert ourselves into event handlers
		self:stealInputs()

	end,

	-- Method: stopRecording
	-- Stops recording user inputs. If the recorder wasn't recording anyway,
	-- this does nothing.
	-- 
	-- Arguments:
	--		none
	-- 
	-- Returns:
	--		nothing

	stopRecording = function (self)
		if self.state ~= Recorder.RECORDING then return end

		self.state = Recorder.IDLE
		self:restoreInputs()
		love.keypressed = self.origKeyPressed
		love.keyreleased = self.origKeyReleased
	end,

	-- Method: startPlaying
	-- Starts playing back user inputs.
	--
	-- Arguments:
	--		record - Record to play back. If ommitted, this uses
	--				 the recorder's record property.
	--
	-- Returns:
	--		nothing

	startPlaying = function (self, record)
		record = record or self.record
		self.state = Recorder.PLAYING 

		self.elapsed = 0
		self.playbackIndex = 1
		self:stealInputs()
	end,

	-- Method: stopPlaying
	-- Stops playing back user inputs.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	stopPlaying = function (self)
		self.state = Recorder.IDLE
		self:restoreInputs()
	end,

	stealInputs = function (self)
		local this = self

		self.origKeyPressed = love.keypressed
		love.keypressed = function (key, code) this:recordKeyPress(key, code) end
		self.origKeyReleased = love.keyreleased
		love.keyreleased = function (key, code) this:recordKeyRelease(key, code) end
	end,

	restoreInputs = function (self)
		love.keypressed = self.origKeyPressed
		love.keyreleased = self.origKeyReleased
	end,
	
	recordKeyPress = function (self, key, unicode)
		table.insert(self.record, { self.elapsed, 'keypress', key, unicode })

		if self.origKeyPressed then
			self.origKeyPressed(key, unicode)
		end
	end,

	recordKeyRelease = function (self, key, unicode)
		table.insert(self.record, { self.elapsed, 'keyrelease', key, unicode })

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
			
			if event[2] == 'keypress' and self.origKeyPressed then
				self.origKeyPressed(event[3], event[4])
			elseif event[2] == 'keyrelease' and self.origKeyReleased then
				self.origKeyReleased(event[3], event[4])
			end

			self.playbackIndex = self.playbackIndex + 1

			if self.playbackIndex > #self.record then
				self:stopPlaying()
			end
		end
	end
})
