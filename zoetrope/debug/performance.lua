-- Class: DebugPerformance
-- Shows a live graph of frames per second. This only records data while visible.

DebugPerformance = DebugInstrument:extend
{
	width = 'narrow',
	contentHeight = 30,
	samples = {},
	sampleInterval = 0.25,
	samplePtr = 1,
	numSamples = 105,
	_sampleTimer = 0,
	_sampleBars = {},
	average = '-',

	onNew = function (self)
		for i = 1, self.numSamples do
			self._sampleBars[i] = self:add(Fill:new{ fill = {255, 255, 255}, width = 0, height = 0 })
		end
	end,

	onUpdate = function (self, elapsed)
		self._sampleTimer = self._sampleTimer + elapsed
		local fps = math.floor(1 / elapsed + 0.5)
		self.title.text = 'FPS (' .. fps .. ', average ' .. self.average .. ')'

		if self._sampleTimer > self.sampleInterval then
			-- record fps and percent of desired fps

			table.insert(self.samples, fps)
			table.insert(self.samples, fps / the.app.fps)

			if #self.samples > self.numSamples * 2 then
				table.remove(self.samples, 1)
				table.remove(self.samples, 1)
			end

			-- calculate average

			local sum = 0

			for i = 1, #self.samples, 2 do
				sum = sum + self.samples[i]
			end

			self.average = math.floor(sum / #self.samples * 2 + 0.5)

			-- sync bars and title bar

			local barHeight = self.contentHeight - 2 * self.spacing

			for i, bar in ipairs(self._sampleBars) do
				local percent = self.samples[i * 2]

				if percent then
					bar.distort.y = percent

					if percent > 0.5 then
						-- blend yellow to green
						bar.fill = {255 * (1 - (percent / 2)), 255, 0}
					else
						-- blend red to yellow
						-- 510 * percent = 255 * percent / 2
						bar.fill = {255, 510 * percent, 0}
					end
				else
					bar.distort.y = 0
				end
			end

			self._sampleTimer = 0
		end
	end,

	onResize = function (self, x, y, width, height)
		self.y = y + self.spacing 
		x = x + self.spacing
		local barWidth = math.ceil((width - 2 * self.spacing) / self.numSamples)

		for _, spr in pairs(self._sampleBars) do
			spr.x = x
			spr.y = self.y
			spr.width = barWidth
			spr.height = height - self.spacing * 2
			spr.origin.y = spr.height
			x = x + barWidth
		end
	end
}
