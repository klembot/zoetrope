require 'zoetrope'

HelloWorld = App:extend({ name = 'Hello World' })

function HelloWorld:onRun()
	print('This just tests the Zoetrope app framework.')
end

function HelloWorld:onDraw()
	love.graphics.print('Hello, world.', 4, 4)
end
