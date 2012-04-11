-- Class: DebugWatch
-- A debug watch displays the value of an expression each frame.
-- It can be used to keep track of fps, the position of a sprite,
-- and so on. It only updates when visible.

DebugWatch = Group:extend({
	-- Property: toggleKey
	-- What key toggles visibility. By default, this is the tilde key.
	toggleKey = '`',

	-- Property: initWithFPS
	-- If true, the watch will automatically start watching the frames
	-- per second. Changing this value after the DebugWatch object has
	-- been created has no effect.
	initWithFPS = true,

	-- Property: fill
	-- Background color of the text.
	fill = { 0, 0, 0, 200 },

	new = function (self, obj)
		obj = self:extend(obj)
		
		obj.visible = false
		obj.watches = {}
		obj.lineHeight = OutlineText.defaultFont:getHeight()
		
		obj.fill = Fill:new({ width = the.app.width, fill = self.fill })
		obj.text = OutlineText:new({ width = the.app.width,
								   height = the.app.height })
		obj:add(obj.fill)
		obj:add(obj.text)
		
		if obj.initWithFPS then
			obj:addWatch('FPS', 'love.timer.getFPS()')
		end
		
		the.watch = obj
		if obj.onNew then obj.onNew() end
		return obj
	end,

	-- Method: addWatch
	-- Adds an expression to be watched.
	--
	-- Arguments:
	--		label - string label
	--		expression - expression to evaluate as a string

	addWatch = function (self, label, expression)
		table.insert(self.watches, { label = label,
									 func = loadstring('return ' .. expression) })
		self.fill.height = self.lineHeight * #self.watches
	end,

	--- Toggles visibility and updates watch expressions.

	update = function (self, elapsed)
		if the.keys:justPressed(self.toggleKey) then
			self.visible = not self.visible
		end
		
		if self.visible then
			self.text.text = ''
		
			for _, watch in pairs(self.watches) do
				self.text.text = self.text.text .. watch.label ..
								 ': ' .. tostring(watch.func()) .. '\n'
			end
		end
		
		Group.update(self, elapsed)
	end
})
