pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--snowman simulator              v0.1.0
--caterpillar games




function drawSnowBall(self, isSelected)
	local col = 7
	if isSelected then
		col = 6
	end

	local rad = self:getRadius()
	if 1.5 < rad and rad < 2 then
		if isSelected then
			spr(4, self.pos.x - 3, self.pos.y - 3)
		else
			spr(3, self.pos.x - 3, self.pos.y - 3)
		end
	elseif rad == 0 then
		pset(self.pos.x, self.pos.y, col)
	else
		circfill(self.pos.x, self.pos.y, self:getRadius(), col)
		circ(self.pos.x, self.pos.y, self:getRadius(), 6)
	end
end

function drawCoal(self, isSelected)
	local col = 0
	if isSelected then
		col = 5
	end
	local rad = self:getRadius()
	if 1.5 < rad and rad < 2 then
		if isSelected then
			spr(2, self.pos.x - 3, self.pos.y - 3)
		else
			spr(1, self.pos.x - 3, self.pos.y - 3)
		end
	else
		circfill(self.pos.x, self.pos.y, self:getRadius(), col)
	end
end


function drawCarrot(self, isSelected)
	local points = self:getCarrotPoints()

	-- TODO fill it in...
	local col = 9
	if isSelected then
		col = 10
	end



	for ind = 1, 3 do
		local prevInd = ind - 1
		if prevInd < 1 then prevInd = 3 end
		local nextInd = ind + 1
		if nextInd > 3 then nextInd = 1 end
		
		local cur = points[ind]
		local prevP = points[prevInd]
		local nextP = points[nextInd]
			
		local dx = prevP.x - nextP.x
		local dy = prevP.y - nextP.y
			
		local n = 40
		for j = 1, n do
			local ix = j/n * dx + nextP.x
			local iy = j/n * dy + nextP.y
			line(cur.x, cur.y, ix, iy, col)
		end

	end

	-- local lastPoint = point3
	-- for point in all({point1, point2, point3}) do
	-- 	line(point.x, point.y, lastPoint.x, lastPoint.y, col)
	-- 	lastPoint = point
	-- end
end


snowBallObjType = 'snowball'
coalObjType = 'coal'
carrotObjType = 'carrot'
drawFuncMap = {}
drawFuncMap[snowBallObjType] = drawSnowBall
drawFuncMap[coalObjType] = drawCoal
drawFuncMap[carrotObjType] = drawCarrot

stampToolName = 'stamp'
coalStamp = 'coal' --stampToolName .. coalObjType
snowballStamp = 'snowball' -- stampToolName .. snowBallObjType
carrotStamp = 'carrot' -- stampToolName .. carrotObjType

deleteToolName = 'delete'
editToolName = 'edit'

function makeToolKit()
	-- {
	-- 	name = stampToolName,
	-- 	objType = snowBallObjType,
		-- protoTypeObj = nil
	-- }
	local tools = {}
	tools[1] = {
		name = snowballStamp,
		objType = snowBallObjType,
		index = 2,
		protoTypeObj = nil,
		isStamp = true
	}
	tools[2] = {
		name = coalStamp,
		objType = coalObjType,
		index = 1,
		protoTypeObj = nil,
		isStamp = true
	}
	tools[3] = {
		name = carrotStamp,
		objType = carrotObjType,
		index = 3,
		protoTypeObj = nil,
		isStamp = true
	}
	tools[4] = {
		name = editToolName,
		index = 4,
		selectedObject = nil,
		isEdit = true
	}
	tools[5] = {
		name = deleteToolName,
		index = 5,
		isDelete = true
	}

	return {
		tools = tools,
		getTentativeObject = function(self)
			local tool = self:getSelectedTool()
			if tool == nil then
				return nil
			end
			if tool.isEdit then
				return tool.selectedObject
			end
			return tool.protoTypeObj
		end,
		selectedToolIndex = nil,
		hasHover = function(self)
			local tool = self:getSelectedTool()
			return tool.isDelete or tool.isEdit
		end,
		hitX = function(self)
			local tool = self:getSelectedTool()
			if tool.isStamp then
				tool.protoTypeObj.isSelected = false
				local clone = tool.protoTypeObj:clone()
				-- clone.isSelected = true
				add(gs.placedObjects, clone)
			elseif tool.isEdit then
				if tool.selectedObject != nil then
					tool.selectedObject = nil
				else
					local obj = self:getHoveredObject()
					if obj == nil then
						return
					end
					tool.selectedObject = obj
					moveCursorToObj(obj)
				end
			elseif tool.isDelete then
				local obj = self:getHoveredObject()
				if obj != nil then
					del(gs.placedObjects, obj)
				end
			end
		end,
		getHoveredObject = function(self)
			-- Get from the top layer down
			for i = #gs.placedObjects, 1, -1 do
				local obj = gs.placedObjects[i]
				if obj:doesIntersect(gs.cursor.pos) then
					return obj
				end
			end
			return nil
		end,
		hitZ = function(self)
			local index = self.selectedToolIndex + 1
			if index > #self.tools then
				index = 1
			end
			self:selectTool(index)
		end,
		hitA = function(self)
			local index = self.selectedToolIndex - 1
			if index < 1 then 
				index = #self.tools
			end
			self:selectTool(index)
		end,
		getSelectedTool = function(self)
			return self.tools[self.selectedToolIndex]
		end,
		selectTool = function(self, toolIndex)
			-- self.selectedTool = self.tools[toolIndex]
			self.selectedToolIndex = toolIndex
			local tool = self:getSelectedTool()
			if tool.isStamp then
				if tool.protoTypeObj == nil then
					tool.protoTypeObj = makeObject(
						tool.objType,
						vec2(64, 64), 
						0, 
						4)
				end

				moveObjToCursor(tool.protoTypeObj)
			end
			-- self.selectedTool.protoTypeObj.isSelected = true
			-- add(gs.placedObjects, self.selectedTool.protoTypeObj)
		end
	}
end

function moveObjToCursor(obj)
	obj.pos.x = gs.cursor.pos.x
	obj.pos.y = gs.cursor.pos.y
end

function moveCursorToObj(obj)
	gs.cursor.pos.x = obj.pos.x
	gs.cursor.pos.y = obj.pos.y
end

function makeSnow()
	local ret = {}
	for i = 1, 100 do
		ret[i] = {
			x = rnd(128),
			y = rnd(128)
		}
	end

	return ret
end

function _init()
	music(1)
	palt(1, true)
	palt(0, false)
	gs = {
		snow = makeSnow(),
		placedObjects = {
			makeObject(snowBallObjType, vec2(64, 90), 0, 4),
			-- makeObject(coalObjType, vec2(25, 64), 0, 4),
			-- makeObject(carrotObjType, vec2(64, 64), 0, 10)
		},
		cursor = {
			pos = vec2(64, 64)
		},
		getSelectedObject = function(self)
			return self.toolKit:getTentativeObject()
			-- for obj in all(self.placedObjects) do
			-- 	if obj.isSelected then
			-- 		return obj
			-- 	end
			-- end
			-- return nil
		end,
		isNoneSelected = function(self)
			return self:getSelectedObject() == nil
		end,
		toolKit = makeToolKit()
		-- selectedTool = nil
	}


	-- initTool()
	gs.toolKit:selectTool(1)
	-- gs.placedObjects[2].isSelected = true
	-- -- init tool
	-- gs.selectedTool.protoTypeObj = makeObject(
	-- 	gs.selectedTool.objType,
	-- 	vec2(64, 64), 
	-- 	0, 
	-- 	4)


end

function vec2(x, y) 
	return {
		x = x,
		y = y
	}
end


function addVec(v1, v2)
	return vec2(
		v1.x + v2.x,
		v1.y + v2.y)
end

function smulVec(s, v)
	return vec2(
		s * v.x,
		s * v.y)
end

function unitVec(ang)
	return vec2(
		cos(ang),
		sin(ang))
end

function mysign(p1, p2, p3)
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
end
-- https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
function pointInTriange(testPoint, points)
    local d1 = mysign(testPoint, points[1], points[2]);
    local d2 = mysign(testPoint, points[2], points[3]);
    local d3 = mysign(testPoint, points[3], points[1]);

    local has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0);
    local has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0);

    return not (has_neg and has_pos);
end

function makeObject(objType, pos, ang, scale)
	local drawFunc = drawFuncMap[objType]
	assert(drawFunc != nil)
	
	return {
		objType = objType,
		pos = pos,
		ang = ang,
		scale = scale,
		draw = drawFunc,
		isSelected = false,
		getRadius = function(self)
			if self.objType == coalObjType then
				return self.scale * 0.5
			elseif self.objType == snowBallObjType then
				return self.scale * 5
			end
			-- Cannot get carrot radius (yet?)
			assert(false)
		end,
		doesIntersect = function(self, coord)
			if self.objType == carrotObjType then
				local radius = self.scale
				if radius < 2 then
					if radius < 1 then
						radius = 1
					end
					local dx = abs(self.pos.x - coord.x)
					local dy = abs(self.pos.y - coord.y)
					if dx < radius and dy < radius then
						return sqrt(dx * dx + dy*dy ) <= radius
					end
					return false
				end
				-- todo
				local points = self:getCarrotPoints()
				return pointInTriange(coord, points)
			else
				local radius = self:getRadius()
				if radius < 1 then
					radius = 1
				end
				local dx = abs(self.pos.x - coord.x)
				local dy = abs(self.pos.y - coord.y)
				if dx < radius and dy < radius then
					return sqrt(dx * dx + dy*dy ) <= radius
				end
				return false
			end
		end,
		clone = function(self)
			return makeObject(
				self.objType,
				vec2(self.pos.x, self.pos.y),
				self.ang,
				self.scale)
		end,
		getCarrotPoints = function(self)
			return {
				addVec(self.pos, smulVec(self.scale * 2, unitVec(self.ang))),
				addVec(self.pos, smulVec(self.scale * 2, unitVec(self.ang - 0.45))),
				addVec(self.pos, smulVec(self.scale * 2, unitVec(self.ang + 0.45)))
			}
		end
	}
end

dirs = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	z = 4,
	x = 5
}

moveFrameCount = 0

function acceptEditInput()

	local moveSpeed = 0.5
	if moveFrameCount > 5 then
		moveSpeed = 1
	end

	local didMove = false

	if btn(dirs.left, 0) then
		gs.cursor.pos.x -= moveSpeed
		didMove = true
	end
	if btn(dirs.right, 0) then
		gs.cursor.pos.x += moveSpeed
		didMove = true
	end
	if btn(dirs.up, 0) then
		gs.cursor.pos.y -= moveSpeed
		didMove = true
	end
	if btn(dirs.down, 0) then
		gs.cursor.pos.y += moveSpeed
		didMove = true
	end

	if didMove then
		moveFrameCount += 1
	else
		moveFrameCount = 0
	end

	local obj = gs:getSelectedObject()

	if obj == nil then
		return
	end

	-- TODO accelerate based on how long it's been happening
	-- obj.pos.x = gs.cursor.pos.x
	-- obj.pos.y = gs.cursor.pos.y
	moveObjToCursor(obj)

	local scaleSpeed = 0.2
	local angSpeed = -0.01
	local minScale = 0

	if btn(dirs.left, 1) then
		obj.ang -= angSpeed
	end
	if btn(dirs.right, 1) then
		obj.ang += angSpeed
	end
	if btn(dirs.up, 1) then
		obj.scale += scaleSpeed
	end
	if btn(dirs.down, 1) then
		obj.scale -= scaleSpeed
		if obj.scale < minScale then
			obj.scale = minScale
		end
	end

end

function acceptToolButtons()
	if btnp(dirs.x) then
		-- obj.isSelected = false
		gs.toolKit:hitX()
	end

	if btnp(dirs.z) then
		gs.toolKit:hitZ()
	end

	if btnp(dirs.x, 1) then
		gs.toolKit:hitA()
	end
end

function updateSnow()
	for flake in all(gs.snow) do
		flake.y += rnd(1.0)
		flake.x += rnd(1.0) - 0.5
		if flake.y > 128 then 
			flake.y = 0
		end
		if flake.x > 128 then
			flake.x = 0
		elseif flake.x < 0 then
			flake.x = 128
		end
	end
end

function _update()
	updateSnow()
	acceptEditInput()

	acceptToolButtons()

	-- if gs:isNoneSelected() then
	-- 	acceptCursorInput()
	-- end
end

function drawbackground()
	rectfill(0, 0, 128, 128, 12)		-- light blue
	rectfill(0, 96, 128, 128, 7)		-- white
end

function drawPlacedObjects()
	local hoveredObj = nil
	if gs.toolKit:hasHover() then
		hoveredObj = gs.toolKit:getHoveredObject()
	end
	for obj in all(gs.placedObjects) do
		obj:draw(obj == hoveredObj)
	end
end

function drawTentativeObject()
	if gs.toolKit:getSelectedTool().isEdit then
		return
	end
	local obj = gs:getSelectedObject()
	if obj != nil then
		obj:draw(true)
	end
end

function drawCursor()
	-- TODO invert colors??
	color(0)
	line(gs.cursor.pos.x - 4, gs.cursor.pos.y,
		gs.cursor.pos.x + 4, gs.cursor.pos.y)

	line(gs.cursor.pos.x, gs.cursor.pos.y - 4,
		gs.cursor.pos.x, gs.cursor.pos.y + 4)
end

function drawMenu()
	local x = 2
	for i = 1, #gs.toolKit.tools do
		local col = 0
		if i == gs.toolKit.selectedToolIndex then
			col = 5
		end
		print(gs.toolKit.tools[i].name, x, 121, col)
		x += #gs.toolKit.tools[i].name * 4 + 3
	end
end

function drawSnow()
	for snow in all(gs.snow) do
		pset(snow.x, snow.y, 7)
	end
end

function _draw()
	cls(0)
	drawbackground()

	drawPlacedObjects()

	drawTentativeObject()

	drawSnow()

	drawCursor()

	drawMenu()

	-- drawSelectedObject()
end

__gfx__
00000000111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111001111115511111166111111661110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000110000111155551111677611116666110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000110000111155551111677611116666110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111001111115511111166111111661110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccc
cccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccc7cccccccccccccccccc7cccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccc7cccccccccccc7ccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7667777777666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc677777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc6677777777777777766cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc677777777777777777776cccccccccccccccccccccccccccccccccccccccccccc7cccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccc67777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc67777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777777777777776ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc7cccccccccccccccccccccccccc677777700777777770077777776cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc677777000077777700007777776cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc677777000077777700007777776cccccccccccccccccccccccccccccccccc7ccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc67777777007777777700777777776ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc7ccccccccccccc67777777777779999777777777776ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc67777777777779799999999777776ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc67777777777779999999999999999ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc7ccccccccccccccccccccccccccccccccc677777777777799999999999999999cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc67777777777779999979999999776ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc67777777777779999977777777776ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc7ccccccccccccccc777777777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc677700777777777777770077776cccccccccccccccc7ccccccccccc7ccccccccccccccccccccc
ccc7cccccccccccccccccccccc7cccccccccccccccccccccccc677000077777777777707007776cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc6700007777777777770000776ccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccc67007770077770077700776cccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc67777700007700007777776cccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc677770000770000777776ccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc7ccccccc7cccccccccccccccccccccccccccccc66667770077770077776666ccccccccccccccccccccccccccccccccc7cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc6777767777777777777677776ccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc677777766677777776667777776cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc67777777777666666677777777776ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc6777777777777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777776c7ccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc67777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc67777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccc6777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccccccccccccccccccccccccccccccccccc6777777777777777777777777777777777776ccccccccccccccccccccccccccccccccc7ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc7ccccccccccccccccc677777777777777777007777777777777777776cccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc677777777777777770000777777777777777776cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777700007777777777777777776ccccccccccccccccccccccc7cccccccc7ccccccccc7
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777770077777777777777777776ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccc7ccccccccc
ccccccccccccccccc7cccccccccccccccccccccccccc67777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777770077777777777777777776ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777700007777777777777777776cccccccccccc0ccccc7cccccccccccccccccccccccc
ccccccccc7cccccccccccccccccccccccccccccccccc67777777777777777700007777777777777777776cccccccccccc0cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc67777777777777777770077777777777777777776cccccccccccc0cccccccccccccccccccccccccccccc
ccccccccccc7ccccccccccccccccccccccccccccccccc677777777777777777777777777777777777776ccccccccccccc05ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777776ccccccccc000000000cccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777776cccccccccccc5055cccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccc6777777777777777700777777777777777776cccccccccccccc05ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccc6777777777777777000077777777777777776cccccccccccccc0cccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc67777777777777700007777777777777776ccccccccccccccc0cccccccccccccccccccccccccccccc
7cccccccccccccccccccccccccccccccccccccccccccccc67777777777777770077777777777777776cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc66777777777777777777777777777777766cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccc6776777777777777777777777777777776776ccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc677776777777777777777777777777777677776ccccccccccccccccccccc7cccccccccccccccccccccc
c7cccccccccccccccccccccccccccccccccccccccccc67777776777777777777777777777777767777776ccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccc6777777776777777777777777777777776777777776cccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc7ccccccc6777777777667777777777777777777667777777776cccccccccccccccc7cccccccccccccc7cccccccccc
cccccccccccccccccccccccccccccccccccccccccc677777777777766777777777777777667777777777776ccccccccccccccccccc7ccccccccccccccccccccc
cccccccccccccccccccccccccccc7ccccccccccccc677777777777777666777777777666777777777777776cccccccc7cccccccccccccccccccccccc7ccccccc
cccccccccccccccccccccccccccccccc7cccccccc67777777777777777776666666667777777777777777776cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccc67777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc6777777777777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc7cccccc6777777777777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc6777777777777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc6777777777777777777777777777777777777777777777776ccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc7c7cccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776ccccccccccccccccccccc7cccccccccccccccc
cccccccccccccccccccccccccccccc7cccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccc677777777777777777777777777777777777777777777777776cccccccccccccccccccccccccccccccccccccc
77777777777777777777777777777777777777776777777777777777777777777777777777777777777777776777777777777777777777777777777777777777
77777777777777777777777777777777777777776777777777777777777777777777777777777777777777776777777777777777777777777777777777777777
77777777777777777777777777777777777777776777777777777777777777777777777777777777777777776777777777777777777777777777777777777777
77777777777777777777777777777777777777776777777777777777777777777777777777777777777777776777777777777777777777777777777777777777
77777777777777777777777777777777777777777677777777777777777777777777777777777777777777767777777777777777777777777777777777777777
77777777777777777777777777777777777777777677777777777777777777777777777777777777777777767777777777777777777777777777777777777777
77777777777777777777777777777777777777777767777777777777777777777777777777777777777777677777777777777777777777777777777777777777
77777777777777777777777777777777777777777767777777777777777777777777777777777777777777677777777777777777777777777777777777777777
77777777777777777777777777777777777777777776777777777777777777777777777777777777777776777777777777777777777777777777777777777777
77777777777777777777777777777777777777777776777777777777777777777777777777777777777776777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777677777777777777777777777777777777777777767777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777767777777777777777777777777777777777777677777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777776777777777777777777777777777777777776777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777677777777777777777777777777777777767777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777767777777777777777777777777777777677777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777776777777777777777777777777777776777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777667777777777777777777777777667777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777776677777777777777777777766777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777766777777777777777776677777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777666677777777766667777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777766666666677777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77700700777007070700070007077707777777557755755575777777700700070007000770070007777000700770007000777700770007077700070007000777
77077707070707070707070707077707777775777575757575777777077707070707070707077077777077707077077707777707070777077707777077077777
77000707070707070700770007077707777775777575755575777777077700070077007707077077777007707077077707777707070077077700777077007777
77770707070707000707070707077707777775777575757575777777077707070707070707077077777077707077077707777707070777077707777077077777
77007707070077000700070707000700077777557557757575557777700707070707070700777077777000700070007707777700070007000700077077000777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__sfx__
0114000026752297522d7520000000000000002f7522d7522f7522d7520000000000000002f7522d7522f7522d7522b7522b7522a7522b7522d75200000000000000000000000000000000000000000000000000
0116000000000000001c752000001c7520000028752000001c752000001c752000001c7520000028752000001c752000001c752000001c75200000287520000026752000001f752000001c752000001a75200000
0110000000000000002c5002b50029500295002850028500275002750027500275002750028500215001e5001c5001b5001c5001f50022500265002950000300004000070000300002000c200183002440000000
011600000075200752000000075200752000000075200752000000000000752007520000000752007520000000000007520075200000000000000000000000000000000000000000000000000000000000000000
00160000000000000018752000001875200000187520000018752000001875200000187520000000000000000000000000187520000018752000000e752000001a75200000000000000000000000000000000000
011600001f752217522175200000000000000000000000001f752217522175200000000000000000000000001f75221752217520000000000000001f752217522175200000000000000000000000000000000000
011000000000000000000000000000000000000000000000000001c752000001c7520000028752000001c752000001c752000001c7520000028752000001c752000001c752000001c75200000287520000026752
011600000075200752000000075200752000000075200752000000000000752007520000000752007520000000000007520075200000000000000000000000000000000000000000000000000000000000000000
0116000000702007020000000702007020000000752000000000018752000001875200000187520000018752000001875200000187520000000000000000000000000187520000018752000000e752000001a752
0016000000000000000000000000000000000000000000000000018752000001875200000187520000018752000001875200000187520000000000000000000000000187520000018752000000e752000001a752
001600001f752217522175200000000000000000000000001f752217522175200000000000000000000000001f75221752217520000000000000001f752217522175200000000000000000000000000000000000
0016000000000000001d752000001d7520000029752000001d752000001d752000001d7520000029752000001d752000001d752000001d752000002875200000267520000021752000001c752000001a75200000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00160000000000000018752000001875200000187520000018752000001875200000187520000000000000000000000000187520000018752000000e752000001d75200000000000000000000000000000000000
__music__
01 00004344
01 01030405
02 0b031005


__meta:cart_info_start__
cart_type: game
game_name: Snowman Simulator
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: 98
    jam_url: null
    jam_theme: Snow
tagline: Do you want to build a snowman?
develop_time: 2h 54m 36s programming + 2h 6m music
description: |
  Use the tools to create and edit snowballs, coal, and carrots.
controls:
  - inputs: [ARROW_KEYS]
    desc: Move the cursor
  - inputs: [E,D]
    desc: Increase/decrease size
  - inputs: [S,F]
    desc: Rotate clockwise/counter-clockwise
  - inputs: [X]
    desc: Place / Select object
  - inputs: [Z]
    desc: Cycle through tools
  - inputs: [A]
    desc: Cycle through tools backwards
hints: ''
acknowledgements: Music created by my girlfriend
to_do: []
version: 0.1.0
img_alt: A snowman standing in a snowy field. Editor tools

number_players: [1]
__meta:cart_info_end__
