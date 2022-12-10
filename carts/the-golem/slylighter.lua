
function makeLightsOut()

local thisGame = nil
local function injectgame(self)
	thisGame = self
end
gridxDim = 3
gridyDim = 3

selectedCell = {
	x = 1,
	y = 2
}

dir = {
	left = 0,
	right = 1,
	up = 2,
	down = 3
}

-- off color, on color
houseColors = {
	{13, 12},	-- mauve, blue
	{2, 14},	-- pink, purple
	{4, 9}		-- brown, orange
}

-- sprite number
houseStyles = {
	2,
	4
}

function makeCell(isOn, colInd, styleInd) 
	return {
		isOn = isOn,
		colInd = colInd,
		styleInd = styleInd
	}
end

drawXOff = 24
drawYOff = 16

function setDrawOffsets()
	if gridxDim == 3 then
		drawXOff = 24
		drawYOff = 16
	elseif gridxDim == 4 then
		drawXOff = 24 - 8
		drawYOff = 16
	else
		drawXOff = 24 - 17
		drawYOff = 16
	end

end

animatedPlayerPosition = {
	x = 64,
	y = -6,
	vx = 0,
	vy = 30
}


local function _init()

animatedPlayerPosition = {
	x = 64,
	y = -6,
	vx = 0,
	vy = 30
}

	menuitem(1, "play easy", doEasyLevel)
	menuitem(2, "play medium", doMediumLevel)
	menuitem(3, "play hard", doHardLevel)

	-- srand()		-- test
	gameState.isWin	 = false
	gameState.isPlayerEntry = false
	gameState.isRandomizing = false
	gameState.randomizeCountDown = 2 * 30
	gameState.skipRandAnimation = false
	-- sfx(4, 1)
	gameState.solution = {{x = 1, y = 2}, {x = 2, y = 3}}-- generateRandomization()
	gameState.solution = generateRandomization()
	cameraY = 0
	gameState.grid = {}
	for i = 1, gridyDim do
		gameState.grid[i] = {}
		for j = 1, gridxDim do
			gameState.grid[i][j] = makeCell(true, flr(rnd(#houseColors)) + 1, flr(rnd(#houseStyles)) +1)
		end
	end

	setDrawOffsets()

	-- for i = 1, gridyDim do
	-- 	for j = 1, gridxDim do
	-- 		if rnd() > 0.5 then
	-- 			-- todo record this
	-- 			toggleCell(j, i)
	-- 		end
	-- 	end
	-- end

	-- toggleCell(1,1)
	-- toggleCell(3,3)
	-- randomizeGrid()


	-- todo randomize
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = flr(rnd(i)) + 1
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end



function generateRandomization() 
	list = {}		-- the ones to hit
	for i = 1, gridyDim do
		for j = 1, gridxDim do
			for k = 1, (2) do
				-- redundant...but better to show...
				if rnd() > 0.5 then
					list[#list + 1] = {x=j, y=i}		
				end
			end
		end
	end
	return shuffle(list)
end

function toggleCell(x, y)
	for xoff = -1, 1 do
		if (1 <= x + xoff) and (x + xoff <= gridxDim) then
			gameState.grid[y][x + xoff].isOn = not gameState.grid[y][x + xoff].isOn
		end
	end

	for yoff = -1, 1 do
		if (1 <= y + yoff) and (y + yoff <= gridyDim) and (yoff != 0) then
			gameState.grid[y + yoff][x].isOn = not gameState.grid[y + yoff][x].isOn
		end
	end

end

function doEasyLevel()
	gridxDim = 3
	gridyDim = 3
	_init()
end


function doMediumLevel()
	gridxDim = 4
	gridyDim = 4
	_init()
end

function doHardLevel()
	gridxDim = 5
	gridyDim = 5
	_init()
end


local function _update()
	-- toggleCell(3, 2)
	acceptInput()

	checkWinCondition()

	actOnWinCondition()	

	updateGameState()

	if gameState.isPlayerEntry then
		animatedPlayerPosition.x += animatedPlayerPosition.vx * 1/30.0
		animatedPlayerPosition.y += animatedPlayerPosition.vy * 1/30.0
	end
end

function updateGameState()
	if gameState.nextLevelCountdown then
		gameState.nextLevelCountdown -= 1
		if gameState.nextLevelCountdown <= 0 then
			gameState.isNextLevel = true
		end
	end

	if gameState.isRandomizing then
		if gameState.skipRandAnimation then
			for toToggle in all(gameState.solution) do
				toggleCell(toToggle.x, toToggle.y)
			end
			gameState.solution = {}
		end

		gameState.randomizeCountDown -= 1
		if #gameState.solution == 0 then
			gameState.isRandomizing = false
		elseif gameState.randomizeCountDown < 0 then
			gameState.isPlayerEntry = false;
			local toToggle = del(gameState.solution, gameState.solution[1])
			selectedCell.x = toToggle.x
			selectedCell.y = toToggle.y
			toggleCell(toToggle.x, toToggle.y)
			gameState.randomizeCountDown = 10	-- 3 times a second
		end
	else
		gameState.isPlayerEntry = false
	end

end
	

gameState = {
	grid = nil,
	isWin = false
}

function incDim()
	gridxDim += 1
	gridyDim += 1
end

cameraSpeed = 3	-- debugg

maxDim = 5

nextLevelCountdown = 5 * 30

function actOnWinCondition() 
	if gameState.isWin then
		cameraY -= cameraSpeed
		if (cameraY < skyOffset - 30) then
			cameraY = skyOffset - 30
			-- assert(false)
			thisGame.isGameOver = true
			-- if gameState.isNextLevel then
			-- 	incDim()
			-- 	_init()
			-- elseif gridyDim < maxDim then
			-- 	gameState.startNextLevelCountdown = true
			-- 	gameState.nextLevelCountdown = nextLevelCountdown
			-- else

			-- 	-- idk?
			-- end

			-- TODO add more of a delay

		end
	end
end

function checkWinCondition()
	if gameState.isRandomizing then
		return
	end

	if gameState.isWin then
		return
	end
	-- todo
	gameState.isWin = false
	for x = 1, gridxDim do
		for y = 1, gridyDim do
			if gameState.grid[y][x].isOn then
				return
			end
		end
	end
	-- Yay, all off
	-- tODO
	gameState.isWin = true
	-- sfx(3)

end

canceldraw = false

lastButton = nil



function acceptInput()
	if lastButton == btn() or gameState.isWin then
		return
	end

	if gameState.isRandomizing then
		if btn(4) then		-- Z
			gameState.skipRandAnimation = true
		end
		return
	end

	if btnp(dir.up) and (selectedCell.y > 1) then
		selectedCell.y -= 1
	end

	if btnp(dir.down) and (selectedCell.y < gridyDim) then
		selectedCell.y += 1
	end

	if btnp(dir.left) and (selectedCell.x > 1) then
		selectedCell.x -= 1
	end

	if btnp(dir.right) and (selectedCell.x < gridxDim) then
		selectedCell.x += 1
	end

	if btnp(5) then
		toggleCell(selectedCell.x, selectedCell.y)
		-- if gameState.grid[selectedCell.y][selectedCell.x].isOn then
		-- 	sfx(1)
		-- else
		-- 	sfx(2)
		-- end
	end

	lastButton = btn()
end

function drawCharacter()
	if gameState.isPlayerEntry then
		spr(1, animatedPlayerPosition.x, animatedPlayerPosition.y, 1, 1, 0, 1)
		return
	end


	local x0 = 17 * selectedCell.x + 6 + drawXOff
	local y0 = 17 * selectedCell.y - 2 + drawYOff

	if gameState.isRandomizing then
		-- make it consistent
		srand(#gameState.solution)
		local flipX = rnd() > 0.5
		local flipY = rnd() > 0.5
		local spriteNumber = 1
		if flipX then
			spriteNumber = 17
		end
		spr(spriteNumber, x0, y0, 1, 1, flipX, flipY)
		if gameState.randomizeCountDown == 1 then
			sfx(0)
		end
		-- play a sound
	else
		-- spr(1, x0, y0)
		x0 -= 7
		rect(x0, y0, x0+17, y0+17, 7)
	end

end




function drawGrid()
	pal()

	for i = 1, gridyDim do
		for j = 1, gridxDim do
			local x0 = j * 17 + drawXOff
			local y0 = i * 17 + drawYOff
			local col = nil

			local cell = gameState.grid[i][j]
			local spriteNumber = houseStyles[cell.styleInd]

			if cell.isOn then
				col = 10	-- window color
				-- bright pink...
				pal(2, houseColors[cell.colInd][2])
			else
				col = 5

				pal(2, houseColors[cell.colInd][1])

			end
			-- 13 12

			-- if (j == selectedCell.x) and (i == selectedCell.y) then
			-- 	col = 6
			-- end

			pal(10, col)

			spr(spriteNumber, x0, y0, 2, 2)
			-- rectfill(x0, y0, x0 + 15, y0 + 15, col)

			pal()

		end
	end
end


cameraY = 0

skyOffset = -230

function drawBackground() 


	-- camera(0, cameraY)
	-- draw sky
	-- map(0, 0, 0, skyOffset, 16, 64)

	-- draw ground
	-- map(57, 32, 0, 42, 16, 16)
	-- camera()
end

function _draw()
	if canceldraw then
		return
	end
	cls()
	drawBackground()
	drawGrid()
	drawCharacter()
end




return makeGame(injectgame, _init, _update, _draw)
end