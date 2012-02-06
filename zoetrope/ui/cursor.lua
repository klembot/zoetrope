-- Class: Cursor
-- A cursor is a group that follows the user's cursor.

Cursor = Group:extend({
	hotspot = { x = 0, y = 0 },

	new = function (self, obj)
		obj = self:extend(obj)
		Current.cursor = obj
		if obj.onNew then obj:onNew() end
		return obj
	end,

	update = function (self, elapsed)
		-- follow the mouse

		self.translate.x = Current.mouse.x - self.hotspot.x
		self.translate.y = Current.mouse.y - self.hotspot.y
		
		Group.update(self, elapsed)
	end
})
