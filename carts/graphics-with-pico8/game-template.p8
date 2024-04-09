pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--base

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

function subinit()

end

function _init()
	gs = {
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
		currentAnimation = nil
	}

	subinit()
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

end

function _update()
	if gs.isGameOver then
		if gs.endTime == nil then
			gs.endTime = t()
		end
		-- Restart
		if not gs:shouldDelayRestart() then
			if btnp(dirs.x) then
				_init()
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

	acceptInput()

end

function drawGameOverWin()

end

function drawGameOverLose()
	color(7)
	if not gs:shouldDelayRestart() then
		print('\n press ❎ to play again')
	end
end
function subdraw()

end

function _draw()
	-- cls(0)
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

	-- Draw
	subdraw()
end
-->8
--cube rasterize

function vec3(x,y,z)
    return {
        x=x,y=y,z=z
    }
end

function polygon(vertex_list)
    return {
        vertex_list = vertex_list
    }
end

function dot(u, v)
    return u.x*v.x + u.y*v.y
end

function world_to_screen(world)
    return {
        x=world.x*32+64,
        y=world.y*32+64
    } 
end

-- Assuming vec2
function point_in_polygon(vertex_list, point)
    local num_vertices = #vertex_list
    for i=1, num_vertices do
        local a = world_to_screen(vertex_list[i])
        local b = world_to_screen(vertex_list[(i % num_vertices) + 1])

        local edge_x, edge_y = b.x - a.x, b.y - a.y
        local normal_x, normal_y = edge_y, -edge_x
        local point_x, point_y = point.x - a.x, point.y - a.y
        -- print(normal_x)
        -- local dotProduct = dot(normalVector, pointVector)
        local dot = normal_x * point_x + normal_y * point_y
        -- print(dot)
        if dot < 0 then
            return false -- Point is outside the polygon
        end
    end
    return true -- Point is inside the polygon
end

local cubeFaces = {
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    polygon({vec3(-1,-1,-1), vec3(-1,1,-1), vec3(1,1,-1), vec3(1,-1,-1)}),
    -- {x = 0, y = 0, z = 0}, -- Vertex 0
    -- {x = 1, y = 0, z = 0}, -- Vertex 1
    -- {x = 1, y = 0, z = 1}, -- Vertex 3, revisiting through the cube
    -- {x = 1, y = 0, z = 0}, -- Vertex 1, backtrack
    -- {x = 1, y = 1, z = 0}, -- Vertex 5, moving up
    -- {x = 1, y = 1, z = 1}, -- Vertex 7, across the top
    -- {x = 0, y = 1, z = 1}, -- Vertex 6, completing top face traversal
    -- {x = 0, y = 0, z = 1}, -- Vertex 2, moving down
    -- {x = 1, y = 0, z = 1}, -- Vertex 3, completing bottom face traversal
    -- {x = 1, y = 1, z = 1}, -- Vertex 7, diagonally across the cube
    -- {x = 1, y = 1, z = 0}, -- Vertex 5, backtrack on the top face
    -- {x = 0, y = 1, z = 0}, -- Vertex 4, completing top face traversal
    -- {x = 0, y = 0, z = 0}, -- Vertex 0, moving down
}



function fillPolygon(polygon)
    for v in all(polygon.vertex_list) do
        local screen = world_to_screen(v)
        line(screen.x, screen.y, 7)
    end
    for x=0,128 do
        for y=0,128 do
           if point_in_polygon(polygon.vertex_list, {x=x,y=y}) then
                pset(x,y,7)
           end
        end
    end
end

function subdraw()
    cls()
    for face in all(cubeFaces) do
        fillPolygon(face)
    end
    -- fillPolygon(cubeFaces[1])
end
-->8
-- function _draw()
-- 	cls()
-- 	for point in all({
-- 		{x=0,y=0},
-- 		{x=0,y=1},
-- 		{x=1,y=1},
-- 		{x=1,y=0}
-- 	}) do
-- 		line(point.x*60, point.y*60)
-- 		flip()
-- 	end
-- end
local cubeVertices = {
    {x = 0, y = 0, z = 0}, -- 000
    {x = 1, y = 0, z = 0}, -- 001
    {x = 1, y = 1, z = 0}, -- 011
    {x = 0, y = 1, z = 0}, -- 010
    {x = 0, y = 1, z = 1}, -- 110
    {x = 1, y = 1, z = 1}, -- 111
    {x = 1, y = 0, z = 1}, -- 101
    {x = 0, y = 0, z = 1}, -- 100
}

local cubePath = {
    {x = 0, y = 0, z = 0}, -- Vertex 0
    {x = 1, y = 0, z = 0}, -- Vertex 1
    {x = 1, y = 0, z = 1}, -- Vertex 3, revisiting through the cube
    {x = 1, y = 0, z = 0}, -- Vertex 1, backtrack
    {x = 1, y = 1, z = 0}, -- Vertex 5, moving up
    {x = 1, y = 1, z = 1}, -- Vertex 7, across the top
    {x = 0, y = 1, z = 1}, -- Vertex 6, completing top face traversal
    {x = 0, y = 0, z = 1}, -- Vertex 2, moving down
    {x = 1, y = 0, z = 1}, -- Vertex 3, completing bottom face traversal
    {x = 1, y = 1, z = 1}, -- Vertex 7, diagonally across the cube
    {x = 1, y = 1, z = 0}, -- Vertex 5, backtrack on the top face
    {x = 0, y = 1, z = 0}, -- Vertex 4, completing top face traversal
    {x = 0, y = 0, z = 0}, -- Vertex 0, moving down
}

math = {
	cos=cos,
	sin=sin
}


local square = {
		{x=0,y=0},
		{x=0,y=1},
		{x=1,y=1},
		{x=1,y=0}
	}

cls()
function subdraw2()
	cls()
	local count = 0
	for point in all(cubePath) do
		count += 1
		-- line(point.x*60+30, point.y*60+30)
		a = t()/6
		
		-- p = point
		p = {
			x=point.x-.5,
			y=point.y-.5,
			z=point.z-.5
		}

		x,y,z=p.x,p.y,p.z+1.2
		x = (z * sin(a) + cos(a) * math.cos(a) * x - math.cos(a) * math.sin(a) * y)
	    y = (math.sin(a) * x + math.cos(a) * y)

		x,y=x/z,y/z

	    -- line((p.z*sin(a)+cos(a)*cos(a)*p.x-cos(a)*sin(a)*p.y)*60+60,(sin(a)*p.x+cos(a)*p.y)*60+60,7)


		x,y,z = x*60+60,y*60+60,z*60+60

	    line(x,y)

	    -- line((p.z*sin(a)+cos(a)*cos(a)*p.x-cos(a)*sin(a)*p.y)*60+60,(sin(a)*p.x+cos(a)*p.y)*60+60,7)
	    -- if count == 8 then
		--     circfill((p.z*sin(a)+cos(a)*cos(a)*p.x-cos(a)*sin(a)*p.y)*60+60,(sin(a)*p.x+cos(a)*p.y)*60+60,3,8)
		-- end
		-- flip()
		-- yield()
	end
	-- gs.currentAnimation = cocreate(function()
	-- 	for point in all({
	-- 		{x=0,y=0},
	-- 		{x=0,y=1},
	-- 		{x=1,y=1},
	-- 		{x=1,y=0}
	-- 	}) do
	-- 		line(point.x*60, point.y*60)
	-- 		-- flip()
	-- 		-- yield()
	-- 	end
	-- end)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

