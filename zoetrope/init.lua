-- copy references to existing globals so that
-- debug.reload() will have a correct initial starting point.

if DEBUG then
	local _initialGlobals = {}

	for key, value in pairs(_G) do
		_initialGlobals[key] = value
	end

	debugger = { _initialGlobals = _initialGlobals }
end

-- Warn about accessing undefined globals in strict mode

if STRICT then
	setmetatable(_G, {
		__index = function (table, key)
			local info = debug.getinfo(2, 'Sl')
			print('Warning: accessing undefined global ' .. key .. ', ' ..
				  info.short_src .. ' line ' .. info.currentline)
		end
	})
end

require 'zoetrope.core.class'

require 'zoetrope.core.app'
require 'zoetrope.core.cached'
require 'zoetrope.core.globals'
require 'zoetrope.core.sprite'
require 'zoetrope.core.gamepad'
require 'zoetrope.core.group'
require 'zoetrope.core.keys'
require 'zoetrope.core.mouse'
require 'zoetrope.core.timer'
require 'zoetrope.core.tween'
require 'zoetrope.core.view'

require 'zoetrope.sprites.animation'
require 'zoetrope.sprites.emitter'
require 'zoetrope.sprites.fill'
require 'zoetrope.sprites.map'
require 'zoetrope.sprites.text'
require 'zoetrope.sprites.tile'

require 'zoetrope.ui.button'
require 'zoetrope.ui.cursor'
require 'zoetrope.ui.textinput'

require 'zoetrope.utils.debug'
require 'zoetrope.utils.factory'
require 'zoetrope.utils.recorder'
require 'zoetrope.utils.storage'
