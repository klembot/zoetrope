-- Class: DebugStepper
-- This lets you pause execution of the app and step through it line by line.
-- This adds a function, debugger.breakpt(), that triggers this intrument.
-- Until this is called, the instrument remains hidden.

DebugStepper = DebugInstrument:extend
{
	visible = false,
	lineContext = 5,
	width = 'wide',
	_fileCache = {},

	onNew = function (self)
		self.stepButton = DebugInstrumentButton:new
		{
			label = 'Step',
			onMouseUp = function (self)
				debugger._stepCommand = 'next'
			end
		}
		self:add(self.stepButton)

		self.continueButton = DebugInstrumentButton:new
		{
			label = 'Continue',
			onMouseUp = function (self)
				debugger._stepCommand = 'continue'
			end
		}
		self:add(self.continueButton)

		self.lineHighlight = Fill:new{ fill = {32, 32, 32} }
		self:add(self.lineHighlight)

		self.sourceLines = Text:new
		{
			font = self.font,
			width = 20,
			align = 'right',
			wordWrap = false,
		}
		self:add(self.sourceLines)

		self.sourceView = Text:new{ font = self.font, wordWrap = false }
		self.lineHeight = self.sourceView._fontObj:getHeight()
		self:add(self.sourceView)

		self.title.text = 'Source'
		self.contentHeight = self.lineHeight * (self.lineContext + 1) * 2 + self.spacing * 3 +
		                     DebugInstrumentButton.height

		debugger.breakpt = function()
			local print = debugger.unsourcedPrint or print
			local caller = debug.getinfo(2, 'S')

			debugger.showConsole()
			self.visible = true

			print('\n' .. string.rep('=', 40))
			print('Breakpoint, ' .. caller.short_src .. ', ' .. caller.linedefined)
			print(string.rep('=', 40))
			debug.sethook(debugger._stepLine, 'l')
		end

		debugger.endBreakpt = function()
			self.visible = false
			if debugger.hideStack then debugger.hideStack() end
			if debugger.hideLocals then debugger.hideLocals() end
			debugger.hideConsole()
			debug.sethook()
		end

		debugger._stepLine = function (_, line)
			local state = debug.getinfo(2, 'S')

			-- not totally in love with this, but it's faster than
			-- checking all possible values

			if string.find(state.source, 'zoetrope/debug') then return end

			if debugger.showStack then debugger.showStack(4) end
			if debugger.showLocals then debugger.showLocals(4) end

			local file = string.match(state.source, '^@(.*)')
			self:showLine(file, line)

			debugger._stepPaused = true

			while debugger._stepPaused do
				debugger._stepCommand = nil
				debugger._miniEventLoop()

				if debugger._stepCommand == 'next' then
					debugger._stepPaused = false
				elseif debugger._stepCommand == 'continue' then
					debugger._stepPaused = false
					debugger.endBreakpt()
				end
			end
		end
	end,

	onResize = function (self, x, y, width, height)
		self.sourceLines.x = x + self.spacing
		self.sourceLines.y = y + self.spacing
		self.sourceLines.height = height - self.sourceLines.y - self.spacing
		
		self.sourceView.x = self.sourceLines.x + self.sourceLines.width + self.spacing
		self.sourceView.y = self.sourceLines.y
		self.sourceView.width = width - self.sourceView.x - self.spacing * 2
		self.sourceView.height = self.sourceLines.height

		self.lineHighlight.x = x + self.spacing
		self.lineHighlight.y = self.sourceLines.y + self.lineHeight * self.lineContext
		self.lineHighlight.width = width - self.spacing * 2
		self.lineHighlight.height = self.lineHeight

		self.stepButton.x = self.sourceLines.x
		self.stepButton.y = self.sourceView.y + self.sourceView.height + self.spacing

		self.continueButton.x = self.stepButton.x + self.stepButton.width + self.spacing
		self.continueButton.y = self.stepButton.y
	end,

	showLine = function (self, file, line)
		if file then
			self.sourceLines.text = ''
			self.sourceView.text = ''

			for i = line - self.lineContext, line + self.lineContext + 1 do
				local source = debugger.sourceLine(file, i)

				if source then
					self.sourceLines.text = self.sourceLines.text .. i .. '\n'
					self.sourceView.text = self.sourceView.text .. string.gsub(debugger.sourceLine(file, i), '\t', string.rep(' ', 4)) .. '\n'
				end
			end

			self.title.text = file .. ':' .. line
		else
			self.title.text = 'Source'
			self.sourceView.text = '(source not available)'
		end
	end
}

