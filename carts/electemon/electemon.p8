pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--electemon                      v0.1.0
--caterpillar games



gs = nil

battleMusic = 6
gameOverMusic = 4


function myYield()
	yield()
end

function waitFrames(num)
	if num == nil then
		myYield()
	else
		for i = 1, num do
			myYield()
		end
	end
end

function waitTime(seconds)
	waitFrames(seconds * gs.fps)
end

function faintAnimation(mon, reverse)
	if reverse then
		for i = 68, 1, -4 do
			mon.yoff = i
			myYield()
		end
		mon.yoff = 0
	else

		for i = 1, 68, 4 do
			mon.yoff = i
			myYield()
		end
	end
end

-- An animation 
function changeHealth(mon, endHp, deltaHp)
	if endHp == nil and deltaHp == nil then
		return
	end

	if deltaHp != nil then
		endHp = mon.health + deltaHp
	end

	while mon.health != endHp do
		mon.health -= sgn(mon.health - endHp)
		-- if not debug then
			myYield()
		-- end
	end

end

function moveCleanup()
	gs.cur.xoff = 0
	gs.cur.yoff = 0
	gs.orangemon.xoff = 0
	gs.orangemon.yoff = 0

	gs.covid.xoff = 0
	gs.covid.yoff = 0


	gs.curAnimationText = nil
end
	
function basicAttackAnimation()
	--gs.curAnimationText = "test text"
	for i = 0, 9, 3 do
		gs.cur.xoff = i
		waitFrames()
	end

	sfx(43)

	for i = 9, 0, -3 do
		gs.cur.xoff = i
		waitFrames()
	end
end


function basicOpponentAttackAnimation()
	for i = 0, 9, 3 do
		gs.opponent.xoff = -i
		waitFrames()
	end

	sfx(43)

	for i = 9, 0, -3 do
		gs.opponent.xoff = -i
		waitFrames()
	end
end


function waitUntilAcknowledged()
	myYield()
	while not btnp(dirs.x) do
		color(0)
		print('❎', 120-5, 120)
		myYield()
	end
end

function endofgameanimation()
    -- if not debug then
       music(gameOverMusic, musicChannel) 
    -- end
    
	while true do
		cls(0)
		color(7)
		print(" please vote!")
		print(" go to www.vote.org\n to find out how")
        print("\n")
        print("\n")
        print(" credits")
        print(" lead design, lead programming, \n additional art, sfx:\n  caterpillar games\n")
        print(" lead art, additional design,\n additional programming:\n  barrelscrapings\n")
        print(" music:\n  \"pico monsters\" by hcnt\n  licensed under cc by-nc-sa 4.0\n")
		myYield()
	end
end

function animationCoroutineCreate(moveParam)
	--local move = moveParam

	-- local moveList = {
	-- 	moveParam
	-- }
	-- if moveParam.followupMove then
	-- 	moveList[2] = moveParam.followupMove
	-- end

	function inner()

		local move = moveParam

		while move != nil do
			if not move.overrideUsedMessage then
				if #move.name > 10 then
					gs.curAnimationText = { move.ownerName .. ' used ',  move.name }
				else
					gs.curAnimationText = move.ownerName .. ' used ' .. move.name
				end
				-- TODO allow skipping??
				-- waitTime(0.8)
				waitUntilAcknowledged()
			end

			gs.curAnimationText = nil

			if move.animation then
				move.animation()
			end

			changeHealth(gs.cur, move.targetHP.cur, move.targetHP.curDelta)
			changeHealth(gs.opponent, move.targetHP.opp, move.targetHP.oppDelta)

			local isFainted = false
			if gs.cur.health <= 0 then
				gs.curAnimationText = gs.cur.name .. ' fainted'
				faintAnimation(gs.cur)
				isFainted = true
			end

			if move.resultText then
				gs.curAnimationText = move.resultText
			end

			-- waitTime(0.8)
			waitUntilAcknowledged()

			moveCleanup()

			if isFainted then
				gs.isCurFainted = true
			end

			move = move.followupMove

		end

        if gs.orangemon.health == 0 then
			endofgameanimation()
		end

	end

	-- if debug then
	-- 	inner(moveParam)
	-- end

	return cocreate(inner)
end




function makeTestCounterAttack()
	local ret = {
		name = "counter",
		ownerName = 'orangemon',
		animation = basicOpponentAttackAnimation,
		targetHP = {
			cur = 0
		}
	}

	return ret
end

noPPmsg = "No PP!"

bidenmon = 'bidenmon'
faucimon = 'faucimon'
muellermon = 'muellermon'
orangemon = 'orangemon'
pelosimon = 'pelosimon'
population = 'americans'

barrmonBatsItAway = 'barrmon bats it away!\n it had no effect'
whyIsntEverythingPerfect = 'why isn\'t everything perfect?'
bidenFlinched = 'bidenmon flinched and\ncouldn\'t speak'
hrc = 'clintonmon'
covid = 'coronamon'
notVeryEffective = "it's not very effective..."
noEffect = 'no effect!'
superEffective = "it's super effective!"
notTheTime = "now isn't the time to use that!"
butItFailed = 'but it failed!'
notVeryEffectiveDriveFar = notVeryEffective .. '\nthe people drove\n for hours to vote'
recordDonations = superEffective .. '\nrecord donations to bidenmon!'


function makeParty()
    local hrc = {
        sprite = 4,
        health = 100,
        name = hrc,
        moves = makeHrcMoves(),
        xoff = 0,
        yoff = 0
    }
    local muellermon = {
        sprite = 8,
        health = 100,
        name = muellermon,
        moves = makeMuellermonMoves(),
        xoff = 0,
        yoff = 0
    }
    local pelosimon = {
        sprite = 12,
        health = 100,
        name = pelosimon,
        moves = makePelosimonMoves(),
        xoff = 0,
        yoff = 0
    }
    local faucimon = {
        sprite = 64,
        health = 100,
        name = faucimon,
        moves = makeFauciMoves(),
        xoff = 0,
        yoff = 0
    }
    local bidenmon = {
		sprite = 72,
		health = 100,
		name = bidenmon,
		moves = makeBidenmonMoves(),
		xoff = 0,
		yoff = 0
	}
    local population = {
		sprite = 76,
		health = 100,
		name = population,
		moves = makeAmericanPeopleMoves(),
		xoff = 0,
		yoff = 0
	}
    
	local ret = {
		hrc,			-- NOT A BUG - this one is fainted and will be skipped immediately
        hrc,
        muellermon,
        pelosimon,
        faucimon,
        bidenmon,
        population,
    }

	return ret
end

function makeAmericanPeopleMoves()
    
    local voteInPerson = createMove(
        'vote in person', -- name
        population, -- ownerName
        superEffective, -- resultText
        {
            opp = 0
        }, -- targetHP
        function()
        	basicAttackAnimation()
        	changeHealth(gs.opponent, 0)
        	music(-1, musicChannel)
        	sfx(45)
        	waitFrames(10)
        end, -- attack animation
        nil -- followupMove
    )
    
    -- Player has to play all 3 'early' actions before they can vote
    local numMovesLeftBeforeVoting = 3
    local function nonTerminalMove()
        basicAttackAnimation()
        numMovesLeftBeforeVoting -= 1
        if numMovesLeftBeforeVoting <= 0 then
            add(gs.cur.moves, voteInPerson)
        end
    end
    
    local delayTheElection = createMove(
        'delay the election', -- name
        orangemon, -- ownerName
        butItFailed, --resultText
        nil, -- targetHP
        nil,
        nil -- followupMove
    )
    local donate = createMove(
        'donate', -- name
        population, -- ownerName
        recordDonations, -- resultText
        {
            oppDelta = -15
        }, -- targetHP
        nonTerminalMove,
        delayTheElection -- followupMove
    )
    
    local dismantleThePostOffice = createMove(
        'dismantle the post office', -- name
        orangemon, -- ownerName
        'it\'s much harder to vote by\n mail', -- resultText
        nil, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )
    local voteByMail = createMove(
        'vote early by mail', -- name
        population, -- ownerName
        superEffective .. '\nrecord number of early votes', -- resultText
        {
            oppDelta = -15
        }, -- targetHP
        nonTerminalMove,
        dismantleThePostOffice -- followupMove
    )
    
    local closeDropoffBoxes = createMove(
        'close dropoff boxes', -- name
        orangemon, -- ownerName
        notVeryEffectiveDriveFar, -- resultText
        nil, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )
    local voteEarlyInPerson = createMove(
        'vote early by drop-off', -- name
        population, -- ownerName
        superEffective .. '\nrecord number of early votes', -- resultText
        {
            oppDelta = -15
        }, -- targetHP
        nonTerminalMove,
        closeDropoffBoxes -- followupMove
    )
    
    
    if debug then
    	return {donate, voteByMail, voteEarlyInPerson, voteInPerson}    
    else
    	return {donate, voteByMail, voteEarlyInPerson}    
	end    	
end

function makeFauciMoves()
	local incubate = createMove(
		'incubate',
		covid,
		covid .. "'s attack rose"
		)


	local yawn = createMove(
		'yawn',
		orangemon,
		'',
		nil,
		function()
			enterbattlefieldanimation(gs.opponent, 1)
			gs.suppressHealthBars = true

			gs.curAnimationText = {
				'everyone got bored of',
				covid .. ' and it disappeared',
				'like magic'
			}

			waitUntilAcknowledged()

			enterbattlefieldanimation(gs.cur, 2)

			-- enterbattlefieldanimation(gs.cur, 3)

			gs.opponent = gs.orangemon
			enterbattlefieldanimation(gs.opponent, 3)

			-- hack
			gs.isCurFainted = true
		end
		)


	-- Note, not in the move list until later
	local bleachDrink = createMove(
		'full restore',
		faucimon,
		{
			orangemon .. ' drank bleach',
			'and became healthy'
		},
		nil,
		function()

			for i = 1, 60 do
				spr(130, 48, 32, 2, 2)
				myYield()
			end

			if not debug then
				sfx(44)
			end
			changeHealth(gs.cur, 100)


			gs.cur.status = nil
			-- Heal him up for when we switch back
			gs.orangemon.health = 100
		end,
		yawn
		)



	local infect = createMove(
		'infect',
		covid,
		orangemon .. ' was poisoned!',
		{
			cur = 10
		},
		function()
			gs.cur.status = 'psn'
			add(gs.cur.moves, bleachDrink)
		end
		)

	local discredit = createMove(
		'discredit',
		orangemon,
		{
			"your team's defense fell",
			"your team's attack fell",
			"your team's speed fell"
		},
		nil,
		nil,
		-- nil
		infect
	)

	local decades = createMove(
		'decades of experience',
		faucimon,
		{
			"your team's defense rose",
			"your team's attack rose",
			"your team's speed rose"
		},
		nil,
		nil,
		discredit
	)
	

	local slowTesting = createMove(
		'slow down testing',
		orangemon,
		covid .. "'s evasiveness rose",
		nil,
		nil,
		nil
		)

	local toxicSpikes = createMove(
		'toxic spikes',
		covid,
		'hotspots popped up everywhere',
		nil,
		basicOpponentAttackAnimation,
		nil
		)

	local downPlay = createMove(
		'downplay',
		orangemon,
		{
			"your team's defense", "greatly fell"
		},
		nil,
		nil,
		toxicSpikes
		)

	local warn = createMove(
		'warn',
		faucimon,
		faucimon .. ' was ignored',
		nil,
		nil,
		downPlay
		)






	local takeOffMask = createMove(
		'take off mask',
		orangemon,
		"your team's defense fell",
		nil,
		-- mask animation?
		nil,
		incubate
	)

	local putOnMask = createMove(
		'put on mask',
		faucimon,
		"your team's defense rose",
		nil,
		nil,
		takeOffMask
		)





	return {warn, putOnMask, decades}
end



function throwObject(spriteNumber, reverse, fast)
	local startX = 32
	local startY = 64

	if fast then
		if reverse then
			for i = 15, 1, -1 do
				spr(spriteNumber, startX + i * 3, startY - i * 3, 2, 2)
				myYield()
			end
		else
			for i = 1, 15 do
				spr(spriteNumber, startX + i * 3, startY - i * 3, 2, 2)
				myYield()
			end
		end
	else
		if reverse then
			for i = 30, 0, -1 do
				spr(spriteNumber, startX + i * 1.5, startY - i * 1.5, 2, 2)
				myYield()
			end
		else
			for i = 0, 30 do
				spr(spriteNumber, startX + i * 1.5, startY - i * 1.5, 2, 2)
				myYield()
			end
		end
	end


end




function makeHrcMoves()
	local butHerEmails = createMove(
		'but her emails',
		orangemon,
		'hit 3 times!',
		{
			curDelta = 0
		},
		-- TODO more advanced
		function()
			for i = 1, 3 do
				throwObject(164, true, true)
				sfx(43)
				changeHealth(gs.cur, nil, -15)
				waitTime(0.6)
			end
		end,
		nil
		)

	local intimidate = createMove(
		'intimidate',
		orangemon,
		hrc .. ' attack fell',
		nil,
		basicOpponentAttackAnimation,
		nil
		)

	local logic = createMove(
		'logic',
		hrc,
		noEffect,
		{
			--oppDelta = -5
		},
		nil, --basicAttackAnimation,
		intimidate)


	local decades = createMove(
		'decades of experience',
		hrc,
		noEffect,
		nil,
		nil,
		butHerEmails
		)

	local deplorable = createMove(
		'deplorable',
		hrc,
		hrc .. ' hurt herself!',
		{ curDelta = -20 },
		-- TODO animate hurting self
		function ( )
			sfx(43)
		end,
		butHerEmails)

	return {logic, decades, deplorable}
end

function makePelosimonMoves()
    
    local twitterRant = createMove(
        'twitter rant', -- name
        orangemon, -- ownerName
        superEffective, -- resultText
        {
            curDelta = -55
        }, -- targetHP
        function()
        	throwObject(134, true)
        	sfx(43)
        end,
        nil -- followupMove
    )
    local speechTear = createMove(
        'speech tear', -- name
        pelosimon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -1
        }, -- targetHP
        basicAttackAnimation,
        twitterRant -- followupMove
    )
    
    local impeach = createMove(
        'impeach', -- name
        pelosimon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -15
        }, -- targetHP
        function()
        	throwObject(162)
        end,
        twitterRant -- followupMove
    )
    
    
    local stonewall = createMove(
        'stonewall', -- name
        orangemon, -- ownerName
        notVeryEffective, -- resultText
        {
            curDelta = -10
        }, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )
    local negotiate = createMove(
        'negotiate', -- name
        pelosimon, -- ownerName
        notVeryEffective, -- resultText
        nil, -- targetHP
        basicAttackAnimation,
        stonewall -- followupMove
    )
    return {negotiate, speechTear, impeach}
end

function makeMuellermonMoves()

    local witchHunt = createMove(
        'witch hunt', -- name
        orangemon, -- ownerName
        superEffective, -- resultText
        {
            curDelta = -34,
        }, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )

    local obstruct = createMove(
    	'obstruct',
    	orangemon,
    	superEffective,
    	{curDelta = -34},
    	basicOpponentAttackAnimation,
    	nil
    	)

    local investigate = createMove(
        'investigate', -- name
        muellermon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -5 
        }, -- targetHP
        basicAttackAnimation,
        obstruct -- followupMove
    )


    
    local fakeNews = createMove(
        'fake news', -- name
        orangemon, -- ownerName
        superEffective, -- resultText
        {
            curDelta = -34
        }, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )    
    local report = createMove(
        'report', -- name
        muellermon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -5 
        }, -- targetHP
        basicAttackAnimation,
        fakeNews -- followupMove
    )
    
 
    -- TODO animation or something showing throwing the ball
    -- TODO animation or something showing barrmon batting it away
    local throwPokeyBall = createMove(
        'throw pokeyball', -- name
        muellermon, -- ownerName
        barrmonBatsItAway, -- resultText
        nil, -- targetHP
        function()
        	throwObject(128)
        end,
        witchHunt -- followupMove
    )

    return {investigate, report, throwPokeyBall}
end

function makeBidenmonMoves()
    local interrupt = createMove(
        'interrupt', -- name
        orangemon, -- ownerName
        bidenFlinched, -- resultText
        {
            curDelta = -30
        },  -- targetHP, no damage
        basicOpponentAttackAnimation,
        nil -- followupMove
    )

    local debate = createMove(
        'debate', -- name
        bidenmon, -- ownerName
        nil, -- resultText
        nil, -- targetHP
        nil,
        interrupt -- followupMove
    )    
    debate.overrideUsedMessage = true
        
    local dismiss = createMove(
        'dismiss', -- name
        orangemon, -- ownerName
        "\"you're a swamp monster!\"", -- resultText
        {
            curDelta = -30
        }, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )
    local decadesOfExperience = createMove(
        'decades of experience', -- name
        bidenmon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -10
        }, -- targetHP
        basicAttackAnimation,
        dismiss -- followupMove
    )
    
    local cruelty =  createMove(
        'cruelty', -- name
        orangemon, -- ownerName
        superEffective, -- resultText
        {
            curDelta = -30 -- fixme relative
        }, -- targetHP
        basicOpponentAttackAnimation,
        nil -- followupMove
    )
    local compassion = createMove(
        'compassion', -- name
        bidenmon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -5
        }, -- targetHP
        function()
			for i = 1, 60 do
				spr(160, 48, 32, 2, 2)
				myYield()
			end

        end,
        cruelty -- followupMove
    )
    
    local infect = createMove(
        'infect', -- name
        orangemon, -- ownerName
        didntAffectBidenmon, -- resultText
        {
        	curDelta = -10
        }, -- targetHP
    	basicOpponentAttackAnimation,
        nil -- followupMove
    )    
    local covidCallout = createMove(
        'covid callout', -- name
        bidenmon, -- ownerName
        notVeryEffective, -- resultText
        {
            oppDelta = -15
        }, -- targetHP
        basicAttackAnimation,
        infect -- followupMove
    )

    return {debate, decadesOfExperience, compassion, covidCallout}
end

function createMove(name, ownerName, resultText, targetHP, animation, followupMove)
	return {
		name = name,
		ownerName = ownerName,
		preventionMessage = nil,
		maxPP = 1,
		curPP = 1,
		animation = animation,
		resultText = resultText,
		targetHP = targetHP or {},
		followupMove = followupMove,
		overrideUsedMessage = false
	}
end


musicChannel = 1

function _init()
    -- if not debug then
	    music(battleMusic, musicChannel)
    -- end
	gs = {
		suppressHealthBars = false,
		opponent = nil,
		cur = nil,
		orangemon = {
			sprite = 0,
			health = 100,
			name = "orangemon",
			xoff = 0,
			yoff = 0
		},
		covid = {
			sprite = 68,
			health = 100,
			name = covid,
			xoff = 0,
			yoff = 0
		},
		party = makeParty(),
		menuIndex = 1,
		selectedMove = nil,
		curAnimation = nil,
		fps = 30,
		curAnimationText = nil,
		curIndex = 1
	}

	-- Hack to send out clinton
	gs.isCurFainted = true

	if debug then
		gs.curIndex = 6
	end

  	gs.opponent = gs.orangemon
	gs.cur = gs.party[gs.curIndex]

	gs.curAnimation = cocreate(function()
		gs.suppressHealthBars = true

		enterbattlefieldanimation(gs.opponent, 3)

		gs.curAnimationText = orangemon .. ' has entered\nthe battlefield!'

		waitUntilAcknowledged()

		gs.suppressHealthBars = false
	end)
	
end

dirs = {
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

function notNull(val)
	return val != nil
end

function hasAnimation()
	return gs.curAnimation != nil and
		costatus(gs.curAnimation) != 'dead'
end


function acceptInput()
	if hasAnimation() then
		return
	end


	if btnp(dirs.up) then
		if gs.menuIndex > 1 then
			gs.menuIndex -= 1
		end
	end
	if btnp(dirs.down) then
		if gs.menuIndex < #gs.cur.moves then
			gs.menuIndex += 1
		end
	end

	if btnp(dirs.x) then
		local move = gs.cur.moves[gs.menuIndex]
		if notNull(move) then
			if move.preventionMessage then
				-- TODO 				
			else
				gs.selectedMove = move
			end
		end
	end
end

function _update()
	acceptInput()


	executeMove()
end

function enterbattlefieldanimation(mon, reverse)
	if reverse == 1 then
			for i = 0, 80, 5 do
				mon.xoff = i
				myYield()
			end
	elseif reverse == 2 then
		for i = 0, -80, -5 do
			mon.xoff = i
			myYield()
		end
	elseif reverse == 3 then
			for i = 80, 0, -5 do
				mon.xoff = i
				myYield()
			end
	else
		for i = -80, 0, 5 do
			mon.xoff = i
			myYield()
		end
	end
end

function checkFaint()
	if not gs.isCurFainted or hasAnimation() then
		return
	end

	gs.isCurFainted = false

	gs.curIndex += 1

	gs.cur = gs.party[gs.curIndex]

	gs.menuIndex = 1

	if gs.cur.name == faucimon then
		gs.curAnimation = cocreate(function()
			gs.suppressHealthBars = true

			gs.cur.xoff = -100

			enterbattlefieldanimation(gs.opponent, 1)
			-- for i = 0, 80, 5 do
			-- 	gs.opponent.xoff = i
			-- 	myYield()
			-- end

			enterbattlefieldanimation(gs.cur)
			-- for i = -80, 0, 5 do
			-- 	gs.cur.xoff = i
			-- 	myYield()
			-- end

			gs.opponent = gs.covid
			gs.cur.health = gs.orangemon.health

			faintAnimation(gs.opponent, true)


			gs.curAnimationText = covid .. ' has entered\nthe battlefield!'
			waitUntilAcknowledged()
			
			gs.suppressHealthBars = false
		end)
	-- elseif gs.cur.name == bidenmon then
	-- 	gs.opponent = gs.orangemon

	-- 	gs.suppressHealthBars = false
		-- gs.curAnimation = cocreate(function()
		-- 	gs.suppressHealthBars = true



		-- 	gs.opponent = gs.covid
		-- 	gs.cur.health = gs.orangemon.health

		-- 	faintAnimation(gs.opponent, true)

		-- 	gs.curAnimationText = covid .. ' has entered\nthe battlefield!'
		-- 	waitUntilAcknowledged()
			
		-- 	gs.suppressHealthBars = false
		-- end)	
	else
			gs.suppressHealthBars = false

		gs.opponent = gs.orangemon
		gs.curAnimation = cocreate(function() 
			gs.curAnimationText = "you sent out " .. gs.cur.name

			for i = -80, 0, 5 do
				gs.cur.xoff = i
				myYield()
			end

			waitUntilAcknowledged()

			if gs.cur.name == population then
				gs.curAnimationText = population .. ' were poisoned\nby toxic spikes!'
				waitUntilAcknowledged()
				gs.cur.status = 'psn'
			end

		end)
	end
	-- TODO animation
end



function executeMove()
	if gs.selectedMove == nil then
		return
	end

	gs.selectedMove.curPP -= 1
	if gs.selectedMove.curPP == 0 then
		gs.selectedMove.preventionMessage = noPPmsg
	end
	-- gs.cur.health = gs.selectedMove.targetHP.cur
	-- gs.opponent.health = gs.selectedMove.targetHP.opp

	gs.curAnimation = animationCoroutineCreate(gs.selectedMove)

	-- if gs.selectedMove.animation then
	-- 	gs.curAnimation = cocreate(gs.selectedMove.animation)
	-- end


	gs.selectedMove = nil
end

function drawmenu()
	-- color(7)
	-- rect(0, 97, 127, 127)
	color(0)
	rect(1, 98, 126, 127)

end

menuXOff = 8
menuYOff = 96 + 4

function drawMenuContents()

	local xoff = menuXOff --8
	local yoff = menuYOff -- 96 + 4
	local moveHeight = 7

	color(0)

	for i = 1, 4 do
		local move = gs.cur.moves[i]
		
		local endy = yoff + i * moveHeight - moveHeight
		
		if move == nil then
			print('--', xoff, endy)
		else
			text = move.name
			print(text, xoff, endy)
			print(move.curPP .. '/' .. move.maxPP, 110, endy)
		end

		if i == gs.menuIndex then
			spr(255, xoff - 5, endy - 1)
		end
	end
end


function drawAnimationText()		
	if gs.curAnimationText then
		color(0)
		if type(gs.curAnimationText) == "string" then
			print(gs.curAnimationText, menuXOff, menuYOff)
		else
			for i = 1, #gs.curAnimationText do
				print(gs.curAnimationText[i], menuXOff, menuYOff + i * 7 - 7)
			end
		end
	end
end

function drawhealth(x, y, mon)
	
	if gs.suppressHealthBars then
		return

	end

	local xoff = 7
	local yoff = 13

	color(0)
	local name = mon.name
	if mon.name == faucimon then
		name = 'orangemon'
	end
	
	print(name, x + xoff - 2, y + yoff - 7)
	if mon.status then
		color(13)
		print(mon.status, x + xoff - 2 + 40, y + yoff - 7)
		color(0)
	end

	

	local barlen = 50
	local barheight = 3

	line(x + xoff, y + yoff, x + xoff + barlen, y + yoff)
	line(x + xoff - 1, y + yoff + 1, x + xoff - 1, y + yoff + barheight - 1)
	line(x + xoff + barlen + 1, y + yoff + 1, x + xoff + barlen + 1, y + yoff + barheight - 1)
	line(x + xoff, y + yoff + barheight, x + xoff + barlen, y + yoff + barheight)


	color(3)
	local len = mon.health / 100 * barlen
	if len > 0 then
		rectfill(x + xoff, y + yoff + 1, x + xoff + len, y + yoff + barheight - 1)
	end

	if mon.name == faucimon then
		y += 6
		color(0)
		line(x + xoff, y + yoff, x + xoff + barlen, y + yoff)
		line(x + xoff - 1, y + yoff + 1, x + xoff - 1, y + yoff + barheight - 1)
		line(x + xoff + barlen + 1, y + yoff + 1, x + xoff + barlen + 1, y + yoff + barheight - 1)
		line(x + xoff, y + yoff + barheight, x + xoff + barlen, y + yoff + barheight)

		color(3)
		len = barlen
		rectfill(x + xoff, y + yoff + 1, x + xoff + len, y + yoff + barheight - 1)

		color(0)
		print(faucimon, x + xoff + 22, y + yoff + 6)

	end


end

function drawsprites(x, y, mon)

	local sp = mon.sprite
	local sx, sy = (sp % 16) * 8, (sp \ 16) * 8

	-- just don't want to be able to draw lower (i.e. fainting)
	clip(0, y, 128, 64)

	sspr(sx, sy, 32, 32, x + mon.xoff, y + mon.yoff, 64, 64)
	clip()
end

debug = false

function _draw()
	cls(6)

	palt(2, true)
	palt(0, false)

	drawmenu()

	drawhealth(0, 0, gs.opponent)
	-- if not gs.isCurFainted then
		drawhealth(65, 65, gs.cur)
	-- end
		
	drawsprites(65, 0, gs.opponent)
	if not gs.isCurFainted then
		drawsprites(0, 33, gs.cur)
	end


	checkFaint()


	if hasAnimation() then

		local active, exception = coresume(gs.curAnimation)

		if debug and exception then
			cls(0)
			color(7)
			stop(trace (gs.curAnimation, exception))
		end

		drawAnimationText()
		-- if not hasAnimation() then
		-- 	moveCleanup()
		-- end
	else

		-- if debug then
		-- 	if gs.curAnimation then
		-- 		assert(false)
		-- 	end
		-- end

		drawMenuContents()
	end
	
end


__gfx__
222222222222ffffffffffff22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222ffffffffffff222222222222222222222222229999922222222222222222222222222222222222222222222222222222222222444442222222222
2222222222f999999999ff2222222222222222222222999994449942222222222222222222777777772222222222222222222222222244444444444222222222
222222222f99999999999ff222222222222222222299944499949949922222222222222277777777777722222222222222222222224444444444444442222222
22222222299707999707999222222222222222222999449999949949992222222222222777777777777722222222222222222222244444444444444444222222
2222222229999999999999922222222222222222999949994494994999222222222222777777777777777222222222222222222244449994444ffff444222222
2222222229999999999999922222222222222229994499994999944992222222222222777777777777fff222222222222222222494499444444444fff2222222
222222222299998899999922222222222222222994499944499444fff222222222222277777777777ff55522222222222222222994494449944444fff2222222
22222222229999888999992222222222222222999449994999999ffff2222222222222777777777fff555522222222222222224944494449444444ffff222222
2222222200099999999990002222222222222299944994499999ffffff22222222222777775777fffff7722222222222222222494449449944944fffff222222
2222222011107777077701110222222222222299949944999999ffffff22222222222777755577fffff70f2222222222222222994494449449944ff70f222222
222222011100777080777011022222222222229944999999999ffffff722222222222757755ffffffffffff22222222222222294449444944944ffffff222222
222220101107000888000011002222222222229949999999999fffff7022222222222555ff55ffffffffffff2222222222222294449444944944fffffff22222
22222011010777708077701101022222222222944999444499ffffffff2222222222255ff555fffffffffffff222222222222294449449944944fffffff22222
22220011010777088807701011002222222222999994499999fffffffff222222222255ffffffffffffffffff222222222222294449449444944ffffffff2222
2220011110077708880770011110222222222299944499999fffffffffff222222222555fffffffffffffffff222222222222294449449444944ffffffff2222
222011111107770888077011101002222222229944999999ffffffffffff2222222225555ffffffffffffff22222222222222294449449449944ffffff222222
22011110107777088807001111010022222222994949499fffffffffff222222222222ffffffffffffffff222222222222222294449949449944ffffff222222
2001110010777708880700111101102222222299944949999ffffffffe2222222222222ffffffffffff000222222222222222244444949444944ffff88222222
2011110010777708880701111101102222222229994944999fffffffee2222222222222ffffffffffffffff22222222222222224444949444994ffffff222222
2011110110777708880701111101102222222222999994ffffffffffff22222222222222ffffffffffffffff22222222222222224449944444944fffff222222
2011100110000008880001111101102222222222222ffffffffffffff222222222222222ffffffffffffffff22222222222222222244444444944444ff222222
2000020000111108880100000001102222222222222ffffffffffff222222222222222222ffffffffff222222222222222222222222ffffff444444422222222
299922011111110888011111102010222222222222ffffffffffff222222222222222222277777777772222222222222222222222200000000ffff2222222222
9299220011111108880111110020002222222222000000000000ff2222222222222222277777777777777222222222222222222200eeeeeee000ff2222222222
222222201111111080111111022999222222000008888888888000002222222222222000000000000000002222222222222200000eeeeeeeeee0000022222222
22222220111111110111111102299222222008888888888888888880000222222220000000000000000000000000222222200eeeeeeeeeeeeeeeeee000022222
2222222011111111111111110222222222008888888888888888888888000222000000000000000000000000000000022200eeeeeeeeeeeeeeeeeeeeee000222
222222201111111000111111022222220008888888888888888888888088802200000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeee0eee022
2222222011111110201111110222222208888888888888888888888880888002000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee0eee002
2222222000000000200000000222222208888888888888888888888880888800000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee0eeee00
2222222000000000200000000222222208888888888888888888888808888880000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeee0eeeeee0
222222ffffffffffff22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222fffffffffffffff2222222222222222222222222222882222222222222222222222222277777772222222222222222222222222222222222222222222222
2222ffffffffffffffff222222222222222222228222000000002822222222222222222227777777777777222222222222222222222222222222222222222222
222fffffffff9ffffff2222222222222222222288000555555550002282222222222222777777777777777722222222222222222222222222222222222222222
22fffffff999999ff22222222222222222222228055555555555555088222222222222277777777777777ff22222222222222222222222222222222222222222
22fffffff999999922222222222222222222222055555555558555550222222222222277777777777777ffff2222222222222222222222222222222222222222
22ffffff999999992222222222222222288222055555555558885555502222222222227777777777777fffff2222222222222222222222222222222222222222
22ffffff999999702222222222222222288880555855555558855555550882222222227777777777777ffffff222222222222222222222222222222222222222
22ff90ff99999999222222222222222222280555585555558555555555508822222227777777777777fffffff222222222222222222222222222222222222222
22f9090f9999999992222222222222222220555588855555555555555555082222222777777777777ffffffff222222222222222222222222222222222222222
222909999999999992222222222222222220585558855555555555555855022222222777777777777fffff7ff222222222222222222222222222222222222222
22290999999999992222222222222222222058555555555555555555588502222222277777777f07fffff70ff222222222222222222222222222222222222222
2222909999999999222777772222222222055885555555555555555888855022222227777777f0f7ffffffffff22222222222222222222222222222222222222
222299999999999222777777772222222205555555555855558555555555502222222777777ff0ffffffffffff22222222222222222222222222229999222222
22277799999999992777777777222222280555555555885555885555555550222222277777fff0ffffffffffff22222222222222555222222222999999922222
20000777777779992777777fff222222280555555558885555555555555550822222277777ffff0ffffffffffff2222222242225555522222222999999f22222
0111100000007722777777ffff022222220555555555555555555555555588822222277777fffffffffffffffff222222244422554402222222999999f0f2222
11111111111100027777000000702222220555555555555855555555555550822222227777fffffffffffffff2222222244444254477222222299999ffff2222
1111111111111100777887ffff0f222222055555555555555555855555555022222222777ffffffffffff2fff2222222244444244777222222299999ffdd2222
1111111111111111778ff88fff8822222205588555555555558885555555502222222222ffffffffffffff22222222222f444f22447222222299999ffdd22222
1111111111111111ff8f0f888888222222205855555555555558855885550222222222227fffffffff0ffffff22222222fffff0ddddd20000099999ffdd22222
1111111111111111ff8fff88888822222220555555555555555555588855022222222222777777fffff0fffff22222222ff7fffdddd000444400999fff222222
1111111111111111ff88888888822222228055555888555558555555855508822222222007777777ffff0ffff22222222fff772dd00444444440099eee022222
11111111111111111ffff8888882222222280555588555555885555555502822222222055007777777fff222222222222fff77dd004444444444009e0ee02222
11111111111111111fffff8888222222222220555555555555855555550222222222205555500777777772222222222222fff2dd044444444444400e0ee02222
11111111111111111177777772222222222222085555555555885555502222222222055555555007777772222222222233333330444444444444440e0eee0222
11111111111111110000000000222222222228805555555555555555088222222220555555555550077770222222222233333304444444444444440880ee0222
11111111111111100000000000000222222888820555555555555550228822222205555555555555507701022222222233333304444444444044488880eee022
1111111111111000000000000000002222228882200085555555000222882222220555555555555555001110222222223333330444444444040884408e0ee022
1111111111110000000000000000000222222822222880000000882222222222205555555555555555501111022222223333330444444880440444408e0eef02
111111111110000000000000000000002222222222288222222228222222222205555555555555555555011102222222333333044444844044044440eee0fff0
111111111100000000000000000000002222222222222222222222222222222255555555555555555555501102222222333333044444444404444440eeee0ff0
2222255555222222221112222222222222227777777722222222222222222222222222222222ffffffffffff22222222222222222222ffffffffffff22222222
222552252255222222777222222222222277777777777722222222222222222222222222222ffffffffffff22222222222222222222ffffffffffff222222222
225252252252522222777772222222222770077777700772c222222222ccc2222222222222f999999999ff22222222222222222222f999999999ff2222222222
252252252252252222777777777222227700007777000077ccc222222ccccc22222222222f99999999999ff222222222222222222f99999999999ff222222222
252252252252252222777777227772227700007777000077ccccc222ccccccc22222222229970799970799922222222222222222299707999707999222222222
552252252252255222777777722272227770077777700777222cccc2cccccccc2222222229997999997999922222222222222222299979999979999222222222
5522520002522552227777777722772227777777777777722cc2ccccccccccc22222222229999988899999922222222222222222299999999999999222222222
5522520902522552227778888887772222777770077777222ccccccccccccc222222222222999999999999222222222222222222229999889999992222222222
552252000252255222998811118899222222777007777222222cccccccccc2222222222200099999999990002222222222222222229999888999992222222222
5522522522522552221181777118112222277777777777222222ccccccccc2222222222011107777077701110222222222222222000999999999900022222222
252252252252252222118171171811222227777777777722c22cccccccccc2222222220111007770807770110222222222222220111077770777011102222222
252252252252252222118177711811222227070707070722ccccccccccccc2222222201011070008880000110022222222222201110077708077701102222222
225252252252522222cc81711718cc2222270000000007222ccccccccccc22222222201101077770807770110102222222222010110700088800001100222222
222552252255222222cc81777118cc22222777777777772222ccccccccc222222222001101077708880770101100222222222011010777708077701101022222
2222255555222222227788111188772222222777777722222222ccccc22222222220011110077708880770011110222222220011010777088807701011002222
22222222222222222227788888877222222222222222222222222222222222222220111111077708880770111010022222200111100777088807700111102222
228888222288882227777777777777722222222222222222cccccccccccccccc2200111010077708880770111001022222201111110777088807701110100222
288888822888888227777777777777722222222222222222cccccccccccccccc2201111010777708880700111101002222011110107777088807001111010022
888888888888888827000000000007722222222222222222ccccccccc7777ccc2001110010777708880700111101102220011100107777088807001111011022
88888888888888882777777777777772777777777777777777cccccc777777c72011110010777708880701111101102220111100107777088807011111011022
888888888888888827000000000000727777777777777777777cccc77777777c2011110110777708880701111101102220111101107777088807011111011022
888888888888888827777777777777725577777777777755c777ccc77777777c2011100110000008880001111101102220111001100000088800011111011022
888888888888888827000000000007727755777777775577c777cc77777777772000020000111108880100000001102220000200001111088801000000011022
288888888888888227777777777777727777555775557777cc7777777777777c2999220111111108880111111020102229992201111111088801111110201022
288888888888888227000000000777727775777557775777ccc77777777777cc9299220011111108880111110020002292992200111111088801111100200022
22888888888888222777777777777772775777777777757777777777777777cc2222222011111110801111110229992222222220111111108011111102299922
228888888888882227077000000000727577777777777757c777777777777ccc2222222011111111011111110229922222222220111111110111111102299222
222888888888822227777777777777727577777777777757ccc7777777777ccc2222222011111111111111110222222222222220111111111111111102222222
222288888888222227077000000000725777777777777775cc7777777777cccc2222222011111110001111110222222222222220111111100011111102222222
222228888882222227777777777777722222222222222222ccc77777777ccccc2222222011111110201111110222222222222220111111102011111102222222
222222888822222227077000000000722222222222222222cc77777777cccccc2222222000000000200000000222222222222220000000002000000002222222
22222228822222222777777777777772222222222222222277777777cccccccc2222222000000000200000000222222222222220000000002000000002222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
2222222222222228822222222222222222222222222222fffffffff22222222222222222222222ffffffffffff22222200000000000000000000000000000000
222222228222000000002822222222222222222222222fffffffff22222222222222222222222ffffffffffff222222200000000000000000000000000000000
22222228800055555555000228222222222222222222f999999f222222222222222222222222f999999999f22222222200000000000000000000000000000000
2222222805555555555555508822222222222222222f9999999ff2222222222222222222222f9999999999ff2222222200000000000000000000000000000000
22222220555555555585555502222222222222222229707970799222222222222222222222299707999707992222222200000000000000000000000000000000
28822205555555555888555550222222222222222229979997999222222222222222222222299979999979992222222200000000000000000000000000000000
28888055585555555885555555088222222222222229999999999222222222222222222222299999999999992222222200000000000000000000000000000000
22280555585555558555555555508822222222222222998889992222222222222222222222229999888999922222222200000000000000000000000000000000
22205555888555555555555555550822222222222222299999922222222222222222222222222999999999222222222200000000000000000000000000000000
22205855588555555555555558550222222222222200078888700022222222222222222222000778888877000222222200000000000000000000000000000000
22205855555555555555555558850222222222222010107887011002222222222222222220101077888770110022222200000000000000000000000000000000
22055885555555555555555888855022222222222011010887011010222222222222222220110107787770110102222200000000000000000000000000000000
22055555555558555585555555555022222222220011010887010110022222222222222200110107887770101100222200000000000000000000000000000000
28055555555588555588555555555022222222200111100887001111022222222222222001111007888770011110222200000000000000000000000000000000
28055555555888555555555555555082222222201111110887011101002222222222222011111107888770111010022200000000000000000000000000000000
22055555555555555555555555558882222222001101100887011100102222222222220011011007888770111001022200000000000000000000000000000000
22055555555555585555555555555082222222011101107880011110100222222222220111011077888700111101002200000000000000000000000000000000
22055555555555555555855555885022222220011001107880011110110222222222200110011077888700111101102200000000000000000000000000000000
22055885555555555588855555588022222220111011107880111110110222222222201110111077888701111101102200000000000000000000000000000000
22205855555555555558855555550222222220111011107880111110110222222222201110111077888701111101102200000000000000000000000000000000
22205555555555555555555555550222222220110011100880111110110222222222201100111000888701111101102200000000000000000000000000000000
22805555588855555855555555550882222220002000001880000000110222222222200020000011888000000001102200000000000000000000000000000000
22280555588555555885555555502822222229992201111881111102010222222222299922011111888111111020102200000000000000000000000000000000
22222055555555555585555555022222222292992200111181111002000222222222929922001111888111110020002200000000000000000000000022222222
22222208555555555588555550222222222222222220111111111022999222222222222222201111181111110229992200000000000000000000000020222222
22222880555555555555555508822222222222222220111111111022992222222222222222201111111111110229922200000000000000000000000020022222
22288882055555555555555022882222222222222220111111111022222222222222222222201111101111110222222200000000000000000000000020002222
22228882200085555555000222882222222222222220111000111022222222222222222222201111101111110222222200000000000000000000000020022222
22222822222880000000882222222222222222222220111020111022222222222222222222201111101111110222222200000000000000000000000020222222
22222222222882222222282222222222222222222220111020111022222222222222222222201111101111110222222200000000000000000000000022222222
22222222222222222222222222222222222222222220111020111022222222222222222222201111101111110222222200000000000000000000000022222222
__label__
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666888866666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666888866666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666688666666000000000000000066886666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666688666666000000000000000066886666666666666666666
66666600660060006600600660006000660060066666666666666666666666666666666666666668888000000555555555555555500000066668866666666666
66666066606060606060606060606000606060606666666666666666666666666666666666666668888000000555555555555555500000066668866666666666
66666066606060066060606060006060606060606666666666666666666666666666666666666668800555555555555555555555555555500888866666666666
66666066606060606060606060606060606060606666666666666666666666666666666666666668800555555555555555555555555555500888866666666666
66666600600660606006606060606060600660606666666666666666666666666666666666666660055555555555555555555885555555555006666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666660055555555555555555555885555555555006666666666666
66666666666666666666666666666666666666666666666666666666666666666668888666666005555555555555555555588888855555555550066666666666
66666660000000000000000000000000000000000000000000000000006666666668888666666005555555555555555555588888855555555550066666666666
66666603333333333333333333333333333333333333333333333333330666666668888888800555555885555555555555588885555555555555500888866666
66666603333333333333333333333333333333333333333333333333330666666668888888800555555885555555555555588885555555555555500888866666
66666660000000000000000000000000000000000000000000000000006666666666666880055555555885555555555558855555555555555555555008888666
66666666666666666666666666666666666666666666666666666666666666666666666880055555555885555555555558855555555555555555555008888666
66666666666666666666666666666666666666666666666666666666666666666666666005555555588888855555555555555555555555555555555550088666
66666666666666666666666666666666666666666666666666666666666666666666666005555555588888855555555555555555555555555555555550088666
66666666666666666666666666666666666666666666666666666666666666666666666005588555555888855555555555555555555555555558855550066666
66666666666666666666666666666666666666666666666666666666666666666666666005588555555888855555555555555555555555555558855550066666
66666666666666666666666666666666666666666666666666666666666666666666666005588555555555555555555555555555555555555558888550066666
66666666666666666666666666666666666666666666666666666666666666666666666005588555555555555555555555555555555555555558888550066666
66666666666666666666666666666666666666666666666666666666666666666666600555588885555555555555555555555555555555588888888555500666
66666666666666666666666666666666666666666666666666666666666666666666600555588885555555555555555555555555555555588888888555500666
66666666666666666666666666666666666666666666666666666666666666666666600555555555555555555558855555555885555555555555555555500666
66666666666666666666666666666666666666666666666666666666666666666666600555555555555555555558855555555885555555555555555555500666
66666666666666666666666666666666666666666666666666666666666666666668800555555555555555555888855555555888855555555555555555500666
66666666666666666666666666666666666666666666666666666666666666666668800555555555555555555888855555555888855555555555555555500666
66666666666666666666666666666666666666666666666666666666666666666668800555555555555555588888855555555555555555555555555555500886
66666666666666666666666666666666666666666666666666666666666666666668800555555555555555588888855555555555555555555555555555500886
66666666666666666666666666666666666666666666666666666666666666666666600555555555555555555555555555555555555555555555555558888886
666666666666ffffffffffffffffffffffff66666666666666666666666666666666600555555555555555555555555555555555555555555555555558888886
666666666666ffffffffffffffffffffffff66666666666666666666666666666666600555555555555555555555555885555555555555555555555555500886
66666666ffffffffffffffffffffffffffffff666666666666666666666666666666600555555555555555555555555885555555555555555555555555500886
66666666ffffffffffffffffffffffffffffff666666666666666666666666666666600555555555555555555555555555555555588555555555555555500666
66666666ffffffffffffffffffffffffffffffff6666666666666666666666666666600555555555555555555555555555555555588555555555555555500666
66666666ffffffffffffffffffffffffffffffff6666666666666666666666666666600555588885555555555555555555555888888555555555555555500666
666666ffffffffffffffffff99ffffffffffff666666666666666666666666666666600555588885555555555555555555555888888555555555555555500666
666666ffffffffffffffffff99ffffffffffff666666666666666666666666666666666005588555555555555555555555555558888555588885555550066666
6666ffffffffffffff999999999999ffff6666666666666666666666666666666666666005588555555555555555555555555558888555588885555550066666
6666ffffffffffffff999999999999ffff6666666666666666666666666666666666666005555555555555555555555555555555555555588888855550066666
6666ffffffffffffff99999999999999666666666666666666666666666666666666666005555555555555555555555555555555555555588888855550066666
6666ffffffffffffff99999999999999666666666666666666666666666666666666688005555555555888888555555555588555555555555885555550088886
6666ffffffffffff9999999999999999666666666666666666666666666666666666688005555555555888888555555555588555555555555885555550088886
6666ffffffffffff9999999999999999666666666666666666666666666666666666666880055555555888855555555555588885555555555555555006688666
6666ffffffffffff9999999999997700666666666666666666666666666666666666666880055555555888855555555555588885555555555555555006688666
6666ffffffffffff9999999999997700666666666666666666666666666666666666666666600555555555555555555555555885555555555555500666666666
6666ffff9900ffff9999999999999999666666666666666666666666666666666666666666600555555555555555555555555885555555555555500666666666
6666ffff9900ffff9999999999999999666666666666666666666666666666666666666666666008855555555555555555555888855555555550066666666666
6666ff99009900ff9999999999999999996666666666666666666666666666666666666666666008855555555555555555555888855555555550066666666666
6666ff99009900ff9999999999999999996666666666666666666666666666666666666666688880055555555555555555555555555555555008888666666666
66666699009999999999999999999999996666666666666666666666666666666666666666688880055555555555555555555555555555555008888666666666
66666699009999999999999999999999996666666666666666666666666666666666666888888886600555555555555555555555555555500666688886666666
66666699009999999999999999999999666666666666666666666666666666666666666888888886600555555555555555555555555555500666688886666666
66666699009999999999999999999999666666666666666666666666666666666666666668888886666000000885555555555555500000066666688886666666
66666666990099999999999999999999666666777777777766666666666666666666666668888886666000000885555555555555500000066666688886666666
66666666990099999999999999999999666666777777777766666666666666666666666666688666666666688880000000000000088886666666666666666666
66666666999999999999999999999966666677777777777777776666666666666666666666688666666666688880000000000000088886666666666666666666
66666666999999999999999999999966666677777777777777776666666666666666666666666666666666688886666666666666666886666666666666666666
66666677777799999999999999999999667777777777777777776666666666666666666666666666666666688886666666666666666886666666666666666666
66666677777799999999999999999999667777777777777777776666666666666666666666666666666666666666666666666666666666666666666666666666
6600000000777777777777777799999966777777777777ffffff6666666666666666666666666666666666666666666666666666666666666666666666666666
6600000000777777777777777799999966777777777777ffffff6666666666666666666666666666666666666666666666666666666666666666666666666666
00111111110000000000000077776666777777777777ffffffff0066666666666666666666666666666666666666666666666666666666666666666666666666
00111111110000000000000077776666777777777777ffffffff0066666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111100000066777777770000000000007700666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111100000066777777770000000000007700666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111110000777777888877ffffffff00ff666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111110000777777888877ffffffff00ff666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111777788ffff8888ffffff8888666666666666666006000600060066600600060006600600666666ddd66dd6dd66666666
11111111111111111111111111111111777788ffff8888ffffff8888666666666666660606060606060606066606660006060606066666d6d6d666d6d6666666
11111111111111111111111111111111ffff88ff00ff888888888888666666666666660606006600060606066600660606060606066666ddd6ddd6d6d6666666
11111111111111111111111111111111ffff88ff00ff888888888888666666666666660606060606060606060606660606060606066666d66666d6d6d6666666
11111111111111111111111111111111ffff88ffffff888888888888666666666666660066060606060606000600060606006606066666d666dd66d6d6666666
11111111111111111111111111111111ffff88ffffff888888888888666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111ffff88888888888888888866666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111ffff88888888888888888866666666666666666600000000000000000000000000000000000000000000000000066666
1111111111111111111111111111111111ffffffff88888888888866666666666666666033333666666666666666666666666666666666666666666666606666
1111111111111111111111111111111111ffffffff88888888888866666666666666666033333666666666666666666666666666666666666666666666606666
1111111111111111111111111111111111ffffffffff888888886666666666666666666600000000000000000000000000000000000000000000000000066666
1111111111111111111111111111111111ffffffffff888888886666666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111111177777777777777666666666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111111177777777777777666666666666666666666600000000000000000000000000000000000000000000000000066666
11111111111111111111111111111111000000000000000000006666666666666666666033333333333333333333333333333333333333333333333333306666
11111111111111111111111111111111000000000000000000006666666666666666666033333333333333333333333333333333333333333333333333306666
11111111111111111111111111111100000000000000000000000000006666666666666600000000000000000000000000000000000000000000000000066666
11111111111111111111111111111100000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111000000000000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111000000000000000000000000000000000066666666666666666666666666666666660006000606066006000600066006006666
11111111111111111111111100000000000000000000000000000000000000666666666666666666666666666666660666060606060666606600060606060666
11111111111111111111111100000000000000000000000000000000000000666666666666666666666666666666660066000606060666606606060606060666
11111111111111111111110000000000000000000000000000000000000000006666666666666666666666666666660666060606060666606606060606060666
11111111111111111111110000000000000000000000000000000000000000006666666666666666666666666666660666060660066006000606060066060666
11111111111111111111000000000000000000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666
11111111111111111111000000000000000000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666600600060006006660060006000660060066666606060006600666660006600600066006600600660006006660666666666666666666666666666606
60666666060606060606060606660666000606060606666606060606066666660606060660660666060606060666060660666666666666666666666666666606
60666666060600660006060606660066060606060606666606060006000666660006060660660006060606060066060660666666666666666666666666666606
60666666060606060606060606060666060606060606666600060606660666660666060660666606060606060666060666666666666666666666666666666606
60666666006606060606060600060006060600660606666600060606006666660666006600060066006606060006000660666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666000006666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660060600666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660006000666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660060600666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666000006666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666606
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006

__sfx__
010100000e07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800103237529305293752f305323753030530375000002637500000283750000030375000002f37500000263752930528375000002d375000002b375000002637500000243750000024375000002337500000
012000000e3700e3700e3700e3700e3700e3700e3700e370103701037010370103701037010370103701037011370113701137011370113701137011370113701337013370133701337013370133701337013370
012000002907029070210702107023070230702407029070280702807023070230701f0701f07021070230702d0702d070260702607024070240702f0702b0702b0702b070290702807026070260702607029070
012000002642126421264212642129421294212942129421284212842128421284212b4212b4212b4212b421294212942129421294212d4212d4212d4212d4212b4212b4212b4212b4212f4212f4212f42130421
001000000b6150a625066350462502615016000360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000100742107420074230742307423074230742307423074200742007422074200742007420074230742307655054000000000000000000000000000000000000000000000000000000000000000000000000
011000000732502305073250732507325023050732507325073250000507325073250732500005073250732507325000050732507325073250000507325073250732500005073250732507325003050732507325
011000000762502605076250762507625026050762507625076250060507625076250762500605076250762507625006050762507625076250060507625076250762500605076250762507625006050762507625
01100000133250e3051332513325133250e3051332513325133250c0051332513325133250c0051332513325133250c0051332513325133250c0051332513325133250c0051332513325133250c3051332513325
0110002026330263002d3002120021200293002933529335293302b0001d200243002b330243002430024300283302930029300283002d3002430024335243352433000000102002130021330112051a2051a205
0110002029330263002d3002120021200293002d3352d3352d3302b0001d20024300303302430024300243002b3302930029300283002d3002430028335283352833000000102002130024330112051a2051a205
011000002b33529305283052833524305263052433500000293352630523305263350000022305293350000028335000000000024335000001f3051f33500000263350000024305203351f305000001d33500000
011000003033500000000002b335000050000528335000052c33500005000052933500005000052c335000052b335000050000528335213050000524335000052933500005000052633500005223052233500005
011000000c075180051000510075000000000013075140050b0750b005000000e07500000000001107500000080750c005000000c07500000000000f075000000707500000000000b0750e005000000e07500000
011000080000000000000000000011675000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700100265500000026050000002655026050260500000026550000000000000000265502605026550265500000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00200c3750c37513372133020c3750c375143720c3050c3750c37513372133020c3750c3750b3720b3000c3750c37513372133020c3750c375143720c305183701837018370183000c3700c3700c3000c300
010e00201037510375183722430010375103751b37216302103751037518372243001037510375143720e3001037510375183722430010375103751b3721d302163001d300153002130021300213001330513300
010e00100437000000000000230004370043000000002300043700000000000000000437000000043750437000000000000000000000000000000000000000000000000000000000000019300000000000000000
010e00201337513375143001530013375133751b302183051337513375183021f30213375133751d302183051337513375183021f30213375133751d302183051b3401b3401b3401830013340133400c3000c300
010e00201337513375143001530013375133751b302183051337513375183021f30213375133751d302183051337513375183021f30213375133751d302183051f3401f3401f3401130013340133400c3000c300
010e00200c3750c37513372133020c3750c375143720c3050c3750c37513372133020c3750c3750b3720b3000c3750c37513372133020c3750c375143720c305183701837018370183000c3700c3700c3000c300
011000003037500000000002b375000050000528375000052c37500005000052937500005000052c375000052b37500005000052837521305000052437528305293752830527305293752b3052c3052237500005
000200001b5402a530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011f00001c5721c5621c5521c5422657226562265522654228572285722856228562285522855228542285422357223562235522354226572265621f55226542285722b5622b5522b54226572265622857228562
010d00002b5752b5052b505295752950529505285752650526505265752d5052f505305752f5052b5052d5752f505285002f57529505245052b57526505000002857528502245050000026505000002650500000
010f00200e513000030e503000030e615000030e513000030e513000030e503000030e513000030e503000030e513005030e503005030e615005030e513005030e6150e5030e5130e5030e5130e5030e5130e513
010a00001a5351c5001a5001a5001a53500000000000000018535000001a5351a5051a5051a5051a535000051a5350000500005180051a5350000000000000001853524000000001a0051a535000000000000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e0000215451c203185451a2051a54523000235451d2051f5451c5051a5451c505185451a2051a2051f5451d5451c200185451a20517545230001d5451d2051c5451c5052054511505215451a205175051f545
011e0000215451c203185451a2051a54523000235451d2051f5451c5051a5451c505185451a2051a2051f5451d5451c200185451a20517545230001d5451d2051c5451c505175451c105185451a205175051f545
011e000011010110101101011010070100701007010070100b0100b0100b0100b0100c0100c0100c0100c0100501005010050100501004010040100401004010070100701007010070100b0100b0100b0100b010
001e000011010110101101011010070100701007010070100b0100b0100b0100b0100c0100c0100c0100c01005010050100501005010130101301013010130101401014010140101401015010150101501015010
011e0000211112111121111211111a1111a1111a1111a1111f1111f1111f1111f111181111811118111181111d1111d1111d1111d111171111711117111171111c1111c1111b1101b1101c1101d1101f11018110
013c001011010110101101011010100101001010010100100e0100e0100e0100e0100c0100c0100c0100c0100b0000b0000b0000b000090000900009000090000b0000b0000b0000b0000c0000c0000c0000c000
013c0000215451c203185451a2051a54523000235451d2051f5451c5051a5451c505185451a2051a2051f5451d5451c200185451a20517545230001d5451d2051c5451c5052054511505215451a205175051f545
00030000125700c170135701657019570111701a5701b5701c1701b5701c5701a1701d5701f5702057022570245702e1702657028170285702b5702f1702e5703057033570335703357034570345703457034570
010400001c17328670286502864028630286200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000c2807624000280762400028006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000f3701137017570143701e5701a3701d3702457024370265702b370295702d3702a5702d570320702f57031570355703a570015000150002500025000250002500025000250002500025000250000000
00090000335702f5702c5702857025570225701d5701b5701757012570115700e5700b57008570055700457002570015700000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000216702167020670206700007026660216601e65019650136500d6600d66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000003000b3500b3500c3500c3500d3500d3500e3500f3501135014350183501d35021350283502c35000300003000030000300003000030000300003000030000300003000030000300003000030000300
00050000003001331016320193301d3402134024350293602b360193201c32021320273302c3402f340313501d3101e3201f320203302233023330263302a3302d3303034033350363503e300003000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c57013570185701c570175701c57022570265702757026570285702d5701f570315702b5002e500255002650027500295001f1002b5001f5002d5002e5001f500305001f5003350035500395003d500
000100000937008370063700437004370043700237001370013700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000190701c07021070260702d07032070360703c070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002475007100021002960023600036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 02030444
01 07480946
00 070b0a09
02 070a0b09
01 0c0d0e0f
02 0c170e0f
01 50111410
02 50161510
00 1b201f22
01 5b231e62
02 5b231e22
00 28424344
00 41424344
00 41424344
03 27424344
00 41424344
00 41424344
00 41424344
00 41424344
03 07080106
00 41424344
00 41424344
01 10111444
03 0c0d0e0f


__meta:cart_info_start__
cart_type: game
game_name: Electémon
# Leave blank to use game-name
game_slug: electemon
jam_info:
  - jam_name: TriJam
    jam_number: 93
    jam_url: null
    jam_theme: Unachievable
tagline: Defeating the Orangemon has been unachievable. The only thing to do now is vote!
develop_time: 16 hours between 2 people
description: |
  Defeating the Orangemon has been unachievable. The only thing to do now is vote!
controls:
  - inputs: [UP_ARROW_KEY,DOWN_ARROW_KEY]
    desc:  navigate menu
  - inputs: [X]
    desc:  select move / acknowledge text
hints: ''
acknowledgements: |
  * barrelscrapings - lead artist, additional designer, additional programmer
  * Music borrowed from hcnt's Pico Monsters https://www.lexaloffle.com/bbs/?tid=4046, licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
to_do: []
version: 0.1.0
img_alt: Faucimon fights Coronamon while Orangemon...exists

number_players: [1]
__meta:cart_info_end__
