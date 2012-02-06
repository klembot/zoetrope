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

require 'zoetrope.core.class'
require 'zoetrope.core.globals'
require 'zoetrope.core.group'
require 'zoetrope.core.keys'
require 'zoetrope.core.mouse'
require 'zoetrope.core.view'

App = Class:extend({
	-- Property: name
	-- This is shown in the window title bar.
	name = 'Zoetrope',
	
	-- Property: fps
	-- Maximum frames per second requested. In practice, your
	-- FPS may vary from frame to frame. Every event handler (e.g. onUpdate)
	-- is passed the exact elapsed time in seconds.
	fps = 60,
	
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

	new = function (self, obj)
		obj = self:extend(obj)
		
		obj.meta = obj.meta or Group:new()
		obj.view = obj.view or View:new()		
		
		obj.keys = obj.keys or Keys:new()
		obj.meta:add(obj.keys)
		obj.mouse = obj.mouse or Mouse:new()
		obj.meta:add(obj.mouse)
		
		obj.width = love.graphics.getWidth()
		obj.height = love.graphics.getHeight()
		
		Current.app = obj
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

	-- Method: toggleFullscreen
	-- Toggles fullscreen appearance. Sadly there's no way
	-- to tell whether we are fullscreen or not.
	--
	-- Arguments:
	-- 		none
	--
	-- Returns:
	--		nothing

	toggleFullscreen = function (self)
		love.graphics.toggleFullscreen()		
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
		-- if we are not active at all, sleep for a half-second

		if not self.active then
			love.timer.sleep(500)
			return
		end
		
		-- did our view change from under us?
		
		if Current.view ~= self.view then
			self.view = Current.viewc
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
		self.view:draw()
		self.meta:draw()
		if self.onDraw then self:onDraw() end
	end,

	onFocus = function (self, value)
		if self.deactivateOnBlur then
			self.active = value
		end
	end	
})
