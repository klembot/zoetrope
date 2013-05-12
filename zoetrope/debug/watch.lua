DebugWatch = Group:extend
{
	_watches = {},

	new = function (self, obj)
		obj = self:extend(obj or {})

		obj.labels = Text:new{ x = the.app.width - the.console.sidebarWidth, y = 0, width = 90, align = 'right' }
		obj.values = Text:new{ x = obj.labels.x + 100, y = 0, width = 90 }

		obj:add(obj.labels)
		obj:add(obj.values)

		obj:addExpression('love.timer.getFPS()', 'FPS')
		obj:addExpression('math.floor(collectgarbage("count") / 1024) .. "M"', 'Memory used')

		Group.new(obj)
		return obj
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
	end,

	update = function (self)
		if self.visible then
			self.labels.text = ''
			self.values.text = ''

			for _, watch in pairs(self._watches) do
				local ok, value = pcall(watch.func)
				if not ok then value = nil end
				self.labels.text = self.labels.text .. watch.label .. '\n'
				self.values.text = self.values.text .. tostring(value) .. '\n'
			end
		end
	end
}
