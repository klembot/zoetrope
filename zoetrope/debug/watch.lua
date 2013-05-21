DebugWatch = DebugInstrument:extend
{
	_watches = {},

	onNew = function (self)
		self.title.text = 'Watch'
		self.labels = self:add(Text:new{ font = self.font })
		self.values = self:add(Text:new{ font = self.font })
		self.lineHeight = self.labels._fontObj:getHeight()

		self:addExpression('love.timer.getFPS()', 'FPS')
		self:addExpression('math.floor(collectgarbage("count") / 1024) .. "M"', 'Memory used')

		debugger.watch = function (exp, label) self:addExpression(exp, label) end
	end,

	-- Method: addExpression
	-- Adds an expression to be watched.
	--
	-- Arguments:
	--		expression - expression to evaluate as a string
	--		label - string label, defaults to expression

	addExpression = function (self, expression, label)
		table.insert(self._watches, { label = label or expression,
									  func = loadstring('return ' .. expression) })
	
		self.contentHeight = #self._watches * self.lineHeight + 2 * self.spacing
	end,

	onUpdate = function (self)
		self.labels.text = ''
		self.values.text = ''

		for _, watch in pairs(self._watches) do
			local ok, value = pcall(watch.func)
			if not ok then value = nil end
			self.labels.text = self.labels.text .. watch.label .. '\n'
			self.values.text = self.values.text .. tostring(value) .. '\n'
		end
	end,

	onResize = function (self, x, y, width, height)
		self.labels.y, self.values.y = y + self.spacing, y + self.spacing
		self.labels.height, self.values.height = height, height

		self.labels.x = x + self.spacing
		self.labels.width = width / 2 - self.spacing * 2
		
		self.values.x = self.labels.x + self.labels.width + self.spacing
		self.values.width = self.labels.width
	end
}
