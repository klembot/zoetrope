-- Class: DebugInstrument
-- This is a container that manages the location and size of debug instruments
-- onscreen. This also creates a title bar and framed content area.
--
-- Event: onResize
--		Responsible for setting the dimensions of all member sprites. Receives
--		x, y, width, and height arguments. This *must* be defined in order for
--		an instrument to be drawn properly. You do not need to resize the built-in
--		frame, titleBar, and title properties in this handler -- that is taken care
--		of for you.
--
--		An instrument is guaranteed to receive this event at least once before it
--		appears onscreen, so there is no need to set up dimensions of sprites anywhere
--		but here.
--
-- Extends:
-- 		<Group>

DebugInstrument = Group:extend
{
	-- Property: contentHeight
	-- Set by the instrument to indicate how much vertical space it wants.
	-- Changing this causes the debugger to recalculate layout for all instruments.
	-- A '*' indicates that it wants all available space. If the instrument
	-- doesn't want to be considered for layout, then it should set its visible
	-- property to false.
	contentHeight = 0,

	-- Property: width
	-- Should be either 'wide' or 'narrow', *not* a pixel width. This must
	-- be set when the instrument is created, and cannot be changed.
	width = 'narrow',

	-- Property: innerBorderColor
	-- Property: outerBorderColor
	-- Property: backgroundColor
	-- Property: titleBarColor
	-- Property: titleColor
	-- Color properties to customize appearance. These must be set when the
	-- instrument is created, and cannot be changed.
	outerBorderColor = {0, 0, 0},
	innerBorderColor = {255, 255, 255},
	backgroundColor = {0, 0, 0, 200},
	titleBarColor = {255, 255, 255},
	titleColor = {0, 0, 0},

	-- Property: spacing
	-- A recommended number of pixels to inset content or otherwise use
	-- as spacing, for consistency. You can ignore this if you like.
	spacing = 5,

	-- Property: titleBarHeight
	-- How tall the title bar should be. This must be set when the instrument
	-- is created, and cannot be changed.
	titleBarHeight = 20,

	-- Property: font
	-- Recommended font, for consistency.

	-- Property: outerFrame
	-- The <Fill> used to draw the outer frame of the instrument.

	-- Property: innerFrame
	-- The <Fill> used to draw the inner frame and background of the instrument.

	-- Property: titleBar
	-- The <Fill> used to draw the background of the title bar.

	-- Property: title
	-- The <Text> used to draw the instrument title on the title bar.

	new = function (self, obj)
		obj = self:extend(obj or {})

		if obj.width == 'wide' then
			obj.font = 12
		else
			obj.font = 11
		end

		obj.outerFrame = Fill:new{ width = 0, height = 0, border = obj.outerBorderColor, fill = {0, 0, 0, 0} }
		obj.innerFrame = Fill:new{ width = 0, height = 0, border = obj.innerBorderColor, fill = obj.backgroundColor }
		obj.titleBar = Fill:new{ width = 0, height = obj.titleBarHeight, fill = obj.titlebarColor }
		obj.title = Text:new{ width = 0, height = 0, fill = obj.titlebarColor, font = obj.font,
		                      tint = {obj.titleColor[1] / 255, obj.titleColor[2] / 255, obj.titleColor[3] / 255}}
		obj:add(obj.outerFrame)
		obj:add(obj.innerFrame)
		obj:add(obj.titleBar)
		obj:add(obj.title)

		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: resize
	-- Tells the instrument to resize itself to match the dimensions passed.
	--
	-- Arguments:
	--		x - x coordinate in pixels
	--		y - y coordinate in pixels
	--		width - width in pixels
	--		height - height in pixels
	--
	-- Returns:
	--		nothing

	resize = function (self, x, y, width, height)
		self.outerFrame.x = x - 1
		self.outerFrame.y = y - 1
		self.outerFrame.width = width + 2
		self.outerFrame.height = height + 2

		self.innerFrame.x = x
		self.innerFrame.y = y
		self.innerFrame.width = width
		self.innerFrame.height = height

		self.titleBar.x = x
		self.titleBar.y = y
		self.titleBar.width = width

		local titleHeight = self.title._fontObj:getHeight()
		local titleInset = (self.titleBarHeight - titleHeight) / 2
		self.title.x = self.titleBar.x + titleInset
		self.title.y = self.titleBar.y + titleInset
		self.title.width = width - titleInset * 2
		self.title.height = titleHeight

		if self.onResize then
			self:onResize(x, y + self.titleBarHeight, width, height - self.titleBarHeight)
		end
	end,

	-- Method: totalHeight
	-- Returns the total height of the instrument, including the title bar.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		pixel height, 0 if no display wanted, or '*' (for maximum height available)

	totalHeight = function (self)
		if self.contentHeight == 0 or self.contentHeight == '*' then
			return self.contentHeight
		else
			return self.contentHeight + self.titleBarHeight
		end
	end
}

-- Class: DebugInstrumentButton
-- A convenience class to keep the appearance of buttons in instruments consistent.

DebugInstrumentButton = Button:extend
{
	width = 75,
	height = 25,

	new = function (self, obj)
		obj = self:extend(obj or {})

		obj.background = Fill:new
		{
			width = self.width, height = self.height,
			fill = {0, 0, 0, 64},
			border = {255, 255, 255}
		}

		obj.label = Text:new
		{
			width = self.width, height = self.height,
			align = 'center',
			y = 5,
			font = DebugInstrument.font,
			text = obj.label
		}

		Button.new(obj)
		return obj
	end,

	onMouseEnter = function (self)
		self.background.fill = { 128, 128, 128, 200 }
	end,

	onMouseExit = function (self)
		self.background.fill = {0, 0, 0, 64 }
	end
}
