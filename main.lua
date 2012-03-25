require 'tests'
require 'menu'

function love.load()
	print 'Welcome to the Zoetrope test suite.'
	testApp = Menu:new()
	testApp:run()
end
