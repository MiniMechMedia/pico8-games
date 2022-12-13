
function makeTextGame(textList)
	-- for entry in all(textList) do
	-- 	assert(type(entry)!='string')
	-- end
	return makeGame(
		function()end,
		function(self)
			self.textList = textList
			self.textIndexStart = 1
			self.textIndexEnd = 1
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
				print(line)
			end
		end,
		function(self)
			if btnp(dirs.x) then
				self.textIndexEnd += 1
				if self.textList[self.textIndexEnd] == nextpage then
					self.textIndexStart = self.textIndexEnd + 1
					self.textIndexEnd = self.textIndexStart
				end
				if self.textIndexEnd > #self.textList then
					self.isGameOver = true
				end
			end
		end
		)
end


function _update()
	gs:activateGame()
	gs:getActiveGame():update()
	if gs:getActiveGame().isGameOver then
		gs:activateNextGame()
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