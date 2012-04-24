require 'zoetrope'

UI = App:extend({
	name = 'UI Test',
	
	cursorImage = 'tests/assets/bluegem.png',

	onRun = function (self)
		local cursor = Cursor:new()
		cursor:add(Tile:new({ image = self.cursorImage, width = 16, height = 16 }))
		the.mouse.useKeyboard = true

		local button = Button:new({ x = 100, y = 100, width = 100, height = 24 })
		button.background = Fill:new({ width = 100, height = 24, fill = { 0, 0, 255 } })
		button.label = Text:new({ text = 'Hello', width = 100 })
		button.label:centerAround(button.background.width / 2, button.background.height / 2)

		button.onMouseEnter = function (self)
			self.background.fill = { 255, 0, 0 }
		end

		button.onMouseExit = function (self)
			self.background.fill = { 0, 0, 255 }
		end

		button.onMouseUp = function (self)
			self.x = math.random(0, the.app.width - self.width)
			self.y = math.random(0, the.app.height - self.height)
		end

		DebugWatch:new()
		the.watch:addWatch('mouse clicked', 'the.mouse.thisFrame.l == true')

		self:add(button)
		self:add(cursor)
		self:useSysCursor(false)
	end
})
