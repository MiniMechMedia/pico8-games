
-- TODO parameterize this???
cartdata('mmm_project_titan')

reply = '    ' --'\^jf0'

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

function makeBranch(branch)
	-- branch.evalText = function(storyState) 
	-- 	return branch[storyState.initReaction]
	-- end

	-- return branch
	return {
		raw = branch,
		type = 'branch',
		evalNode = function(self, storyState)
			return parseTextList({
				self.raw[storyState.initReaction]
			})[1]
		end
		-- evalText = function(self, storyState)

		-- 	return self.raw[storyState.initReaction]
		-- end
	}
end

function makeImage(img)
	local hash = 0
	for i = 1, #img do
		hash = hash * 2.142352 + 5.33893825 * ord(img[i])
	end
	return {
		img = img,
		hash = hash,
		type = 'img'
	}
end

function parseTextList(textList)
	local ret = {}
	local dialogBlock = nil
	isDialog = false
	-- add(textList, '')
	local imageInPage = false
	for line in all(textList) do
		if type(line) == 'table' then
			add(ret, makeBranch(line))
		elseif type(line) != 'string' then
			assert('type is not string' == 'bad')
		elseif #line > 1000 then
			assert(not imageInPage)
			imageInPage = true
			add(ret, makeImage(line))
		elseif line[1] == '*' then
			if isDialog then
				add(dialogBlock, parseChoiceLine(line))
			else
				isDialog = true
				dialogBlock = {
					parseChoiceLine(line),
					type='choice',
					['choiceindex'] = 1
				}
			end
			-- Note, may need to refine this later
			-- if we add context-choices
			imageInPage = false
		else
			if isDialog then
				-- exiting dialog block
				add(ret, dialogBlock)
				isDialog = false
				dialogBlock = nil
				add(ret, line)
			else
				-- still no dialog
				if line == nextpage then
					imageInPage = false
				end
				-- TODO should think through implications of this
				if line != ignore then
					add(ret, line)
				end
			end
		end
	end
	if isDialog then
		if #dialogBlock == 1 and dialogBlock[1].text == '' then
			dialogBlock.isGoTo = true
		end
		add(ret, dialogBlock)
	end

	return ret
end

-- function assertTextListValid(textList)

-- end



function makeTextGame(textList, node_id, is_terminal)
	-- for entry in all(textList) do
	-- 	assert(type(entry)!='string')
	-- end

	local ret = makeGame(
		function()end,
		function(self)
			self.getStoryState = function()
				-- TODO
				return {
					initReaction = readReaction()
				}
			end
			self.printLine = function(self, text)
				if (text != pause) print(text, 7)
			end
			self.is_terminal = is_terminal
			if self.is_terminal then
				add(textList, '*chapter1/intro play again')
				-- add(self.textList, '*chapter1/intro play again')
			end
			self.shouldAdvance = function(self)
				local node = self:lastNode()
				local next = self:getNodeAt(self.textIndexEnd + 1)
				if type(node) == 'string' and type(next) == 'string' then
					if next != nextpage and next != pause then
						return true
					end
				end
				return false
			end
			self.textList = parseTextList(textList)
			-- assertTextListValid(self.textList)
			self.textIndexStart = 1
			self.textIndexEnd = 1
			self.updateChoiceIndex = function(self, delta)
				if self:isChoice() then
					self:lastNode().choiceindex = mid(1, self:lastNode().choiceindex + delta, #self:lastNode())
				else
					-- TODO remove...
					assert('idk' == 'bad')
				end
			end
			self.isGoTo = function(self)
				return self:isChoice() and self:lastNode().isGoTo
			end
			self.isChoice = function(self)
				-- TODO maybe add a type attribute
				return type(self:lastNode()) == 'table' and self:lastNode().type == 'choice'
				-- index = index or self.textIndexStart
				-- if index > #self.textList then
				-- 	return false
				-- end
				-- -- TODO check for an image
				-- return self.textList[index][1] == '*'
			end
			self.getNodeAt = function(self, index)
				if (self.textList[index] == nil) return nil
				return self:getEvaluated(self.textList[index])
			end
			self.lastNode = function(self)
				return self:getNodeAt(self.textIndexEnd)
			end
			self.getEvaluated = function(self, node)
				if node.type == 'branch' then
					return node:evalNode(self:getStoryState())
				else
					return node
				end
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
					add(ret, self:getEvaluated(self.textList[i]))
				end
				return ret
			end
		end,
		-- draw
		function(self)
			cls()
			for line in all(self:curText()) do
				if type(line) == 'string' then
					self:printLine(line)
				elseif line.isGoTo then
					-- nothing
				elseif line.type == 'choice' then
					for i = 1, #line do
						local choice = line[i]
						if i == line.choiceindex then
							print('> '..choice.text)
						else
							print('  '..choice.text)
						end
					end
				elseif line.type == 'img' then
					load_img(line)
					-- print(line.hash)
					spr(0,0,0,16,16)
				-- elseif line.type == 'branch' then
				-- 	self:printLine(line:evalText(self:getStoryState()))
				else
					assert('' == 'asdf')
				end
			end
		end,
		-- update
		function(self)
			if self:isChoice() then
				self:updateChoiceIndex(tonum(btnp(dirs.down))-tonum(btnp(dirs.up)))
				if btnp(dirs.x) or self:isGoTo() then
					-- Oh boy, they made a choice
					local choice = self:selectedChoice()
					-- TODO this is def gonna bite me
					self.isGameOver = true
					self.choice = choice
					return
				end
			end

			if btnp(dirs.x) or self:shouldAdvance() then
				self.textIndexEnd += 1
				-- TODO could be evalnode
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
-- TODO can get rid of this eventually
ignore = '<IGNORE>'
pause = '<PAUSE>'
-- fallthrough = '<'
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

function myreset(node, reac) 
	writeTargetNode(node or 'any_hack') 
	poke(0x8000, reac or 1)
end

function _init()
	poke(0x5f36, (@0x5f36)|0x80)
	gs = {
		loaded_img_hash = 0,
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
			-- TODO maybe want to get rid of this
			writeTargetNode(self.games[self.activeGameIndex].node_id)
			if self.activeGameIndex > #self.games then
				self.activeGameIndex = -1
			end
		end,
		navigateToChoice = function(self, choice)
			-- TODO handle loading a different cart
			-- assert(choice.cart == '.')
			-- assert(choice.text)
			if choice.text == '[awe]' then
				writeReaction('awe')
			elseif choice.text == '[suspicion]' then
				writeReaction('sus')
			elseif choice.text == '[disdain]' then
				writeReaction('dis')
			end

			if choice.cart == '.' then
				local found = false
				-- print(choice.node .. 'awerwer')
				for i = 1, #self.games do
					-- print(choice.node)
					-- print(self.games[i].node_id)
					if self.games[i].node_id == choice.node then
						-- assert(false)
						-- Ugh this is bad...
						self:getActiveGame().isGameOver = false
						self:getActiveGame().isInitialized = false
						self.activeGameIndex = i
						self:getActiveGame().isGameOver = false
						self:getActiveGame().isInitialized = false
						found = true
						break
					end
				end
				-- TODO should add a "compile time" check
				-- Easy for relative links
				-- Hard for global
				assert(found)
				-- TODO maybe not necessary?
				writeTargetNode(choice.node)
				
			else
				writeTargetNode(choice.node)
				-- assert(false)
				assert(load(choice.cart))
			end
			-- assert(false)
		end
	}

	gs.games = chapter_init()

	local targetNode = readTargetNode()
	print(targetNode)
	if targetNode != nil then
		local found = false
		for i = 1, #gs.games do
			if gs.games[i].node_id == targetNode then
				gs.activeGameIndex = i
				found = true
				break
			end
		end
		-- TODO??
		assert(found)
	end
end

reacMap = {
	awe = 1,
	dis = 2,
	sus = 3
}

invReacMap = {'awe', 'dis', 'sus'}

-- TODO this won't scale..
function writeReaction(str)
	local val = reacMap[str]
	assert(val)
	poke(0x8000, val)
end

function readReaction()
	local val = peek(0x8000)
	assert(val > 0)
	assert(val < 4)
	return invReacMap[val]
end

function writeTargetNode(node)
	if node == nil then
		poke(0x8001, 0)
		return
	end
	poke(0x8001, #node)
	for i = 1, #node do
		poke(0x8001 + i, ord(node[i]))
	end
end

function readTargetNode()
	local len = peek(0x8001)
	if len == 0 then
		return nil
	end
	local ret = ''
	for i = 1, len do
		ret ..= chr(peek(0x8001 + i))
	end
	return ret
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



function
	load_img(img)
	if gs.loaded_img_hash == img.hash then
		-- print(gs.loaded_img_hash)
		-- print(img.hash)
		-- -- assert(false)
		return
	end

	-- pre-emptively do it...hope this doesn't bite me??
	gs.loaded_img_hash = img.hash


	-- TODO try not to corrupt the target node
	-- but probably fine?
	poke(0x8000+256, ord(img.img, 1, #img.img))
	x0,y0,src,vget,vset = 0,0,0x8000+256,sget,sset
	local function vlist_val(l, val)
		-- find position and move
		-- to head of the list

--[ 2-3x faster than block below
		local v,i=l[1],1
		while v!=val do
			i+=1
			v,l[i]=l[i],v
		end
		l[1]=val
--]]

--[[ 7 tokens smaller than above
		for i,v in ipairs(l) do
			if v==val then
				add(l,deli(l,i),1)
				return
			end
		end
--]]
	end

	-- bit cache is between 8 and
	-- 15 bits long with the next
	-- bits in these positions:
	--   0b0000.12345678...
	-- (1 is the next bit in the
	--   stream, 2 is the next bit
	--   after that, etc.
	--  0 is a literal zero)
	local cache,cache_bits=0,0
	function getval(bits)
		if cache_bits<8 then
			-- cache next 8 bits
			cache_bits+=8
			cache+=@src>>cache_bits
			src+=1
		end

		-- shift requested bits up
		-- into the integer slots
		cache<<=bits
		local val=cache&0xffff
		-- remove the integer bits
		cache^^=val
		cache_bits-=bits
		return val
	end

	-- get number plus n
	function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header

	local
		w,h_1,      -- w,h-1
		eb,el,pr,
		x,y,
		splen,
		predict
		=
		gnp"1",gnp"0",
		gnp"1",{},{},
		0,0,
		0
		--,nil

	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w-1 do
			splen-=1

			if(splen<1) then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a] or {unpack(el)}
			pr[a]=l

			-- grab index from stream
			-- iff predicted, always 1

			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)
		end
	end
end