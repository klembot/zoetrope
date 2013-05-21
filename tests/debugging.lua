require 'zoetrope'

Debugging = TestApp:extend
{
	onRun = function (self)
		the.block = self:add(Fill:new{ x = 300, y = 200, width = 200, height = 200, fill = {255, 255, 255 } })
		debugger.watch('the.block.x')
		debugger.watch('the.block.y')

		self:add(Text:new
		{
			x = 10, y = 500, width = 650, font = 14,
			text = 'Press the tab key to bring up the debug console, which displays recently printed ' ..
				   'text. You can enter any Lua statement -- the.block.width = 50, for example -- and ' ..
				   'also watch values. Try entering the.console:watch("mouse x", "the.mouse.x"). ' ..
				   'The console supports command history with the up and down arrow keys, and will ' ..
				   'activate if your app crashes (hit Ctrl-D to try this out). You can also force ' ..
				   'LOVE to reload your code from on disk and restart your app by pressing ' ..
				   'Ctrl-Alt-R (Ctrl-Option-R on a Mac). You can also add your own debugging hotkeys.'
		})
	end,

	onUpdate = function (self)
		if the.keys:justPressed('d') and the.keys:pressed('ctrl') then
			local testLocal = 'a string'
			local testLocal2 = 23
			local testLocal3 = true

			error('testing error handler')
		end

		if the.keys:justPressed('b') and the.keys:pressed('ctrl') then
			debugger.breakpt()
			local a = 1
			local b = 2
			local c = a + b
			print(c)
		end
	end
}
