DebugStepperButton = Button:extend
{
	width = 75,
	height = 25,
	visible = false,
	active = false,

	new = function (self, obj)
		obj = self:extend(obj or {})
		obj.y = the.app.height - obj.height + 1

		obj.background = Fill:new
		{
			width = self.width, height = self.height,
			fill = {64, 64, 64, 200},
			border = {255, 255, 255}
		}

		obj.label = Text:new
		{
			width = self.width, height = self.height,
			align = 'center',
			y = 5,
			text = obj.label
		}

		Button.new(obj)
		return obj
	end,

	onMouseEnter = function (self)
		self.background.fill = { 128, 128, 128, 200 }
	end,

	onMouseExit = function (self)
		self.background.fill = { 64, 64, 64, 200 }
	end
}

DebugStepper = Group:extend
{
	active = false,
	visible = false,
	lineContext = 2,

	new = function (self, obj)
		obj = self:extend(obj or {})

		obj.x = the.app.width - the.console.sidebarWidth
		
		obj.stepButton = DebugStepperButton:new
		{
			x = obj.x,
			label = 'Step',
			onMouseUp = function (self)
				debugger._stepCommand = 'next'
			end
		}
		obj:add(obj.stepButton)

		obj.stepButton = DebugStepperButton:new
		{
			x = obj.x + DebugStepperButton.width + 5,
			label = 'Continue',
			onMouseUp = function (self)
				debugger._stepCommand = 'continue'
			end
		}
		obj:add(obj.stepButton)

		obj.sourceFile = Text:new
		{
			font = 11,
			x = obj.x,
			y = the.app.height - 120,
			width = the.console.sidebarWidth
		}

		local fontHeight = obj.sourceFile._fontObj:getHeight()

		obj.lineHighlight = Fill:new
		{
			x = obj.x,
			y = the.app.height - 100 + fontHeight * obj.lineContext,
			height = fontHeight,
			width = the.console.sidebarWidth,
			fill = {128, 128, 128}
		}
		obj:add(obj.lineHighlight)

		obj:add(obj.sourceFile)

		obj.sourceLines = Text:new
		{
			font = 11,
			x = obj.x,
			y = the.app.height - 100,
			width = 20
		}
		obj:add(obj.sourceLines)

		obj.sourceView = Text:new
		{
			font = 11,
			x = obj.x + 20,
			y = the.app.height - 100,
			width = the.console.sidebarWidth - 20
		}
		obj:add(obj.sourceView)

		Group.new(obj)
		return obj
	end,

	show = function (self)
		self.active = true
		self._fileCache = {}

		for _, spr in pairs(self.sprites) do
			spr.active = true
			spr.visible = true
		end
	end,

	showLine = function (self, file, line)
		if file then
			if not self._fileCache[file] then
				self._fileCache[file] = {}

				for line in love.filesystem.lines(file) do
					table.insert(self._fileCache[file], line)
				end
			end

			sourceLine = self._fileCache[file][line]

			self.sourceFile.text = file
			self.sourceLines.text = ''
			self.sourceView.text = ''

			for i = line - self.lineContext, line + self.lineContext do
				self.sourceLines.text = self.sourceLines.text .. i .. '\n'
				self.sourceView.text = self.sourceView.text .. string.gsub(self._fileCache[file][i], '\t', string.rep(' ', 20)) .. '\n'
			end
		else
			self.sourceView.text = '(source not available)'
		end
	end
}
