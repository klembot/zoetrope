StorageApp = App:extend({
	onRun = function (self)
		self.storage = Storage:new({ filename = 'test.dat' })
		self.storage.data.count = self.storage.data.count or 0
		self.storage.data.count = self.storage.data.count + 1
		self.storage:save()

		self:add(Text:new({ x = 4, y = 4, width = 500,
							text = 'You have loaded this test ' ..
							self.storage.data.count .. ' times.' }))
	end
})
