
-- Choice lines are like
-- '*cart/node the text'
-- '*./node the text' for relative links
function parseChoiceLine(choiceLine)
	local linkCart = ''
	local linkNode = ''
	local linkText = ''
	-- TODO remove
	assert(choiceLine[1] == '*')

	local state = 'cart'
	for i = 2, #choiceLine do
		local char = choiceLine[i]
		if state == 'cart' then
			if char == '/' then
				state = 'node'
			else
				linkCart ..= char
			end
		elseif state == 'node' then
			if char == ' ' then
				state = 'text'
			else
				linkNode ..= char
			end
		elseif state == 'text' then
			linkText ..= char
		end
	end
	-- todo remove
	assert(state == 'text')
	return {
		cart = linkCart,
		node = linkNode,
		text = linkText
	}
end

function parseTextList(textList)
	local ret = {}
	local dialogBlock = nil
	isDialog = false
	-- add(textList, '')

	for line in all(textList) do
		if line[1] == '*' then
			if isDialog then
				add(dialogBlock, parseChoiceLine(line))
			else
				isDialog = true
				dialogBlock = {
					parseChoiceLine(line),
					['choiceindex'] = 1
				}
			end
		else
			if isDialog then
				-- exiting dialog block
				add(ret, dialogBlock)
				isDialog = false
				dialogBlock = nil
				add(ret, line)
			else
				-- still no dialog
				add(ret, line)
			end
		end
	end
	if isDialog then
		add(ret, dialogBlock)
	end

	return ret
end

function makeTextGame(textList, node_id)
	-- for entry in all(textList) do
	-- 	assert(type(entry)!='string')
	-- end

	local ret = makeGame(
		function()end,
		function(self)
			self.textList = parseTextList(textList)
			self.textIndexStart = 1
			self.textIndexEnd = 1
			self.updateChoiceIndex = function(self, delta)
				if self:isChoice() then
					self:lastNode().choiceindex = mid(1, self:lastNode().choiceindex + delta, #self:lastNode())
				else
					-- TODO remove...
					assert(false)
				end
			end
			self.isChoice = function(self)
				-- TODO maybe add a type attribute
				return type(self:lastNode()) == 'table'
				-- index = index or self.textIndexStart
				-- if index > #self.textList then
				-- 	return false
				-- end
				-- -- TODO check for an image
				-- return self.textList[index][1] == '*'
			end
			self.lastNode = function(self)
				return self.textList[self.textIndexEnd]
			end
			self.selectedChoice = function(self)
				local node = self:lastNode()
				assert(type(node) == 'table')
				return node[node.choiceindex]
			end
			-- all lines to display
			-- note: a line could be a dialog block or image
			self.curText = function(self)
				local ret = {}
				for i = self.textIndexStart, self.textIndexEnd do
					add(ret, self.textList[i])
				end
				return ret
			end
		end,
		function(self)
			cls()
			for line in all(self:curText()) do
				if type(line) == 'string' then
					print(line)
				else
					-- have a table. Must be choice
					for i = 1, #line do
						local choice = line[i]
						if i == line.choiceindex then
							print('> '..choice.text)
						else
							print('  '..choice.text)
						end
					end
				end
			end
		end,

		function(self)
			if self:isChoice() then
				self:updateChoiceIndex(tonum(btnp(dirs.down))-tonum(btnp(dirs.up)))
				if btnp(dirs.x) then
					-- Oh boy, they made a choice
					local choice = self:selectedChoice()
					-- TODO this is def gonna bite me
					self.isGameOver = true
					self.choice = choice
				end
			end

			if btnp(dirs.x) then
				self.textIndexEnd += 1
				if self.textList[self.textIndexEnd] == nextpage then
					self.textIndexStart = self.textIndexEnd + 1
					self.textIndexEnd = self.textIndexStart
				end
				if self.textIndexEnd > #self.textList then
					self.isGameOver = true
				end
				-- if self:isChoice() then
				-- 	self.textIndexEnd = self.textIndexStart
				-- 	while self:isChoice(self.textIndexEnd) do
				-- 		self.textIndexEnd += 1
				-- 	end
				-- end
			end
		end
		)

	ret.node_id = node_id
	return ret
end


function _update()
	gs:activateGame()
	gs:getActiveGame():update()
	if gs:getActiveGame().isGameOver then
		local choice = gs:getActiveGame().choice
		if choice == nil then
			gs:activateNextGame()
		else
			gs:navigateToChoice(choice)
		end
	end
	-- if not gs:getActiveGame()
	-- if gs.isGameOver then
	-- 	if gs.endTime == nil then
	-- 		gs.endTime = t()
	-- 	end
	-- 	-- Restart
	-- 	if btnp(dirs.x) then
	-- 		_init()
	-- 	end
	-- 	return
	-- end

	-- if hasAnimation() then
	-- 	local active, exception = coresume(gs.currentAnimation)
	-- 	if exception then
	-- 		stop(trace(gs.currentAnimation, exception))
	-- 	end

	-- 	return
	-- end

	-- acceptInput()

end

-- function drawGameOverWin()

-- end

-- function drawGameOverLose()

-- end

nextpage = '<NEXTPAGE>'
gs = nil


dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

function makeGame(injectgame, init, draw, update)
	return {
		isInitialized = false,
		injectgame = injectgame,
		init = init,
		draw = draw,
		update = update,
		isGameOver = false,
		gameOverState = nil,
		startTime = t(),
		endTime = nil,
		currentAnimation = nil
	}
end

function _init()
	gs = {
		activeGameIndex = 1,
		getActiveGame = function(self)
			return self.games[self.activeGameIndex]
		end,
		activateGame = function(self, game)
			game = game or self:getActiveGame()
			if not game.isInitialized then
				game:injectgame()
				game:init()
				game.isInitialized = true
			end
		end,
		activateNextGame = function(self)
			self.activeGameIndex += 1
			if self.activeGameIndex > #self.games then
				self.activeGameIndex = -1
			end
		end,
		navigateToChoice = function(self, choice)
			-- TODO handle loading a different cart
			assert(choice.cart == '.')
			for i = 1, #self.games do
				-- print(choice.node)
				-- print(self.games[i].node_id)
				if self.games[i].node_id == choice.node then
					-- Ugh this is bad...
					self:getActiveGame().isGameOver = false
					self:getActiveGame().isInitialized = false
					self.activeGameIndex = i
					break
				end
			end
			-- assert(false)
		end
	}

	gs.games = chapter_init()
end

function _draw()
	-- if btnp(dirs.x) then
	-- 	reload(0,0,0x8000,'image-text.p8')
	-- end
	-- if btnp(dirs.z) then
	-- 	reload(0,0,0x8000,'image-text3.p8')
	-- end
	-- cls()
	-- spr(0,0,0,16,16)
	-- if true then return end
	if not gs:getActiveGame().isInitialized then
		return
	end
	gs:getActiveGame():draw()
	-- cls(0)
	-- if gs.isGameOver then
	-- 	if gs.gameOverState == gameOverWin then
	-- 		drawGameOverWin()
	-- 	else
	-- 		drawGameOverLose()
	-- 	end
	-- 	return
	-- end

	-- Draw
end