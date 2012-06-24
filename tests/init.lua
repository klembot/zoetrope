require 'zoetrope'

TestApp = App:extend
{
	update = function (self, elapsed)
		if the.keys:pressed('escape') then
			the.app = Menu:new()
			the.app:run()
		end
		App.update(self, elapsed)

	end
}

require 'tests.benchmark'
require 'tests.collisions'
require 'tests.debugging'
require 'tests.emitters'
require 'tests.reuse'
require 'tests.files'
require 'tests.gamepad'
require 'tests.input'
require 'tests.maps'
require 'tests.recording'
require 'tests.scrolling'
require 'tests.sounds'
require 'tests.spritetypes'
require 'tests.tiled'
require 'tests.timers'
require 'tests.tweens'
require 'tests.ui'
