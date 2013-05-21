-- Class: DebugLocals
-- Shows all local variables for a particular stack level.

DebugLocals = DebugInstrument:extend
{
	visible = false,
	width = 'narrow',

	onNew = function (self)
		self.title.text = 'Locals'
		self.names = Text:new{ font = self.font }
		self.values = Text:new{ font = self.font }
		self.lineHeight = self.names._fontObj:getHeight()
		self:add(self.names)
		self:add(self.values)

		debugger.showLocals = function (level) self:showLocals(level) end
		debugger.hideLocals = function (level) self.visible = false end
	end,

	-- Method: showLocals
	-- Makes the instrument visible and shows all locals at a stack level.
	-- To hide this instrument, just set its visible property to false.
	--
	-- Arguments:
	--		level - level to show
	--
	-- Returns:
	--		nothing

	showLocals = function (self, level)
		self.visible = true
		self.contentHeight = 2 * self.spacing
		self.names.text = ''
		self.values.text = ''

		local i = 1

		while true do
			local name, value = debug.getlocal(level, i)
			if not name then break end

			-- skip variables named (*temporary*)

			if not string.match(name, '^%(') then
				self.names.text = self.names.text .. name .. '\n'
				self.values.text = self.values.text .. tostring(value) .. '\n'
				self.contentHeight = self.contentHeight + self.lineHeight
			end

			i = i + 1
		end
	end,

	onResize = function (self, x, y, width, height)
		self.names.y, self.values.y = y + self.spacing, y + self.spacing
		self.names.height, self.values.height = height, height

		self.names.x = x + self.spacing
		self.names.width = width * 0.3 - self.spacing * 2
		
		self.values.x = self.names.x + self.names.width + self.spacing
		self.values.width = width * 0.7
	end
}
