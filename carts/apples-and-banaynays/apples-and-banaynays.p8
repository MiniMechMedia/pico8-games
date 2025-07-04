pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--apples and banaynays           v0.1.0
--mini mech media

-- Sound effect IDs (to be filled in later)
attack_sound = 0
hit_banana_sound = 1
collect_banana_sound = 3
hit_orange_sound = 2
defeat_orange_sound = 2
game_over_sound = 5
win_sound = 4
toggle_hotdog_sound = 6

gs = nil

dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

hot_dog_sprite = 145
hot_dog_sprite_rotated = 136
lizard_sprite = 11
lizard_sprite_rotated = 132
auto_hotdog_mode = false  -- Track if hotdog mode was auto-activated
hotdog_mode = false

banana_spr = 1
banana_spr2 = 17
banana_spr3 = 33
apple_spr = 2
apple_spr2 = 18
orange_spr = 3

gameOverWin = 'win'
gameOverLose = 'lose'

-- Sword related
sword_sprite = 16  -- Using sprite slot 16 for sword
sword_radius = 12  -- Distance from player center
sword_rotation_speed = 0.05  -- Speed of rotation

function _init(is_2_player)
    auto_hotdog_mode = false  -- Track if hotdog mode was auto-activated
    hotdog_mode = false
	gs = {
        bananas = {},
        oranges = {},
        score = 0,
        total_bananas_collected = 0,
        max_bananas = 10,
        bananas_to_win = 20,
        isGameOver = false,
        isDrawGameOver = false,
        restartGameDelay = 1,
        shouldDelayRestart = function(self)
            if self.endTime == nil then
                return false
            end

            return time() - self.endTime <= self.restartGameDelay
        end,
        gameOverState = nil,
        startTime = time(),
        endTime = nil,
        currentAnimation = nil,
        player1 = {
            playerNum = 0,
            x = 64,
            y = 64,
            sprite = apple_spr,
            radius = 4,
            sword_angle = 0,  -- Current angle of sword rotation
            is_attacking = false,  -- Whether sword is visible
            attack_timer = 0,  -- Timer for attack duration
            facing_dir = dirs.up,  -- Direction player is facing
            anim_timer = 0,  -- Animation timer for walking
            is_moving = false,  -- Track if player is currently moving
            fatness = 0  -- How fat the lizard is from eating hot dogs
        },
        player2 = {
            playerNum = 1,
            x = 32,
            y = 32,
            sprite = apple_spr2,
            radius = 4,
            sword_angle = 0,  -- Current angle of sword rotation
            is_attacking = false,  -- Whether sword is visible
            attack_timer = 0,  -- Timer for attack duration
            facing_dir = dirs.up,  -- Direction player is facing
            anim_timer = 0,  -- Animation timer for walking
            is_moving = false,  -- Track if player is currently moving
            fatness = 0  -- How fat the lizard is from eating hot dogs
        },
        is_2_player = is_2_player,
        particles = {}  -- Particle system for juice effects
	}

    gs.player = gs.player1

    music(21)

    if is_2_player then
        menuitem(1, "1 player", function() _init(false) end)
    else
        menuitem(1, "2 player", function() _init(true) end)
    end

    -- Create more evenly distributed bananas using blue noise
    local grid_size = 16
    local grid = {}
    
    -- Initialize grid
    for x = 0, grid_size-1 do
        grid[x] = {}
        for y = 0, grid_size-1 do
            grid[x][y] = false
        end
    end
    
    -- Function to spawn a new banana
    function spawn_banana()
        if gs.total_bananas_collected + #gs.bananas >= gs.bananas_to_win then return nil end
        
        local max_attempts = 100
        while max_attempts > 0 do
            local gx = flr(rnd(grid_size))
            local gy = flr(rnd(grid_size))
            
            -- Check if position and neighbors are empty
            if not grid[gx][gy] then
                local ok = true
                for dx = -1, 1 do
                    for dy = -1, 1 do
                        local nx, ny = (gx+dx+grid_size)%grid_size, (gy+dy+grid_size)%grid_size
                        if grid[nx] and grid[nx][ny] then ok = false end
                    end
                end
                
                if ok then
                    grid[gx][gy] = true
                    return {
                        x = (gx/grid_size)*120 + 4 + rnd(4)-2,
                        y = (gy/grid_size)*120 + 4 + rnd(4)-2,
                        sprite = banana_spr,
                        health = 3,
                        max_health = 3
                    }
                end
            end
            max_attempts -= 1
        end
        return nil
    end
    
    -- Initial spawn of bananas
    for i = 1, min(gs.max_bananas, gs.bananas_to_win) do
        local banana = spawn_banana()
        if banana then
            add(gs.bananas, banana)
        end
    end
    
    -- Create evil oranges
    local min_distance_from_player = 32  -- Minimum distance from player
    -- local min_distance_from_player = 1000
    for i = 1, 10 do
        local angle = rnd() * 6.28
        local speed = 0.5 + rnd(0.5)
        local x, y
        local attempts = 0
        
        -- Try to find a position that's not too close to player
        repeat
            x = 10 + rnd(108)
            y = 10 + rnd(108)
            attempts += 1
            -- If we can't find a good spot after many tries, just use whatever
            if attempts > 50 then break end
        until (x - gs.player.x)^2 + (y - gs.player.y)^2 >= min_distance_from_player^2
        
        add(gs.oranges, {
            x = x,
            y = y,
            dx = cos(angle) * speed,
            dy = sin(angle) * speed,
            sprite = orange_spr
        })
    end
end

-- Particle system functions
function add_particle(x, y, col)
    local angle = rnd()
    local speed = 1 + rnd(2)
    add(gs.particles, {
        x = x,
        y = y,
        vx = cos(angle) * speed,
        vy = sin(angle) * speed - 1,  -- Slight upward bias
        col = col,
        life = 15 + rnd(10),
        size = 1 + rnd(2)
    })
end

function update_particles()
    for i = #gs.particles, 1, -1 do
        local p = gs.particles[i]
        p.x += p.vx
        p.y += p.vy
        p.vy += 0.2  -- Gravity
        p.life -= 1
        p.size *= 0.95  -- Shrink over time
        
        if p.life <= 0 or p.size < 0.5 then
            del(gs.particles, p)
        end
    end
end

function draw_particles()
    for p in all(gs.particles) do
        circfill(p.x, p.y, p.size, p.col)
    end
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
		end
	}

	setmetatable(ret, metaTable)

	return ret
end


function hasAnimation()
	return gs.currentAnimation != nil and costatus(gs.currentAnimation) != 'dead'
end

function acceptInput()
    -- Handle X button for sword attack
    if btnp(dirs.x, gs.player.playerNum) and not gs.player.is_attacking then
        gs.player.is_attacking = true
        gs.player.attack_timer = 0
        gs.player.sword_angle = 0
        sfx(attack_sound)
    end
    
    -- -- Handle Z button for hotdog mode toggle
    -- if btnp(dirs.z) then
    --     hotdog_mode = not hotdog_mode
    --     sfx(toggle_hotdog_sound)
    -- end
end

function _update()
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if not gs:shouldDelayRestart() then
			if btnp(dirs.x) then
				_init(gs.is_2_player)
			end
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

    gs.player = gs.player1
    
    update(true)
    if gs.is_2_player then
        gs.player = gs.player2
        update(false)
    end
end

function update(is_first)
    -- Update sword attack
    if gs.player.is_attacking then
        gs.player.attack_timer += 1
        local rotation_frames = 20  -- Total frames for full rotation
        
        if gs.player.attack_timer <= rotation_frames then
            -- Update sword angle
            gs.player.sword_angle = (gs.player.attack_timer / rotation_frames) * 1
            
            -- Check collision with oranges during attack (skip in hot dog mode)
            -- (Oranges can be hit from any angle with sword)
            -- But avoid hitting the same orange multiple times in one attack
            if not hotdog_mode then
                local hit_oranges = {}
                for j, orange in ipairs(gs.oranges) do
                    local dx = gs.player.x + cos(gs.player.sword_angle) * sword_radius - orange.x
                    local dy = gs.player.y + sin(gs.player.sword_angle) * sword_radius - orange.y
                    if (dx*dx + dy*dy < 144) then  -- Collision with sword tip
                        -- Only hit each orange once per attack
                        if not orange.hit_this_attack then
                            -- Create orange juice particles
                            for i = 1, 8 do
                                add_particle(orange.x, orange.y, 9)  -- Orange color
                            end
                            
                            -- Defeat the orange
                            local angle = rnd() * 6.28
                            orange.x = 10 + rnd(108)
                            orange.y = 10 + rnd(108)
                            orange.dx = cos(angle) * (0.5 + rnd(0.5))
                            orange.dy = sin(angle) * (0.5 + rnd(0.5))
                            orange.hit_this_attack = true
                            gs.score += 15  -- More points for sword defeat
                            sfx(hit_orange_sound)
                        end
                    end
                end
            end
            
            -- Calculate sword position for collision checks
            local sword_x = gs.player.x + cos(gs.player.sword_angle) * sword_radius
            local sword_y = gs.player.y + sin(gs.player.sword_angle) * sword_radius
            
            -- Check collision with bananas during attack
            for j = #gs.bananas, 1, -1 do
                local banana = gs.bananas[j]
                local dx = sword_x - banana.x
                local dy = sword_y - banana.y
                if dx*dx + dy*dy < 64 then  -- Sword hit radius
                    -- Only hit each banana once per attack
                    if not banana.hit_this_attack then
                        -- Create banana juice particles
                        for i = 1, 6 do
                            add_particle(banana.x, banana.y, 10)  -- Yellow color
                        end
                        
                        -- If in hotdog mode, make lizard fatter
                        if hotdog_mode then
                            gs.player.fatness += 3
                        end
                        
                        banana.health -= 1
                        banana.hit_this_attack = true
                        sfx(hit_banana_sound)
                        
                        -- Update sprite based on health
                        if banana.health == 2 then
                            banana.sprite = banana_spr2
                        elseif banana.health == 1 then
                            banana.sprite = banana_spr3
                        elseif banana.health <= 0 then
                            -- Banana destroyed
                            del(gs.bananas, banana)
                            gs.score += 10
                            gs.total_bananas_collected += 1
                            sfx(collect_banana_sound)
                            
                            -- Spawn a new banana if we haven't reached the total yet
                            if gs.total_bananas_collected < gs.bananas_to_win then
                                local new_banana = spawn_banana()
                                if new_banana then
                                    add(gs.bananas, new_banana)
                                end
                            end
                            

                            
                            -- Win condition
                            if gs.total_bananas_collected >= gs.bananas_to_win then
                                gs.gameOverState = gameOverWin
                                gs.isGameOver = true
                                sfx(win_sound)
                            end
                        end
                    end
                end
            end
        else
            -- Attack finished
            gs.player.is_attacking = false
            -- Reset hit flags
            if not hotdog_mode then
                for j, orange in ipairs(gs.oranges) do
                    orange.hit_this_attack = false
                end
            end
            for j, banana in ipairs(gs.bananas) do
                banana.hit_this_attack = false
            end
        end
    end

    -- Move player with arrow keys
    local move_speed = 1.5
    local was_moving = false
    
    if btn(dirs.left, gs.player.playerNum) then
        gs.player.x = max(4, gs.player.x - move_speed)
        gs.player.facing_dir = dirs.left
        was_moving = true
    end
    if btn(dirs.right, gs.player.playerNum) then
        gs.player.x = min(124, gs.player.x + move_speed)
        gs.player.facing_dir = dirs.right
        was_moving = true
    end
    if btn(dirs.up, gs.player.playerNum) then
        gs.player.y = max(4, gs.player.y - move_speed)
        gs.player.facing_dir = dirs.up
        was_moving = true
    end
    if btn(dirs.down, gs.player.playerNum) then
        gs.player.y = min(124, gs.player.y + move_speed)
        gs.player.facing_dir = dirs.down
        was_moving = true
    end
    
    -- Update movement state and animation timer
    gs.player.is_moving = was_moving
    if gs.player.is_moving then
        gs.player.anim_timer += 1
    else
        gs.player.anim_timer = 0
    end

    -- Check if we should auto-activate hotdog mode every frame
    if gs.total_bananas_collected == gs.bananas_to_win - 1 then
        if not hotdog_mode then
            hotdog_mode = true
            auto_hotdog_mode = true
        end
    end

            
    -- Bananas no longer get collected by walking into them
    -- They must be defeated with the sword

    acceptInput()

    -- if not is_first then return end
    -- Update particles
    if is_first then
        update_particles()
    end
    
    -- Update oranges (skip in hot dog mode)
    if not hotdog_mode then
        for i, orange in ipairs(gs.oranges) do
            if is_first then
                orange.x = orange.x + orange.dx
                orange.y = orange.y + orange.dy
                
                -- Bounce off walls
                if orange.x <= 4 or orange.x >= 124 then
                    orange.dx = -orange.dx
                    orange.x = mid(4, orange.x, 124)
                end
                if orange.y <= 4 or orange.y >= 124 then
                    orange.dy = -orange.dy
                    orange.y = mid(4, orange.y, 124)
                end
            end
            
            -- Check collision with player
            local dx = gs.player.x - orange.x
            local dy = gs.player.y - orange.y
            local dist_sq = dx*dx + dy*dy
            local collision_dist = (gs.player.radius + 4)^2
            
            if dist_sq < collision_dist then
                -- Check if hitting from above (player is below the orange and moving up)
                if dy > 2 and (gs.player.y > orange.y + 2) and btn(dirs.up, gs.player.playerNum) then
                    -- Defeat the orange
                    local angle = rnd() * 6.28
                    local newx = 10 + rnd(108)
                    local newy = 10 + rnd(108)
                    for i = 1, 100 do
                        local diffx = abs(newx - gs.player1.x)
                        local diffy = abs(newy - gs.player1.y)
                        if diffx > 20 and diffy > 20 then
                            if gs.is_2_player then
                                local diffx2 = abs(newx - gs.player2.x)
                                local diffy2 = abs(newy - gs.player2.y)
                                if diffx2 > 20 and diffy2 > 20 then
                                    orange.x = newx
                                    orange.y = newy
                                    break
                                end
                            else
                                orange.x = newx
                                orange.y = newy
                                break
                            end
                        end
                    end
                    -- orange.x = 
                    -- orange.y = 10 + rnd(108)
                    orange.dx = cos(angle) * (0.5 + rnd(0.5))
                    orange.dy = sin(angle) * (0.5 + rnd(0.5))
                    -- Add score for defeating an orange
                    gs.score += 5
                    sfx(defeat_orange_sound)
                else
                    -- Regular collision - game over
                    gs.gameOverState = gameOverLose
                    gs.isGameOver = true
                    gs.gameOverBlame = gs.player.playerNum
                    sfx(game_over_sound)
                end
            end
        end
    end


end

function drawGameOverWin()
    color(11)
    print("you win! score: "..gs.score, 30, 54)
    color(7)
    if not gs:shouldDelayRestart() then
        print('press ❎ to play again', 30, 70)
    end
end

function drawGameOverLose()
    if gs.is_2_player then
        print("player "..(gs.gameOverBlame+1).." was\nhit by an orange!", 30, 54-24)
    end
    color(8)
    print("game over! score: "..gs.score, 30, 54)
    color(7)
    if not gs:shouldDelayRestart() then
        print('press ❎ to play again', 30, 70)
    end
end

function _draw()
    gs.player = gs.player1
    draw(true)
    if gs.is_2_player then
        gs.player = gs.player2
        draw(false)
    end
end

function draw(is_first)
    if is_first then
        cls(0)
    end
	if gs.isGameOver then
		if gs.isDrawGameOver then
			if gs.gameOverState == gameOverWin then
				drawGameOverWin()
			else
				drawGameOverLose()
			end
			return
		else
			gs.isDrawGameOver = true
		end
	end

    -- Draw score and stats
    color(7)
    print("score: "..gs.score, 2, 2)
    print("bananas: "..gs.total_bananas_collected.."/"..gs.bananas_to_win, 2, 10)
    
    -- Draw player
    if hotdog_mode then
        -- Draw lizard sprite (4x4) with directional awareness
        local sprite_to_use = lizard_sprite  -- Default facing up
        local flip_x = false
        local flip_y = false
        
        -- Add walking animation by toggling flip state when moving
        local walk_flip = false
        if gs.player.is_moving then
            walk_flip = (gs.player.anim_timer % 16) < 8  -- Toggle every 8 frames
        end
        
        if gs.player.facing_dir == dirs.down then
            -- Face down: use up sprite flipped vertically
            sprite_to_use = lizard_sprite
            flip_y = true  -- Always flipped for down direction
            flip_x = walk_flip  -- Horizontal wiggle for walking
        elseif gs.player.facing_dir == dirs.left then
            -- Face left: use rotated sprite
            sprite_to_use = lizard_sprite_rotated
            flip_y = walk_flip  -- Vertical wiggle for walking
        elseif gs.player.facing_dir == dirs.right then
            -- Face right: use rotated sprite flipped horizontally
            sprite_to_use = lizard_sprite_rotated
            flip_x = true  -- Always flipped for right direction
            flip_y = walk_flip  -- Vertical wiggle for walking
        else
            -- dirs.up uses default sprite
            sprite_to_use = lizard_sprite
            flip_x = walk_flip  -- Horizontal wiggle for walking
        end
                -- Draw fatness circle if lizard has eaten hot dogs
        if gs.player.fatness > 0 then
            circfill(gs.player.x, gs.player.y, gs.player.fatness, 11)  -- Lime green
        end
        spr(sprite_to_use, gs.player.x - 16, gs.player.y - 16, 4, 4, flip_x, flip_y)
        

    else
        -- Draw apple sprite
        spr(gs.player.sprite, gs.player.x - 4, gs.player.y - 4)
    end
    
    -- Draw sword if attacking
    if gs.player.is_attacking then
        local sword_x = gs.player.x + cos(gs.player.sword_angle) * sword_radius
        local sword_y = gs.player.y + sin(gs.player.sword_angle) * sword_radius
        
        -- Draw sword sprite rotated based on angle
        -- For simplicity, we'll draw it as a line with a handle
        -- Draw sword blade
        local blade_end_x = sword_x + cos(gs.player.sword_angle) * 8
        local blade_end_y = sword_y + sin(gs.player.sword_angle) * 8
        line(sword_x, sword_y, blade_end_x, blade_end_y, 7)  -- White blade
        
        -- Draw sword handle
        local handle_x = sword_x - cos(gs.player.sword_angle) * 3
        local handle_y = sword_y - sin(gs.player.sword_angle) * 3
        circfill(handle_x, handle_y, 2, 4)  -- Brown handle
        
        -- Draw red stripe on handle
        local stripe_x1 = handle_x + cos(gs.player.sword_angle) * 1.5
        local stripe_y1 = handle_y + sin(gs.player.sword_angle) * 1.5
        local stripe_x2 = handle_x - cos(gs.player.sword_angle) * 1.5
        local stripe_y2 = handle_y - sin(gs.player.sword_angle) * 1.5
        if is_first then
            line(stripe_x1, stripe_y1, stripe_x2, stripe_y2, 8)  -- Red stripe
        else
            line(stripe_x1, stripe_y1, stripe_x2, stripe_y2, 11)  -- green stripe
        end
        
        -- Draw sword guard
        local guard_angle = gs.player.sword_angle + 0.25
        local guard_x1 = sword_x + cos(guard_angle) * 3
        local guard_y1 = sword_y + sin(guard_angle) * 3
        local guard_x2 = sword_x - cos(guard_angle) * 3
        local guard_y2 = sword_y - sin(guard_angle) * 3
        line(guard_x1, guard_y1, guard_x2, guard_y2, 6)  -- Gray guard
    end
    
    -- Draw particles
    draw_particles()

    -- Draw bananas
    for i, banana in ipairs(gs.bananas) do
        if banana.health > 0 then
            if hotdog_mode then
                -- Draw hot dog sprite with bite marks based on health
                local max_health = 3
                local health_ratio = banana.health / max_health
                
                -- Hot dog sprite is now 2x2 (16x16 pixels)
                local sprite_size = 16
                
                -- Calculate sprite position to center it
                local sprite_x = banana.x - 8  -- Center the 16x16 sprite
                local sprite_y = banana.y - 8
                
                if health_ratio < 1 then
                    -- Calculate how much of the hot dog to show (from bottom)
                    local visible_height = flr(sprite_size * health_ratio)
                    
                    -- Use sspr to draw only part of the sprite
                    -- sspr(sx, sy, sw, sh, dx, dy, [dw], [dh])
                    local sprite_num = hot_dog_sprite
                    local sx = (sprite_num % 16) * 8  -- Source x in sprite sheet
                    local sy = flr(sprite_num / 16) * 8  -- Source y in sprite sheet
                    
                    if visible_height > 0 then
                        -- Draw from bottom up (start from bottom of sprite)
                        local source_y_offset = sprite_size - visible_height
                        sspr(sx, sy + source_y_offset, sprite_size, visible_height, 
                             sprite_x, sprite_y + source_y_offset)
                        
                        -- Draw bite marks on the top edge
                        local bite_y = sprite_y + source_y_offset
                        for i=0,sprite_size-1,2 do
                            -- Create a jagged edge
                            local offset = sin(i * 0.3) * 2
                            if visible_height < sprite_size then
                                pset(sprite_x + i, bite_y + offset, 7)  -- White bite marks
                                pset(sprite_x + i, bite_y + offset - 1, 5)  -- Dark brown
                            end
                        end
                    end
                else
                    -- Full health, draw normally
                    spr(hot_dog_sprite, sprite_x, sprite_y, 2, 2)
                end
            else
                spr(banana.sprite, banana.x - 2, banana.y - 2)
            end
        end
    end

    -- Draw oranges (skip in hot dog mode)
    if not hotdog_mode then
        for i, orange in ipairs(gs.oranges) do
            -- Flash orange when vulnerable (when player is below and close)
            local dx = gs.player.x - orange.x
            local dy = gs.player.y - orange.y
            local is_vulnerable = dy > 2 and (gs.player.y > orange.y + 2) and (dx*dx + dy*dy < 400)
            
            if is_vulnerable and t() % 0.2 < 0.1 then
                -- Flash white when vulnerable
                pal(8, 7)  -- Replace orange with white
            end
            
            spr(orange.sprite, orange.x - 4, orange.y - 4)
            spr(7, orange.x - 4, orange.y - 4, 2, 2)
            
            if is_vulnerable then
                pal()  -- Reset palette
            end
        end
    end
    
end

__gfx__
00000000000444000004b0000070007000000000000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000
000000000000ab000078870000093900000000000000000000000000000000000000000000000000fff88fff0000000000000000000000000000000000000000
007007000000ab0000888800009a9a90000000009990000000000000000000008880000000000000f8a8abaf0000000000000000000000000000000000000000
00077000000abb0000888f00009999900000000aaa9000000000000000000008f8f0000000000000f88a88ff0000000000000000000000000000000000000000
0007700000aaa00000888f0000999990000000066660000000000000000000066660000000000000fffffff00000000000000000000000000000000000000000
007007000aaa000000888f0000999990000000666660000000000000000000666660000000000000000000000000000000000000000000000000000000000000
00000000aaa0000000000000009a9a9000000066660000000000000000000066660000000000000000000000000000000000000bbb0000000000000000000000
000000000000000000000000000999000000004440000000000000000000004440000000000000000000000000000000000000b0b00000000000000000000000
00000000000000000004b000000000000000044440000000000000000000044440000000000000000000000000000000000000b7b7b000000000000000000000
000000000000000000733700000000000000444440000000000000000000444440000000000000000000000000000000000000bbbbb000000000000000000000
000000000000a00000333300000000000004444400000000000000000004444400000000000000000000000000000000060000bbbbb000000000000000000000
00000000000abb0000333f000000000000044440000000000000000000044440000000000000000000000000000000000b000888888800600000000000000000
0000000000aaa00000333f000000000000004400000000000000000000004400000000000000000000000000000000000b000bbbbbbb00b00000000000000000
000000000aaa000000333f00000000000000000000000000000000000000000000000000000000000000000000000006bbbbbbbbbbbbbbbb6000000000000000
00000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000bbbbbbb00b00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000bbbbbbb00600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000bbbbbbb00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600bbbbbbb00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00bbbbbbb06000000000000000000
000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000006bbbbbbbbbbb0b000000000000000000
00000000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00bbbbbbbbbbb6000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600bbbbbbb0b000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb06000000000000000000
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
00000000000000000000000000000000000000000000060000000060000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000b00000000b0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000f88f00000000000000000000000006bbb6000000b0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ff8aff00000000000000000000000000b0000006bbb600000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ff8aff00000000000000000000000000b00000000b0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ff8bff0000000000000000000000008bbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ff8bff000000000000000000000bbb8bbbbbbbbbbbbb00000000000000000ffffffffff00000000000000000000000000000000000000000000
0000000000000ff8aff0000000000000000000b07bb8bbbbbbbbbbbbb0000000000000000ffffffffffff0000000000000000000000000000000000000000000
0000000000000ff8aff0000000000000000000bbbbb8bbbbbbbbbbbbb00000000000000008aabbaaabaa80000000000000000000000000000000000000000000
0000000000000ff8aff0000000000000000000b07bb8bbbbbbbbbbbbb00000000000000008888888888880000000000000000000000000000000000000000000
0000000000000ff8bff00000000000000000000bbbb8bbbbbbbbbbbbb0000000000000000ffffffffffff0000000000000000000000000000000000000000000
0000000000000ff8aff0000000000000000000000008bbbbbbbbbbbbb00000000000000000ffffffffff00000000000000000000000000000000000000000000
0000000000000ff8aff00000000000000000000000000b0000000b00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000f88f000000000000000000000000000b0000000b00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000b000006bbb6000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000006bbbbb60000b00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000b0000000600000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077007700770777077700000000077007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700070007070707070000700000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777070007070770077000000000007007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007070007070707070000700000007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770007707939707077700000000077707770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009a9a908880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000999998f8f0000000000000000000000000000000000000000000000000000000000000444000000000000000000000000000000000000000000000
000000000099999666600000000000000000000000000000000000000000000000000000000000000ab000000000000000000000000000000000044400000000
007770777099996666670077700770000000007770007077007770000000000000000000000000000ab00000000000000000000000000000000000ab00000000
00707070709a9a666670707070700007000000707007000700707000000000000000000000000000abb00000000000000000000000000000000000ab00000000
0077007770799944407070777077700000000070700700070070700000000000000000000000000aaa00000000000000000000000000000000000abb00000000
007070707070744440707070700070070000007070070007007070000000000000000000000000aaa00000000000000000000000000000000000aaa000000000
00777070707044444070707070770000000000777070007770777000000000000000000000000aaa00000000000000000000000000000000000aaa0000000000
000000000004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa00000000000
00000000700474400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000093944000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009a9a90888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999998f8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999996666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999966666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009a9a66660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099944400000000000000000000000000000000000000000000000000000000004440000000000000000000000000000000000000000000000000000
00000000000444400000000000000000000000000000000000000000000000000000000000ab0000000000000000000000000000000000000000000000000000
00000000004444400000000000000000000000000000000000000000000000000000000000ab0000000000000000000000000000000000000000000000000000
0000000004444400000000000000000000000000000000000000000000000000000000000abb0000000000000000000000000000000000000000000000000000
000000000444400000000000000000000000000000000000000000000000000000000000aaa00000000000000000000000000000000000000000000000000000
00000000004400000000000000000000000000000000000000000000000000000000000aaa000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000aaa0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000700070000000000000000000000000000000000000000000000000000090000000000000000000
00000000000000000000000000000000000000000000000000093900000000000000000000000000000000000000000000000000000999000000000000000000
0000000000000070007000000000000000000000000a0000009a9a90888000000000000000000000000000000000000000000000000090000000000000000000
000000000000000939000000000000000000000000aaa00000999998f8f000000000000000000000000000000000000000000000000000000000000000000000
000000000000009a9a9088800000000000000000000a000000999996666000000000000000000000000000000000000000000000000000000000000000000000
00000000000000999998f8f000000000000000000000000000999966666000000000000000000000000000000000000000000000000000000000000000000000
000000000000009999966660000000000000000000000000009a9a6666000a000000000000000000000000000000000000000000000000000000000000000000
000000000000009999666660000000000000000000000000000999444000aaa00000000000000000000000000000000000000000000000000000000000000000
000000000000009a9a6666000000000000000000000000000000044440000a0000a0004b00000000000000000000000000000000000000000000000000000000
00000000000000099944444400000000000000000000000000004444400000000000078870000000000000000000000000000000000000000000000000000000
0000000000000000044440ab00000000000000000000000000044444000000000000088880000000000000000000000000000000000000000000000000000000
0000000000000000444440ab000000000000000000000000000444400000000000000888f0000000000000000000000000000000009000000000000000000000
000000000000000444440abb000000000000000000000000000044000000000000000888f0000000000000000000000000000000000000000000000000000000
00000000000000044440aaa0000000000000000000000000000000000000000000000888f0000000000000000000000000000000000000000000000000000000
0000000000000000440aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000a00000000000004aaa000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000abb000000000004aaaaa00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaa0000000000004aaaaa00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000a0aaa00000000000004aaaaa60000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000aaaaa0000000000000004aaaa00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000a0000000000000000066aaa000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000aaa000000000000000000000000000000000000000000000000000
0000000000000000000000000004440000000000000000000000000000000000000000000aaaaa00000000000000000000000000000000000000000000000000
0000000000000000000000000000ab0000000000000000000000000000000000000000000aaaaa00000000000000000000000000000000000000000000000000
0000000000000000000000000000ab0000000000000000000000000000000000aaa000000aaaaa00000000000000000000000000000000000000000000000000
000000000000000000000000000abb000000000000000000000000000000000aaaaa000a00aaa700000000000000000000000000000000000000000000000000
00000000000000000000000000aaa0000000000000000000a00000000000000aaaaa00aaaabb0700000000000000000000000000000000000000000000000000
0000000000000000000000000aaa0000000000000000000aaa0000000000000aaaaa000aaaa00700000000000000000000000000000000000000000000000000
000000000000000000000000aaa000000000000000000000a000000000000000aaa0000aaa000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000a000000000000aaa0000000000000000000000000000000000000000000000000000000
00000000070007000000000000700070000000000000000000000000aaa000000000000000000000000000004440000000000000000000000000000000000000
000000000093900000000000000939000000000000000000000000000a0000000000000000000000000000000ab0000000000000000000000000000000000000
0000000009a9a90888000000009a9a90888000000000000000000000000000000000000000000000000000000ab0000000000000000000000000000000000000
000000000999998f8f00000000999998f8f00000000000000000000000000000000000000000000000000000abb0000000000000000000000000000000000000
000000000999996666000000009999966660000000000000000000000000000000000000000000000000000aaa00000000000000000000000000000000000000
00000000099996666600000000999966666000000000000000000000000000000000000000000000000000aaa000000000000000000000000000000000000000
0000000009a9a66660000000009a9a6666000000000000000000000000000000000000000000000000000aaa0000000000000000000000000000000000000000
00000000009994440000000000099944400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000044440000000000000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444440000000000004444407000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004444400000000000044444000939000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000
00000000004444000000000000044440009a9a908880000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044440000000000000440000999998f8f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ab00000000000000000009999966660000000000000000000000000000000000000000000000000000000900000000000000000000000000000
0000000000000ab00000000000000000009999666660000000000000000000000700070000000000000000000000000000000000000000000000000000000000
000000000000abb00000000000000000009a9a666600000000000000000000000093900000000000000000000000000000000000000000000000000000000000
00000000000aaa0000007000700000000009994440000000000000000000000009a9a90888000000000000000000000000000000000000000000000000000000
0000000000aaa0000000093900000000000004444000000000000000000000000999998f8f000000000000000000000000000000000000000009000000000000
000000000aaa000000009a9a90888000000044444000000000000000000000000999996666000000000000000000000000000000000000000000000000000000
00000000000000000000999998f8f000000444440000000000000000000000000999966666000000000000000000000000000000000000000000000000000000
007000700000000000009999966660000004444000000000000000000000000009a9a66660000000000000000000000000000000000000000000000000000000
00093900000000000000999966666000000044000000000000000000000000000099944400000000000000000000000000000000000000000000000000000000
009a9a908880000000009a9a66660000000000000000000000000000000000000000444400000000000000000000000000000000000000000000000000000000
00999998f8f000000000099944400000000000000000000000000000000000000004444400000000000000000000000044400000000000000000000000000000
0099999666600000000000044440000000000000000000000000000000000000004444400000000000000000000000000ab00000000000000000000000000000
0099996666600000000000444440000000000000000000000000000000000000004444000000000000000000000000000ab00000000000000000000000000000
009a9a666600000000000444440000000000000000000000000000000000000000044000000000000000000000000000abb00000000000000000000000000000
00099944400000000000044440000000000000000000000000000000000000000000000000000000000000000000000aaa000000000000000000000000000000
0000044440000000000000440000000000000000000000000000000000000000000000000000000000000000000000aaa0000000000000000000000000000000
000044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa00000000000000000000000000000000
00044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

__sfx__
000100000c0100f0111201114011170111b0111c0111e01120011210112101122011220112202121011200111e0111c0111a01117011130110f0110e0110e0110f0111001110011100111201115011170111c011
00010000310702d0702a07025060200501e0401a0301702014014130151205011050110501305014050170501b0501e050200501f05018050140500f0500c05009050050500305003050070500d0501305018050
0001000039270362703527033260302501c5402d2302b2202921026250005002325000500202501e250005001b250182501625014250112500f2500c2500b2500825005250042500325002250002500025000500
0001000004115041500315003150031500315003125031500315003150031500411504150051500615008150091500c1500e15012150161501a1501e15026155301502f100331053610037100391003b1003d100
00060000000000b3500d3250f3501235015350173501a3501541516450184501a4501c4501f455214501a3501d3502135025340293402f330323201c3001b3001b3001c3002030029300213001d3001c3001d300
000200002835027350263502535024350233502135020350203501c4501b4501b4501a450194501945018450184501135010350103500f3500e3500d3500c3500c35000000000000000000000000000000000000
00090000180701a070150701607000000180701a070150701607000000240702607021070220700c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c00000000000000000000000
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
012c002000000000000000000000000000000000000000001372413720137201372015724157201572015722137241872418720187201872018720187201872018725187021a7241c7211c7201c7201c7201c720
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
01 2e2f3031
00 2e2f3032
02 2e2f3033
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

__meta:cart_info_start__
cart_type: game
# Embed: 750 x 680
game_name: Apples and Banaynays
# Leave blank to use game-name
game_slug: 
jam_info: []
tagline: Revenge has never tasted so good
time_left: '0:0:0'
develop_time: ''
description: |
  Take on the evil oranges while slicing your way to banana-y goodness. 
  But watch out for the bonus level - everything is not as it seems
controls:
  - inputs: [X]
    desc: Swing sword
  - inputs: [ARROW_KEYS]
    desc: Move
hints: ''
acknowledgements: |
  * Game design and art by Ryan
  * Music is from [Gruber](https://www.lexaloffle.com/bbs/?uid=11292)'s [Pico-8 Tunes Vol. 2](https://www.lexaloffle.com/bbs/?tid=33675), Track 3 - Like Clockwork 
   Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
to_do: 
  - Fix bug of hot dog mode not resetting
  - Add sfx
  - Get rid of low fidelity hot dog
version: 0.1.0
img_alt: An apple holding a sword, surrounded by bananas and oranges
about_extra: ''
number_players: [1, 2]
__meta:cart_info_end__

