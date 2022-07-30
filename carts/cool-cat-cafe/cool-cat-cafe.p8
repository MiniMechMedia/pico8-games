pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--cool cat cafe                  v0.1.0
--caterpillar games




gs = nil

dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

gameOverWin = 'win'
gameOverLose = 'lose'

-- This font is by zep, found in Custom Fonts section of this post https://www.lexaloffle.com/bbs/?tid=41544
poke(0x5f58, 0x81)
poke(0x5600,unpack(split"8,8,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,63,63,63,63,63,63,0,0,0,63,63,63,0,0,0,0,0,63,51,63,0,0,0,0,0,51,12,51,0,0,0,0,0,51,0,51,0,0,0,0,0,51,51,51,0,0,0,0,48,60,63,60,48,0,0,0,3,15,63,15,3,0,0,62,6,6,6,6,0,0,0,0,0,48,48,48,48,62,0,99,54,28,62,8,62,8,0,0,0,0,24,0,0,0,0,0,0,0,0,0,12,24,0,0,0,0,0,0,12,12,0,0,0,10,10,0,0,0,0,0,4,10,4,0,0,0,0,0,0,0,0,0,0,0,0,12,12,12,12,12,0,12,0,0,54,54,0,0,0,0,0,0,54,127,54,54,127,54,0,8,62,11,62,104,62,8,0,0,51,24,12,6,51,0,0,14,27,27,110,59,59,110,0,12,12,0,0,0,0,0,0,24,12,6,6,6,12,24,0,12,24,48,48,48,24,12,0,0,54,28,127,28,54,0,0,0,12,12,63,12,12,0,0,0,0,0,0,0,12,12,6,0,0,0,62,0,0,0,0,0,0,0,0,0,12,12,0,32,48,24,12,6,3,1,0,62,99,115,107,103,99,62,0,24,28,24,24,24,24,60,0,63,96,96,62,3,3,127,0,63,96,96,60,96,96,63,0,51,51,51,126,48,48,48,0,127,3,3,63,96,96,63,0,62,3,3,63,99,99,62,0,127,96,48,24,12,12,12,0,62,99,99,62,99,99,62,0,62,99,99,126,96,96,62,0,0,0,12,0,0,12,0,0,0,0,12,0,0,12,6,0,48,24,12,6,12,24,48,0,0,0,30,0,30,0,0,0,6,12,24,48,24,12,6,0,30,51,48,24,12,0,12,0,0,30,51,59,59,3,30,0,0,0,62,96,126,99,126,0,3,3,63,99,99,99,63,0,0,0,62,99,3,99,62,0,96,96,126,99,99,99,126,0,0,0,62,99,127,3,62,0,124,6,6,63,6,6,6,0,0,0,126,99,99,126,96,62,3,3,63,99,99,99,99,0,0,24,0,28,24,24,60,0,48,0,56,48,48,48,51,30,3,3,51,27,15,27,51,0,12,12,12,12,12,12,56,0,0,0,99,119,127,107,99,0,0,0,63,99,99,99,99,0,0,0,62,99,99,99,62,0,0,0,63,99,99,63,3,3,0,0,126,99,99,126,96,96,0,0,62,99,3,3,3,0,0,0,62,3,62,96,62,0,12,12,62,12,12,12,56,0,0,0,99,99,99,99,126,0,0,0,99,99,34,54,28,0,0,0,99,99,107,127,54,0,0,0,99,54,28,54,99,0,0,0,99,99,99,126,96,62,0,0,127,112,28,7,127,0,62,6,6,6,6,6,62,0,1,3,6,12,24,48,32,0,62,48,48,48,48,48,62,0,12,30,18,0,0,0,0,0,0,0,0,0,0,0,30,0,12,24,0,0,0,0,0,0,28,54,99,99,127,99,99,0,63,99,99,63,99,99,63,0,62,99,3,3,3,99,62,0,31,51,99,99,99,51,31,0,127,3,3,63,3,3,127,0,127,3,3,63,3,3,3,0,62,3,3,115,99,99,126,0,99,99,99,127,99,99,99,0,63,12,12,12,12,12,63,0,127,24,24,24,24,24,15,0,99,51,27,15,27,51,99,0,3,3,3,3,3,3,127,0,99,119,127,107,99,99,99,0,99,103,111,107,123,115,99,0,62,99,99,99,99,99,62,0,63,99,99,63,3,3,3,0,62,99,99,99,99,51,110,0,63,99,99,63,27,51,99,0,62,99,3,62,96,99,62,0,63,12,12,12,12,12,12,0,99,99,99,99,99,99,62,0,99,99,99,99,54,28,8,0,99,99,99,107,127,119,99,0,99,99,54,28,54,99,99,0,99,99,99,126,96,96,63,0,127,96,48,28,6,3,127,0,56,12,12,7,12,12,56,0,8,8,8,0,8,8,8,0,14,24,24,112,24,24,14,0,0,0,110,59,0,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,127,127,0,85,42,85,42,85,42,85,0,65,99,127,93,93,119,62,0,62,99,99,119,62,65,62,0,17,68,17,68,17,68,17,0,4,12,124,62,31,24,16,0,28,38,95,95,127,62,28,0,0,54,127,127,62,28,8,0,42,28,54,119,54,28,42,0,28,28,62,93,28,20,20,0,8,28,62,127,62,42,58,0,62,103,99,103,62,65,62,0,62,127,93,93,127,99,62,0,24,120,8,8,8,15,7,0,62,99,107,99,62,65,62,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,62,115,99,115,62,65,62,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,62,119,99,99,62,65,62,0,0,10,4,0,80,32,0,0,17,42,68,0,17,42,68,0,62,107,119,107,62,65,62,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))

maxSeats = 4

function makeParticle(sprite, life, pos)
	add(gs.particles, {
		sprite = sprite,
		life = life,
		pos = pos
	})
end

function _init()
	-- music(19, 1000)
	music(59, 1000)
	gs = {
		highlightSquare = nil,
		successCount = 0,
		failCount = 0,
		dt = 1/30.0,
		isGameOver = false,
		gameOverState = nil,
		getTimeState = function(self)
			-- 3 minutes
			return min(12, flr(self:getCurrentTime() / 120 * 12))
		end,
		getCurrentTime = function(self)
			return t() - self.startTime
		end,
		particles = {},
		coffeePotContents = {},
		currentRecipes = {},
		startTime = t(),
		endTime = nil,
		currentAnimation = nil,
		player = {
			spriteNumber = 32,
			stack = {},
			speed = 60,
			pos = vec2(64, 64),
			facingLeft = false
		},
		seatedCustomers = {

		},
		getSeatedCustomers = function(self) 
			local ret = {}
			for i = 1, maxSeats do 
				if self.seatedCustomers[i] != nil then
					add(ret, self.seatedCustomers[i])
				end
			end
			return ret
		end,
		getFreeSeats = function(self)
			local ret = {}
			for i = 1, maxSeats do 
				if self.seatedCustomers[i] == nil then
					add(ret, i)
				end
			end
			return ret
		end,
		customerInd = 1,
		queuedCustomers = {

		}
	}

	-- local first = {1,2}
	-- local second = {1}
	-- multisetEquals(first, second)
	-- assert(#first == 2)
	-- assert(#second == 2)

	gs.currentRecipes = {
		recipes.machiato,
		recipes.latte,
		recipes.espresso,
		-- recipes.pawfee,
		recipes.tea
	}

	gs.queuedCustomers = lineUpCustomers(4)

	-- HACK!
	-- gs.seatedCustomers = gs.queuedCustomers
	-- gs.queuedCustomers = {}
end

function makeCustomer(spriteNumber, order)
	return {
		spriteNumber = spriteNumber,
		order = order
		-- pos = pos
	}
end

catSprites = {
	16,
	48,
	64,
	80
}

function lineUpCustomers(num)
	local ret = {}
	for i = 1, num do
		add(ret, makeCustomer(catSprites[gs.customerInd], rnd(gs.currentRecipes)) )
		gs.customerInd += 1
		if gs.customerInd > #catSprites then
			gs.customerInd = 1
		end
	end
	return ret
end

ing = {
	sugar = 4,
	milk = 5,
	bean = 6,
	ice = 7
}

recipes = {
	pawfee = {
		name = 'iCED pAWFEE',
		ingredientList = {ing.bean, ing.ice},
		sprite = 60
	},
	latte = {
		name = 'cLAWTTE',
		ingredientList = {ing.bean, ing.milk, ing.milk},
		sprite = 59
	},
	machiato = {
		name = 'mEOWCCHIATO',
		ingredientList = {ing.bean, ing.sugar, ing.milk},
		sprite = 58
	},
	tea = {
		name = 'iCED kITTEA',
		ingredientList = {ing.milk, ing.sugar, ing.ice},
		sprite = 60
	},
	espresso = {
		name = 'hISSPRESSO',
		ingredientList = {ing.bean, ing.bean},
		sprite = 61
	}
}

function rndrange(_min, _max)
	local diff = _max - _min
	return _min + diff * rnd()
end

metaTable = {
	__add = function(v1, v2)
		return vec2(v1.x + v2.x, v1.y + v2.y)
	end,
	__sub = function(v1, v2)
		return vec2(v1.x - v2.x, v1.y - v2.y)
	end,
	__mul = function(s, v)
		if type(s) == 'table' then
			s,v = v,s
		end

		return vec2(s * v.x, s * v.y)
	end,
	__div = function(v, s)
		return vec2(v.x / s, v.y / s)
	end,
	__eq = function(v1, v2)
		return v1.x == v2.x and v1.y == v2.y
	end
}

function vec2fromAngle(ang)
	return vec2(cos(ang), sin(ang))
end

function vecFromDir(dir)
	if dir == dirs.left then
		return vec2(-1, 0)
	elseif dir == dirs.right then
		return vec2(1, 0)
	elseif dir == dirs.up then
		return vec2(0, -1)
	elseif dir == dirs.down then
		return vec2(0, 1)
	else
		assert(false)
	end
end

function modInc(x, mod)
	return (x + 1) % mod
end

function modDec(x, mod)
	return (x - 1) % mod
end

function vec2(x, y)
	local ret = {
		x = x,
		y = y,
		norm = function(self)
			if self == vec2(0, 0) then 
				return self 
			end
			return vec2fromAngle(atan2(self.x, self.y))
		end,
		squareDist = function(self, other)
			return max(abs(self.x - other.x), abs(self.y - other.y))
		end,
		taxiDist = function(self, other)
			return abs(self.x - other.x) + abs(self.y - other.y)
		end,
		-- Beware of using this on vectors that are more than 128 away
		eucDist = function(self, other)
			local dx = self.x - other.x
			local dy = self.y - other.y
			-- return sqrt(dx * dx + dy * dy)
			return approx_magnitude(dx, dy)
		end,
		isWithin = function(self, other, value)
			return self:taxiDist(other) <= value and
				self:eucDist(other) <= value
		end,
		isOnScreen = function(self, extra)
			if extra == nil then extra = 0 end

			return extra <= self.x and self.x <= 128 - extra
				and extra <= self.y and self.y <= 128 - extra
		end,
		length = function(self)
			return self:eucDist(vec2(0, 0))
		end,
		angle = function(self)
			return atan2(self.x, self.y)
		end,
		clone = function(self)
			return vec2(self.x, self.y)
		end
	}

	setmetatable(ret, metaTable)

	return ret
end


function hasAnimation()
	return gs.currentAnimation != nil and costatus(gs.currentAnimation) != 'dead'
end

function inputToVec()
	local ret = vec2(0, 0)
	if btn(dirs.up) then
		ret.y = -1
	end
	if btn(dirs.down) then
		ret.y = 1
	end
	if btn(dirs.left) then
		ret.x = -1
	end
	if btn(dirs.right) then
		ret.x = 1
	end

	return ret:norm()
end

function mymget(pos)
	return mget(pos.x / 8, pos.y/8)
end

function acceptInput()
	local newpos = gs.player.pos:clone()
	local moveDir = inputToVec()
	newpos += gs.player.speed * gs.dt * moveDir

	if moveDir.x < 0 then
		gs.player.facingLeft = true
	elseif moveDir.x > 0 then
		gs.player.facingLeft = false
	end

	-- Check if it's a walkable tile
	if fget(mymget(newpos), 0)
		and fget(mymget(newpos + vec2(7, 7)), 0) then
		gs.player.pos = newpos
	end
end

function _update()
	-- if btnp(dirs.z) then gs.isGameOver = true end
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if btnp(dirs.x) then
			_init()
		end
		return
	end

	if hasAnimation() then
		return
	end

	acceptInput()

	checkActionButton()

	checkActionButtonServeCustomer()

	checkTimeUp()
end

function showEnd()
	-- while not btnp(dirs.x) do
		local startX = 8
		local startY = 16
		rectfill(startX, startY, 128-startX, 128 - startY, 15)
		rect(startX, startY, 128-startX, 128 - startY, 4)

		local x = startX + 8
		local y = startY + 4
		print("tIME'S uP!\n", x, y)

		print("rIGHT oRDERS")
		print(gs.successCount)

		print("\nwRONG oRDERS")
		print(gs.failCount) 

		print('')
		print('pLAY aGAIN ')
		spr(63, 104, 101)
		-- -- assert(#gs:getSeatedCustomers() > 0)
		-- for i, customer in ipairs(gs:getSeatedCustomers()) do

		-- 	-- assert(false)
		-- 	palt(15, true)
		-- 	palt(0, false)
		-- 	local x = startX + 8
		-- 	local y = startY + 8 + (i-1)*24
		-- 	drawCat(customer, vec2(x - 4,y), true)
		-- 	print(customer.order.name, x + 8, y, 5)
		-- 	-- print(recipe.name, x, y, 5)
		-- 	-- print(' = ')
		-- 	-- spr(recipe.sprite, x, y + 8)
		-- 	-- x += 8
		-- 	-- for ind, ingr in ipairs(recipe.ingredientList) do
		-- 	-- 	spr(ingr, x + ind * 8, y + 8)
		-- 	-- end
		-- 	palt()
		-- end

		-- yield()
	-- end
end

function checkTimeUp()
	if gs:getTimeState() >= 12 then
		gs.currentAnimation = cocreate(function()
			for i = 1, 60 do
				yield()
				showEnd()
			end
			gs.isGameOver = true
	 	end)
	end
end

coffeeLocation = {
	x = 14, y = 6
}

-- Pop it into the coffee pot
-- function popIngredient()
-- 	local last = gs.player.stack[#gs.player.stack]
-- end

-- function deleteIngredient()
-- 	-- local ret =  gs.player.stack 
-- 	-- #gs.player.stack = #gs.player.stack - 1
-- 	-- del(gs.player.stack, gs.player.stack[#gs.player.stack])
-- 	local newStack = {}
-- 	for i = 1, (#gs.player.stack - 1) do
-- 		newStack[i] = gs.player.stack[i]
-- 	end

-- 	gs.player.stack = newStack
-- end

-- function insertIngredientOrObject(spriteNumber)
	
-- end

function enqueueIngredient(spriteNumber)
	-- assert(gs.player.stack)
	-- gs.player.stack = nil
	-- assert(spriteNumber != nil)
	add(gs.player.stack, spriteNumber)
	-- assert(#gs.player.stack > 0)
end

-- Peeks at what would be dequeued
function peekIngredient()
	return gs.player.stack[1]
end

function dequeueIngredient()
	local ret = gs.player.stack[1]

	local newStack = {}
	for i = 2, #gs.player.stack do
		add(newStack, gs.player.stack[i])
	end

	gs.player.stack = newStack

	return ret
end

function isIngredient(spriteNumber)
	for key, val in pairs(ing) do
		if val == spriteNumber then
			-- assert(false)
			return true
		end
	end

	return false
end

function showTerminal()
	yield()
	while not btnp(dirs.x) do
		local startX = 8
		local startY = 16
		rectfill(startX, startY, 128-startX, 128 - startY, 15)
		rect(startX, startY, 128-startX, 128 - startY, 4)



		-- assert(#gs:getSeatedCustomers() > 0)
		for i, customer in ipairs(gs:getSeatedCustomers()) do

			-- assert(false)
			palt(15, true)
			palt(0, false)
			local x = startX + 8
			local y = startY + 8 + (i-1)*24
			drawCat(customer, vec2(x - 4,y), true)
			print(customer.order.name, x + 8, y, 5)
			-- print(recipe.name, x, y, 5)
			-- print(' = ')
			-- spr(recipe.sprite, x, y + 8)
			-- x += 8
			-- for ind, ingr in ipairs(recipe.ingredientList) do
			-- 	spr(ingr, x + ind * 8, y + 8)
			-- end
			palt()
		end

		if #gs:getSeatedCustomers() == 0 then
			local x = startX + 8
			local y = startY + 8
			print('no orders', x, y)
		end

		yield()
	end
end

function showRecipeBook()
	yield()
	while not btnp(dirs.x) do
		local startX = 8
		local startY = 16
		rectfill(startX, startY, 128-startX, 128 - startY, 15)
		rect(startX, startY, 128-startX, 128 - startY, 4)

		for i, recipe in ipairs(gs.currentRecipes) do
			-- assert(false)
			palt(15, true)
			palt(13, true)
			palt(0, false)
			local x = startX + 8
			local y = startY + 4 + (i-1)*24
			print(recipe.name, x, y, 5)
			print(' = ')
			spr(recipe.sprite, x, y + 8)
			x += 8
			for ind, ingr in ipairs(recipe.ingredientList) do
				spr(ingr, x + ind * 8, y + 8)
			end
			palt()
		end

		yield()
	end
end

function getSeatedCustomerPos(i)
	return vec2(2 * 8, (4 + 2*(i-1)) * 8)
end

function checkActionButtonServeCustomer()
	if not btnp(dirs.x) then 
		return 
	end

	local lookLeft = gs.player.pos + vec2(-10, 4)
	for i = 1, maxSeats do
		local topLeft = getSeatedCustomerPos(i)
		-- if (topLeft.x - lookLeft.x) < 8 and
		-- 	(lookLeft.y - topLeft.y) < 16 and 
		if topLeft.x < lookLeft.x and lookLeft.x < (topLeft.x + 8) and
			topLeft.y < lookLeft.y and lookLeft.y < (topLeft.y + 12) and
			gs.seatedCustomers[i] != nil then
				-- assert(false)
				serveCustomer(i)
		end
	end
end

function serveCustomer(i)
	if not isIngredient(peekIngredient()) and peekIngredient() != nil then
		local drink = dequeueIngredient()
		-- assert(gs.seatedCustomers[i].order.sprite == drink)
		local customer = gs.seatedCustomers[i]
		if customer.order.sprite == drink then
			-- Happy
			makeParticle(38, 30, getSeatedCustomerPos(i))
			gs.successCount += 1
		else
			makeParticle(39, 30, getSeatedCustomerPos(i))
			gs.failCount += 1
		end
		-- del(gs.seatedCustomers, customer)
		gs.seatedCustomers[i] = nil
	end
end

function checkActionButton()
	-- gs.debug = gs:getCurrentTime()
	if btnp(dirs.x) then
		local sprite = mymget(gs.player.pos + vec2(4, -6))
		-- gs.debug = sprite

		if isIngredient(sprite) then
			-- assert
		-- 	gs.debug = true
		-- else
		-- 	gs.debug = false
			-- add(gs.player.stack, sprite)
			-- insertIngredientOrObject(sprite)
			enqueueIngredient(sprite)
		end
	end

	local rSprite = mymget(gs.player.pos + vec2(12, 4))

	if btnp(dirs.x) then
		-- trash
		if rSprite == 21 then
			dequeueIngredient()
		elseif 52 <= rSprite and rSprite <= 57 
			and isIngredient(peekIngredient()) 
			and #gs.coffeePotContents < 5 then
			local ingr = dequeueIngredient()
			if ingr != nil then
				add(gs.coffeePotContents, ingr)
			end
		-- Book
		elseif rSprite == 22 then
			gs.currentAnimation = cocreate(showRecipeBook)
			return

		-- Terminal
		elseif rSprite == 23 then
			gs.currentAnimation = cocreate(showTerminal)
		end
	end

	local frontSprite = mymget(gs.player.pos + vec2(4, 10))
	if btnp(dirs.x) and frontSprite == 26 then
		-- TODO show something for this
		if #gs:getFreeSeats() > 0 and #gs.queuedCustomers > 0 then
			seatCustomer()
		end
	end

	if btnp(dirs.z) and (52 <= rSprite and rSprite <= 57) then
		makeCoffee()
	end


end

function seatCustomer()
	local newqueue = {}
	local cust = gs.queuedCustomers[1]
	for i = 2, #gs.queuedCustomers do
		add(newqueue, gs.queuedCustomers[i])
	end

	gs.queuedCustomers = newqueue
	add(gs.queuedCustomers, lineUpCustomers(1)[1])

	local seatInd = rnd(gs:getFreeSeats())
	gs.seatedCustomers[seatInd] = cust
end


-- Order doesn't matter
function multisetEquals(tbl1, tbl2)
	assert(tbl1 != nil)
	assert(tbl2 != nil)
	local clone1 = {}
	-- local clone2 = {}
	for val1 in all(tbl1) do
		add(clone1, val1)
	end
	-- for val2 in all(tbl2) do
	-- 	add(clone2, val2)
	-- end
	for val2 in all(tbl2) do
		if del(clone1, val2) == nil then
			return false
		end
	end

	return #clone1 == 0
end

function makeCoffee()
	if #gs.coffeePotContents == 0 then
		return
	end

	for recipe in all(gs.currentRecipes) do
		if multisetEquals(gs.coffeePotContents, recipe.ingredientList) then
			enqueueIngredient(recipe.sprite)
			gs.coffeePotContents = {}
			return
		end
	end
	-- Else

	enqueueIngredient(8)
	gs.coffeePotContents = {}
end

function drawGameOverWin()
end

function drawGameOverLose()
	showEnd()

end

function drawCat(cat, posOverride, headShot)
	local pos = posOverride or cat.pos
	palt(0, false)
	palt(14, true)
	palt(15, true)
	local offset = 0
	if headShot then offset = 1 end
	spr(cat.spriteNumber + offset, pos.x, pos.y, 1, 1, cat.facingLeft)
	palt()
end

function drawPlayer()
	drawCat(gs.player)

	palt(0, false)
	palt(15, true)
	palt(13, true)
	-- add(gs.player.stack, 3)
	for i, v in ipairs(gs.player.stack) do
		-- assert(false)
		spr(v, gs.player.pos.x, gs.player.pos.y - i * 4)
	end
	palt()
end



function drawCoffeePot()
	palt(13, true)
	palt(15, true)
	spr(52 + #gs.coffeePotContents, coffeeLocation.x * 8, coffeeLocation.y * 8)
	palt()
end

function drawQueuedCustomers()
	for i = #gs.queuedCustomers, 1, -1 do
		drawCat(gs.queuedCustomers[i], vec2(64, 90 + 8 * i))
	end
end

function drawSeatedCustomers()
	for i = 1, maxSeats do
		local cust = gs.seatedCustomers[i]
		if cust != nil then
			drawCat(cust, vec2(16, 16 + i * 16))
		end
	end
end

function drawParticles()
	for part in all(gs.particles) do
		part.life -= 1
		if part.life <= 0 then
			del(gs.particles, part)
		end
		spr(part.sprite, part.pos.x, part.pos.y)
	end
end

function drawClock()
	local clockX = 8 * 14
	local clockY = 8 * 1
	spr(112 + gs:getTimeState(), clockX, clockY)
end

function _draw()
	cls(0)

	map(0, 0)
	drawCoffeePot()
	drawClock()
	drawPlayer()

	drawQueuedCustomers()

	drawSeatedCustomers()

	-- print(gs.debug)

	drawParticles()

	if gs.isGameOver then
		if gs.gameOverState == gameOverWin then
			drawGameOverWin()
		else
			drawGameOverLose()
		end
		return
	end

	if hasAnimation() then
		local active, exception = coresume(gs.currentAnimation)
		if exception then
			stop(trace(gs.currentAnimation, exception))
		end
	end
	-- Draw
end

__gfx__
00000000000000000000000000000000dfdfdfdfdf555fdfdfdfdfdfdfdfdfdfffffffffffffffff7ffffff777777777777777777d7777777d77777700000000
00000000000000000000000000000000fdfdfdfdf5fff5fdfdfd44fdfdfdcc7cfff0fffffffffffff7ffff7f6666666777777777d7777777d777777700000000
00700700000000000000000000000000fff7ffffff5f5ffffff4444fffff1117fff0ffffffffffffff7ff7ff77777767777777777d7777777d77777700000000
00077000000000000000000000000000ff777ffff5fff5ffff44044fff7ccc1cfff05ffffffffffffff77fff7777d76777777777d7777777d777777700000000
00077000000000000000000000000000f77757fff57775fff440444fffc7cc1cff050ffffffffffffff77fff7777d767777777777d7777777d77777700000000
007007000000000000000000000000007775757ff57775ff440444ffffcc7cfff50500ffffffffffff7ff7ff7777776777777777d7777777d777777700000000
000000000000000000000000000000007777577fd57775df444444dfdfccccdff500505ffffffffff7ffff7f777777677d7d7d7d7d7777777d7d7d7d00000000
00000000000000000000000000000000f77777fdf55555fdf444fdfdfdfdfdfd00505055ffffffff7ffffff777777767d7d7d7d7d7777777d7d7d7d700000000
eeeeeeee5eeeeee5000000000000000000000000ff5555ff5555555555555555dfdfdfdfdfdfdfdf767777777777777677777777fdfffffddfdfdfdf00000000
e5eeeeee55eeee55000000000000000000000000f566665f5444444550000005fdfdcc7cfdfcc7cd56767777777d776666666667dfffffdffdfdfdfd00000000
5eeeeeee55555555000000000000000000000000566556654444444450bb0b05ffff1117fff1117f5556767777d7767677777767fdfffffdffffffff00000000
5eee5e5e55955955000000000000000000000000566666654444444450000005ff7ccc1cf7ccc1cf555556777777677677771767dfffffdfffffffff00000000
e5ee959e55955955000000000000000000000000f656565f4444444450b0bb05ffc7cc1cfc7cc1cf555555577776777677771767fdfffffdffffffff00000000
ee55555e55555555000000000000000000000000f565656f4444444450000005ffcc7cfffcc7cfff555555577767777677777767dfffffdfffffffff00000000
ee5555eee555555e000000000000000000000000f565656fffffffff500bb005dfccccdfdccccfdf7d7d7d7d7677777677777767fdfffffddfdfdfdf00000000
ee5ee5eeee5555ee000000000000000000000000f565656f7777777755555555fdfdfdfdfdfdfdfdd7d7d7d76777777677777767dfffffdffdfdfdfd00000000
eeeeeeee000000000000000000000000f888888f000000000000000000aaaa000000000000000000000000007ffffff677777777000000000000000000444400
e5eeeeee0000000000000000000000008888888800000000088088000aaaaaa0000000000000000000000000f7ffff6677777777000000000000000004444440
5eeeeeee000000000000000000000000f888888f0000000088887880aa5aa5aa000000000000000000000000ff7ff67677777777000000000000000044044044
5eee5e5e000000000000000000000000fff66fff0000000088888780aaaaaaaa000000000000000000000000fff7677677777777000000000000000044400444
e5eeb5be000000000000000000000000fff66fff0000000088888880aaa55aaa000000000000000000000000fff67776fff77fff000000000000000044400444
ee50555e000000000000000000000000ff6666ff0000000008888800aa5aa5aa000000000000000000000000ff677776ff7ff7ff000000000000000044044044
ee5000ee000000000000000000000000f666666f00000000008880000aaaaaa0000000000000000000000000f6777776f7ffff7f000000000000000004444440
ee5ee5ee0000000000000000000000007ffffff7000000000008000000aaaa00000000000000000000000000677777767ffffff7000000000000000000444400
eeeeeeee0eeeeee00000000000000000f88ffffdf88ffffff88ffffff88ffffff88ffffff88ffffffffffffff55555ffffffffffffffffff0000000004444400
e0eeeeee00eeee000000000000000000df8888ffff8888ffff8888ffff8888ffff8888ffff8888fff7777fff5555555f7fffff7fffffffff0000000044040440
0eeeeeee000000000000000000000000f5ffff5ff5ffff5ff5ffff5ff5ffff5ff5ffff5ff544445f744447ff7555557f7474447fffffffff0000000044404440
0eee0e0e00a00a0000000000000000005ffffff55ffffff55ffffff55ffffff55444444554444445777777777777777f7447447fff7447ff0000000044040440
e0eea0ae00a00a0000000000000000005fff7ff55fff7ff55fff7ff5544474455444744554447445777777f7f88888fff74447ffff77777f0000000004444400
ee00000e0000000000000000000000005ff7fff55ff7fff55447444554474445544744455447444577777777f88888fff74447ffff7777ff0000000000000000
ee0000eee000000e00000000000000005ffffff55444444554444445544444455444444554444445777777fff77777fff74447fffff77fff0000000000000000
ee0ee0eeee0000ee0000000000000000f555555ff555555ff555555ff555555ff555555ff555555ff7777ffff77777fff77777ffffffffff0000000000000000
eeeeeeee9eeeeee90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9eeeeee99eeee990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9eeeeeee999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9eee9e9e99b99b990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9eeb9be99b99b990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee99999e999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee9999eee999999e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee9ee9eeee9999ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee7eeeeee70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e7eeeeee77eeee770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7eeeeeee777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7eee7e7e77c77c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e7eec7ce77c77c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee77777e777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee7777eee777777e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee7ee7eeee7777ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600007776000077760000777600007776000077760000777600007776000077760000777600007776000077760000777600000000000000000000000000
07757760077757600777776007777760077777600777776007777760077777600777776007777760077777600757776007757760000000000000000000000000
77757776777557767777557677777776777777767777777677777776777777767777777677777776755777767755777677757776000000000000000000000000
77757776777577767775577677755576777557767775777677757776777577767755777675557776775577767775777677757776000000000000000000000000
77777776777777767777777677777776777755767775577677757776775577767557777677777776777777767777777677777776000000000000000000000000
07777760077777600777776007777760077777600777576007757760075777600777776007777760077777600777776007777760000000000000000000000000
00777600007776000077760000777600007776000077760000777600007776000077760000777600007776000077760000777600000000000000000000000000
__label__
7ffffff77ffffff77ffffff77d777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
f7ffff7ff7ffff7ff7ffff7fd7777777666666676666666766666667666666676666666766666667666666676666666766666667666666676666666766666667
ff7ff7ffff7ff7ffff7ff7ff7d777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777777767
fff77ffffff77ffffff77fffd77777777777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d767
fff77ffffff77ffffff77fff7d7777777777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d767
ff7ff7ffff7ff7ffff7ff7ffd7777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777777767
f7ffff7ff7ffff7ff7ffff7f7d777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777777767
7ffffff77ffffff77ffffff7d7777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777777767
7ffffff77ffffff77ffffff77d777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7776ff77777776
f7ffff7ff7ffff7ff7ffff7fd7777777fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777776f777d7766
ff7ff7ffff7ff7ffff7ff7ff7d777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777777677d77676
fff77ffffff77ffffff77fffd7777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7555777677776776
fff77ffffff77ffffff77fff7d777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777777677767776
ff7ff7ffff7ff7ffff7ff7ffd7777777fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777776f77677776
f7ffff7ff7ffff7ff7ffff7f7d777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7776ff76777776
7ffffff77ffffff77ffffff7d7777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff67777776
7ffffff77ffffff77ffffff77d777777dfdfdfdfdfdfdfdfdfdfdfdfdf555fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf77777776
f7ffff7ff7ffff7ff7ffff7fd7777777fdfdfdfdfdfd44fdfdfdfdfdf5fff5fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdcc7cfdfdfdfdfdfdfdfdfdfdfdfd777d7766
ff7ff7ffff7ff7ffff7ff7ff7d777777fffffffffff4444fffffffffff5f5ffffffffffffff7ffffffffffffffff1117ffffffffffffffffffffffff77d77676
fff77ffffff77ffffff77fffd7777777ffffffffff44044ffffffffff5fff5ffffffffffff777fffffffffffff7ccc1cffffffffffffffffffffffff77776776
fff77ffffff77ffffff77fff7d777777fffffffff440444ffffffffff57775fffffffffff77757ffffffffffffc7cc1cffffffffffffffffffffffff77767776
ff7ff7ffff7ff7ffff7ff7ffd7777777ffffffff440444fffffffffff57775ffffffffff7775757fffffffffffcc7cffffffffffffffffffffffffff77677776
f7ffff7ff7ffff7ff7ffff7f7d777777dfdfdfdf444444dfdfdfdfdfd57775dfdfdfdfdf7777577fdfdfdfdfdfccccdfdfdfdfdfdfdfdfdfdfdfdfdf76777776
7ffffff77ffffff77ffffff7d7777777fdfdfdfdf444fdfdfdfdfdfdf55555fdfdfdfdfdf77777fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfd67777776
7ffffff77ffffff77ffffff77d777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777776
f7ffff7ff7ffff7ff7ffff7fd77777776666666766666667666666676666666766666667666666676666666766666667666666676666666766666667777d7766
ff7ff7ffff7ff7ffff7ff7ff7d777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777d77676
fff77ffffff77ffffff77fffd77777777777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d767777717677777176777776776
fff77ffffff77ffffff77fff7d7777777777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d7677777d767777717677777176777767776
ff7ff7ffff7ff7ffff7ff7ffd7777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777677776
f7ffff7ff7ffff7ff7ffff7f7d777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776776777776
7ffffff77ffffff77ffffff7d7777777777777677777776777777767777777677777776777777767777777677777776777777767777777677777776767777776
7ffffff77ffffff77ffffff77d7777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7ff5555ff77777776
f7ffff7ff7ffff7ff0ffff7fd7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff566665f777d7766
ff7ff7ffff7ff7ff0f7ff7ff7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff5665566577d77676
fff77ffffff77fff0ff70f0fd7777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff5666666577776776
fff77ffffff77ffff0f7a0af7d777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffff656565f77767776
ff7ff7ffff7ff7ffff00000fd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7fff565656f77677776
f7ffff7ff7ffff7ff700007f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff565656f76777776
7ffffff77ffffff77f0ff0f7d77777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7f565656f67777776
7ffffff77ffffff7f888888f7d7777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff6fdfffffd77777776
f7ffff7ff7ffff7f88888888d7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff66dfffffdf777d7766
ff7ff7ffff7ff7fff888888f7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff676fdfffffd77d77676
fff77ffffff77ffffff66fffd7777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff76776dfffffdf77776776
fff77ffffff77ffffff66fff7d777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff67776fdfffffd77767776
ff7ff7ffff7ff7ffff6666ffd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff677776dfffffdf77677776
f7ffff7ff7ffff7ff666666f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff6777776fdfffffd76777776
7ffffff77ffffff77ffffff7d77777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff767777776dfffffdf67777776
7ffffff77ffffff77ffffff77d7777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff777777776f88ffffd77777776
f7ffff7ff7ffff7ff7ffff7fd7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f777d7766df8888ff777d7766
ff7ff7ffff7ff7ffff7ff7ff7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7777f7ff7ffff7ff7ffff7ff7ffff7ff7ff77d77676f5ffff5f77d77676
fff77ffffff77ffffff77fffd7777777fff77ffffff77ffffff77ffffff77ffffff7744447f77ffffff77ffffff77ffffff77fff777767765ffffff577776776
fff77ffffff77ffffff77fff7d777777fff77ffffff77ffffff77ffffff77ffffff7777777777ffffff77ffffff77ffffff77fff777677765fff7ff577767776
ff7ff7ffff7ff7ffff7ff7ffd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f77777777f7ffff7ff7ffff7ff7ffff7ff7ff776777765ff7fff577677776
f7ffff7ff7ffff7ff7ffff7f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff77777777ff7ff7ffff7ff7ffff7ff7ffff7f767777765ffffff576777776
7ffffff77ffffff77ffffff7d77777777ffffff77ffffff77ffffff77ffffff77fff77777717fff77ffffff77ffffff77ffffff767777776f555555f67777776
7ffffff77ffffff7f888888f7d7777777ffffff77ffffff77ffffff77ffffff77ffff7777c1cfff77ffffff77ffffff77ffffff777777776fdfffffd77777776
f7ffff7ff7ffff7f88888888d7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffffc7cc1cff7ff7ffff7ff7ffff7ff7ffff7f777d7766dfffffdf777d7766
ff7ff7ffff7ff7fff888888f7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7cc7c7ff7ffff7ff7ffff7ff7ffff7ff7ff77d77676fdfffffd77d77676
fff77ffffff77ffffff66fffd7777777fff77ffffff77ffffff77ffffff77ffffff77fcccc477ffffff77ffffff77ffffff77fff77776776dfffffdf77776776
fff77ffffff77ffffff66fff7d777777fff77ffffff77ffffff77ffffff77ffffff77f4404477ffffff77ffffff77ffffff77fff77767776fdfffffd77767776
ff7ff7ffff7ff7ffff6666ffd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff440444ff7ffff7ff7ffff7ff7ffff7ff7ff77677776dfffffdf77677776
f7ffff7ff7ffff7ff666666f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff4404445fff7ff7ffff7ff7ffff7ff7ffff7f76777776fdfffffd76777776
7ffffff77ffffff77ffffff7d77777777ffffff77ffffff77ffffff77ffffff77fff444444f5fff77ffffff77ffffff77ffffff767777776dfffffdf67777776
7ffffff77ffffff77ffffff77d7777777ffffff77ffffff77ffffff77ffffff77ffff4447ff5fff77ffffff77ffffff77ffffff7777777765555555577777776
f7ffff7ff7ffff7ff5ffff7fd7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7fffb5bf75fff7ff7ffff7ff7ffff7ff7ffff7f777d776654444445777d7766
ff7ff7ffff7ff7ff5f7ff7ff7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff555057ff7ffff7ff7ffff7ff7ffff7ff7ff77d776764444444477d77676
fff77ffffff77fff5ff75f5fd7777777fff77ffffff77ffffff77ffffff77ffffff77f0005f77ffffff77ffffff77ffffff77fff777767764444444477776776
fff77ffffff77ffff5f7959f7d777777fff77ffffff77ffffff77ffffff77ffffff77f5ff5f77ffffff77ffffff77ffffff77fff777677764444444477767776
ff7ff7ffff7ff7ffff55555fd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff776777764444444477677776
f7ffff7ff7ffff7ff755557f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f76777776ffffffff76777776
7ffffff77ffffff77f5ff5f7d77777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7677777767777777767777776
7ffffff77ffffff7f888888f7d7777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff777777776fdfffffd77777776
f7ffff7ff7ffff7f88888888d7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f777d7766dfffffdf777d7766
ff7ff7ffff7ff7fff888888f7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff77d77676fdfffffd77d77676
fff77ffffff77ffffff66fffd7777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff77776776dfffffdf77776776
fff77ffffff77ffffff66fff7d777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff77767776fdfffffd77767776
ff7ff7ffff7ff7ffff6666ffd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff77677776dfffffdf77677776
f7ffff7ff7ffff7ff666666f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f76777776fdfffffd76777776
7ffffff77ffffff77ffffff7d77777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff767777776dfffffdf67777776
7ffffff77ffffff77ffffff77d7777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7777777765555555577777776
f7ffff7ff7ffff7ff9ffff7fd7777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f777d776650000005777d7766
ff7ff7ffff7ff7ff9f7ff7ff7d777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff77d7767650bb0b0577d77676
fff77ffffff77fff9ff79f9fd7777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff777767765000000577776776
fff77ffffff77ffff9f7b9bf7d777777fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff7776777650b0bb0577767776
ff7ff7ffff7ff7ffff99999fd7777777ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff776777765000000577677776
f7ffff7ff7ffff7ff799997f7d777777f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f76777776500bb00576777776
7ffffff77ffffff77f9ff9f7d77777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7677777765555555567777776
7ffffff77ffffff7f888888f7d777777777777777777777777777777777777777677777777777777777777777777777777777777777777777777777777777777
f7ffff7ff7ffff7f88888888d7777777777777777777777777777777777777775676777777777777777777777777777777777777777777777777777777777777
ff7ff7ffff7ff7fff888888f7d777777777777777777777777777777777777775556767777777777777777777777777777777777777777777777777777777777
fff77ffffff77ffffff66fffd7777777777777777777777777777777777777775555567777777777777777777777777777777777777777777777777777777777
fff77ffffff77ffffff66fff7d777777777777777777777777777777777777775555555777777777777777777777777777777777777777777777777777777777
ff7ff7ffff7ff7ffff6666ffd7777777777777777777777777777777777777775555555777777777777777777777777777777777777777777777777777777777
f7ffff7ff7ffff7ff666666f7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d
7ffffff77ffffff77ffffff7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7
7ffffff77ffffff77ffffff777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
f7ffff7ff7ffff7ff7ffff7f77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
ff7ff7ffff7ff7ffff7ff7ff77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
fff77ffffff77ffffff77fff77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff7ff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff7f7f777fff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffc7cff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f7777777ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f7777f77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff77ff77ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffff5f77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff5ff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff5f7f575fff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff5ff959ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f5555577ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f5555f77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff75ff57ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffff0f77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff0ff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff0f7f070fff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff0ffa0aff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f0000077ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f0000f77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff70ff07ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffff9f77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
fff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff9ff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77fff
ff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff9f7f979fff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ff
f7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff9ffb9bff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7ff7ffff7f
7ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77f9999977ffffff77ffffff77ffffff77ffffff77ffffff77ffffff77ffffff7

__gff__
0000000000000000000001010000000000000000000000000000000100000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0a0a0a0d0b0b0b0b0b0b0b0b0b0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d09090909090909090909091b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d1e061e051e041e071e1e1e1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d0b0b0b0b0b0b0b0b0b1c1c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d0a0a0a0a0a0a0a0a0a0a151b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a240d0a0a0a0a0a0a0a0a0a2b1d1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d0a0a0a0a0a0a0a0a0a1b341b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a240d0a0a0a0a0a0a0a0a0a1b1d1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d0a0a0a0a0a0a0a0a0a1b161b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a240d0a0a0a0a0a0a0a0a0a1b1d1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0d0a0a0a0a0a0a0a0a0a1b171b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a240e0c0c0c0c1a0c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a2c2c2c2c2c2c2c2c2c2c2c2c2c2c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
0112000003744030250a7040a005137441302508744080251b7110a704037440302524615080240a7440a02508744087250a7040c0241674416025167251652527515140240c7440c025220152e015220150a525
011200000c033247151f5152271524615227151b5051b5151f5201f5201f5221f510225212252022522225150c0331b7151b5151b715246151b5151b5051b515275202752027522275151f5211f5201f5221f515
011200000c0330802508744080250872508044187151b7151b7000f0251174411025246150f0240c7440c0250c0330802508744080250872508044247152b715275020f0251174411025246150f0240c7440c025
011200002452024520245122451524615187151b7151f71527520275202751227515246151f7151b7151f715295202b5212b5122b5152461524715277152e715275002e715275022e715246152b7152771524715
011200002352023520235122351524615177151b7151f715275202752027512275152461523715277152e7152b5202c5212c5202c5202c5202c5222c5222c5222b5202b5202b5222b515225151f5151b51516515
011200000c0330802508744080250872508044177151b7151b7000f0251174411025246150f0240b7440b0250c0330802508744080250872524715277152e715080242e715080242e715246150f0240c7440c025
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
011a00000173401025117341102512734120250873408025127341202501734010251173411025087340802505734050250d7340d025147341402506734060250873408025127341202511734110250d7340d025
010d00200c0331b51119515195152071220712145151451518615317151d5151d515125050c03314515145150c0330150519515195150d517205161451514515186153171520515205150d5110c033145150c033
011a00000a7340a02511734110250d7340d02505734050250673406025147341402511734110250d7340d0250a7340a02511734110250d7340d02508734080250373403025127341202511734110250d7340d025
010d00200c0331b511295122951220712207122c5102c51018615315143151531514295150c03329515295150c0330150525515255150d517205162051520515186153171520515205150d5110c033145150c033
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
011800001d5351f53516525275151d5351f53516525275151f5352053518525295151f5352053518525295151f5352053517525295151f5352053517525295151d5351f53516525275151d5351f5351652527515
010c00200c0330f13503130377140313533516337140c033306150c0330313003130031253e5153e5150c1430c043161340a1351b3130a1353a7143a7123a715306153e5150313003130031251b3130c0331b313
010c00200c0331413508130377140813533516337140c033306150c0330813008130081253e5153e5150c1330c0430f134031351b313031353a7143a7123a715306153e5150313003130031251b3130c0333e515
011800001f5452253527525295151f5452253527525295151f5452253527525295151f5452253527525295151f5452353527525295151f5452353527525295151f5452253527525295151f545225352752529515
010c002013035165351b0351d53513025165251b0251d52513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165251b0351d545
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5001e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50030011
0114001800140005351c7341c725247342472505140055352173421725287342872504140045351f7341f725247342472502140025351d7341d72524734247250000000000000000000000000000000000000000
011400180c043287252b0152f72534015377253061528725290152d72530015377250c0432f7253001534725370153c725306152b7252d01532725370153b7250000000000000000000000000000000000000000
0114001809140095351f7341f7252473424725091400953518734187251f7341f72505140055351f7341f7252473424725051400553518734187251f7341f7250000000000000000000000000000000000000000
0114001802140025351f7341f725247342472504140045351f7341f725247342472505140055352b7242b715307243071507140075352b7242b71534724347150000000000000000000000000000000000000000
011400180c0433772534015307252f0152d725306152d7252f0153072534015377250c0433772534015307252f0152d725306152d7252f0153072534015377250000000000000000000000000000000000000000
011400180c0433c7253701534725300152f725306152f7253001534725370153c7250c0433c7253701534725300152f725306152f7253001534725370153c7250000000000000000000000000000000000000000
011400180c043287252b0152f725340153772530615287252901530725370153c7250c043287252901530725370153c72530615287252901530725370153c7250000000000000000000000000000000000000000
011400180c003287052b0052f705340053770530605287052900530705370053c7050c0032f7053000534705370053c705306052b7052d00532705370053b7050000000000000000000000000000000000000000
000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00014344
00 00014344
01 00014344
00 00014344
00 02034344
02 02034344
00 04424344
00 04424344
00 04054344
00 04054344
01 04054344
00 04054344
00 06074344
02 08094344
01 0a0b4344
00 0c0d4344
00 0a0e4344
02 0c0e4344
00 10424344
01 100f4344
00 100f4344
00 10114344
00 12114344
02 12134344
01 14154344
00 14154344
00 16154344
00 16154344
00 18174344
02 16174344
00 19424344
01 191a4344
00 191a4344
00 1b1a4344
00 191c4344
02 1b1c4344
01 1d1e4344
00 1d1f4344
00 1d1e4344
00 1d1f4344
00 21204344
02 1d224344
00 27424344
01 24234344
00 24234344
02 26254344
01 28294344
03 2a2b4344
01 2d304344
00 2e304344
00 2d304344
00 2e304344
00 2d2c4344
00 2d2c4344
02 2e2f4344
01 31324344
00 31324344
00 33344344
02 35364344
01 3738433f
00 3738433f
00 393b433f
00 393c433f
02 3a3d433f


__meta:cart_info_start__
cart_type: game
game_name: Cool Cat Cafe
# Leave blank to use game-name
game_slug: cool-cat-cafe
jam_info:
  - jam_name: TriJam
    jam_number: 120
    jam_url: null
    jam_theme: Coffee
tagline: Work as a purrista at a cat cafe!
time_left: ''
develop_time: '4h 41m 24s'
description: |
  You are a purrista at the Cool Cat Café. Serve as many cats as you can before your shift is over.
 
  * Use the cat register to seat customers
  * Use the computer screen to see what the customers have ordered
  * Use the recipe book to find out how to make an order
  * Use the ingredients counter to grab coffee beans, milk, sugar, or ice
  * Use the coffee pot to put ingredients in it
      * Press Z on the coffee pot to grab the finished drink
  * Use the trash can to discard unneeded ingredients or drinks
  * Activate a seated customer to serve them a drink
  * Your shift is up after 3 minutes

controls:
  - inputs: [ARROW_KEYS]
    desc:  Move
  - inputs: [X]
    desc:  Use / Activate
  - inputs: [Z]
    desc:  Take the drink out of the coffee pot
hints: |
  * When you take an ingredient or drink, it is added to the top of the stack. But when you use an ingredient or drink, it comes off the bottom of the stack
  * If you try to make a drink that isn't in the recipe book, you will create sludge, which will have to be thrown away.
acknowledgements: |
  Font is from Zep's [PICO-8 0.2.2 release notes](https://www.lexaloffle.com/bbs/?tid=41544)  

  Music is from Gruber's [Pico-8 Tunes Vol. 1](https://www.lexaloffle.com/bbs/?tid=29008), Track 12 - Village. 
  Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
to_do: []
version: 0.1.0
img_alt: A cat barista balancing coffee ingredients on its head in a diner with other cats
about_extra: |

  Also created for [Mini Jam 80](https://itch.io/jam/mini-jam-80-cats)  
  Theme: Cats  
  Limitation: 8x8 textures

__meta:cart_info_end__
