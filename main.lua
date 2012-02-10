require 'tests.helloworld'
require 'tests.benchmark'
require 'tests.collisions'
require 'tests.emitters'
require 'tests.focus'
require 'tests.input'
require 'tests.maps'
require 'tests.scrolling'
require 'tests.sounds'
require 'tests.spritetypes'
require 'tests.timers'
require 'tests.tweens'
require 'tests.ui'

require 'zoetrope.utils.debugwatch'

function love.load()
	print 'Welcome to the Zoetrope test suite.'
	testApp = Sounds:new()
	testApp.meta:add(DebugWatch:new())
	testApp:run()
end
