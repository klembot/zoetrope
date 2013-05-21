-- Class: DebugShortcuts
--
-- This allows for debugging shortcuts that perform tasks that aid 
-- debugging -- e.g. skipping to a certain level or making a player sprite
-- invincible. These can be triggered by a hotkey at any time, or appear
-- in a list in the debug console.
--
-- Out of the box:
--		- Control-Alt-F toggles fullscreen
--		- Control-Alt-Q quits the app.
--		- Control-Alt-P deactivates the view.
-- 		- Control-Alt-R reloads all app code from on disk.
--		- Control-Alt-S saves a screenshot to the app's directory --
--		  see https://love2d.org/wiki/love.filesystem for where this is.

DebugShortcuts = DebugInstrument:extend
{
	width = 'narrow',
	visible = false,

	-- Property: modifiers
	-- A table of modifier keys that must be held in order to activate
	-- a debugging hotkey (set via <add()>). If you want hotkeys to
	-- activate without having to hold any keys down, set this to nil.
	modifiers = {'ctrl', 'alt'},

	-- internal property: _shortcuts
	-- A table with entries that have desc (long description), key
	-- (triggering key) and func (function to run) properties.
	_shortcuts = {},

	-- internal property: _buttons
	-- An ordered table of shortcut buttons.
	_buttons = {},

	onNew = function (self)
		self.title.text = 'Shortcuts'

		self:addShortcut('Fullscreen', 'f', function() the.app:toggleFullscreen() end)

		self:addShortcut('Pause', 'p', function()
			the.view.active = not the.view.active
			if the.view.active then
				the.view:tint()
			else
				the.view:tint(0, 0, 0, 200)
			end
		end)

		self:addShortcut('Quit', 'q', love.event.quit)

		if self.reload then
			self:addShortcut('Reload Code', 'r', self.reload)
		end

		self:addShortcut('Save Screenshot', 's', function()
			if debugger.console.visible then
				debugger.hideConsole()
				the.view.timer:after(0.05, bind(the.app, 'saveScreenshot', 'screenshot.png'))
				the.view.timer:after(0.1, debugger.showConsole)
			else
				the.app:saveScreenshot('screenshot.png')
			end
		end)

		debugger.addListener(bind(self, 'listen'))
		debugger.addShortcut = function (desc, key, func) self:addShortcut(desc, key, func) end
		debugger.setShortcutModifiers = function (...) self.modifiers = {...} end
	end,

	addShortcut = function (self, desc, key, func)
		table.insert(self._shortcuts, { desc = desc, key = key, func = func })

		local label = desc

		if key then
			label = label .. ' (' .. key .. ')'
		end

		local button = self:add(DebugInstrumentButton:new
		{
			label = label,
			onMouseUp = func
		})

		button.label.font = 11
		button.label.y = 6
		button.background.height = 24
		
		table.insert(self._buttons, button)

		self.contentHeight = #self._buttons * (DebugInstrumentButton.height + self.spacing) + 2 * self.spacing

		self.visible = true
	end,

	listen = function (self)
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
			for _, shortcut in pairs(self._shortcuts) do
				if the.keys:justPressed(shortcut.key) then
					shortcut.func(shortcut.key)
				end
			end
		end
	end,

	onResize = function (self, x, y, width, height)
		y = y + self.spacing 
		x = x + self.spacing
		width = width - self.spacing * 2

		for _, spr in pairs(self._buttons) do
			spr.x = x
			spr.y = y
			spr.background.width = width
			spr.label.width = width
		
			y = y + DebugInstrumentButton.height + self.spacing
		end

	end
}
