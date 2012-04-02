-- Class: App 
-- An app is where all the magic happens. :) It contains a 
-- view, the group where all major action happens, as well as the
-- meta view, which persists across views. Only one app may run at
-- a time.
--
-- An app's job is to get things up and running -- most of its logic
-- lives in its onRun handler, but for a simple app, you can also
-- use the onUpdate handler instead of writing a custom <View>.
-- 
-- Once an app has begun running, it may be accessed globally via
-- <Current>.app.
--
-- Extends:
--  	<Class>
--
-- Event: onRun
-- 		Called once, when the app begins running.

App = Class:extend({
	-- Property: name
	-- This is shown in the window title bar.
	name = 'Zoetrope',
	
	-- Property: fps
	-- Maximum frames per second requested. In practice, your
	-- FPS may vary from frame to frame. Every event handler (e.g. onUpdate)
	-- is passed the exact elapsed time in seconds.
	fps = 60,

	-- Property: timeScale
	-- Multiplier for elapsed time; 1.0 is normal, 0 is completely frozen.
	timeScale = 1,
	
	-- Property: active
	-- If false, nothing receives update-related events, including the meta view.
	-- These events specifically are onStartFrame, onUpdate, and onEndFrame.
	active = true,

	-- Property: deactivateOnBlur
	-- Should the app automatically set its active property to false when its
	-- window loses focus?
	deactivateOnBlur = true,
	
	-- Property: view
	-- The current <View>. When the app is running, this is also accessible
	-- globally via <Current>.view.

	-- Property: meta
	-- A <Group> that persists across all views during the app's lifespan.

	-- Property: keys
	-- A <Keys> object that listens to the keyboard. When the app is running, this
	-- is also accessible globally via <Current>.keys.

	-- Property: width
	-- The width of the window in pixels. Changing this value has no effect. To
	-- set this for real, edit conf.lua. 

	-- Property: height
	-- The height of the window in pixels. Changing this value has no effect. To
	-- set this for real, edit conf.lua.

	-- Property: fullscreen
	-- Whether the app is currently running in fullscreen mode. Changing this value
	-- has no effect. To change this, use the enterFullscreen(), exitFullscreen(), or
	-- toggleFullscreen() methods.

	-- Property: inset
	-- The screen coordinates where the app's (0, 0) origin should lie. This is only
	-- used by Zoetrope to either letterbox or pillar fullscreen apps, but there may
	-- be other uses for it.
	inset = { x = 0, y = 0},

	new = function (self, obj)
		obj = self:extend(obj)
	
		-- view containers

		obj.meta = obj.meta or Group:new()
		obj.view = obj.view or View:new()		
		
		-- input

		obj.keys = obj.keys or Keys:new()
		obj.meta:add(obj.keys)
		obj.mouse = obj.mouse or Mouse:new()
		obj.meta:add(obj.mouse)
		
		-- screen dimensions and state

		local conf = { screen = {}, modules = {} }
		love.conf(conf)

		obj.width = conf.screen.width or 800
		obj.height = conf.screen.height or 600
		obj.fullscreen = conf.screen.fullscreen or false

		-- housekeeping
		
		the.app = obj
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: run
	-- Starts the app running. Nothing will occur until this call.
	--
	-- Arguments:
	-- 		none
	-- 
	-- Returns:
	--		nothing

	run = function (self)
		math.randomseed(os.time())
		if self.onRun then self:onRun() end
		
		love.graphics.setCaption(self.name)
		love.update = function (elapsed) self:update(elapsed) end
		love.draw = function() self:draw() end
		love.focus = function (value) self:onFocus(value) end	
	end,
	
	-- Method: quit
	-- Quits the application immediately.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	quit = function (self)
		love.event.push('q')
	end,

	-- Method: useSysCursor
	-- Shows or hides the system mouse cursor.
	--
	-- Arguments:
	--		value - show the cursor?
	--
	-- Returns:
	--		nothing
	
	useSysCursor = function (self, value)
		love.mouse.setVisible(value)
	end,

	enterFullscreen = function (self, hint)
		local modes = love.graphics.getModes()

		if not hint then
			if self.width * 9 == self.height * 16 then
				hint = 'letterbox'
			elseif self.width * 3 == self.height * 4 then
				hint = 'pillar'
			end
		end

		-- find the mode with the highest screen area that
		-- matches either width or height, according to our hint

		local bestMode = { area = 0 }

		for _, mode in pairs(modes) do
			mode.area = mode.width * mode.height

			if (mode.area > bestMode.area) and 
			   ((hint == 'letterbox' and mode.width == self.width) or
			    (hint == 'pillar' and mode.height == self.height)) then
					bestMode = mode
			end
		end

		-- if we found a match, switch to it

		assert(bestMode.width, 'this app\'s width and height are not supported in fullscreen on this screen')
		love.graphics.setMode(bestMode.width, bestMode.height, true)
		self.fullscreen = true

		-- and adjust inset and scissor

		self.inset.x = math.floor((bestMode.width - self.width) / 2)
		self.inset.y = math.floor((bestMode.height - self.height) / 2)
		love.graphics.setScissor(self.inset.x, self.inset.y, self.width, self.height)
	end,

	exitFullscreen = function (self)
		love.graphics.setMode(self.width, self.height, false)
		love.graphics.setScissor(0, 0, self.width, self.height)
		self.fullscreen = false
		self.inset.x = 0
		self.inset.y = 0
	end,

	toggleFullscreen = function (self)
		if self.fullscreen then
			self:exitFullscreen()
		else
			self:enterFullscreen()
		end
	end,

	saveScreenshot = function (self, filename)
		local screenshot = love.graphics.newScreenshot()
		local data = screenshot:encode('bmp')
		love.filesystem.write(filename, data)
	end,

	-- Method: add
	-- A shortcut for adding a sprite to the app's view.
	--
	-- Arguments:
	--		sprite - sprite to add
	-- 
	-- Returns:
	--		nothing

	add = function (self, sprite)
		self.view:add(sprite)
	end,

	-- Method: remove
	-- A shortcut for removing a sprite from the app's view.
	--
	-- Arguments:
	--		sprite - sprite to remove
	--
	-- Returns: nothing

	remove = function (self, sprite)
		self.view:remove(sprite)
	end,

	update = function (self, elapsed)
		elapsed = elapsed * self.timeScale

		-- if we are not active at all, sleep for a half-second

		if not self.active then
			love.timer.sleep(500)
			return
		end
		
		-- did our view change from under us?
		
		if the.view ~= self.view then
			self.view = the.view
		end

		-- update everyone
		-- app gets precedence, then meta view, then view

		if self.onStartFrame then self:onStartFrame(elapsed) end
		self.meta:startFrame(elapsed)
		
		self.view:startFrame(elapsed)
		self.view:update(elapsed)	
		self.meta:update(elapsed)
		if self.onUpdate then self:onUpdate(elapsed) end

		self.view:endFrame(elapsed)
		self.meta:endFrame(elapsed)
		if self.onEndFrame then self:onEndFrame(elapsed) end
		
		-- if we're going faster than our max fps, sleep it off
		
		if elapsed < 1 / self.fps then
			love.timer.sleep(1000 * (1 / self.fps - elapsed))
		end
	end,
	
	draw = function (self)
		local inset = self.inset.x ~= 0 or self.inset.y ~= 0

		if inset then love.graphics.translate(self.inset.x, self.inset.y) end
		self.view:draw()
		self.meta:draw()
		if self.onDraw then self:onDraw() end
		if inset then love.graphics.translate(0, 0) end
	end,

	onFocus = function (self, value)
		if self.deactivateOnBlur then
			self.active = value
		end
	end	
})
