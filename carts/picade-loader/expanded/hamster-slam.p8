pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--hamster slam                   v0.1.0
--caterpillar games


gs = nil
debug = false

everyoneLoses = 'everyoneLoses'
player1Wins = 'player1Wins'
player2Wins = 'player2Wins'
cpuWins = 'cpuWins'

function drawHamsters()
	for hamster in all(getAllHamsters()) do
		drawSingleHamster(hamster)
	end
	-- drawSingleHamster(gs.player1)
	-- drawSingleHamster(gs.player2)
	-- for opp in all(gs.opponents) do 
	-- 	drawSingleHamster(opp)
	-- end
end


function drawSingleHamster(hamster)
	circ(hamster.posX, hamster.posY, hamster.radius, hamster.color)
	palt(0, false)
	palt(2, true)
	local spriteNumber = 32 + 32 * hamster.number + 2 * flr(8*atan2(hamster.velX, -hamster.velY))
	spr(spriteNumber, hamster.posX-8 + 1, hamster.posY-8 + 1, 2, 2)
	palt()
	-- palt(0, true)
	-- fillp(0b0111111111011111.1)
	-- -- circfill(hamster.posX, hamster.posY, hamster.radius, hamster.color)
	-- fillp(0)

end

function makeHamster(number, initX, initY, color, mass)
	return {
		number = number,
		posX = initX,
		posY = initY,
		velX = 0,
		velY = 0,
		accX = 0,
		accY = 0,
		mass = mass or 1,
		force = 40,
		color = color,
		radius = 10,
		targetX = 64,
		targetY = 64,
		isDead = false,
	}
end	

function  _init() 

	menuitem(1, '1 player', function()
		initWithArgs(true, true, gs.isSuperBouncy)
	end)

	menuitem(2, '2 player', function()
		initWithArgs(false, true, gs.isSuperBouncy)
	end)



	-- menuitem(3, '1 on 1', function()
	-- 	initWithArgs(false, false)
	-- end)
	

	initWithArgs(true, true)
end

function initWithArgs(isAgainstCpu, withOpponents, isSuperBouncy)

	local opponents = {}
	if withOpponents then
		opponents = {
			makeHamster(3, 32, 64, 12, 1),
			makeHamster(4, 96, 64, 9)
		}
	end

	local elasticity = nil
	if isSuperBouncy then
		elasticity = 1.2
		menuitem(3, 'super bounce off', function()
			initWithArgs(gs.isAgainstCpu, true, false)
		end)
	else
		elasticity = .95
		menuitem(3, 'super bounce on', function()
			initWithArgs(gs.isAgainstCpu, true, true)
		end)
	end

	gs = {
		dt = 1/30,
		isAgainstCpu = isAgainstCpu,
		stageRadius = 63,
		stageX = 64,
		stageY = 64,
		player1 = makeHamster(1, 64, 96, 3, 1),
		player2 = makeHamster(2, 64, 32, 8),
		opponents = opponents,
		damping = 0.5,
		collisionElasticity = elasticity,
		winningPlayerStatus = nil,
		isSuperBouncy = isSuperBouncy
	}
end

dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	x = 5
}

function mybtn(val, playerNum) 
	if btn(val, playerNum) then
		return 1
	else
		return 0
	end
end	

function checkHamsterAiTarget(hamster, forceNew)
	local dist = abs(hamster.posX - hamster.targetX) + abs(hamster.posY - hamster.targetY)
	if dist < 15 or forceNew then
		-- Close enough. Pick new target!
		local r = gs.stageRadius * 0.6 * rnd()
		local alpha = rnd()

		hamster.targetX = gs.stageX + r * cos(alpha)
		hamster.targetY = gs.stageY + r * sin(alpha)
	end
end

-- Try a simple implementation - just move towards the center
function getAiInput(hamster)
	checkHamsterAiTarget(hamster)

	local deltaX = hamster.posX - hamster.targetX
	local deltaY = hamster.posY - hamster.targetY

	local left = 0
	local right = 0
	local up = 0
	local down = 0

	if deltaX > 0 then
		left = 1
	elseif deltaX < 0 then
		right = 1
	end

	if deltaY > 0 then
		up = 1
	elseif deltaY < 0 then
		down = 1
	end

	return {
		left,
		right,
		up,
		down
	}
end

function acceptInput()
	acceptInputPlayer(gs.player1, {
		mybtn(dirs.left, 0),
		mybtn(dirs.right, 0),
		mybtn(dirs.up, 0),
		mybtn(dirs.down, 0)
	})

	if gs.isAgainstCpu then
		acceptInputPlayer(gs.player2, getAiInput(gs.player2))
	else
		acceptInputPlayer(gs.player2, {
			mybtn(dirs.left, 1),
			mybtn(dirs.right, 1),
			mybtn(dirs.up, 1),
			mybtn(dirs.down, 1)
		})
	end

	for opp in all(gs.opponents) do
		acceptInputPlayer(opp, getAiInput(opp))
	end
end

function acceptInputPlayer(hamster, inputPacket)
	local accX = -inputPacket[1] + inputPacket[2]
	local accY = -inputPacket[3] + inputPacket[4]

	-- if btn(dirs.left, playerNum) then
	-- 	accX -= 1
	-- end
	-- if btn(dirs.right, playerNum) then
	-- 	accX += 1
	-- end
	-- if btn(dirs.up, playerNum) then
	-- 	accY -= 1
	-- end
	-- if btn(dirs.down, playerNum) then
	-- 	accY += 1
	-- end

	local mag = 1
	if accX != 0 or accY != 0 then
		mag = sqrt(accX*accX + accY*accY)
	end

	accX /= mag
	accY /= mag

	applyForce(hamster, accX, accY)
end

function applyForce(hamster, accX, accY)
	hamster.accX = accX * hamster.force
	hamster.accY = accY * hamster.force

	-- Make it a little more responsive by acting as pseudo-velocity
	hamster.velX += accX * hamster.force * gs.dt
	hamster.velY += accY * hamster.force * gs.dt
end

function physics()
	for hamster in all(getAllHamsters()) do
		hamster.posX += hamster.velX * gs.dt
		hamster.posY += hamster.velY * gs.dt

		hamster.velX += hamster.accX * gs.dt - hamster.velX * gs.damping * gs.dt
		hamster.velY += hamster.accY * gs.dt - hamster.velY * gs.damping * gs.dt
	end
end

function getAllHamsters()
	local ret = {}

	if not gs.player1.isDead then
		add(ret, gs.player1)
	end

	if not gs.player2.isDead then
		add(ret, gs.player2)
	end

	for opp in all(gs.opponents) do
		if not opp.isDead then
			add(ret, opp)
		end
	end

	return ret
end

function collisions()
	local allHamsters = getAllHamsters()

	for i = 1, #allHamsters do
		for j = i+1, #allHamsters do
			resolveCollision(allHamsters[i], allHamsters[j])
		end
	end
end

function normalize(x, y)
	local mag = sqrt(x * x + y * y)
	if mag == 0 then
		return {x=1,y=0}
	end
	return {
		x = x/mag,
		y = y/mag
	}
end	

function resolveCollision(hamster1, hamster2)
	local deltaX = hamster1.posX - hamster2.posX
	local deltaY = hamster1.posY - hamster2.posY

	local dist = sqrt(deltaX * deltaX + deltaY * deltaY)
	if dist >= (hamster1.radius + hamster2.radius) then
		-- No collision to resolve
		return
	end

	local avgX = (hamster1.posX + hamster2.posX) / 2
	local avgY = (hamster1.posY + hamster2.posY) / 2

	local deltaVec = normalize(deltaX, deltaY)

	-- Make them no longer overlap
	hamster1.posX = avgX + deltaVec.x * hamster1.radius * 1.01
	hamster1.posY = avgY + deltaVec.y * hamster1.radius * 1.01

	hamster2.posX = avgX - deltaVec.x * hamster2.radius * 1.01
	hamster2.posY = avgY - deltaVec.y * hamster2.radius * 1.01


	-- Solve momentum
	local v1Minusv2 = makeVec(
		hamster1.velX - hamster2.velX,
		hamster1.velY - hamster2.velY
		)
	local x1Minusx2 = makeVec(
		deltaX, deltaY
		)

	local v1Mult = gs.collisionElasticity * 2*hamster2.mass/(hamster1.mass + hamster2.mass) * dotProduct(v1Minusv2, x1Minusx2) / dotProduct(x1Minusx2, x1Minusx2)
	hamster1.velX -= v1Mult * x1Minusx2.x
	hamster1.velY -= v1Mult * x1Minusx2.y


	local v2Minusv1 = makeVec(
		-v1Minusv2.x,
		-v1Minusv2.y
		)
	local x2Minusx1 = makeVec(
		-deltaX, -deltaY
		)
	
	local v2Mult = gs.collisionElasticity * 2*hamster1.mass/(hamster1.mass + hamster2.mass) * dotProduct(v1Minusv2, x1Minusx2) / dotProduct(x1Minusx2, x1Minusx2)
	hamster2.velX -= v2Mult * x2Minusx1.x
	hamster2.velY -= v2Mult * x2Minusx1.y

	local impact = sqrt(dotProduct(v2Minusv1, v2Minusv1))
	-- sfx(0)
	if impact > 70 then
		sfx(0)
	elseif impact > 50 then
		sfx(4)
	elseif impact > 30 then
		sfx(1)
	end

	-- if debug and btn(4) and hamster1.number == 1 then
	-- 	assert(false)
	-- end
end

function makeVec(x, y)
	return {
		x = x,
		y = y
	}
end

function dotProduct(vec1, vec2)
	return vec1.x * vec2.x + vec1.y * vec2.y
end

function endScreenAcceptInput()
	if btnp(dirs.x) then
		initWithArgs(gs.isAgainstCpu, true, gs.isSuperBouncy)
	end
end


function _update()
	if gs.winningPlayerStatus == nil then
		acceptInput()

		physics()

		collisions()

		checkDeath()
	else
		endScreenAcceptInput()
	end
end

function myDist(x1, y1, x2, y2)
	local dx = x1 - x2
	local dy = y1 - y2
	return sqrt(
		dx * dx + dy * dy
		)
end

function checkDeath()
	if debug then 
		return
	end
	for hamster in all(getAllHamsters()) do
		if myDist(hamster.posX, hamster.posY, gs.stageX, gs.stageY) > (gs.stageRadius - hamster.radius) then
			hamster.isDead = true
			sfx(3)
		end
	end

	local remaining = getAllHamsters()


	if #remaining == 1 then
		if remaining[1].number == 1 then
			gs.winningPlayerStatus = player1Wins
		elseif remaining[1].number == 2 and not gs.isAgainstCpu then
			gs.winningPlayerStatus = player2Wins
		else
			gs.winningPlayerStatus = cpuWins
		end
	elseif #remaining == 0 then
		gs.winningPlayerStatus = everyoneLoses
	else
		-- If only bots are left, bail
		if gs.player1.isDead and gs.isAgainstCpu then
			gs.winningPlayerStatus = cpuWins
		elseif gs.player1.isDead and gs.player2.isDead then
			gs.winningPlayerStatus = cpuWins
		end
	end
end

function drawTargets()
	for hamster in all(getAllHamsters()) do
		circ(hamster.targetX, hamster.targetY, 3, hamster.color)
	end
end

function drawEndScreen()
	color(7)
	print('')
	if gs.winningPlayerStatus == player1Wins then
		print(' player 1 is the winner!')
	elseif gs.winningPlayerStatus == player2Wins then
		print(' player 2 is the winner!')
	elseif gs.winningPlayerStatus == cpuWins then
		print(' cpu is the winner!')
	elseif gs.winningPlayerStatus == everyoneLoses then
		print(' everyone loses!')
	end
	print('')
	print(' press ❎ to play again')
end

function _draw()
	cls(0)
	if gs.winningPlayerStatus == nil then
		circfill(gs.stageX, gs.stageY, gs.stageRadius, 6)
		circ(gs.stageX, gs.stageY, gs.stageRadius, 5)

		drawHamsters()


		if debug then
			drawTargets()
		end
	else
		drawEndScreen()
	end
end
#include shim.lua


-- Here
old_draw = _draw
old_init = _init

ssmemloc = 0x0000
original_saved_ss = 0x8000
picade_saved_ss = 0x8000 + 8192

function init_spritesheet()
	-- -- reload()
	-- -- TODO pass args
	-- if old_init then
	-- 	old_init()
	-- 	return
	-- end
	local fullss = 'bbbbbb00010bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb101010101bbbbbb0aaaaaafaffffffffffffff9999999999494444442222222e2eededdddddddcdccccccccc1c1c1c11111111110bbbbbbbbbbbbbbbbbbbbbb00001010101bbbbb0aaaaaaafaffffffffffffff9f99999999494444442222222e2eeddddddddddcdccccccc1c1c1c111111111110bbbbbbbbbbbbbbbbbbbbb0010101111111bbbb0aaaaaaaafafaffffffffffff9f999999994944442422222e2eededdddddddcdccccccc1c1c111111111111110bbbbbbbbbbbbbbbbbbbb000010101011101bbb0aaaaaaaaafafaffffffff66666f9666669946664422266666ed6666666dd666666666cc1c1111111111111110bbbbbbbbbbbbbbbbbbbb000101011116111bbb0aaaaaaaaaafafaffffff6777776f677769667776642267776ee67777776c677777776c1111111111111111100bbbbbbbbbbbbbbbbbbb0000010101167d110bb0aaaaaaaaaaafafafafff677777766777667777777626677776e6777777766777777761c111111111111111010bbbbbbbbbbbbbbbbbbb000010101111d1111bb0aaaaaaaaaaaaaafafaff677777776777667777777666777776e677777777677777776c1111111111111010100bbbbbbbbbbbbbbbbbbb00000101010111010bb0aaaaaaaaaaaaaaafafaf677767776777677776777766777777667777777767776666611111111111110101000bbbbbbbbbbbbbbbbbbb00000010111111111bbb05a5aaaaaaaaaaaafafa67776677677767776666666677677766777667776777777761111111111110101000bbbbbbbbbbbbbbbbbbbb00000101010101010bbb0a5a5a5aaaaaaaaaafaf67777777677767777677776777677766777767776777666661111111110101000000bbbbbbbbbbbbbbbbbbbbb000001010101010bbbb0555a5a5aaaaaaaaaafa67777776677766777777776777767776777777776777777761111111101010000000bbbbbbbbbbbbbbbbbbbbb000000001010101bbbb0555555a5a5aaaaaaaaf67777766677766777777767777767776777777766777777761111101010100000000bbbbbbbbbbbbbbbbbbbbbb0000001010101bbbbb0555555555a5a5aaaaaa6777666f6777696777776677777667767777776c6777777761111010101000000000bbbbbbbbbbbbbbbbbbbbbbb00000000000bbbbbb05555555555a5a5aaaaa66666fff666669966666266666666666666666cc6666666661010101010000000000bbbbbbbbbbbbbbbbbbbbbbbb000000001bbbbbbb05555555555555a5a5aaaaaafafaffff9999494444222e2eeddddddcdccccc1c111110101010000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0000000bbbbbbbb055555555555555a5a5aaaaaafaffff9f9999444422222eededdddcdccccc111111101010100000000000000bbbbbbbbbbbbbbbbbbbbbbb0005d667000bbbbbb055555555555555555a5aaaaaafaffff9999494444222eeeeddddddccccc1111111010100000000000000000bbbbbbbbbbbbbbbbbbbbbb00005d6670101bbbbb0555555555555555555aaaaaaaafaff9f9999444422222eeddddddccccccc111110101000000000000000000bbbbbbbbbbbbbbbbbbbbb000015d66710100bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbb0000105d667110101bbbbbb05555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000000000bbbbbbbbbbbbbbbbbbbbbbb00000105d51101000bbbbbb0555555557777777777777777777777777777777777777777777777777777777777777777000000000bbbbbbbbbbbbbbbbbbbbbbb00001011111110101bbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbb000010101010100bbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbb0010101010101bbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbbbb44444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbbbb00010bbbbbbbbbbbbbbbb10101101bbbbbbbbbbb0555555557bbbbbbbbbbbbbbbbbb44aaaaafbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7000000000bbbb101010101bbbbbbbbbbbbb0000100101bbbbbbbbbb0555555557bbbbbbbbbbbbbbbbb449aaaaaaf4bbbbbbbb44444bbbbbbbbbbbbbbbbbbbbb7000000000bbb00001010101bbbbbbbbbbb001010111111bbbbbbbbb0555555557bbbbbbbbbbbbbbbb449aaaaaaaaf5bbbbb44aaaaafbbbbbbbbbbbbbbbbbbbb7000000000bb0010101111111bbbbbbbbb00001010011101bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbbb4a9aaaaaaf4bbbbbbbbbbbbbbbbbb7000000000b000010101011101bbbbbbbb00010101116111bbbbbbbb0555555557bbbbbbbbbbbbbbb444aaaaaaaaaafbbb4a9aaaaaaaaf5bbbbbbbbbbbbbbbbb7000000000b000101011116111bbbbbbb000001010167d110bbbbbbbb055555557bbbbbbbbbbbbbbb4449aaaaaaafafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b0000010101167d110bbbbbb0000010100111010bbbbbbbb055555557bbbbbbbbbbbbbbbb4449aaaaffaafbb444aaaaaaaaaafbbbbbbbbbbbbbbbbb700000000b000010101111d1111bbbbbb0000001011111111bbbbbbbb055555557bbbbbbbbbbbbbbbb49999aaaaaaa5bb4449aaaaaaafafbbbbbbbbbbbbbbbbb700000000b00000101010111010bbbbbb0000010100101010bbbbbbbb055555557bbbbbbbbbbbbbbbbb49aaaaaaa45bbbb4449aaaaffaa5bbbbbbbbbbbbbbbbb700000000b00000010111111111bbbbbbb00000101101010bbbbbbbbb055555557bbbbbbbbbbbbbbbbbb44aaaaa45bbbbbb4499aaaaa4bbbbbbbbbbbbbbbbbbb700000000b00000101010101010bbbbbbb00000000010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbb4444444bbbbbbbbbbbbbbbbbbbb700000000bb000001010101010bbbbbbbbb000000110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bb000000001010101bbbbbbbbbb0000000000bbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbb0000001010101bbbbbbbbbbbb00000001bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbb000000000007bbbbbbbbbbbbbb0000bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbb00000000167000bbbbbbbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000005d6670000bbbbbbbbb5d67bbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0005d66710101bbbbbbb05d6700bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb24eeee5bbbbbbbbb555d551bbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000015dd5010100bbbb0005d667000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb4eeeeeeedbbbbbbb53cccccd5bbbbbbbbbbbbbbbbbbb700000000bbbbbbb00001015d11110101bb00005dd670101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb4eeeeeeeeedbbbbb5dcccccccd5bbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101111101000b000015dd6710100bbbbbbbb055555557bbbbbbbbbbbbbbbb24eeeeeeeeefdbbb5dcccccccccdbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000101111111010100001015d51110101bbbbbbb055555557bbbbbbbbbbbbbbbb44eeeeeeeeef6bb151cccccccccc5bbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101010100b00000101111101000bbbbbbb055555557bbbbbbbbbbbbbbbb444eeeeeeefefbb1d11cccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101010101bb00001011111110101bbbbbbb055555557bbbbbbbbbbbbbbbb4444eeeee7feebb51d1dccccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbb00000010000bbbb000010101010100bbbbbbbb055555557bbbbbbbbbbbbbbbb24e44eeefeeedbbd1ddd3cccccccc5bbbbbbbbbbbbbbbb700000000bbbbbbbbbbbb0101010bbbbbbb0010101010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbb44eeeeeeee4bbbf5ddccccccc665bbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbb24eeeeee4bbbbbd15dccccc67dbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbb2244442bbbbbbbb55dcccccdbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbbbb00010bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdddddddbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbbb101010101bbbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbbb00001010101bbbbbbbbbbbbbbbbbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbbb0010101111111bbbbbbbb000010bbbbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000010101011101bbbbb1010110101bbbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbbb000101011116111bbbb000010010101bbbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb0000010101167d110bb00101011111111bbbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb000010101111d1111b0000101001011101bbbbbbb055555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb700000000bbbbbbb00000101010111010b0001010111116111bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb0000001011111111100000101001167d110bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbb000001010101010100000101011111d1111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000001010101010b000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb000000001010101b000001010010111010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbb0000001010101bb000000101111111111bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbbbb00000000000bbb000001010010101010bbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbbbb005000000001bbbbb0000010110101010bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbbb00005d600000bbbbbbb0000000001010101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb000055d667101bbbbbbbb00000011010101bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000015d66670100bbbbbbbb000000000000bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000105d667110101bbbbbbb00000000001bbbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb0000010d577101000bbbbbb0000000000101bbbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbb00001011511110101bbbbb000015d66710100bbbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbb000010101010100bbbbb0000105d667110101bbbbbbbb05555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb70000000bbbbbb0010101010101bbbbbb00000105d51101000bbbbbbbb055555577777777777777777777777777777777777777777777777777777777777777770000000bbbbbbb00000010000bbbbbbb00001011111110101bbbbbbbb0555555555555555555aaaaaaaffffff999944442222eeeedddddcccccc1111111000000000000bbbbbbbbb0101010bbbbbbbbbb000010101010100bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0010101010101bbbbbbb055555555555555555555aaaaaaaaffffffff9994442222eedddddddcdcccccc11111100000000000000bbbbbbbbbbbbbbbbbbbbbbbbb00000010000bbbbbbb05555555555555555555555aaaaaafaffffff9999944422eeeedddddddcdcccc1c11110100000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb0101010bbbbbbbbb0555555555555555555555aaaaaaaaffffff9f9994942222eedddddddcdcccccc111555d55510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5aaaaaafaffff9f9994942422eeeedddddddcdcccc1c115dccccc510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555555555aaaaaafaffffff999994442222eededddddcdcccccc111cccccccc510000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f9994942222eeeedddddddcdcccc1113ccccccccc55000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaafaffff9f999494222222eeeedddd24eeee50c113cccccccccc55000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555555a5aaaaaaaaffff9f999494242222eeeedddd4eeeeeeed0111ccccccccccd50000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a5aaaaaaffffff9f949424222222eeeedd4eeeeeeeeed0d11cccccccccc50000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaafaffff9f999494222222eeeede24eeeeeeeeefd1dd3ccccccccd500000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555555a5a55aaaaaaaffff9f99949422222222eeeed44eeeeeeeeef61ddcccccccccd5000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555555a5a55aaaaaaaffffff9f949422222222eeeeee444eeeeeeefef515cccccc67d50000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a5a555aaaaaafaffff9f94942422222222eeeed4444eeeee7fee55513cccc6d5000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555555555555a5a5a555aaaaaafaffff9f99942422222222e2eeee24e44eeefeeed11153cccdd50000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555a55555aaaaaafaffff9f9994942222222222eeeeee44eeeeeeee41153ccccccd500000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb05555555555555555555a55555aaaaaaffffff9f999994242222222222eeeedd24eeeeee4115dccccccccd500000000000000000bbbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a555aaaaaaafffff9f999994242222222222eeeeeedd2244442c15dccccccccccd50000000000000000bbbbbbbbbbbbbbbbbbbbbbb0555555555555555555a5a555aaaaaaffafff9f99999424222222222222eeeeee24eeed5cc151ccccccccccc510100000000000000bbbbbbbbbbbbbbbbbbbbb05555555555555555a5a5a555aaaaaaffffff9f99999424222222222222e2eee44eeeeeee5c551dccccccccccd510100000000000000bbbbbbbbbbbbbbbbbbbb0555555555555555a5a5a55aaaaaaaffffff9f9999999424222222222222eee44eeeeeeeee51d11ccccccccccc501010000000000000bbbbbbbbbbbbbbbbbbb05555555555555a5a5a5a5aaaaaaaaffffffff9999999444222222222222e2ee44eeeeeeeeee51d1dcccccccccc5101010100000000000bbbbbbbbbbbbbbbbbb0555555555555a5a5a5aaaaaaaafffffffff9999999944424222222222222ee44eeeeeeeeeefd1ddd3ccccccccc5110101010100000000bbbbbbbbbbbbbbbbbb055555555555a5a5aaaaaaaaaafafffffff999999994942422222222222222e44eeeeeeeeeeff5ddcccccccc6651111110101010100000bbbbbbbbbbbbbbbbbb055555555a5a5aaaaaaaaaaaffffffffff999999999944424222222222222e2444eeeeeeeefffd15dcccccc67d51111111110101010000bbbbbbbbbbbbbbbbbb05a5a5a5a5a5aaaaaaaaaffffffffffff999999999944424222222222222222444eeeeeeef7e7d555dccccccd511111111111110101000bbbbbbbbbbbbbbbbbb0a5a5a5a5aaaaaaaaffffffffffffff999999999994442422222222222222242444eeeee77e77dcccddddddd5111111111111111111100bbbbbbbbbbbbbbbbb0a5aaaaaaaaaaafaffffffffffffff999999999999444442422222222222222f24ee4eeeffef76cccccccccc1c1111111111111111111110bbbbbbbbbbbbbbbb0aaaaaaaafafafffffffff9ffff9999999999999949444242222222222222222e24eeeeeef776cdcccccccccc1c111111111111111111110bbbbbbbbbbbbbbbb0aaaaafafaaafffffffff9f999999999999999494944424222222222222222222ee44eeef776cdcccccccccc1c1c11111111111111111110bbbbbbbbbbbbbbbb0fafafafafafffffff9f9f999999999999999494944424242222222222222222e2eeedeee6dddcdcccccccccc1c1c1111111111111111110bbbbbbbbbbbbbbbb0afafafffffffff9f9f9f99999999999999949444444424222222222222222222e2eeeeeddddddcdcccccccccccc1c1c1111111111111110bbbbbbbbbbbbbbbb0fffffffffff9f9f9f999999999999999494944444442422222222222222222222e2eeeeddd5dddcdcccccccccccc1c1c111111111111110bbbbbbbbbbbbbbb0fffffffffff9f9f9999999999999994949494444444242222222222222222222222e2eeeddddddddcccccccccccccc1c1c111111111111110bbbbbbbbbbbbbb0fffff9ffff9f999999999999999494949494444444242422222222222222222222e2eeeeeddddddcdcccccccccccccc1c1c11111111111110bbbbbbbbbbbbbb0fffffff9f9f99999999999994949494444444444444242222222222222222222222e2eeeeeddddddcdcccccccccccccccc1c1c11111111110bbbbbbbbbbbbbb09f9f9f9f999999999999999494949444444444444424222222222222222222222222e2eeeedddddddcccccccccccccccccc1c1c1111111110bbbbbbbbbbbbbb099f9f9999999999999994949494944444444444442422222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbbbbbbbb099999999999999999999494949444444444444444242222222222222222222222222222e2eeededdddcdcccccccccccccccccccc1c111111110bbbbbbbbbbbb0999999999999999994949494944444444444444424242222222222222222222222222222eeeeeddddddcdcccccccccccccccccccc1c11111110bbbbbbbbbbbb05999999999994449494949494444444444444442424222222222222222222222222222222eeeeeddddddcccccccccccccccccccccc111111110bbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb'

local mymap = {
		["0"] = 0,
		["1"] = 1,
		["2"] = 2,
		["3"] = 3,
		["4"] = 4,
		["5"] = 5,
		["6"] = 6,
		["7"] = 7,
		["8"] = 8,
		["9"] = 9,
		["a"] = 10,
		["b"] = 11,
		["c"] = 12,
		["d"] = 13,
		["e"] = 14,
		["f"] = 15,
		[' '] = nil
	}
	-- Store the original away for safety
	memcpy(original_saved_ss, ssmemloc, 8192)

	-- Overwrite the sprite sheet with picade
	local x = 0
	local y = 0
	for i = 1, #fullss do
		sset(x, y, mymap[fullss[i]])
		-- print(mymap[fullss[i]])
		x += 1
		if x > 127 then
			x = 0
			y += 1
		end
	end
	
	-- Save picade ss to other half of general use
	memcpy(picade_saved_ss, ssmemloc, 8192)
end

function draw_header()
	
	-- local x = 0
	-- local y = 0
	-- for i = 1, #actual do
	-- 	if actual[i] != ' ' then
	-- 		pset(x, y, mymap[actual[i]])
	-- 	end
	-- 	x += 1
	-- 	if x > 127 then
	-- 		x = 0
	-- 		y += 1
	-- 	end
	-- end

	palt(0, false)

	 sspr(17,0,128,21,17, 0)

	 -- Left Bar
	 sspr(18, 0, 14, 96, 18, 0)

	 -- right bar
	 sspr(96, 0, 9, 96, 96, 0)

	 -- bottom console part 1
	 sspr(17, 85, 95, 30, 17, 85)

	 -- bottom console part 2
	 sspr(0, 96, 128, 32, 0, 96)

	

end

function draw_joystick()
  local buttons = {
    ['xunpressed'] = {
      x = 48,
      y = 32,
      width = 16,
      height = 16,
      -- cx = 8,
      -- cy = 21
    },
    ['xpressed'] = {
      x = 64,
      y = 32,
      width = 16,
      height = 16,
      -- cx = 8,
      -- cy = 21
    }
  }
  local controls = {
    ['neutral'] = {
      x = 0,
      y = 0,
      width = 17,
      height = 30,
      cx = 8,
      cy = 21
    },
    ['left'] = {
      x = 105,
      y = 32,
      width = 32,
      height = 26,
      cx = 119,
      cy = 52
    },
    ['right'] = {
      x = 107,
      y = 60,
      width = 32,
      height = 26,
      cx = 115,
      cy = 80
    },
    ['up'] = {
      x = 0,
      y = 32,
      width = 17,
      height = 30,
      cx = 8,
      cy = 55
    },
    ['down'] = {
      x = 0,
      y = 64,
      width = 18,
      height = 28,
      cx = 8,
      cy = 84
    }
  }

  local dir = 'neutral'
  if btn(0) then
    dir = 'left'
  elseif btn(1) then
    dir = 'right'
  elseif btn(2) then
    dir = 'up'
  elseif btn(3) then
    dir = 'down'
  end

  local ctrl = controls[dir]
  palt(11, true)
  palt(0, false)
  local xoff = ctrl.cx - ctrl.x
  local yoff = ctrl.cy - ctrl.y
  sspr(
    ctrl.x, 
    ctrl.y, 
    ctrl.width, 
    ctrl.height,
    38-xoff, 109-yoff)

  local xbut = nil
  if btn(5) then
    xbut = buttons['xpressed']
  else
    xbut = buttons['xunpressed']
  end
  sspr(
    xbut.x,
    xbut.y,
    xbut.width,
    xbut.height,
    58,
    109
    )

  local zbut = nil
  if btn(4) then 
    zbut = buttons['xpressed']
  else
    zbut = buttons['xunpressed']
  end
  sspr(
    zbut.x,
    zbut.y,
    zbut.width,
    zbut.height,
    60,
    97
    )

  palt()
end

firstDrawObject = {
	isFirstDraw = true
}

function _draw()
	if firstDrawObject.isFirstDraw then
		init_spritesheet()
		firstDrawObject.isFirstDraw = false
	end
	local old_draw_state = {}
	for i = 0x5f00, 0x5f3f do
		add(old_draw_state, peek(i))
		-- poke(i, 0)
		-- TODO set draw state to sensible default
	end

	if old_draw then
		-- Restore original sprite sheet
		memcpy(ssmemloc, original_saved_ss, 8192)
		old_draw()

	end
	-- if true then return end
	-- local cornerX, cornerY = 31, 32-8-1
	poke(0x5f54, 0x60)
	palt(0,false)

	-- TODO
	camera()
	-- This makes the minimap
	local minimapY = 21
	sspr(0,0,128,128, 32,minimapY,64,64) 
	-- rectfill(0,0,128,minimapY,13)
	-- rectfill(0,0,17,96,13)
	-- rectfill(105, 18, 128, 92, 13)
	-- rectfill(0,0,128,minimapY,13)
	rectfill(0,0,32,128,13)
	rectfill(96,0,128,128,13)

	palt()

	-- rectfill(0,0,24,128,0)
	-- rectfill(128 - 24-1,0,128,128,0)

	poke(0x5f54, 0x00)
	-- Restore the picade sprite sheet
	memcpy(ssmemloc, picade_saved_ss, 8192)
	draw_header()
	draw_joystick()

	-- for i = 0, 7 do
	-- 	rect(cornerX-i, cornerY-i, cornerX+i+64, cornerY+i+64,7)
	-- end

	for i = 0x5f00, 0x5f3f do
		local nothing = nil
		-- poke(i, old_draw_state[i-0x5f00+1])
		-- add(old_draw_state, peek(i))
	end

	pal(11,13,1)
	-- memcpy(0x8000, 0x6000, 8192)
end
-- End Here

__gfx__
000000002222222e222222222222222e2222222222222222222222222222222e2222222200000000000000000000000000000000000000000000000000000000
00000000222222fff2222222222222fff22222222222222222222222222222fff222222200000000000000000000000000000000000000000000000000000000
0070070022222fffff22222222222fffff222222222222222222222222222fffff22222200000000000000000000000000000000000000000000000000000000
0007700022222f0f0f22222222222f0f0f222222222222222222222222222f0f0f22222200000000000000000000000000000000000000000000000000000000
0007700022222fffff22222222222fffff2222222222fffff442222222222fffff22222200000000000000000000000000000000000000000000000000000000
007007002222fffffff22222222244fff442222222fffffff44fff222222fffffff2222200000000000000000000000000000000000000000000000000000000
000000002222fffffff22222222244ffff42222222ff444fffff0ff22222fffffff2222200000000000000000000000000000000000000000000000000000000
000000002222fffffff222222222fffffff22222eef4444ffffffffe2222fffffff2222200000000000000000000000000000000000000000000000000000000
000000002222fffffff222222222fffffff2222222f44fffffff0ff22222fffffff2222200000000000000000000000000000000000000000000000000000000
000000002222fffffff222222222ff44ff42222222ffffffff4fff222222fffffff2222200000000000000000000000000000000000000000000000000000000
000000002222fffffff222222222ff44ff4222222222444ff44222222222fffffff2222200000000000000000000000000000000000000000000000000000000
000000002222fffffff222222222ff444f42222222222222222222222222fffffff2222200000000000000000000000000000000000000000000000000000000
0000000022222fffff22222222222ff44f222222222222222222222222222fffff22222200000000000000000000000000000000000000000000000000000000
0000000022222fffff22222222222fffff222222222222222222222222222fffff22222200000000000000000000000000000000000000000000000000000000
000000002222222e222222222222222e2222222222222222222222222222222e2222222200000000000000000000000000000000000000000000000000000000
000000002222222e222222222222222e2222222222222222222222222222222e2222222200000000000000000000000000000000000000000000000000000000
00000000222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000
00000000222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000
000000002222222222fffe222222222222fffe2222222222222222222222222222fffe2200000000000000000000000000000000000000000000000000000000
0000000022222222ffffff2222222222ffffff22222222222222222222222222ffffff2200000000000000000000000000000000000000000000000000000000
00000000222222ffff0fff22222222f44f0fff222222222222222222222222ffff0fff2200000000000000000000000000000000000000000000000000000000
0000000022222fffffff0f2222222ff44fff0f22222222222222222222222fffffff0f2200000000000000000000000000000000000000000000000000000000
0000000022222fffffffff2222222fffffffff22222222222222222222222fffffffff2200000000000000000000000000000000000000000000000000000000
000000002222fffffffff2222222fffffff4422222222222222222222222fffffffff22200000000000000000000000000000000000000000000000000000000
000000002222ffffffff22222222f4ffff44222222222222222222222222ffffffff222200000000000000000000000000000000000000000000000000000000
00000000222ffffffff22222222f44fffff222222222222222222222222ffffffff2222200000000000000000000000000000000000000000000000000000000
00000000222fffffff222222222f44ffff2222222222222222222222222fffffff22222200000000000000000000000000000000000000000000000000000000
00000000222ffffff222222222244ffff22222222222222222222222222ffffff222222200000000000000000000000000000000000000000000000000000000
00000000222ffff222222222222f4ff2222222222222222222222222222ffff22222222200000000000000000000000000000000000000000000000000000000
0000000022e222222222222222e2222222222222222222222222222222e222222222222200000000000000000000000000000000000000000000000000000000
000000002e222222222222222e2222222222222222222222222222222e2222222222222200000000000000000000000000000000000000000000000000000000
00000000222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
22222222222222222e2222222222222222222222e222222222222222222222e222222222222222222222222222222222222222fff22222222222222222222222
222222222222222222e2222222222222222222fffff222222222222222222e22222222222222222222effff22222222222222fffff2222222222222222fffe22
2222222222222222222f4ff222222222222222f44ff22222222222222ff4f222222222222222222222fff0f42222222222222f0f0f22222222222222ffffff22
2222fffff44222222224444ff2222222222224f444ff22222222222ffff44222222222222222222222fffff44222222222222fffff222222222222f44f0fff22
22fffffff44fff22222ff444fff22222222224ff44ff2222222222ffff44f2222222244ff444222222ff0fff4f222222222244fff442222222222ff44fff0f22
22ff444fffff0ff2222fffffffff2222222224ff44ff222222222fffff44f22222fff4ffffffff22222ffffffff22222222244ffff42222222222fffffffff22
eef4444ffffffffe2222ffffff44222222222fffffff2222222244ffff4f22222ff0fffffff44f22222f44ffffff22222222fffffff222222222fffffff44222
22f44fffffff0ff22222ffffff44f22222222fffffff222222244fffffff2222effffffff4444fee222244ffffff22222222fffffff222222222f4ffff442222
22ffffffff4fff2222222ffffffff222222224ffff44222222fffffffff222222ff0fffff444ff222222fffffffff2222222ff44ff422222222f44fffff22222
2222444ff4422222222222f4fff0ff222222244fff44222222f0fff44ff2222222fff44fffffff2222222fff444ff2222222ff44ff422222222f44ffff222222
2222222222222222222222244fffff22222222fffff2222222fff0f44f2222222222244fffff22222222222ff44442222222ff444f42222222244ffff2222222
2222222222222222222222224f0fff22222222f0f0f2222222ffffff222222222222222222222222222222222ff4f22222222ff44f222222222f4ff222222222
2222222222222222222222222ffffe22222222fffff2222222efff222222222222222222222222222222222222222e2222222fffff22222222e2222222222222
222222222222222222222222222222222222222fff2222222222222222222222222222222222222222222222222222e22222222e222222222e22222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
22222222222222222e2222222222222222222222e222222222222222222222e22222222222222222222222222222222222222244422222222222222222222222
222222222222222222e222222222222222222244444222222222222222222e22222222222222222222e444422222222222222444442222222222222222444e22
22222222222222222224444222222222222222444442222222222222244442222222222222222222224440402222222222222404042222222222222244444422
22224400044222222224440042222222222224444404222222222224444442222222440004422222224444400222222222222444442222222222224444044422
22440000044444222224444000022222222224444004222222222244444442222244000004444422224404400422222222224444404222222222200444440422
22444000044404422224444000042222222224444000222222222444444042222244400004440442222444440442222222224444400222222222200444444422
ee4444444444444e222244444444222222222044400022222222000440002222ee4444444444444e222444444444222222220004400222222222400444000222
22444444444404422222444444444222222220044000222222200044400422222244444444440442222244444444222222220004440222222222000440002222
22444444000444222222244044444222222220044444222222444444400222222244444400044422222240000444422222220004444222222224044444422222
22224440004222222222224004404422222224044444222222404444400222222222444000422222222220000444422222224004444222222224444444222222
22222222222222222222222004444422222222444442222222444044442222222222222222222222222222240044422222224044444222222224444442222222
22222222222222222222222204044422222222404042222222444444222222222222222222222222222222222444422222222444442222222224444222222222
22222222222222222222222224444e22222222444442222222e444222222222222222222222222222222222222222e22222224444422222222e2222222222222
2222222222222222222222222222222222222224442222222222222222222222222222222222222222222222222222e22222222e222222222e22222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
22222222222222222e2222222222222222222222e222222222222222222222e22222222222222222222222222222222222222277722222222222222222222222
222222222222222222e222222222222222222277777222222222222222222e22222222222222222222e777722222222222222777772222222222222222777e22
22222222222222222227777222222222222222777772222222222222277772222222222222222222227770772222222222222707072222222222222277777722
22227777777222222227777772222222222227777777222222222227777772222222222222222222227777777222222222222777772222222222227777077722
22777777777777222227777777722222222227777777222222222277777772222222277777772222227707777722222222227777777222222222277777770722
22777777777707722227777777772222222227777777222222222777777772222277777777777722222777777772222222227777777222222222277777777722
ee7777777777777e2222777777772222222227777777222222227777777722222770777777777722222777777777222222227777777222222222777777777222
2277777777770772222277777777722222222777777722222227777777772222e7777777777777ee222277777777222222227777777222222222777777772222
22777777777777222222277777777222222227777777222222777777777222222770777777777722222277777777722222227777777222222227777777722222
22227777777222222222227777707722222227777777222222707777777222222277777777777722222227777777722222227777777222222227777777222222
22222222222222222222222777777722222222777772222222777077772222222222277777772222222222277777722222227777777222222227777772222222
22222222222222222222222277077722222222707072222222777777222222222222222222222222222222222777722222222777772222222227777222222222
22222222222222222222222227777e22222222777772222222e777222222222222222222222222222222222222222e22222227777722222222e2222222222222
2222222222222222222222222222222222222227772222222222222222222222222222222222222222222222222222e22222222e222222222e22222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
22222222222222222e2222222222222222222222e222222222222222222222e22222222222222222222222222222222222222255522222222222222222222222
222222222222222222e222222222222222222255555222222222222222222e22222222222222222222e555522222222222222555552222222222222222555e22
22222222222222222225555222222222222222557552222222222222257552222222222222222222225550552222222222222505052222222222222255555522
22225555555222222225555552222222222225555555222222222225555552222222222222222222225555557222222222222555552222222222225555055522
22555575555555222227555575522222222225575555222222222255575552222222275555552222225505555522222222225557557222222222255555550522
22555555555505522225575555552222222225555575222222222555555552222255555555555522222555755552222222225555555222222222255557555522
ee5755555575555e2222555555552222222225555555222222227555555522222550555555755522222555555555222222225555555222222222575555555222
2255575555550552222255555555522222222555555522222225555555752222e5555755555575ee222255555555222222225555555222222222555555572222
22555555555555222222255557555222222225555555222222555575555222222550555555555522222255555575522222225755555222222225555555522222
22225555557222222222225555505522222227557555222222505555555222222255555557555522222225575555722222225555755222222225557555222222
22222222222222222222222755555522222222555552222222555055552222222222255555552222222222255555522222225555555222222225555552222222
22222222222222222222222255055522222222505052222222555555222222222222222222222222222222222555522222222557552222222225575222222222
22222222222222222222222225555e22222222555552222222e555222222222222222222222222222222222222222e22222225555522222222e2222222222222
2222222222222222222222222222222222222225552222222222222222222222222222222222222222222222222222e22222222e222222222e22222222222222
2222222222222222222222222222222222222222e22222222222222222222222222222222222222222222222222222222222222e222222222222222222222222
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000055555555555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000055555566666666666666655555500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000555566666666666666666666666666655550000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000555666666666666666666666666666666666665550000000000000000000000000000000000000000000
00000000000000000000000000000000000000000555666666666666666666666666666666666666666665550000000000000000000000000000000000000000
00000000000000000000000000000000000000055666666666666666666666666666666666666666666666665500000000000000000000000000000000000000
00000000000000000000000000000000000005566666666666666666666666666666666666666666666666666655000000000000000000000000000000000000
00000000000000000000000000000000000556666666666666666666666666666666666666666666666666666666550000000000000000000000000000000000
00000000000000000000000000000000055666666666666666666666666666666666666666666666666666666666665500000000000000000000000000000000
00000000000000000000000000000005566666666666666666666666666666666666666666666666666666666666666655000000000000000000000000000000
00000000000000000000000000000056666666666666666666666666666666666666666666666666666666666666666666500000000000000000000000000000
00000000000000000000000000005566666666666666666666666666666666666666666666666666666666666666666666655000000000000000000000000000
00000000000000000000000000056666666666666666666666666666666666666666666666666666666666666666666666666500000000000000000000000000
00000000000000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000000000000
00000000000000000000000055666666666666666666666666666666666666666666666666666666666666666666666666666665500000000000000000000000
00000000000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000000000
00000000000000000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000000000000000
00000000000000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000000000000
00000000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000000
00000000000000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000000000000
00000000000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000000000
00000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000
00000000000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000000000
00000000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000000
00000000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000000
00000000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000000
00000000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000000
00000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000
00000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000
00000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000
00000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000
00000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000
00000000056666666666666666666666666666666666666666666666666668888888666666666666666666666666666666666666666666666666666500000000
00000000056666666666666666666666666666666666666666666666666886666666886666666666666666666666666666666666666666666666666500000000
00000000566666666666666666666666666666666666666666666666668666666666668666666666666666666666666666666666666666666666666650000000
0000000056666666666666666666666666666666666666666666666668666666e666666866666666666666666666666666666666666666666666666650000000
00000005666666666666666666666666666666666666666666666666866666644466666686666666666666666666666666666666666666666666666665000000
00000005666666666666666666666666666666666666666666666668666666444446666668666666666666666666666666666666666666666666666665000000
00000056666666666666666666666666666666666666666666666668666666404046666668666666666666666666666666666666666666666666666666500000
00000056666666666666666666666666666666666666666666666686666666444446666666866666666666666666666666666666666666666666666666500000
00000566666666666666666666666666666666666666666666666686666664444404666666866666666666666666666666666666666666666666666666650000
00000566666666666666666666666666666666666666666666666686666664444400666666866666666666666666666666666666666666666666666666650000
00000566666666666666666666666666666666666666666666666686666660004400666666866666666666666666666666666666666666666666666666650000
00005666666666666666666666666666666666666666666666666686666660004440666666866666666666666666666666666666666666666666666666665000
00005666666666666666666666666666666666666666666666666686666660004444666666866666666666666666666666666666666666666666666666665000
00005666666666666666666666666666666666666666666666666686666664004444666666866666666666666666666666666666666666666666666666665000
00056666666666666666666666666666666666666666666666666668666664044444666668666666666666666666666666666666666666666666666666666500
00056666666666666666666666666666666666666666666666666668666666444446666668666666666666666666666666666666666666666666666666666500
00056666666666666666666666666666666666666666666666666666866666444446666686666666666666666666666666666666666666666666666666666500
0005666666666666666666666666666666666666666666666666666668666666e666666866666666666666666666666666666666666666666666666666666500
0056666666666666666666666666666666666666666666666666666666866666e666668666666666666666666666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666666886666666886666666666666666666666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666ccccccc88888666666666666666666666666666666666666666666666666666666666650
005666666666666666666666666666666666666666666666666666cc6666666cc666666666666666666666666666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666c66666666666c66666666666666666666666666666666666666666666666666666666666650
0056666666666666666666666666666666666666666666666666c6666666666666c6666666666666666666666666666666666666666666666666666666666650
056666666666666666666666666666666666666666666666666c666666666666666c666666666666666666666666666666666666666666666666666666666665
05666666666666666666666666666666666666666666666666c66666666666666666c66666666666666666666666666666666666666666666666666666666665
05666666666666666666666666666666666666666666666666c66666666666666666c66666666666666666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c6666667777777666666c6666666666666666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c6666777777777777666c6666666666666666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c6666777777777707766c6666666666666666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c66ee7777777777777e6c6666666666666666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c6666777777777707766c6666666666666666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c6666777777777777666c6666999999966666666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666c6666667777777666666c6699666666699666666666666666666666666666666666666666666665
05666666666666666666666666666666666666666666666666c66666666666666666c66966666666666966666666666666666666666666666666666666666665
05666666666666666666666666666666666666666666666666c66666666666666666c696666666e6666696666666666666666666666666666666666666666665
056666666666666666666666666666666666666666666666666c666666666666666c6966666666e6666669666666666666666666666666666666666666666665
0566666666666666666666666666666666666666666666666666c6666666666666c6966666665555566666966666666666666666666666666666666666666665
05666666666666666666666666666666666666666666666666666c66666666666c66966666665575566666966666666666666666666666666666666666666665
005666666666666666666666666666666666666666666666666666cc6666666cc669666666655555556666696666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666ccccccc66669666666655755556666696666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666666666666669666666655555756666696666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666666666666669666666655555556666696666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666666666666669666666655555556666696666666666666666666666666666666666666650
00566666666666666666666666666666666666666666666666666666666666666669666666655555556666696666666666666666666666666666666666666650
00056666666666666666666666666666666666666666666666666666666666666669666666675575556666696666666666666666666666666666666666666500
00056666666666666666666666666666666666666666666666666666666666666666966666665555566666966666666666666666666666666666666666666500
00056666666666666666666666666666666666666666666666666666666666666666966666665050566666966666666666666666666666666666666666666500
00056666666666666666666666666666666666666666666666666666666666666666696666665555566669666666666666666666666666666666666666666500
00005666666666666666666666666666666666666666666666666666666666666666669666666555666696666666666666666666666666666666666666665000
000056666666666666666666666666666666666666666666666666666666666666666669666666e6666966666666666666666666666666666666666666665000
00005666666666666666666666666666666666666666666666666666666666666666666699666666699666666666666666666666666666666666666666665000
00000566666666666666666666666666666666666666666666666666666666666666666666999999966666666666666666666666666666666666666666650000
00000566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666650000
00000566666666666666666666666666666666666666666663333333666666666666666666666666666666666666666666666666666666666666666666650000
00000056666666666666666666666666666666666666666336666666336666666666666666666666666666666666666666666666666666666666666666500000
00000056666666666666666666666666666666666666663666666666663666666666666666666666666666666666666666666666666666666666666666500000
00000005666666666666666666666666666666666666636666666666666366666666666666666666666666666666666666666666666666666666666665000000
00000005666666666666666666666666666666666666366666666666666e36666666666666666666666666666666666666666666666666666666666665000000
0000000056666666666666666666666666666666666366666666666666e663666666666666666666666666666666666666666666666666666666666650000000
000000005666666666666666666666666666666666636666666666ff4f6663666666666666666666666666666666666666666666666666666666666650000000
0000000005666666666666666666666666666666663666666666ffff446666366666666666666666666666666666666666666666666666666666666500000000
000000000566666666666666666666666666666666366666666ffff44f6666366666666666666666666666666666666666666666666666666666666500000000
00000000005666666666666666666666666666666636666666fffff44f6666366666666666666666666666666666666666666666666666666666665000000000
000000000056666666666666666666666666666666366666644ffff4f66666366666666666666666666666666666666666666666666666666666665000000000
00000000000566666666666666666666666666666636666644fffffff66666366666666666666666666666666666666666666666666666666666650000000000
00000000000056666666666666666666666666666636666fffffffff666666366666666666666666666666666666666666666666666666666666500000000000
00000000000056666666666666666666666666666636666f0fff44ff666666366666666666666666666666666666666666666666666666666666500000000000
00000000000005666666666666666666666666666663666fff0f44f6666663666666666666666666666666666666666666666666666666666665000000000000
00000000000000566666666666666666666666666663666ffffff666666663666666666666666666666666666666666666666666666666666650000000000000
00000000000000056666666666666666666666666666366efff66666666636666666666666666666666666666666666666666666666666666500000000000000
00000000000000056666666666666666666666666666636666666666666366666666666666666666666666666666666666666666666666666500000000000000
00000000000000005666666666666666666666666666663666666666663666666666666666666666666666666666666666666666666666665000000000000000
00000000000000000566666666666666666666666666666336666666336666666666666666666666666666666666666666666666666666650000000000000000
00000000000000000056666666666666666666666666666663333333666666666666666666666666666666666666666666666666666666500000000000000000
00000000000000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000000000000
00000000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000000
00000000000000000000056666666666666666666666666666666666666666666666666666666666666666666666666666666666666500000000000000000000
00000000000000000000005666666666666666666666666666666666666666666666666666666666666666666666666666666666665000000000000000000000
00000000000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000000000
00000000000000000000000055666666666666666666666666666666666666666666666666666666666666666666666666666665500000000000000000000000
00000000000000000000000000566666666666666666666666666666666666666666666666666666666666666666666666666650000000000000000000000000
00000000000000000000000000056666666666666666666666666666666666666666666666666666666666666666666666666500000000000000000000000000
00000000000000000000000000005566666666666666666666666666666666666666666666666666666666666666666666655000000000000000000000000000
00000000000000000000000000000056666666666666666666666666666666666666666666666666666666666666666666500000000000000000000000000000
00000000000000000000000000000005566666666666666666666666666666666666666666666666666666666666666655000000000000000000000000000000
00000000000000000000000000000000055666666666666666666666666666666666666666666666666666666666665500000000000000000000000000000000
00000000000000000000000000000000000556666666666666666666666666666666666666666666666666666666550000000000000000000000000000000000
00000000000000000000000000000000000005566666666666666666666666666666666666666666666666666655000000000000000000000000000000000000
00000000000000000000000000000000000000055666666666666666666666666666666666666666666666665500000000000000000000000000000000000000
00000000000000000000000000000000000000000555666666666666666666666666666666666666666665550000000000000000000000000000000000000000
00000000000000000000000000000000000000000000555666666666666666666666666666666666665550000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000555566666666666666666666666666655550000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000055555566666666666666655555500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000055555555555555500000000000000000000000000000000000000000000000000000000

__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000000100191100e1100c11009110031100311003110031100311000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000100000050002510025100251003510005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010a00001f0532805128051280511b6530060300603180511b653006031a051006031b653006031c0511d0511b6531f05123051006031b6530060321051240511b65300603260511d0511b653000001a0511c051
000200000f2101521012210102100e2100d2100b21009210082100721006210052100521003210032000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000100000050002570025600256003560005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500

__meta:cart_info_start__
cart_type: game
game_name: Hamster Slam
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 95
    jam_url: null
    jam_theme: Hamsters
tagline: Knock the other hamster balls out of the ring!
develop_time: 2h 53m 52s
description: |
  Roll your hamster ball to knock others out of the ring. Last hamster standing wins. Supports one or two players.
controls:
  - inputs: [ARROW_KEYS]
    desc:  Move player one's hamster (green hamster ball)
  - inputs: [ESDF]
    desc:  In 2-player mode, move player two's hamster (red hamster ball)
  - inputs: [P]
    desc:  Pause menu. Allows selecting 2 player mode and activating/deactivating Super Bounce mode
  - inputs: [X]
    desc:  Start a new game when round ends
hints: ''
acknowledgements: Inspired by the Sumo minigame from Fuzion Frenzy
to_do: []
version: 0.1.0
img_alt: Four hamsters in different colored hamster balls

number_players: [1,2]
__meta:cart_info_end__
