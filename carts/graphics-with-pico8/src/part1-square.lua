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
function subdraw()
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