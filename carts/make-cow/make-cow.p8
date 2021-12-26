pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--make cow                       v0.1.1
--by caterpillar games 



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

cartdata('caterpillargames_makecow_v0-1')

function saveGame()
	for key, resourceType in pairs(gs.resourceTypes) do
	 	if gs:resourceTypeIsDiscovered(resourceType.name) then
	 		dset(resourceType.id, 1)
	 	else
	 		dset(resourceType.id, 0)
	 	end
	end
end

function loadGame()
	for key, resourceType in pairs(gs.resourceTypes) do
		if dget(resourceType.id) == 1 then

				local newLocation = gs:getNextEmptyCell()
				local resultingResource = createResourceInstance(
					resourceType, newLocation, true)

			if not gs:resourceTypeIsDiscovered(resultingResource.resourceType.name) then
				add(gs.resources, resultingResource)
			end

			if resourceType.name == 'cow' then
				gs.shouldDrawCow = t()
			end

		end
	end
end

titleScreenStates = {
	titleScreen = 'titleScreen',
	instructions = 'instructions',
	solution = 'solution'
}

function _init()
	poke(0x5f2d, 0x1 | 0x2)

	-- This font is by zep, poke code compiled by pancelor on this post https://www.lexaloffle.com/bbs/?pid=101394#p
	poke(0x5f58, 0x81)
	poke(unpack(split"0x5600,6,8,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7,7,0,0,0,0,7,7,7,0,0,0,0,0,7,5,7,0,0,0,0,0,5,2,5,0,0,0,0,0,5,0,5,0,0,0,0,0,5,5,5,0,0,0,0,4,6,7,6,4,0,0,0,1,3,7,3,1,0,0,0,7,1,1,1,0,0,0,0,0,4,4,4,7,0,0,0,5,7,2,7,2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,1,2,0,0,0,0,0,0,3,3,0,0,0,5,5,0,0,0,0,0,0,2,5,2,0,0,0,0,0,0,0,0,0,0,0,0,0,14,14,14,14,0,14,0,0,10,10,0,0,0,0,0,0,0,10,31,10,31,10,0,0,4,30,5,14,20,15,0,0,0,19,11,4,26,25,0,0,6,1,10,6,9,22,0,0,4,4,0,0,0,0,0,0,12,6,6,6,6,12,0,0,6,12,12,12,12,6,0,0,0,4,21,14,21,4,0,0,0,4,4,31,4,4,0,0,0,0,0,0,4,6,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,6,0,0,12,12,6,6,3,3,0,0,31,27,27,27,27,31,0,0,15,12,12,12,12,31,0,0,31,24,31,3,3,31,0,0,31,24,30,24,24,31,0,0,27,27,31,24,24,24,0,0,31,3,31,24,24,31,0,0,31,3,31,27,27,31,0,0,31,24,12,6,6,6,0,0,31,27,31,27,27,31,0,0,31,27,31,24,24,31,0,0,0,6,0,0,6,0,0,0,0,6,0,0,6,3,0,0,0,12,6,3,6,12,0,0,0,0,14,0,14,0,0,0,0,6,12,24,12,6,0,0,15,24,24,14,0,6,0,0,14,17,29,29,1,30,0,0,0,0,30,27,27,23,0,0,3,3,15,27,27,31,0,0,0,0,30,3,3,30,0,0,24,24,30,27,27,30,0,0,0,0,14,27,7,30,0,0,28,6,6,31,6,6,0,0,0,0,30,27,27,30,24,15,3,3,15,27,27,27,0,0,6,0,6,6,6,12,0,0,0,0,12,12,12,12,12,7,3,27,11,7,11,27,0,0,6,6,6,6,6,12,0,0,0,0,10,31,27,27,0,0,0,0,15,27,27,27,0,0,0,0,30,27,27,15,0,0,0,0,15,27,27,15,3,3,0,0,30,27,27,30,24,24,0,0,14,27,3,3,0,0,0,0,30,7,28,15,0,0,6,6,15,6,6,12,0,0,0,0,27,27,27,30,0,0,0,0,27,27,10,4,0,0,0,0,27,27,31,10,0,0,0,0,27,14,27,27,0,0,0,0,27,27,27,30,24,14,0,0,31,12,6,31,0,0,14,6,6,6,6,14,0,0,6,6,12,12,24,24,0,0,14,12,12,12,12,14,0,0,4,10,0,0,0,0,0,0,0,0,0,0,0,31,0,0,2,4,0,0,0,0,0,0,14,27,27,31,27,27,0,0,15,27,15,27,27,15,0,0,14,27,3,3,27,14,0,0,15,27,27,27,27,15,0,0,30,3,15,3,3,30,0,0,30,3,15,3,3,3,0,0,30,3,3,27,27,30,0,0,27,27,31,27,27,27,0,0,15,6,6,6,6,15,0,0,31,12,12,12,12,7,0,0,27,27,7,27,27,27,0,0,3,3,3,3,3,31,0,0,27,31,31,27,27,27,0,0,15,27,27,27,27,27,0,0,14,27,27,27,27,14,0,0,15,27,27,15,3,3,0,0,14,27,27,27,15,30,0,0,15,27,27,7,27,27,0,0,30,3,14,24,24,15,0,0,31,6,6,6,6,6,0,0,27,27,27,27,27,14,0,0,27,27,27,27,14,4,0,0,27,27,27,31,31,27,0,0,27,27,4,27,27,27,0,0,27,27,31,24,24,15,0,0,31,24,12,6,3,31,0,0,12,4,6,6,4,12,0,0,6,6,6,6,6,6,0,0,12,8,24,24,8,12,0,0,0,10,5,0,0,0,0,0,0,4,31,14,10,0,0,0,127,127,127,127,127,0,0,0,85,42,85,42,85,0,0,0,65,127,93,93,62,0,0,0,62,99,99,119,62,0,0,0,17,68,17,68,17,0,0,0,4,60,28,30,16,0,0,0,28,46,62,62,28,0,0,0,54,62,62,28,8,0,0,0,28,54,119,54,28,0,0,0,28,28,62,28,20,0,0,0,28,62,127,42,58,0,0,0,62,103,99,103,62,0,0,0,127,93,127,65,127,0,0,0,56,8,8,14,14,0,0,0,62,99,107,99,62,0,0,0,8,28,62,28,8,0,0,0,0,0,85,0,0,0,0,0,62,115,99,115,62,0,0,0,8,28,127,62,34,0,0,0,62,28,8,28,62,0,0,0,62,119,99,99,62,0,0,0,0,5,82,32,0,0,0,0,0,17,42,68,0,0,0,0,62,107,119,107,62,0,0,0,127,0,127,0,127,0,0,0,85,85,85,85,85,0,0,0,14,4,30,45,38,0,0,0,17,33,33,37,2,0,0,0,12,30,32,32,28,0,0,0,8,30,8,36,26,0,0,0,78,4,62,69,38,0,0,0,34,95,18,18,10,0,0,0,30,8,60,17,6,0,0,0,16,12,2,12,16,0,0,0,34,122,34,34,18,0,0,0,30,32,0,2,60,0,0,0,8,60,16,2,12,0,0,0,2,2,2,34,28,0,0,0,8,62,8,12,8,0,0,0,18,63,18,2,28,0,0,0,60,16,126,4,56,0,0,0,2,7,50,2,50,0,0,0,15,2,14,16,28,0,0,0,62,64,64,32,24,0,0,0,62,16,8,8,16,0,0,0,8,56,4,2,60,0,0,0,50,7,18,120,24,0,0,0,122,66,2,10,114,0,0,0,9,62,75,109,102,0,0,0,26,39,34,115,50,0,0,0,60,74,73,73,70,0,0,0,18,58,18,58,26,0,0,0,35,98,34,34,28,0,0,0,12,0,8,42,77,0,0,0,0,12,18,33,64,0,0,0,125,121,17,61,93,0,0,0,62,60,8,30,46,0,0,0,6,36,126,38,16,0,0,0,36,78,4,70,60,0,0,0,10,60,90,70,48,0,0,0,30,4,30,68,56,0,0,0,20,62,36,8,8,0,0,0,58,86,82,48,8,0,0,0,4,28,4,30,6,0,0,0,8,2,62,32,28,0,0,0,34,34,38,32,24,0,0,0,62,24,36,114,48,0,0,0,4,54,44,38,100,0,0,0,62,24,36,66,48,0,0,0,26,39,34,35,18,0,0,0,14,100,28,40,120,0,0,0,4,2,6,43,25,0,0,0,0,0,14,16,8,0,0,0,0,10,31,18,4,0,0,0,0,4,15,21,13,0,0,0,0,4,12,6,14,0,0,0,62,32,20,4,2,0,0,0,48,8,14,8,8,0,0,0,8,62,34,32,24,0,0,0,62,8,8,8,62,0,0,0,16,126,24,20,18,0,0,0,4,62,36,34,50,0,0,0,8,62,8,62,8,0,0,0,60,36,34,16,8,0,0,0,4,124,18,16,8,0,0,0,62,32,32,32,62,0,0,0,36,126,36,32,16,0,0,0,6,32,38,16,12,0,0,0,62,32,16,24,38,0,0,0,4,62,36,4,56,0,0,0,34,36,32,16,12,0,0,0,62,34,45,48,12,0,0,0,28,8,62,8,4,0,0,0,42,42,32,16,12,0,0,0,28,0,62,8,4,0,0,0,4,4,28,36,4,0,0,0,8,62,8,8,4,0,0,0,0,28,0,0,62,0,0,0,62,32,40,16,44,0,0,0,8,62,48,94,8,0,0,0,32,32,32,16,14,0,0,0,16,36,36,68,66,0,0,0,2,30,2,2,28,0,0,0,62,32,32,16,12,0,0,0,12,18,33,64,0,0,0,0,8,62,8,42,42,0,0,0,62,32,20,8,16,0,0,0,60,0,62,0,30,0,0,0,8,4,36,66,126,0,0,0,64,40,16,104,6,0,0,0,30,4,30,4,60,0,0,0,4,62,36,4,4,0,0,0,28,16,16,16,62,0,0,0,30,16,30,16,30,0,0,0,62,0,62,32,24,0,0,0,36,36,36,32,16,0,0,0,20,20,20,84,50,0,0,0,2,2,34,18,14,0,0,0,62,34,34,34,62,0,0,0,62,34,32,16,12,0,0,0,62,32,60,32,24,0,0,0,6,32,32,16,14,0,0,0,0,21,16,8,6,0,0,0,0,4,30,20,4,0,0,0,0,0,12,8,30,0,0,0,0,28,24,16,28,0,0,0,8,4,99,16,8,0,0,0,8,16,99,4,8,0,0,0"))

	music(39)
	local textDuration = 60
	gs = {
		lastMouseCoords = nil,
		cursorPositionKeyboardOverride = nil,
		titleScreenState = titleScreenStates.titleScreen,
		player = makePlayer(),
		secretWord = {'f','l','u','f','y','c','o','w'},
		secretWordProgress = { letters = {}},
		stage = 0,
		textDuration = textDuration,
		isCowFullyFormed = function(self)
			return gs:getCowScale() == 1
		end,
		getCowScale = function(self)
			if gs.shouldDrawCow then
				local elapsed = (t() - gs.shouldDrawCow) / 3
				return min(1, elapsed)
			else
				return 0
			end
		end,
		dt = 1/30.0,
		resourceTypeIsDiscovered = function(self, resourceTypeName)
			for resource in all(gs.resources) do
				if resource.resourceType.name == resourceTypeName then
					return true
				end
			end
			return false
		end,
		getNextEmptyCell = function(self)
			for j = 0, 7 do
				for i = 0, 7 do
					if gs:getResourceAt(vec2(i, j)) == nil then
						return vec2(i, j)
					end
				end
			end
		end,
		isGameOver = false,
		gameOverState = nil,
		startTime = t(),
		endTime = nil,
		shouldDrawCow = false,
		currentAnimation = nil,
		graspedResource = nil,
		recipeBook = {},
		messageQueue = {},
		messageCountdown = textDuration,
		messageCooldown = textDuration,
		addMessage = function(self, message)
			if #self.messageQueue == 0 then
				self.messageCountdown = self.messageCooldown
			end
			add(self.messageQueue, message)
		end,
		getMatchingRecipe = function(self, staticResource, graspedResource)
			for recipe in all(self.recipeBook) do
				if recipe:matches(staticResource, graspedResource) then
					return recipe
				end
			end
			return nil
		end,
		setGraspedResource = function(self, resource)
			if resource:isDeleteIcon() then
				return
			end
			-- TODO check if successful
			if resource.isRenewable then
				self.graspedResource = createResourceInstance(
					resource.resourceType, vec2(0, 0))
			else
				del(self.resources, resource)
				self.graspedResource = resource
			end
		end,
		getResourceAt = function(self, gridPos)
			for res in all(self.resources) do 
				if res.gridPos == gridPos then
					return res
				end
			end
			return nil
		end,
		getHoveredCoords = function(self)
			local ret = vec2(
				flr(self.cursor.pos.x / 16),
				flr(self.cursor.pos.y / 16)
			)
			-- TODO return nil if there's something there
			return ret
		end,
		getHoveredResource = function(self)
			for res in all(self.resources) do
				if res:isHovered() then
					return res
				end
			end
			return nil
		end,
		cursor = {
			isClicked = false,
			isLeadingClick = false,

			isClickedPreviousFrame = false,
			-- isClickedThisFrame = false,
			updateClick = function(self)
				-- if btn(dirs.x) then
				-- 	-- self.isLeadingClick = true
				-- 	return
				-- elseif btn(dirs.z) then
				-- 	self.isRightClick = true
				-- 	return
				-- end
				self.isLeadingClick = false

				self.isRightClick = (stat(34) & 0x2) > 0 or btn(dirs.z)

				if (stat(34) & 0x1) > 0 or btn(dirs.x) then
					self.isClicked = true
					if not self.isClickedPreviousFrame then
						self.isLeadingClick = true
					end
				else
					self.isClicked = false
				end

				self.isClickedPreviousFrame = self.isClicked
			end,
			pos = vec2(0,0),
			rad = 20,
			stickiness = 10,
			canGrasp = function(self)
				return gs.graspedResource == nil
			end,
			isGrasping = function(self)
				return not (gs.graspedResource == nil)
			end
		},
		nodes = createNodeGrid(5),
		resourceTypes = createResourceTypes(),
		resources = {}
	}

	createRecipeBook()
	gs.resources = initialResources()

	gs.buttons = makeButtons()
	gs.backToTitleScreenButton = makeSingleButton('back to main menu', vec2(10, 100), function()
		gs.titleScreenState = titleScreenStates.titleScreen
	end)

	-- setStage(2)
end

function writeRecipe2(
	resource1Name,
	resource2Name,
	resultName,
	message1,
	message2
	)
	local resourceType1 = gs.resourceTypes[resource1Name]
	local resourceType2 = gs.resourceTypes[resource2Name]
	local resultType = gs.resourceTypes[resultName]
	assert(resourceType1 != nil)
	assert(resourceType2 != nil)
	assert(resultType != nil)
	add(gs.recipeBook,writeRecipe(
		resourceType1,
		resourceType2,
		{resultType},
		{message1, message2}))
	add(gs.recipeBook,writeRecipe(
		resourceType2,
		resourceType1,
		{resultType},
		{message1, message2}))
end

function writeRecipe(
	staticResourceType, 
	graspedResourceType, 
	resultingResourceTypes,
	messages)
	return {
		staticResourceType = staticResourceType,
		graspedResourceType = graspedResourceType,
		resultingResourceTypes = resultingResourceTypes,
		messages = messages,
		matches = function(self, staticResource, graspedResource)
			return staticResource.resourceType.name == self.staticResourceType.name 
				 and graspedResource.resourceType.name == self.graspedResourceType.name
		end
	}
end


function createResourceInstance(resourceType, gridPos, isRenewable)
	assert(resourceType != nil)
	return {
		isDeleteIcon = function(self)
			return self.resourceType.name == 'delete'
		end,
		resourceType = resourceType,
		gridPos = gridPos,
		isRenewable = isRenewable,
		isBeingGrasped = function(self)
			return gs.graspedResource == self
		end,
		pixelPos = function(self)
			return self.gridPos * 16
		end,
		isHovered = function(self)
			local middle = self:pixelPos() + vec2(8, 8)
			return gs.cursor.pos:isWithin2(middle, 8)
		end,
		draw = function(self, posOverride)
			local upperLeft = posOverride or self:pixelPos() -- 
			if fget(self.resourceType.spriteNumber, 0) then
				palt(0, false)
				palt(14, true)
			else
				palt(0, true)
				palt(14, false)
			end
			spr(self.resourceType.spriteNumber, 
					upperLeft.x, upperLeft.y, 
					self.resourceType.dim.x, self.resourceType.dim.y)
			palt()
			if gs.stage == 0 then
				return
			end
			if not self:isBeingGrasped() and self:isHovered() then
				local upperLeft = self:pixelPos()
				rect(upperLeft.x, upperLeft.y, 
					-- TODO use dimensions
					upperLeft.x + 16, upperLeft.y + 16, 7)
			end
		end
	}
end

function createResourceTypes()
	local ret = {
		earth = makeResource(78, 1),
		water = makeResource(106, 2),
		air = makeResource(132 + 64, 3),
		fire = makeResource(110, 4),

		bone = makeResource(138 + 64, 5),
		bonemeal = makeResource(140 + 64, 6),
		sand = makeResource(104, 7),
		eggplant = makeResource(8, 9),
		eggplant_seeds = makeResource(10, 10),
		bird = makeResource(14, 11),
		delete = makeResource(76, 12),
		dirt = makeResource(108, 13),
		moss = makeResource(128 + 64, 14),
		grass = makeResource(142 + 64, 15),
		violet = makeResource(134 + 64, 16),
		flour = makeResource(164 + 64, 17),
		wheat = makeResource(160 + 64, 18),
		ash = makeResource(162 + 64, 19),
		spaghetti = makeResource(166 + 64, 20),
		egg = makeResource(168 + 64, 21),
		spaghetti_squash = makeResource(170 + 64, 22),
		cow_egg = makeResource(172 + 64, 23),
		violet_dye = makeResource(174 + 64, 24),
		cowbird = makeResource(12, 25),
		eggplant_sprout = makeResource(44, 26),
		ink = makeResource(130 + 64, 27),
		cow = makeResource(46, 28)
	}


	for key, val in pairs(ret) do
		val.name = key
	end

	return ret
end


function createRecipeBook()
	writeRecipe2('earth', 'air', 'sand', 'erode rock', 'make sand')
	writeRecipe2('earth', 'water', 'moss', 'moisten rock', 'make moss')
	writeRecipe2('sand', 'water', 'dirt', 'moisten sand', 'make dirt')
	writeRecipe2('sand', 'air', 'bone', 'blow sand', 'reveal bone')
	writeRecipe2('bone', 'earth', 'bonemeal', 'smash bone', 'make bonemeal')
	writeRecipe2('dirt', 'moss', 'grass', 'bury moss', 'make grass')
	writeRecipe2('grass', 'water', 'wheat', 'water grass', 'make wheat')
	writeRecipe2('grass', 'bonemeal', 'violet', 'fertilize grass', 'make violet')
	writeRecipe2('violet', 'earth', 'violet_dye', 'smash violet', 'make violet dye')
	writeRecipe2('wheat', 'earth', 'flour', 'smash wheat', 'make flour')
	writeRecipe2('flour', 'water', 'spaghetti', 'moisten flour', 'make spaghetti')
	writeRecipe2('spaghetti', 'earth', 'spaghetti_squash', 'squash spaghetti', 'make spaghetti squash')
	writeRecipe2('spaghetti_squash', 'violet_dye', 'eggplant', 'dye spaghetti squash', 'make eggplant')
	writeRecipe2('eggplant', 'earth', 'eggplant_seeds', 'smash eggplant', 'make eggplant seeds')
	writeRecipe2('dirt', 'eggplant_seeds', 'eggplant_sprout', 'bury eggplant seeds', 'make eggplant sprout')
	writeRecipe2('eggplant_sprout', 'water', 'egg', 'water eggplant sprout', 'make egg')
	writeRecipe2('egg', 'fire', 'bird', 'warm egg', 'make bird')
	writeRecipe2('wheat', 'fire', 'ash', 'burn wheat', 'make ash')
	writeRecipe2('ash', 'water', 'ink', 'moisten ash', 'make black dye')
	writeRecipe2('bird', 'ink', 'cowbird', 'dye bird', 'make cowbird')
	writeRecipe2('cowbird', 'eggplant_seeds', 'cow_egg', 'feed cowbird', 'make cow egg')
	writeRecipe2('cow_egg', 'fire', 'cow', 'warm cow egg', 'hatch cow')
	
end

function initialResources()
	local ret = {
		createResourceInstance(gs.resourceTypes.earth, vec2(0, 0), true),
		createResourceInstance(gs.resourceTypes.water, vec2(1, 0), true),
		createResourceInstance(gs.resourceTypes.fire, vec2(2, 0), true),
		createResourceInstance(gs.resourceTypes.air, vec2(3, 0), true),
		createResourceInstance(gs.resourceTypes.delete, vec2(7,5), true)
	}

	return ret
end


function makeResource(spriteNumber, id)
	return {
		spriteNumber = spriteNumber,
		id = id,
		dim = vec2(2, 2),
		name = nil
	}
end

-- Technically inverse density
function createNodeGrid(density)
	local ret = {}
	for i = 0, 128, density do
		for j = 0, 3/4*128, density do
			local offset = vec2(rnd(2), rnd(2))
			add(ret, makeNode(vec2(i, j), rnd(16)))
		end
	end
	return ret
end

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
			if self.x == 0 and self.y == 0 then
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
			return sqrt(dx * dx + dy * dy)
		end,
		isWithin2 = function(self, other, value)
			return self:squareDist(other) < value
		end,
		isWithin = function(self, other, value)
			return self:taxiDist(other) <= value or
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
		copy = function(self)
			return vec2(self.x, self.y)
		end
	}

	setmetatable(ret, metaTable)

	return ret
end

function getMouseCoords()
	return vec2(
		stat(32),
		stat(33)
		)
end

function getCursor()
	local ret = gs.cursorPositionKeyboardOverride
		or getMouseCoords()
	return ret - vec2(0, 16)
end

function makeNode(pos, col)
	local pixelCoords = pos / 2 + vec2(0,-2)
	col = sget(pixelCoords.x, pixelCoords.y)
	return {
		initPos = pos:copy(),
		pos = pos,
		col = col,
		maxDisplacement = 1.2,
		initAttachedCursorPos = nil,
		initAttachedSelfPos = nil,
		rad = 1.5,
		isAttached = false,
		draw = function(self)
			local col = self.col
			if self.col == 0 then
				return
			end

			-- local eff = effectivePlayerPos() - vec2(0, 100)
			-- local eff = vec2(0,0)
			line(
				self.pos.x, 
				self.pos.y, 
				self.initPos.x, 
				self.initPos.y, 
				col)
		end
	}
end

function hasAnimation()
	return gs.currentAnimation != nil and costatus(gs.currentAnimation) != 'dead'
end

function setArrowOverride()
	if gs.lastMouseCoords != getMouseCoords() then
		gs.cursorPositionKeyboardOverride = nil
		return
	elseif gs.cursorPositionKeyboardOverride == nil then
		gs.cursorPositionKeyboardOverride = getMouseCoords()
	end

	local offset = vec2(0,0)
	if btn(dirs.up) then
		offset.y -= 1
	end
	if btn(dirs.down) then
		offset.y += 1
	end
	if btn(dirs.left) then
		offset.x -= 1
	end
	if btn(dirs.right) then
		offset.x += 1
	end

	offset = offset:norm()
	local arrowSpeed = 2.5
	gs.cursorPositionKeyboardOverride += offset * arrowSpeed
end

function acceptInput()
	setArrowOverride()
	gs.cursor.pos = getCursor()
	gs.cursor:updateClick()
	gs.lastMouseCoords = getMouseCoords()
	if gs.cursor.isRightClick then
		gs.graspedResource = nil
	end

	checkSecretWord()
end

function checkSecretWord()
	-- gs.secretWordProgress.lastKey = nil
	if stat(30) then
		local key, flag = stat(31)
		if gs.secretWordProgress.lastKey == key then
			return
		end
		if key == ' ' then
			return
		end
		gs.secretWordProgress.lastKey = key

		add(gs.secretWordProgress.letters, key)

		assert(#gs.secretWordProgress < 1)

		if not (key == gs.secretWord[#gs.secretWordProgress.letters]) then
			gs.secretWordProgress.letters = {}
			if key == gs.secretWord[1] then
				add(gs.secretWordProgress.letters, key)
			end
		end

		if #gs.secretWordProgress.letters == #gs.secretWord then
			setStage(2)
		end
	end
end

function _update()
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
		local active, exception = coresume(gs.currentAnimation)
		if exception then
			stop(trace(gs.currentAnimation, exception))
		end

		return
	end

	acceptInput()

	if gs.stage == 0 then
		updateStageZero()
	elseif gs.stage == 1 then
		updateStageOne()
	elseif gs.stage == 2 then
		updateStageTwo()
	end

	if gs:isCowFullyFormed() then
		updateAttached()
		updateAttachmentPos()
	end

end

function updateStageOne()
	checkCursorOperations()
end

function updateStageZero()
	if gs.cursor.isLeadingClick then
		if gs.titleScreenState == titleScreenStates.titleScreen then
			for button in all(gs.buttons) do
				if button:isHovered() then
					button:onclick()
				end
			end
		elseif gs.titleScreenState == titleScreenStates.instructions then
			if gs.backToTitleScreenButton:isHovered() then
				gs.backToTitleScreenButton:onclick()
			end
		end
	end
end

function makePlayer()
	return {
		pos = vec2(64, 64),
		-- pos = vec2(120 * 8, 250),
		speed = 50,
		isFlipped = false,
		draw = function(self)
			spr(40, self.pos.x - 8, self.pos.y - 8, 2, 2, self.isFlipped)
		end,
		acceptInput = function(self)
			local vel = vec2(0,0)
			if btn(dirs.left) then
				self.isFlipped = false
				vel.x = -1
			elseif btn(dirs.right) then
				self.isFlipped = true
				vel.x = 1
			end

			if btn(dirs.up) then
				vel.y = -1
			elseif btn(dirs.down) then
				vel.y = 1
			end

			vel = vel:norm()
			local potential = self.pos + vel * self.speed * gs.dt

			local mapCoords = potential / 8
			if not fget(mget(mapCoords.x, mapCoords.y), 1) then
				return
			end

			self.pos = potential
			-- if not self.shouldDrawCow then
			-- 	self.shouldDrawCow = t()
			-- end

			if fget(mget(mapCoords.x, mapCoords.y), 2) then
				if not gs.shouldDrawCow then
					gs.shouldDrawCow = t()
				end
			else
				gs.shouldDrawCow = false
			end
		end
	}
end

function updateStageTwo()
	gs.player:acceptInput()
end

function printCentered(text, y)
	print(text, (21.5 - #text) / 2 * 6, y, getTextColor())
end

-- TODO inventory
function combineResources(targetResource)
	if targetResource:isDeleteIcon() then
		gs.graspedResource = nil
		return
	end

	local recipe = gs:getMatchingRecipe(targetResource, gs.graspedResource)
	if recipe == nil then return end

	local newLocation = gs:getNextEmptyCell()
	local resultingResource = createResourceInstance(
		recipe.resultingResourceTypes[1], newLocation, true)
	if not gs:resourceTypeIsDiscovered(resultingResource.resourceType.name) then
		add(gs.resources, resultingResource)
		gs.graspedResource = nil
	end

	if resultingResource.resourceType.name == 'cow' then
		gs.shouldDrawCow = t()
	end
	
	add(gs.messageQueue, recipe.messages)
	saveGame()
end

function checkCursorOperations()
	if gs.cursor.isLeadingClick then
		if gs.cursor:isGrasping() then
			local hoveredCoords = gs:getHoveredCoords()
			local targetResource = gs:getResourceAt(hoveredCoords)
			if targetResource == nil then

			else
				combineResources(targetResource)
			end
		else
			local hovered = gs:getHoveredResource()

			if not (hovered == nil) then
				gs:setGraspedResource(hovered)
			end
		end
	end
end

function updateAttachmentPos()
	for node in all(gs.nodes) do
		if node.isAttached then
			local desiredOffset = gs.cursor.pos - node.initAttachedCursorPos
			node.pos = node.initAttachedSelfPos + desiredOffset

			local totalOffset = node.pos - node.initPos
			if totalOffset:length() > node.maxDisplacement then
				node.pos = node.initPos + totalOffset:norm() * node.maxDisplacement
			end

		else

		end
	end
end

function updateAttached()
	if gs.cursor.isClicked then
		if #gs.messageQueue == 0 then
			add(gs.messageQueue, 'pet cow')
		elseif gs.messageQueue[1] == 'pet cow' then
			gs.messageCountdown = max(gs.textDuration / 2, gs.messageCountdown)
		end

		for node in all(gs.nodes) do
			if node.pos:isWithin(gs.cursor.pos, gs.cursor.rad) then
				if not node.isAttached then
					node.isAttached = true
					node.initAttachedCursorPos = gs.cursor.pos:copy()
					node.initAttachedSelfPos = node.pos:copy()
				end
			else
				node.isAttached = false
				node.initAttachedCursorPos = nil
				node.initAttachedSelfPos = nil
			end
		end
	else
		for node in all(gs.nodes) do
			node.isAttached = false
			node.initAttachedCursorPos = nil
			node.initAttachedSelfPos = nil
		end
	end
	
end

function drawGameOverWin()

end

function drawGameOverLose()

end

function drawGrid()
	if gs:getCowScale() < 1 then
		return
	end
	for node in all(gs.nodes) do
		node:draw()
	end
end

function defaultCamera()
	camera(0, -16)
end

function drawHand()
	-- camera()
	local pos = gs.cursor.pos
	local col = 9
	local spriteNumber = 72

	if gs.cursor.isLeadingClick or gs.cursor:isGrasping() then
		col = 10
		spriteNumber = 88
	end

	spr(spriteNumber, pos.x - 4, pos.y - 3, 2, 1)
end

function drawResources()
	for resource in all(gs.resources) do
		resource:draw()
	end
end

function drawResourceGridOutline()
	for i = 0, 8 do 
		for j = 0,5 do
			local upperLeft = 16 * vec2(i, j)
			-- upperLeft += vec2(-8, -8)
			rect(upperLeft.x, upperLeft.y, 
				upperLeft.x + 16, upperLeft.y + 16, 5)
		end
	end	
	line(127, 0, 127, 64 + 32, 5)
end

function drawGraspedResource()
	if gs.graspedResource == nil then return end
	gs.graspedResource:draw(gs.cursor.pos - vec2(8,8))
end

function getTextColor()
	local messageAge = (gs.textDuration - gs.messageCountdown)/gs.textDuration

	if messageAge < 0.05 then
		return 5
	elseif messageAge < 0.1 then
		return 13
	elseif messageAge < 0.15 then
		return 6
	elseif messageAge < 0.85 then
		return 7
	elseif messageAge < 0.9 then
		return 6
	elseif messageAge < 0.95 then
		return 13
	else
		return 5
	end
end

function drawMessages()
	if #gs.messageQueue == 0 then
		return
	end

	if type(gs.messageQueue[1]) == 'string' then
		printCentered(gs.messageQueue[1], -16 + 1)
	else
		printCentered(gs.messageQueue[1][1], -16 + 1)
		printCentered(gs.messageQueue[1][2], -8 + 1)
	end

	gs.messageCountdown -= 1
	if gs.messageCountdown <= 0 then
		del(gs.messageQueue, gs.messageQueue[1])
		gs.messageCountdown = gs.messageCooldown
	end

end

function drawInventory()
	for i = 0, 7 do 
		for j = 6,7 do
			local upperLeft = 16 * vec2(i, j)
			rect(upperLeft.x, upperLeft.y, 
				upperLeft.x + 16, upperLeft.y + 16, 6)
		end
	end	
end

function effectivePlayerPos()
	return gs.player.pos - vec2(64, 64) * gs:getCowScale() + vec2(0, 10)
end

function drawCow()
	local scale = gs:getCowScale()
	local center = vec2(64, 64) * (1-scale)

	sspr(0, 0, 64, 64 * 3/4, 
		center.x, center.y + 5, 128 * scale, 3/4 * 128 * scale)

	pal(2, 128+20, 1)
	pal(12, 128+31, 1)
end

function setStage(stage)
	gs.stage = stage
	if gs.stage == 2 then
		music(-1)
		music(40)
	end
end

function makeSingleButton(text, pos, onclick)
	local dims = {
		height = 11,
		width = #text * 6 + 5,
		tovec = function(self)
			return vec2(self.width, self.height)
		end
	}
	return {
		text = text,
		dims = dims,
		pos = pos,
		onclick = onclick,
		isHovered = function(self)
			local test = gs.cursor.pos
			local topLeft = self.pos
			local botRight = self.pos + self.dims:tovec()
			return topLeft.x < test.x and test.x < botRight.x and
				topLeft.y < test.y and test.y < botRight.y 
		end,
		draw = function(self)
			local pos = self.pos

			local textColor = colors.white
			local backColor = colors.darkgray
			local highlightColor = colors.lightgray
			local darklightColor = colors.darkblue

			if self:isHovered() then
				textColor = colors.white
				backColor = colors.purple
				highlightColor = colors.white
				darklightColor = colors.darkgray
			end

			rectfill(pos.x, pos.y, pos.x + self.dims.width, pos.y + self.dims.height, backColor)
			rect(pos.x, pos.y, pos.x + self.dims.width, pos.y + self.dims.height, darklightColor)
			line(pos.x, pos.y, pos.x, pos.y + self.dims.height, highlightColor)
			line(pos.x, pos.y+self.dims.height, pos.x+self.dims.width, pos.y + self.dims.height, highlightColor)

			print(self.text, self.pos.x + 3, self.pos.y + 3, textColor)
		end
	}
end

colors = {
	black = 0,
	darkblue = 1,
	wine = 2,
	darkgreen = 3,
	brown = 4,
	darkgray = 5,
	lightgray = 6,
	white = 7,
	red = 8,
	orange = 9,
	yellow = 10,
	lightgreen = 11,
	lightblue = 12,
	purple = 13,
	pink = 14,
	tan = 15
}

function hasPlayedBefore()
	return dget(gs.resourceTypes.sand.id) > 0 or dget(gs.resourceTypes.moss.id) > 0
end

function makeButtons()
	local ret = {
		makeSingleButton('new game', vec2(40, 90 - 16), function()
			-- At this stage saving the game will start you from scratch
			saveGame()
			setStage(1)
		end),
		makeSingleButton('how to play', vec2(31, 108 - 16 - 1), function()
			gs.titleScreenState = titleScreenStates.instructions
		end)
	}

	if hasPlayedBefore() then
		add(ret, makeSingleButton('continue', vec2(40, 70 - 16 + 3), function()
			loadGame()
			setStage(1)
		end))
	end

	return ret
end

function myspr(spriteNumber, x, y)
	if fget(spriteNumber, 0) then
		palt(0, false)
		palt(14, true)
	else
		palt(0, true)
		palt(14, false)
	end

	spr(spriteNumber, x, y, 2, 2)
end


function drawStageZero()
	if gs.titleScreenState == titleScreenStates.titleScreen then
		camera(0, -16)

		print('\^t\^wmake cow', 17, 15 - 16, 7)
		if hasPlayedBefore() then
			spr(gs.resourceTypes.cow.spriteNumber, 64-8, 52-8 - 16, 2, 2)
		else
			spr(gs.resourceTypes.cow.spriteNumber, 64-8, 52-8 - 16 + 8, 2, 2)
		end

		for button in all(gs.buttons) do
			button:draw()
		end
	elseif gs.titleScreenState == titleScreenStates.solution then
		-- cls(1)
		local yoff = 0
		local xoff = 20
		local xstart = 3
		for i=33, #gs.recipeBook, 2 do
			local recipe = gs.recipeBook[i]
			myspr(recipe.staticResourceType.spriteNumber, xstart, yoff)
			print('+', xstart + 16, yoff + 5, 7)
			print('=', xstart + 35, yoff + 5, 7)
			print('=', xstart + 36, yoff + 5, 7)
			myspr(recipe.graspedResourceType.spriteNumber, xstart + xoff, yoff)

			myspr(recipe.resultingResourceTypes[1].spriteNumber, xstart + xoff * 2, yoff)
			
			yoff += 16

			if i == 15 then
				yoff = 0
				xstart += 64
			end

		end
	elseif gs.titleScreenState == titleScreenStates.instructions then
		-- cls(3)
		camera(0, -16)
		local xoff = 5
		local yoff = -3 - 16 - 10
		print('\^t\^whow', 0 + xoff, 15 + yoff, 7)    
		print('\^t\^wto', 42 + xoff, 15 + yoff, 7)    
		print('\^t\^wplay', 73 + xoff, 15 + yoff, 7)  

	  drawResourceGridOutline()
		drawResources()

		print('discard resources\nhere (or right\nclick anywhere)', 10, 84 - 16, 7)

		-- print('')
		spr(106, 7, 14, 2, 2)
		spr(88, 14, 22, 2, 1)

		local lineOff = 22
		print('pick up\nresources', 67, 3, 7)
		print('combine\nresources', 67, 3 + lineOff, 7)
		print('make a cow', 67, 3 + lineOff * 2, 7)

		gs.backToTitleScreenButton:draw()
	end

	drawHand()
end

function drawStageTwo()
	camera(gs.player.pos.x - 64, gs.player.pos.y - 64)
	cls(3)
	map(0,0,0,0,128,128)

	gs.player:draw()

	if gs.shouldDrawCow then
		defaultCamera()

		drawCow()
		drawGrid()
		drawHand()
	else
		pal()
	end

end

function drawStageOne()
	defaultCamera()

	drawResourceGridOutline()
	drawResources()
	drawGraspedResource()

	if gs.shouldDrawCow then
		drawCow()
		drawGrid()
	end
	drawHand()

	drawMessages()
end

function _draw()
	cls(0)

	if gs.isGameOver then
		if gs.gameOverState == gameOverWin then
			drawGameOverWin()
		else
			drawGameOverLose()
		end
		return
	end

	if gs.stage == 0 then
		drawStageZero()
	elseif gs.stage == 1 then
		drawStageOne()
	elseif gs.stage == 2 then
		drawStageTwo()
	end

end

__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee0000000000000000
00000000000000cfcccccccccccccc44cc4cc4444ccccc00000000000000000000000000000000000000700000000000eeeeeeeeeeeeeeee0000000000000000
0000000044444cccfcccccccc44cc44444cfccccc4cccccf00000000000000000000000000003000000f000000000070eeee8eeeeeeeeeee0000800000000000
000004444444444ccccccccc44ccc224cccfccccccccc244c0000000000000000000000000b300000000000000f000f0eeee88eeeeeeeeee0000880000000000
000024442224444fccfcccc44ccc4444ccffcccccccccc444cc0000000000000000000000ddd30000000000000700000ee9977eee5eeeeee0099770007000000
00042222222444cfcccccc44cccc444cccccccccccc44cc4444c04442440000000000000d7ddd0000000000000000000ee9e777550556eee0090777777777000
00044442224444fccc4cc4444ccc4ccccfcccccccfc224cc4cc442222244c0000000000d7ddd5000000f700000000000eeee7777000006ee0000777766676700
0004444444224cccc44c224cccccccccccccc4224ffc24444cc222222222400000000ddddddd00000000000000000000eeee7777600766ee0000777767776600
0000444444c24ccc44c2244cccccc4ccccccccc444fcc4444ccc222222424400000d7dddddd5000000000007f0000000eee67767676666ee0006776767666600
000024442ff4444444422ccccccc4ccccccc4cffc2ccfc4424cc224444cc440000d7dddddd5000000000000000000000eee507667767666e0006676677667660
000004444ffc444424224ccccc4ccccccccc424ccc4ccf4422cc42224444c00000dddddddd5000000000000000000f70eee5007777006eee0007677777676000
00000044cffc444222224cccccccccccccccc44cfc244cc2224c4c422444000000ddddddd500000000f0000000000000eeee506700006eee0000766766666000
000000c44cfc44422222ccccccccc4cc4cc4ccccfc444cc4224c4c4444000000000ddddd500000000070000007000000eeee77770066eeee0000777767760000
00000000444444222224ffccccccccccccf4ccccfc444c44442ccc44000000000000d555000000000000000000f00000eeeeeee766eeeeee0000000777000000
0000000004442422222cfc4cccccccc44cfccccfcc44cc444c24cc000000000000000000000000000000000000000000eeeeeee9e9eeeeee0000000909000000
0000000004444422224cc44ccfccccc44ccccfffccc4c44c4c2440000000000000000000000000000000000000000000eeeeeee9e9eeeeee0000000909000000
000000000c4444224444224fccccfcc4cccccfffccc42444444c4000000000000000000000000000111111111111111100000000000000000000000000000000
000000000c444442444222ccccccffcccccccfccccc222cc4444000000000000007000000000070011c77cc11111111100000000000000000060600000000000
00000000cc444442444244cccfccfffccccccfcccc42222c424400000000000000777222002777001cc11c11c1111cc100033330000000000044640000000000
00000000c4444444c42224c4ccccfffcfccfcfccccc2422444c4000000000000000772222227700011111111c1cccc1100b000b3000000000414440000000000
0000000044444424c42424c4cccccffccccfcfc4cc4222222444000000000000000222fffff2220011111111111111110003000300000000e444444000004440
000000004444444cc44424444cccffffcccccfcc4442222244440000000000000022ffffffff2200111111177c1111110076000300000000ee44444444444444
00000000444444ccc44444444ccccfcccfcccc4c4444424444440000000000000027f27ff27f7200111111c111ccccc10077000b303335000044444444444444
00000000c44444ccc4444cc444cccccccfcccc4c24c4424c4444000000000000007efe7ffe7fe70011111c111111111107776000333003000044444444454444
00000000c4444cccc4444c44444ccccccfcccc4424cc44cc444400000000000007e2ffffffff2e70111111111111111107777000330033350004444444454444
0000000c4444444cc4444444444ccccccc4cccc444cc44cc444400000000000000022ffffff02200111111111111111107776000300007600004444444445444
00000004444444ccc444444444cccccccc4cccc4444c44cc444400000000000000222055550222001cc771111111111100770000300007700004444444445444
00000000444444cc444444444ccc4ccccc4ccc444444c44c444400000000000002200667c66220001c11ccc111cc1111000000003000777600004040404eee40
0000000044244444244444444ccc4ccccc4ccc4c44ccc44c44440000000000000000666cd66600001111111ccc11cc7100000000300077770000404000040e40
00000000444442222244c444cccccccc4cccccccc4cc444c42400000000000000000666666660000111111111111111100000000300077760000404000040040
00000000444442222244cccccccccccc4ccccccccccc424444400000000000000000666666660000111111111111111100000000300007700000505000050050
0000000004442222224cccccccccccccc4cccccccccf422444400000000000000000000000000000111111111111111100000000000000000000000000000000
0000000000c42222224cccc44cccfffccccccfcccccf422444000000000000000066666000000000fff33333333fffff00000000000000000000000000000000
0000000000442222224ccc44cf44fcfccffcccfc4ccf42244400000000000000006767666000000011ffffffffff111100000000000000000000000000000000
0000000004444222224cc44cff42cfcccccc44ff44cf422244000000000000006667676760000000111111111111111100000000000000000000777000000000
0000000004442222224cf44fffc22ffffffc24ff44cf42224c00000000000000676767676000000011c111111111111100088000000880000007666777700000
0000000000442222224cc44cfff424ffffc22cffc24c422240000000000000006767777760000000c11111111111111100088000000880000007667666677000
0000000000442222224cc44cfffc44cccc224fff444c42224c00000000000000677777776000000011111111cccc1c1100000880088000000076676666666d00
0000000000422222224cc44ffffcfc44cccccfff444422224c000000000000006677777660000000111111c1c11ccc1100000880088000000066666666666d50
00000000004222222224444cfffccc424cfc4ffc4242222244c0000000000000066666660000000011111c111111111100000008800000000066666666666d50
0000000000442222222244244ccc42222244cffc22222222444000000000000000000000000000001111111111111111000000088000000000d6666666666500
000000000444222222222222222222242222444222222224444000000000000000666660000000001111111111111111000008800880000000d666666666d500
00000000044422222222222222444ccc4442222222222222440000000000000000676766600000001cc7711111111111000008800880000000dd6666666d5500
000000000000000000000000000000000000000000000000000000000000000066676767600000001c11ccc111cc11110008800000088000005dd66ddd555000
000000000000000000000000000000000000000000000000000000000000000067677777600000001111111ccc111111000880000008800000055dd555550000
00000000000000000000000000000000000000000000000000000000000000006777777760000000111111111111111100000000000000000000055500000000
00000000000000000000000000000000000000000000000000000000000000006677777660000000111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000666666600000000111111111111111100000000000000000000000000000000
f11111111111111111111111111111f3333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
3ff11111111111111111cc1111111cf3fff33333333333333333333333333fff0000000000000000000000000000000000000000000000000000000000000000
33f111111111111111111c1111111ff31cfff3333333333333333333333fffc10000000ff000000000000000c00000000049444440040000000008a800000000
33ff11ccc11111111111171111111f331111ff33333333333333333333ff1111000000ffff00000000000000c00000000004a49649444d000000009aa9000000
333fcc111ccc11c11111c7111111ff33111111ff3333333333333333ff11111100000fff7ff000000000000cc1000000004444494444440000000009aa900000
333ff11111177cc11111c111c111f3331111111fff333333333333fff11111110000ffffffff00000000000ccc0000000494464494544640000008009a890000
3333ff11111111111111c1111c1f3333111111c11ff3333333333ff11c1111110000ff7fffa90000000000cccc10000000554454444444400000890098a90000
33333f1111111111111c111111ff333311111c1111f3333333333f1111c11111000ffffffa9f900000000cc7ccc1000006449444444944400000d0099aae0900
33333f1111c11111111c111111f333331111111111f3333333333f111111111100fff7fffff9f90000000c7ccccc00000444444449445450000000988a8e0900
33333ff11c111111111c11111ff333331111111111ff33333333ff111111111100fffffaff9f94000000cc7ccccc100004544494944545d0000009aa88889000
333333fff11111111111c1ffff3333331cc77111111ff333333ff11111177cc100ffffffa9f94e000000cccccccc10000444495444d4545000000eaa88a89000
33333333ff1111111111cff3333333331c11ccc111ccf333333fcc111ccc11c100fff7ff9f9e44000000cccccccc1000044444444545555000000eaaaae89000
3333333333ff1111111fff33333333331111111ccc11ff3333ff11ccc1111111000ffff9f9f4900000000ccccccd00000044444454d455000000098ae8889000
33333333333fffc11fff3333333333331111111111111f3333f111111111111100000ff9ff49000000000cccccd10000000d0544005540000000009888890000
3333333333333fff1f333333333333331111111111111ff33ff111111111111100000000000000000000000dd100000000000000000000000000000d99d00000
3333333333333333f333333333333333111111111111111ff1111111111111110000000000000000000000000000000000000000000000000000000000000000
e4f48d6777b5a2b2b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b347578c9c9c9c8c8c0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f
1f0f1f0f1fc7d7c7d70f1f0f1f0f1f0f1fc7d7c7d70f1f0f1f0f1f0f1f0f1fc7d7c7d70f1f0f1f0f1f0f1f0f1f0f1f8d8c8d8c8d8c8d8d8c9c8c9c8d9de4f48c
e5f576a5b5a5a3b3b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b246568c8c8d8d0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1ec6d6c6d6c6
d6c6d6c6d6c6d6c6d60e1e0e1e0e1e0e1ec6d6c6d60e1e0e1e0e1e0e1e0e1ec6d6c6d60e1e0e1e0e1e0e1e0e1e0e1e8c9c8c9c8c9c8c8c8d9d8d9de4f4e5f59c
8c6777a2b2a2b2a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b347579c8c9c8c0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1fc7d7c7d7c7
d7c7d7c7d7c7d7c7d70f1f0f1f0f1f0f1fc7d7c7d70f1f0f1f0f1f0f1f0f1fc7d7c7d70f1f0f1f0f1f0f1f0f1f0f1f8d8c8d8c8d8c8d8d8c9c8c9ce5f5e4f48c
76a2b2a3b3a3b3a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b246560c1c0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1ec6d6c6d6c6
d6c6d6c6d6c6d6c6d60e1e0e1ec6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d60e1e0e1e0e1e0e1e0e1e0e1e9c8c9c8c9c8c9c9c8d9d8d9d8d9de5f58c
b2a3b3a2b2a2b2b2b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b347570d1d0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1fc7d7c7d7c7
d7c7d7c7d7c7d7c7d70f1f0f1fc7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d70f1f0f1f0f1f0f1f0f1f0f1f8c8d8c8d8c8d8c9c8c9c8c9c0c1ce4f48d
b3a3b3a3b3a3b3b3b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b226360c1c0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e
1e0e1e0e1e0e1e0e1e0e1e0e1ec6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d60e1e0e1e0e1e0e1e0e1e0e1e9c8c9c8c9c8c8d9d8d9d0c1c0d1de5f58c
b2a2b2a2b2a2b2a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b327370d1d0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f
1f0f1f0f1f0f1f0f1f0f1f0f1fc7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d70f1f0f1f0f1f0f1f0f1f0f1f8c9c8c8d9d8d9d8d9d8c0d1de4f49c8c9c
b3a3b3a3b3a3b3a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b226368d8d8c8d0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e
1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0c1ce4f4e4f4e4f40c1ce4f4e4f4e5f58c9c8c
a2b2a2b2a2b2a2b2b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b327378c8c9c8c0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f
1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0d1de5f5e5f5e5f50d1de5f5e5f58c9c8d9d8d
a3b3a3b3a3b3a3b3b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b226368d8c8d8d8c8d0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e
1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e8d8ce4f4e4f4e4f4e4f4e4f48c8d8d9d8c8d8c
a2b2a2b2a2b2b2a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b327378c9c8c8c9c8c0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f
1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f8c9ce5f5e5f5e5f5e5f5e5f59c8c9c8c9c8c9c
a2b2a2b2a2b2b3a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b226368d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d
8c9c8d8c8d8c8d8c8d8c8d8c8d9d8d9d8d9d8d9d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c
a3b3a3b3a3b3a2b2b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b327379c8c9c8c9c9c9c8c8c9c8c9c8c9c8c9c8c9c9c9c8c8c9c8c9c8c9c8c9c
8c9c9c9c8c8c9c8c9c8c9c8c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c9c9c8c8c9c8c9c8c9c8c9c8c9c9c9c8c8c9c8c9c8c9c8c9c8c9c9c9c8c8c9c8c9c8c9c8c
a2b2a2b2a2b2a2b2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b226368c9c8c8d8c8d8c8c8c8d8d8c8d8c8d8c8d8c8d8c8c8c8d8d8c8d8c8d8c8d8c
8d8c8c8c8d8d8c8d8c8d8c8d8d9d8d9d8d9d8c9c8c9c8d8c8d8c8d8c8c8c8d8d8c8d8c8d8c8d8c8d8c8c8c8d8d8c8d8c8d8c8d8c8d8c8c8c8d8d8c8d8c8d8c8d
a3b3a3b3a3b3a3b3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b3a3b327378d9d9c8c9c8c9c9c8c9c8c9c8c9c8c9c8c9c8c9c9c8c9c8c9c8c9c8c9c8c9c
8c9c9c8c9c8c9c8c9c8c9c8c8d9d8d9d8d9d8d9d8d9d8c9c8c9c8c9c9c8c9c8c9c8c9c8c9c8c9c8c9c9c8c9c8c9c8c9c8c9c8c9c8c9c9c8c9c8c9c8c9c8c9c8c
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000eeeeeeeeeeeeeeee000000000000000000000000000000003333333333333333000000000000000000000000000000000000000000000000
0000000000000000eeeeeeee5eeeeeee0070000000000000000000000d0000003333333333333333000000000000000000000000000000000000000b30000000
0000b6b000000000eeeeeee505eeeeee070077770000000000000000d1d0000033333333333333330000000000077000000000000000000000000a3c33300000
000b666b3b300000eeeeeee505eeeeee07077000000000000000000d1dd00000333333333333333300000000007777000000007000777000000bb3b335335000
0007b3a6b3bb3000eeeeee50005eeeee00770000000000600000d00dd2000000333333b3333333330000000000777700000067667056670003badbdb3b333530
00766a633b333500eeeeee50005eeeee0000077770006600000dedd579ddd000333333b333333333000000000777f00000007767777766000433b3b333535340
00b6b63636335350eeeee5000005eeee0000070007007000000ddeeda911dd003333333b333333330000000077fff6500007677676777700094b4b3a35334140
006b3bb3b3b33350eeee500700005eee00007700000700000000dddd2ddd1d003333333b33333b33000000077f66666000076767677667000444444334435450
00d6b33b33533500eeee507000005eee000077000007000000000b3d1d5dd000333333333333b33300000077f6005600000576776656500004f4644454445d40
00db33b33d3d3500eee50070000005ee00000770007700000000c0bd1d3030003333333333333333007707ff6000000000067657776565000644494945154540
00dd3b3b35d35100eee50000000005ee00000077770000000000000bd30000003333333333333333077f7f66000000000007776576667500044f44c4545451d0
005dd365d3551000eee50000000005ee00000000000000000000000c35000000333333333333333307f7f660000000000006767655666000046464464544d440
0005533551110000eeee500000005eee007700077000000000000000b3000000333b333333333333007f66000000000000007775666600000004449454554000
0000055100000000eeee500000005eee00700777660000000000000c350000003333b3333333333300066600000000000000000005560000000004494d400000
0000000000000000eeeee5500055eeee00777700000000000000000b50000000333b333333333333000d60000000000000000000000000000000000450000000
0000000000000000eeeeeee555eeeeee00000000000000000000000b300000003333333333333333000000000000000000000000000000000000000000000000
0000000000000000eeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000400000000eeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004740000000eeeeeeeeeeeeeeee0000000000000000000000000000000000000007f0000000000000000000b00000000007f00000000000000000000000
0090047a95004000eeeeeee57eeeeeee00000007700000000000000000000000000000777f0000000000000000b30000000000777f0000000000000000000000
000904aaa40d0000eeeeee56565eeeee00000076776000000000005555000000000007777f600000000000000aa93000000007744f6000000000000000000000
0000474949400000eeee56756555eeee000077777777000000005577a75000000000777777f600000000000a7a9aa0000000774447f60000000000dfedd00000
00909fa49a50d000eee5656555505eee00076777777f7000000577a999a500000000777777f6000000000aaaa99a40000000774447f600000000dfedddddd000
00094aa4a9440000ee655655555555ee0077777777f777000005a99a9a4a500000077777777f60000000a7aa9aaa000000077747777f6000000deddddddddd00
000044a494400000ee5655555555005e007777777777ff60005797779a44a50000077777777f6000000a7aa99aa4000000077777777f6000000ddddddddd2100
0090974449504000ee5565555550501e0077777777f7665000579999a4f9495000077777777f600000aaa99aaa40000000077777777f60000000ddddddd21000
00094fa49a450000ee655555050005ee007777777677f7000579aaaa444f9f9000077777777f600000aa9aaaaa40000000074777777f6000000000ddd2100000
00009af4a9400000eee55555005001ee00077767f7f66500047999444ff9449000077777777f600000a9aaaaa400000000044777777f60000000000000000000
000004a494000000eeeee55515151eee0000077776f50000047a99aaa444994000077777777f6000000aaaaa4000000000044477777f60000000000000000000
0000004450000000eeeeeeeeeeeeeeee00000000000000000044aaaa999944000000777777f600000000a444000000000000444777f600000000000000000000
0000000400000000eeeeeeeeeeeeeeee00000000000000000000000000000000000007777f6000000000000000000000000004477f6000000000000000000000
0000000400000000eeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000077770077770000777777000077770077770000777777770000000000000000777777000000777777000077770077770000000000000000000
00000000000000077770077770000777777000077770077770000777777770000000000000000777777000000777777000077770077770000000000000000000
00000000000000077777777770077770077770077770077770077770000000000000000000077770077770077770077770077770077770000000000000000000
00000000000000077777777770077770077770077770077770077770000000000000000000077770077770077770077770077770077770000000000000000000
00000000000000077777777770077770077770077777700000077777777000000000000000077770000000077770077770077770077770000000000000000000
00000000000000077777777770077770077770077777700000077777777000000000000000077770000000077770077770077770077770000000000000000000
00000000000000077770077770077777777770077770077770077770000000000000000000077770000000077770077770077777777770000000000000000000
00000000000000077770077770077777777770077770077770077770000000000000000000077770000000077770077770077777777770000000000000000000
00000000000000077770077770077770077770077770077770077770000000000000000000077770077770077770077770077777777770000000000000000000
00000000000000077770077770077770077770077770077770077770000000000000000000077770077770077770077770077777777770000000000000000000
00000000000000077770077770077770077770077770077770000777777770000000000000000777777000000777777000077770077770000000000000000000
00000000000000077770077770077770077770077770077770000777777770000000000000000777777000000777777000077770077770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000004464000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000041444000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000e44444400000444000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000ee4444444444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000004444444444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000004444444445444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000444444445444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000444444444544400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000444444444544400000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000004040404eee4000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000404000040e4000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000040400004004000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000050500005005000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666660000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000676766600000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066676767600000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067676767600000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067677777600000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777777600000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066777776600000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006111111111111111111111111111111111111111111111111111110000000000000000000000000000000000
00000000000000000000000000000000000000006555555555555555555555555555555555555555555555555555510000000000000000000000000000000000
00000000000000000000000000000000000000006555555555555555555555555555555555555555555555555555510000000000000000000000000000000000
00000000000000000000000000000000000000006557777555777757757755555555777755777557757755777755510000000000000000000000000000000000
00000000000000000000000000000000000000006557757757755557757755555557755557757757777757755555510000000000000000000000000000000000
00000000000000000000000000000000000000006557757757777557757755555557755557757757777757777555510000000000000000000000000000000000
00000000000000000000000000000000000000006557757757755557777755555557757757777757757757755555510000000000000000000000000000000000
00000000000000000000000000000000000000006557757757755557777755555557757757757757757757755555510000000000000000000000000000000000
00000000000000000000000000000000000000006557757755777757757755555555777757757757757755777755510000000000000000000000000000000000
00000000000000000000000000000000000000006555555555555555555555555555555555555555555555555555510000000000000000000000000000000000
00000000000000000000000000000000000000006555555555555555555555555555555555555555555555555555510000000000000000000000000000000000
00000000000000000000000000000000000000006666666666666666666666666666666666666666666666666666660000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000006111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000
00000000000000000000000000000006555555555555555555555555555555555555555555555555555555555555555555555510000000000000000000000000
00000000000000000000000000000006555555555555555555555555555555555555555555555555555555555555555555555510000000000000000000000000
00000000000000000000000000000006557757755777557757755555557777755777555555557777557755555777557757755510000000000000000000000000
00000000000000000000000000000006557757757757757757755555555775557757755555557757757755557757757757755510000000000000000000000000
00000000000000000000000000000006557777757757757757755555555775557757755555557757757755557757757777755510000000000000000000000000
00000000000000000000000000000006557757757757757777755555555775557757755555557777557755557777755557755510000000000000000000000000
00000000000000000000000000000006557757757757757777755555555775557757755555557755557755557757755557755510000000000000000000000000
00000000000000000000000000000006557757755777557757755555555775555777555555557755557777757757757777555510000000000000000000000000
00000000000000000000000000000006555555555555555555555555555555555555555555555555555555555555555555555510000000000000000000000000
00000000000000000000000000000006555555555555555555555555555555555555555555555555555555555555555555555510000000000000000000000000
00000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666660000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000101000000000000000000000000000001010000000000000000000000000000000006060000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202000000000000000000000000000002020000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000202000000000000000001010000000002020000000000000000010100000000000000000606000000000101000000000000000006060000
__map__
cecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfc8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c8c9c8c9c9c9c8
dedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfced8c8d8c8c8c8d8
c8cecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfc8dedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdec8c9c8c9c9c8c9
c8dedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfcecfc9c8c9c8c8c9c8
cecfcecfcecfc9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c9c8c9c8dedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfdedfc8d8c8d8d8c8d8
dedfdedfdedfc9d8c8d8c8d8c8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1c8c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8
c8cecfcecfc8c8c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c9f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8
c9dedfdedfc8c9c8c9c8c8d8c8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1c8c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8
cecfcecfcecfc8d8c8d8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c9f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8
dedfdedfdedfc9c8c9c8c8d8c8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1c9c9c9c8c8c9c8c9c8c9c8c9c8c9c9c9c8
c8cecfcecfd8c8d8c8d8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9c9c8c8c9c8c9c8c9c8c9c8c9c9c9c8c8f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1c8c8c8d8d8c8d8c8d8c8d8c8d8c8c8c8d8
c9dedfdedfc8c9c8c9c8c8d8c8d8c8d8c8d8c8d8c8d8c8d8c8d8c8c8d8d8c8d8c8d8c8d8c8d8c8c8c8d8d8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1c9c9c8c9c8c9c8c9c8c9c8c9c8c9c9c8c9
cecfcecfcecfc8d8c8d8c9c8c8c8c9c8c9c8c94e4fc8c9c8c9c8c9c8c9c8c94e4fc8c9c8c9c8c9c9c8c9c8f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f14e4f4e4fc9c8c9c8c9c8c9c8c9c8c8c9c8
dedfdedfdedfc8c9c8c9c8d8d8d8c8d8c8d8c85e5fd8c8d8c8d8c8c9c8c9c85e5fc9c8c9c8c9c8c8c9c8c9e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6d6c6d6c6d6c6d6c6de0e1e0e15e5f5e5fc8d84e4fc8d8c8d8c8d8d8c8d8
d8cecfcecfc8d8c8d8c8c8c9c8c9c9c8c8c9c8c9c8c9c8c9c8c9d8c8d8c8d8c8d8c8d8c8d8c8d8d8c8d8c8f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7d7c7d7c7d7c7d7c7df0f1f0f14e4fc0c14e4f5e5fc9c8c9c8c9c8c8c9c8
c8dedfdedfc9c8c9c8c9d8c8d8c8c8d8d8c8d8c8d8c8d8c8d8c8c8c9c8c9c8c9c8c9c8c9c8c9c84e4fc8c96c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1e0e1e0e16c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1e0e16c6d6c6d6c6d6c6d6c6d6c6de0e1e0e15e5fd0d15e5f4e4f4e4fc8d8c8d8d8c8d8
cecfcecfcecfc9c8c9c8c8c9c8c9c8c9c8c9c8c9c8c9c8c9c8c9d8c8d8c8d8c8d8c8d8c8d8c8d85e5fd8c87c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1f0f1f0f17c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1f0f17c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1d8d9d8d9d8d95e5f5e5f4e4fc0c1c8c9c8
dedfdedfdedfc8d8c8d8d8c8d8c8d8c8d8c8d8c8d8c8d8c8c9c8c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c96c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1e0e1e0e16c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6de0e1e0e1d8d8c8c9c8c9c8c9c8c95e5fd0d1d8c8d8
c9cecfcecfc8c9c8c9c8c8c9c86c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6dc8d8c8d8d8c8d8c87c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1f0f1f0f17c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7df0f1f0f1c9c9d8d9d8d9d8d9d8d9c8c94e4f4e4fc8
c8dedfdedfd8c8d8c8d8d8c8d87c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7dc8c9c8c9c8c9c8c96c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6de0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6d6c6d6c6dc8c8c8d8d8c8d8c8d8c8d8c85e5f5e5fd8
cecfcecfcecfc9c8c9c8c8c9c86c6deaebeaebeaebeaeb6c6d08090809080908096c6dd8c8d8c8d8c8d8c87c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7df0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7d7c7d7c7dc9c9c8c9c8c9c8c9c8c9c8c9c8c94e4fc9
dedfdedfdedfc8d8c8d8d8c8d87c7dfafbfafbfafbfafb7c7d18191819181918197c7dc8c0c1c9c8c9c8c96c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6de0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6d6c6d6c6dc8c8c9c8c9c8c9c8c9c8c9c8c9c85e5fc8
c8cecfcecfc9c8c9c8c9c9c9c86c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6dc8d0d1d8d8c8d8c87c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7df0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7d7c7d7c7dd8d8c8d8c8d8c8d8c8d8c8d8c8d84e4fd8
d8dedfdedfc8d8c8d8c8c8c8d87c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7dc8c9c8c9c9c9c8c86c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1c8c8c9c8c9c8c9c8c9c8c9c8c9c85e5fc8
cecfcecfcecfc8c9c8c9c9c8c9c8c9c8c9c8c9c8c9c8c9c8d8c8c8c8d84e4fd8c8d8c8d8c8d8c8c8c8d8d87c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f17c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1d8d8c8d8c8d8c8d8c8d8c8d8c8d84e4fd8
dedfdedfdedfc9c8c9c8c9c8c966674a4b4a4b6465c0c1c9c8c9c9c8c95e5fc8c9c8c9c8c9c8c9c9c8c9c86c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1c8c8c9c8c9c8c9c8c9c8c9c8c0c15e5fc8
c8cecfcecfc9c8c9c8c9c8d8d976775a5b5a5b7475d0d1c8c9c8c8c9c8c9c8c9c8c9c8c9c8c9c8c8c9c8c97c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f17c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f1f0f1f0f1f0f1d8d8c8d8c8d8c8d8c8d8c8d8d0d14e4fd8
d8dedfdedfc0c1c8c966674a4b2a2b2a2b2a2b2a2b6465d8c866674a4b4a4b6465c8d8c8d8c8d8d8c8d8c8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e16c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1c9c9c9c8c8c9c8c9c8c9c8c9c8c95e5fc8
cecfc8c8c8d0d1d8d976775a5b3a3b3a3b3a3b3a3b7475c8c976775a5b5a5b7475c9c8c9c8c9c8c8c0c1c9f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f17c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1c8c8c8d8d8c82e2fd8c8d8c8d8c84e4fc8
dedfc84e4f66674a4b2a2b2a2b2a2b2a2b2a2b2a2b2a2b4a4b2a2b2a2b2a2b2a2b6465c8d8c8d8d8d0d1c8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e16c6d6c6de0e1e0e16c6d6c6d6c6d6c6d6c6d6c6d6c6de0e1e0e16c6d6c6d6c6d6c6d6c6d6c6de0e1e0e1c9c9c8c9c8c93e3fc8c9c8c9c8c95e5fd8
c84e4f5e5f76775a5b3a3b3a3b3a3b3a3b3a3b3a3b3a3b5a5b3a3b3a3b3a3b3a3b7475c9c8c9c8c8c9c8c9f0f1f0f1f0f1f0f1f0f1f0f1f0f1f0f17c7d7c7df0f1f0f1f0f17c7d7c7df0f1f0f17c7d7c7d7c7d7c7d7c7d7c7d7c7df0f1f0f17c7d7c7d7c7d7c7d7c7d7c7df0f1f0f1d8c8d8c8d8c8d8d8c8d8c8d8d8c0c14e4f
d85e5f66673a3b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b2a2b6465c8d8d8c8d8c8e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e16c6d6c6de0e1e0e1e0e1e0e1e0e1e0e1c8c9c8c9c8c9c8c8c9c8c9c8c8d0d15e5f
__sfx__
013d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
0108080a1307014070180701806018050180401803018020180141801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200280c31500000000000000000000000000f2250000000000000000c3000c415000000000000000000000c3000000000000000000c30000000000000741500000000000c2150000000000000000c30000000
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090004180701a07015070160700c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
0109000418070160701307011070295052650529505265052d505295052950526505225051f5051d505215052e5052b50528505245052d5052d5052850528505265052e5052b5052850524505215051d50521505
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
0116002006055061550d055061550d547061550d055061550d055060550615501155065470d15504055041550b055041550b547041550b055041550b0550b155040550b155045460b1550b055041550b0550b155
010b00201e4421e4321f4261e4261c4321c4221e4421e4321e4221e4221f4261e4261c4421c4321c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c4221c42510125101051012510105
011600001e4401e4321e4221e4250653500505065351a0241a025065351a0250653500505065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010b00201e4421e4361f4261e4261c4421c4421a4451c4451e4451f44521445234452644528445254422543219442194322544225432264362543623442234322144221432234472343625440234402144520445
01160000190241902506535135000653500505065351a0241a025065351a0250653506404065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
010c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010c00200c05312235064303a324064453c3253c3240c0533c6150c0530644006440062353e5253e5250c1530c05311244054451b323054453a0242e5223a0253c6153e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
007800000c8410c8410c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c84018841188401884018840188401884018840188402483124830248302483024830248302483024830
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
0110002005b4008b3009b200ab3009b4008b3006b2002b3001b4006b3006b2003b3002b4003b3005b2007b3008b4009b300ab200ab300ab4009b3008b2007b3005b4003b3002b2002b3002b4002b3004b2007b30
0118042000c260cc260cc2600c2600c2600c260cc260cc260cc2600c2600c260cc260cc260cc2600c2600c260cc2600c2600c2600c260cc260cc260cc2600c260cc2600c260cc260cc2600c260cc260cc2605c26
012000200cb200fb3010b4011b5010b400fb300db2009b3008b400db500db400ab3009b200ab300cb400eb500fb4010b3011b2011b3011b4010b500fb400eb300cb200ab3015b4015b5015b4015b300bb200eb30
012c1900000001372413720137201372015724157201572015722137241872418720187201872018720187201872018725187021a7241c7211c7201c7201c7201c72000000000000000000000000000000000000
012800001c7201f7241f7201f7201f7201f720157241572015720157201572015720157201572215725000001c7241c7201c7201c7201c7201f7241f7201f7201f7201f722157241572015720157201572015720
012800001572015725000001f7241c7241c7201c7201c7201c7201c72215724137211372013720137201372013720137221872418720187201872018720187201872018720187201872218725187001870018705
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
011d0c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0120000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
0112000024e4524e3521f251ff351ff451de3524f2524f3518e451de351fe251d73018e251de351fe451d7321ff4521f3524f252973029e252be352ee4524e3524e2524e3521f451ff351ff251de352473224f35
0112000024e2524e35219451ff352192524e3524e4524f3526f2526f351fe451d73232f4532f352be25297322bf252bf352df253573235e2537e353ae4530e3530e2530e352df452bf352bf2529e253073230f35
011200002de252de352af4528f3528f2526e352df452df3521e2526e3528e452673221e3526e2528e352673228f252af352df253273232e3534e2537e352de252de352de252af3528f2528f3526e252d7322df35
011200000a0550a0350a0250a0550a0350a0250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a0350a0250a0550a035050250a0550a035050250a0550a035050250a0550a035
011200000505505035050250505505035050250505505035050250505505035000250505505035050250505505035000250505505035050250505505035000250505505035000250505505035000250505505035
011200000705507035070250705507035070250705507035070250705507035020250705507035070250705502035020550205502035020250205502035090250205502035090250205502035090250205502035
__music__
00 08094344
00 080a4344
00 0b094344
00 0c0a4344
00 0b094344
02 0c0a4344
01 12134344
00 12134344
00 12134344
00 12134344
00 14154344
00 14154344
02 16174344
01 18424344
00 1b424344
00 1c424344
00 18424344
00 181a4344
00 1b1a4344
00 1c194344
02 181d4344
00 1e424344
00 1f424344
01 1e204344
00 1f204344
00 1e204344
00 1f204344
00 1e214344
00 1f224344
00 1e214344
02 1f224344
00 23424344
00 23424344
01 23244344
00 23244344
00 25294344
00 25264344
00 23274344
02 23284344
03 2a2b2c2d
01 6e6f7031
00 6e6f7032
02 6e6f7033
01 34354344
00 34354344
00 36374344
00 34384344
00 34384344
02 36394344
00 0d117f44
01 0d117f44
00 0d0e7f44
00 0d0e7f44
00 0d107f44
00 0d107f44
02 0d0f7f44
01 3d3a4344
00 3e3a4344
00 3d3b4344
00 3e3a4344
00 3f3c5344
02 3f3c5344
00 7e7f5344
00 7e7f5344

