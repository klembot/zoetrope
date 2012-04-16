require 'zoetrope'

RedParticle = Fill:extend({ width = 16, height = 16, fill = { 255, 0, 0, 128 } })

Emitters = App:extend({
	title = 'Particle Emitter',

	onRun = function (self)
		print("This demonstrates Zoetrope's particle emitter class. Press the space bar " ..
			  "to launch all 1200 particles at once.")
	end,

	onNew = function (self)
		self.emitter = Emitter:new({ x = 350, y = 250, width = 100, height = 100 })
		self.emitter.min = { velocity = { x = -500, y = -500, rotation = math.pi / 4 }, alpha = 0.25 }
		self.emitter.max = { velocity = { x = 500, y = 500, rotation = 4 * math.pi }, alpha = 0.75 }
		self.emitter.period = 0.05

		for i = 1, 400 do
			self.emitter:add(Fill:new({ width = 16, height = 16, fill = { 0, 0, 255, 128 }}))
		end

		self.emitter:loadParticles(RedParticle, 400)
		self.emitter:loadParticles(RedParticle:extend({ fill = { 0, 255, 0, 128 } }), 400)

		self:add(self.emitter)
	end,

	onUpdate = function (self, elapsed)
		if the.keys:justPressed(' ') then
			self.emitter:emit(#self.emitter.sprites)
		end
	end
})
