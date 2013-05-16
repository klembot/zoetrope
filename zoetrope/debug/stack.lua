-- Class: DebugStack
-- This shows a stack trace for a particular stack level.

DebugStack = DebugInstrument:extend
{
	visible = false,
	width = 'narrow',

	onNew = function (self)
		self.title.text = 'Stack'
		self.text = Text:new{ font = self.font, wordWrap = false }
		self.lineHeight = self.text._fontObj:getHeight()
		self:add(self.text)

		debugger.showStack = function (level) self:showStack(level) end
		debugger.hideStack = function() self.visible = false end
	end,

	-- Method: showStack
	-- Makes the instrument visible and shows a stack trace.
	-- To hide this, just set the instrument's visible property to false.
	--
	-- Arguments:
	--		level - stack level to show
	--
	-- Returns:
	--		nothing
	
	showStack = function (self, level)
		self.text.text = ''
		self.visible = true
		self.contentHeight = self.spacing * 2

		local info

		repeat
			info = debug.getinfo(level, 'nlS')
			
			if info then
				if info.name then
					self.text.text = self.text.text .. info.name .. '()\n    '
					self.contentHeight = self.contentHeight + self.lineHeight
				end

				self.text.text = self.text.text .. info.short_src .. ':' .. info.currentline .. '\n'
				self.contentHeight = self.contentHeight + self.lineHeight
			end

			level = level + 1
		until not info
			
		--[[
		--]]
	end,

	onResize = function (self, x, y, width, height)
		self.text.x = x + self.spacing
		self.text.y = y + self.spacing
		self.text.width = width - self.spacing * 2
		self.text.height = height - self.spacing * 2
	end
}
