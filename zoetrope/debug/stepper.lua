-- Class: DebugStepper
-- This lets you pause execution of the app and step through it line by line.
-- This adds a function, debugger.breakpt(), that triggers this intrument.
-- Until this is called, the instrument remains hidden.

DebugStepper = DebugInstrument:extend
{
	visible = false,
	lineContext = 10,
	width = 'wide',
	_fileCache = {},

	onNew = function (self)
		self.stepIntoButton = self:add(DebugInstrumentButton:new
		{
			label = 'Step Into',
			onMouseUp = function (self)
				debugger._stepPaused = false
				debugger._stepFilter = nil
			end
		})

		self.stepOverButton = self:add(DebugInstrumentButton:new
		{
			label = 'Step Over',
			onMouseUp = function (self)
				debugger._stepPaused = false
				local prevStack = debugger._stepStack()

				debugger._stepFilter = function (stack)
					for i = 1, #stack - #prevStack do
						local match = true

						for j = 1, #prevStack do
							if stack[i + j] ~= prevStack[j] then
								match = false
								break
							end
						end

						-- we are now executing a sub-call;
						-- temporarily disable our line hook until
						-- we return to the previous function

						if match then
							debug.sethook(function()
								local state = debug.getinfo(3, 'f')

								if state.func == prevStack[1] then 
									-- we're at least on our old function, but is
									-- the stack depth the same?

									local depth = 1
									
									while true do
										state = debug.getinfo(3 + depth, 'f')
										if not state then break end
										depth = depth + 1
									end

									if depth == #prevStack then
										debug.sethook(debugger._stepLine, 'l')
									end
								end
							end, 'r')
							return false
						end
					end

					return true
				end
			end
		})

		self.stepOutButton = self:add(DebugInstrumentButton:new
		{
			label = 'Step Out',
			onMouseUp = function (self)
				debugger._stepPaused = false
			end
		})

		self.continueButton = self:add(DebugInstrumentButton:new
		{
			label = 'Continue',
			onMouseUp = function (self)
				debugger._stepPaused = false
				debugger.endBreakpt()
			end
		})

		self.lineHighlight = self:add(Fill:new{ fill = {64, 64, 64} })

		self.sourceLines = self:add(Text:new
		{
			font = self.font,
			width = 20,
			align = 'right',
			wordWrap = false,
		})

		self.sourceView = self:add(Text:new{ font = self.font, wordWrap = false })
		self.lineHeight = self.sourceView._fontObj:getHeight()

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

		-- hook to handle stepping over source

		debugger._stepLine = function (_, line)
			local state = debug.getinfo(2, 'Sl')

			if string.find(state.source, 'zoetrope/debug') or
			   (debugger._stepFilter and not debugger._stepFilter(debugger._stepStack())) then
				--print('skipping', state.source, state.currentline, #debugger._stepStack())
				return
			end

			if debugger.showStack then debugger.showStack(4) end
			if debugger.showLocals then debugger.showLocals(4) end

			local file = string.match(state.source, '^@(.*)')
			self:showLine(file, line)

			debugger._stepPaused = true

			while debugger._stepPaused do
				debugger._miniEventLoop()
			end
		end

		-- returns a table representing the call stack during a source step

		debugger._stepStack = function()
			local level = 2
			local result = {}
			local info = {}
			local afterHook = false

			while true do
				info = debug.getinfo(level, 'f')
				if not info then break end

				if afterHook then
					table.insert(result, info.func)
				elseif info.func == debugger._stepLine then
					afterHook = true
				end

				level = level + 1
			end

			return result
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

		self.stepIntoButton.x = self.sourceLines.x
		self.stepIntoButton.y = self.sourceView.y + self.sourceView.height + self.spacing

		self.stepOverButton.x = self.stepIntoButton.x + self.stepIntoButton.width + self.spacing
		self.stepOverButton.y = self.stepIntoButton.y

		self.stepOutButton.x = self.stepOverButton.x + self.stepOverButton.width + self.spacing
		self.stepOutButton.y = self.stepOverButton.y

		self.continueButton.x = width - self.stepOverButton.width
		self.continueButton.y = self.stepOverButton.y
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

