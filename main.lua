require 'tests'
require 'zoetrope.utils.debugwatch'

function love.load()
	print 'Welcome to the Zoetrope test suite.'
	testApp = Input:new()
	testApp.meta:add(DebugWatch:new())
	testApp:run()
end
