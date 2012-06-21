ViewFx = App:extend
{
	onUpdate = function (self)
		if the.keys:justPressed('r') then
			self.view:tint(255, 0, 0, 64)
		elseif the.keys:justPressed('g') then
			self.view:tint(0, 255, 0, 64)
		elseif the.keys:justPressed('b') then
			self.view:tint(0, 0, 255, 64)
		elseif the.keys:justPressed(' ') then
			self.view:tint()
		end

		if the.keys:justPressed('f') then
			self.view:fade{0, 0, 0}, 1, function() self.view:flash{0, 0, 0}, 1) end) 
		end
	end
}
