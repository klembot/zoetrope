-- Class: DebugHotkeys
--
-- This allows for debugging hotkeys -- e.g. you could set it so that
-- pressing Control-Alt-I toggles invincibility of the player sprite.
-- Out of the box:
--		- Control-Alt-F toggles fullscreen
--		- Control-Alt-Q quits the app.
--		- Control-Alt-P deactivates the view.
-- 		- Control-Alt-R reloads all app code from on disk.
--		- Control-Alt-S saves a screenshot to the app's directory --
--		  see https://love2d.org/wiki/love.filesystem for where this is.

DebugHotkeys = Sprite:extend
{
	-- Property: modifiers
	-- A table of modifier keys that must be held in order to activate
	-- a debugging hotkey (set via <add()>). If you want hotkeys to
	-- activate without having to hold any keys down, set this to nil.
	modifiers = {'ctrl', 'alt'},

	-- internal property: _hotkeys
	-- A table with entries that have key (triggering key) and func
	-- (function to run) properties.
	_hotkeys = {},

	visible = false,

	new = function (self, obj)
		obj = self:extend(obj or {})

		obj:add('f', function() the.app:toggleFullscreen() end)
		obj:add('p', function()
			the.view.active = not the.view.active
			if the.view.active then
				the.view:tint()
			else
				the.view:tint(0, 0, 0, 200)
			end
		end)
		obj:add('q', love.event.quit)
		if debugger then obj:add('r', debugger.reload) end
		obj:add('s', function() the.app:saveScreenshot('screenshot.png') end)

		if obj.onNew then obj.onNew() end
		return obj
	end,

	add = function (self, key, func)
		table.insert(self._hotkeys, { key = key, func = func })
	end,

	update = function (self, elapsed)
		local modifiers = (self.modifiers == nil)

		if not modifiers then
			modifiers = true

			for _, key in pairs(self.modifiers) do
				if not the.keys:pressed(key) then
					modifiers = false
					break
				end
			end
		end

		if modifiers then
			for _, hotkey in pairs(self._hotkeys) do
				if the.keys:justPressed(hotkey.key) then
					hotkey.func(hotkey.key)
				end
			end
		end
	end
}
