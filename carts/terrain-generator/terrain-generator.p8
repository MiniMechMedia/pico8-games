pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--terrain generator              v0.1.0
--caterpillar games



metaTable = {
	__unm = function(v)
		return vec2(-v.x, -v.y)
	end,
	__tostring = function(v)
		return 'vec2(' .. v.x .. ', ' .. v.y .. ')'
	end,
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


function vec2(x, y)
	local ret = {
		x = x,
		y = y,
		dot = function(self, other)
			return self.x * other.x + self.y * other.y
		end,
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
			return sqrt(dx * dx + dy * dy)
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

points = nil
isFirst = nil
cellDim = 10
cellWidth = nil
corner = vec2(0, 0)

points2 = {}
points3 = {}

maskFunction = nil

function _init()
	reload()
	for i, val in pairs(colorMap) do
		pal(i-1, val, 1)
	end

	-- returns a value between 0 (not really) and 1 
	local heightFunc = function(x, y, peak)
		local dist = max(-0.5, (64 - (vec2(x,y) - peak):length()) / 64)
		return dist
	end

	local mountains = {
		vec2(64,64) + vec2fromAngle(rnd()) * 20,
		vec2(64,64) + vec2fromAngle(rnd()) * 20,
		vec2(64,64) + vec2fromAngle(rnd()) * 40 * rnd(),
		vec2(64,64) + vec2fromAngle(rnd()) * 40 * rnd()
	}
	local sign = sgn(rnd() - 1) 
	local radius = rnd(2) + 1


	maskFunction = rnd({
		function(originalHeight, x, y)
			return originalHeight + heightFunc(x, y, vec2(64, 64)) - 0.5
		end,

		function(originalHeight, x, y)
			for peak in all(mountains) do
				originalHeight += heightFunc(x, y, peak) - 0.5
			end
			return originalHeight
		end,

		function(originalHeight, x, y)
			return originalHeight + 2*(1.5*(vec2(x, y) - vec2(64,64)):length() - 64) / 128
		end,

		function(originalHeight, x, y)
			local diff = ((x - 64) * (y - 64) / 4000)
			return originalHeight + diff * sign
		end,

		function(originalHeight, x, y)
			return originalHeight
		end,

		function(originalHeight, x, y)
			local distance = (vec2(x, y) - vec2(64,64)):length() / 20
			local offset = 1 / (1 + (distance - radius) * (distance - radius))
			return originalHeight + offset - 1
		end
	})

	points = {}
	isFirst = true
	lastLine = 0
	cellWidth = 64 / cellDim

	for i = 1, cellDim + 1 do
		points[i] = {}
		for j = 1, cellDim + 1 do
			points[i][j] = vec2fromAngle(rnd())
		end
	end

	for i = 1, cellDim*2 + 1 do
		points2[i] = {}
		for j = 1, cellDim*2 + 1 do
			points2[i][j] = vec2fromAngle(rnd())
		end
	end

	for i = 1, cellDim*4 + 1 do
		points3[i] = {}
		for j = 1, cellDim*4 + 1 do
			points3[i][j] = vec2fromAngle(rnd())
		end
	end
end

colorMap = {
	129,
	1,
	140,
	12,
	15,
	11,
	3,
	6,
	7
}

function mapNoise(noiseValue)
	local normalized = (noiseValue + 1) / 2
	local index = flr(#colorMap * normalized)
	return mid(0, index, #colorMap - 1)
	-- return 0
end

function getNoise(scale, pointArray, mypos)
	local pos = mypos / 128 * (scale * cellDim)
	local relativePos = vec2(pos.x % 1, pos.y % 1)
	local gridStart = vec2(flr(pos.x) + 1, flr(pos.y) + 1)

	local g00 = pointArray[gridStart.x][gridStart.y]:dot(relativePos - vec2(0, 0))
	local g10 = pointArray[gridStart.x+1][gridStart.y]:dot(relativePos - vec2(1, 0))
	local g01 = pointArray[gridStart.x][gridStart.y+1]:dot(relativePos - vec2(0, 1))
	local g11 = pointArray[gridStart.x+1][gridStart.y+1]:dot(relativePos - vec2(1, 1))

	local blendedTop = (1 - relativePos.x) * g00 + relativePos.x * g10
	local blendedBot = (1 - relativePos.x) * g01 + relativePos.x * g11

	return blendedTop * (1 - relativePos.y) + relativePos.y * blendedBot
end

function writeToSheet()
	for x = 0, 127 do
		local y = lastLine

		local firstOctave = getNoise(1, points, vec2(x, y))
		local secondOctave = getNoise(2, points2, vec2(x, y)) / 2
		local thirdOctave = getNoise(4, points3, vec2(x, y)) / 4
		local noiseValue = firstOctave + secondOctave + thirdOctave

		local finalNoise = maskFunction(noiseValue, x, y)

		sset(x, y, mapNoise(finalNoise))
	end
end

lastLine = 0

function _draw()
	-- draw it all
	palt(0, false)
	spr(0, 0, 0, 16, 16)

	pal(15, 129)
	rectfill(0, lastLine, 128, 128, 15)
end

function _update()
	if lastLine < 128 then
		writeToSheet(lastLine)
		lastLine += 1
	end

	if btnp(5) then
		_init()
	end
end
__label__
hhhhhhhhhhhhhh11111hhhhhhh11sss11hhh1111sccccsss11111111s11sssss1hhhhh111111111sssssccssss1111hhhhhhhhh11sssssss111hh111hhhhhhhh
hhhhhhhhhhhhhh1111hhhhhhhh111ss11hh1111ssccccsss1111ss11111ssss11hhhhhhh11111111111sscccssss111hhhhhh11ssssssss1111hh11111hhhhhh
1hhhhhhhhhhhhhh11hhhhhhhh1111ss11hh11ss1ssccccsss1sssss1111111111hhhhhhhhhhhhhhh11ssssccsssss11hhhh111sssssssss111hhhh111111hhh1
1hhhhhhhhhhhhhhhhhhhhhhh111111s11hh11ss1ssccccccssssccss1111111hhhhhhhhhhhhhhhh111ssssssssssss11h1111sscccccssss111hhh1111111111
1hhhhhhhhhhhhhh11hhhh1111111111111111s111scccccccccccccs11111hhhhhhhhhhhhhhhhhh11sssssss1sssss11111ssccccccccsss1111h1111111111s
11hhhhhhhhhhhh111hhhh1111111111111111111ssscccccffccccccs111hhhhhhhhhhhhhhhhhhh1sscssss11ssssss111sscccccccccsss111111111111111s
111hhhhhhhhhh111111hh111h1111h1111ss1111ssccffccfffcffccss1hhh1hhhhhhhhhhhhhhh11scccssssssssssss11sssccccsssss111111111111111111
111hhhh11hhhhh11111h1111hhhhhhh1111s11ssssccffffffffffccss11h1111hhhhhhhh111111sscccsssssscssssss1ssssccssssss11111h111111111111
111hhhh11hhhhhh111111111hhhhhhhhh1111ssscccfffffffffffccss1111111hhhhhhh111111ssscccccsssscsssssssssssssssssss1111hh111sss111111
111hhhh11hhhhh11111111111hhhhhhh111ssssccccffbfffffccccsss1111sss1hhhhhh11sssssssccccccsssssssssssssssssssssss111hhh111sss111111
hhhhhhhhhhhh11111sss1111hhhhhhh111ssssscccffbbbbbffccccssssssssss111111111sssssscccccccsssssssssssssssssscccss11hhh111ssss1111ss
hhhhhhhhh11111111sss11hhhhhhhh1111sssssccffbbbbbbffcccssssssssssssssss1111ssscccccccccccssssss11s111ssssscccss1hhhh11sssss1111ss
hhh111111111111111ss111hh111111111ssssscccffbb3bbffcccssssssssssccccsssssssssccccccffffccssss11111111ssssscss1hhhhh11sssss111111
h1111111111111111111111111ssssss111111sscccffbbbbffccccssccccccccffccssscsssscccffffbbffccsss11111111sssssss11hhhhh1ssssssss1111
h111111111111ssss11hhh1111sssss11h1111sssccfffbbbfccsccccffffcffffffcccccccccccffbbbbbbfffcccssss111sssssssss111h111sssss111111h
h111111hhh11sssss11hhhh111sssss1hhh1111sscccfffbbfccsccfffffffffbfffffccccffcccfbbb3bbbbbfffccssss1sssssscssss11111sssssss11111h
h1111hhhhh111sss1s11hhh11sssss11hhh11ss1ssccfffffffccccffbfbbbbbbbffffffffffffffbb333333bbfffccccsssssssscssssss111ssscccsss111h
111111hhhh1111ssss11hhh11ssss111hhh111111sccfffffffcccffbbbbbbbbbbbbbbbffffbbfffbbbbb333bbfffcccccssss1sssssssss11sssccccsss11hh
h11111hhhh11111ssss11hh11sssss111h111s111ssccfffffccccffbbbbbb333bbbbbbbffbbbbbbbbbb3333bbffffccccsss111ssssssssssssccccccsss11h
h111111hhhh111ssss111hh11ssccss11111sss11scccfcccccccccfffffb3333bbbb33bbbbbbbbbbbbb3333bbfffccccssss1s11ssssssssssccfffccccss11
h111111hhhh111111ss111111ssccsssss11ss111ssccfcccccccccfffffb3333bbbbbbbbb333b33333366633bfffccccssssss11ssssssssscfffffcccccs11
111ss11hhhh1111111ss11111ssccccssssss1111sccffcccccccccffffffb333bbbbbbbb3333333333666633bfffccccssssss111sssssssccfffffccscss11
1111ss111h111111ssss11111sccccccccsss111ssccfccccfffcccffffffb3333b333bbb3333333333336333bffcfffcsssss11111sss1sscccccccccssss11
1111111111111h11ssss11111sccfcccccssssssscfffcccffffcccffffffbbbbb333333bbbbbbbbb333333bbbffffffcsssss111111s1ssccccccccccsss111
1hhh111111111111sss111111scfffffcccssssscfbbffffffffcccfffffffbbbb333333bbbbbbbbbbbbbbbbbffffffcccsssss1111111sscccsssssssss111h
1hhhh1111111111ssss111111sccfffcccssssccfbbbbffffffffcccccfcfffffb3333bbbbbbbfffffffbbbfffffffccccccccsss1111ssccssssssssss1111h
1hhhhhhhhh1ssssssss111111sccfffccssssccfbb333bbffffffcccccccccccfb33bbbbfffffcccccccfffcccfcccccfccccccsss111scccss1111sss111111
hhhhhhhhhh11ssssss111111sscffffccssssccfbb333bbbbfffffffccccssscfbbbbfffffffcsssccccccccccccccccffcccccss1111sssss111111ssssss11
hhhhhhhhhh11sssss1111111sccffffccssssccfbb33bbbbbfffffffcccssssccfbbfffffccccs1ssssssssccccsscccffcccccss1111sssss111111sssssss1
hhhhhhhhhh1111s111111111sccffffccssssccfbbbbbbbbfffffffccccssssccfbffffccccccs11sssssssscsssccccccfffcccsss111ss1sssssssssssssss
hhhhhhhhhh1111111111111ssccffffcccccccffbbbbbbbbffffffccfccssssscfffffccccccss111sssssssssscccfccfffffccsss11s1111ssssssssssssss
hhhhhhhhhh111111111sssssccccffffccccccffbbbbbbbffccfffccfccsssssccffffccccccss111sssssssssscccfccfffffccssssss1111ssssssssssssss
hhhhhhhhhh11111111sssssccccffbbffffccffffbbbbbbffccffffffcs11ssccccffffffcccssss111sscsssscccccccfffcccsssssss1111sss1ssss1ssss1
hhhhhhhhh11111111ssssscccffffbbbfffffffffbbbbfffcccffcccccs1ssssccccffffffffccsss1ssssssssscccccccccffcccccsss11111s1111ssssssss
hhhhhhhhh1111111ssscsscccfffbbbbfffffffbbbbbffffccccccsssss11sssccccffffffffcccsssssssssssccccccscccfffcccccss1111111111ssscssss
hhhhhhhhh1111111sscccsccccffbbbbbbffffbbbbbfffffcccccsss111111ssscccffccfffccccsssssssssssccccccccccfffccccccssss11s11111ssccss1
hhhhhhhhhh111111sscccccccccfbb33bbbbbbbbbbbffcfffcccsss1111111sscccfffccccfccccssssssssssccccccccccfffffcccccccss11sss111ssscss1
hhhhhhhhh111111ssccfcccccccfbb33bbbbfbbbbbbffccffcccss11111h11sscccffcccccffccsssssssscccccfffffcfffffffcccccccssssssss111sscss1
11hhhhh1111sssssccffffffccffbb3bbffffffffffffcffffccs111111111ssscccccccccffccccccccccccccfffffffbbffffffccfccccssssss1111ssssss
1111hhh111ssccscccfffffffffbbbbbfffcccffffffffffffcss1hhh1hh11ssssccccccccffcccccffccccccfffbbbbbbbbffffffffccccssscss111sssssss
111111111sscccccccfffffffffbb3bbffcffffffffffbffffcs11hhhhhhh111sssscccccccccscccffffffcffbbbbbbbbbbbffffffffcccssccss11ssssssss
111111111sscccccccfffffffffbb3bbffffffffbffffbbbffccs1hhhhhhhhh111sscccssssssssccfffffffffbbbbbb33bbbbfffffffcccccccssssssssssss
1ss11111sssscccffffffffffffbbb3bbbbbbbbbbbfffbbbbffcs1111hhhhhhh11ssccsssssssssccffcfffffbb33b3333333bbffffffcccccccssssccssssss
1sssssssssssccfffffffffffffbbb333bbbbbbbbffffbbbbffccs111hhhhhhhh1ssssssssssssscfffccfffbb33333333333bbbbbbffcccccccssssccssssss
1sssssssssssccffffffffffffbbb333333333bbfffcfffbfffccs111hhhhhhhh11sssssssssssscfffccfffbbbbbbbb33333bbbbbbbffcccccsssssssssssss
1scccsssssssccfffffffffffbb333663333333bffcccffffffcccs111hhhhhhh111111111ssssscccccccfffbbbbffbbb33bbbbbbbbbfccccssssssssssssss
1scccccccccscccccfffffffbb3366633333333bffccccccfcccccssss1hhhhhhh11111111sssssccccccccffbbbffffbbbbbbfbbbbbbbfffcssssssssssssss
1sscccccccccsscccfffffffb3366663333333bbffccssccccccccsssss1hhhhhhh1111111sssscccccccccfffbffffffbbbbbffbbbbbbbbfccsssssssssssss
1sscfffcccccsssccccfffffbb33333333b333bfccccsssssssccccssss1111hhhh1111111ssssccccccccccffffffffffffbbffbbbbb33bbfcsssssss1111ss
hsscfffcccccsssssscccfffbb33333333bbbbfccssssssss1ssccccsss11111111111111ssssssccccsssssccfcccccffffbbfbbb333333bffcssssss11111s
1sccffffffcccsssssssccccffbbbbbbbbbbbffccssssss1111scccssss11111111111s11ssss1sssssss1sssccccccccccffbffbb333333bbfccsssss111111
1scccfffffccccsssssssssscffbbfffbbbffcccsss111111h11ssss111sss1111111sss1ssss1ssssss111ssscsssccccccffffbb3333333bfcccsccss11111
scfffffffffccss11ss11ssscfffbbbbbbbffccssss11111hhh1sss1111sssss11111ssssssssssssss111ssssccccccccccffffbb333b33bbfcccccccssssss
cffffffffffccss111s1sssccffbbbbbbbfffccssss1111hhhh11ss1111sscsssss1sscccssssssssss111ssssccccccccccfffffb33bbbbbfcccccccccssscc
fffffffffffccss1111sssscffbbbb33bbffccsssss1111hhhh111111111ssssssssssccccsssssssssssssssssccccccccffffffbbbbbbbffcccccccccccccc
fffffffffffcccs1111ssscffbbbb3333bfcccsssss11111hhhh111111111ssccccsssccfccssssssssssscccsssssccfffffffffbbbffffcccccccccccccccc
ffffffffffffccs1111ssccffbbbb333bbfccssssss11111hhhhhhhhhhh11ssccccsssccfccsssssscccccccccscssccffffffffbbbffffccccccccccccccccc
ffffffffffffcs11111sccfffbbb3333bffcsssssss11hhhhhhhhhhhhhh11ssccsssssccccccssssccccccfcccscccccccccffffbbbfffcccccccccccccccccc
ccffcfffffffcs11111scccfffbbbbbbbfccsssssss11hhhhhhhhhhhhhh111ssssss11sscccccccccffcfffccssccccccccccccfffffffccccccccccccccccss
scccffffffffcs1111ssccccfffffbbbfcccsssssss11hhhhhhhhhhhhhhhh1ssssss111sssscccfffffffffccssscccccccccccccfccffccccccccccccccssss
scccffffffffcss1sssscccccffffbbffcccssssss11hhhhhhhhhhhhhhhhh11sss11111ssssccffffffffffccssssccccccccccccccccccccccccfccccccsss1
sccfffffccccccsssssscccccfffbbbbfccccssss1hhhh11hhhhhhhhhhhhhh1111111111ssssccfffccfffffccsssssscccccccccccccccccsscffffffccsss1
sccfffffcccccccccccsscsccffbbbbbffffccss11hhh11111hhhhhhhhhhhhh1hhhhhh1111sssccfccffffffccsssssssccccccccssscccccsccffffffccsss1
sccfffffcccccccccccssssscffbbbbbfffffcss11hh11sss11hhhhhhhhhhhhhhhhhhhh111111sccccfcffccccsssccccccffcfcssssscscccccfffffcccss11
1scffffcccccccccccccccssscfbb33bbbfffccs111111sssss1hhhhhhhhhh11hhhhhhhhhhhhh1sscccccccccssssccccffffffcss111ssscccccffcccccss11
scccccccccccccccccssscssscfbb33bbbfffcss111111sssss1hhhhhhhhhh111hhhhhhhhhhhh11sccccccccss11ssccfffffffccs111sscccfcfccccccss111
scccccccccccccccsssssssssccfbbbbbfffccss111111sssss1hhhhhhhhhh1111hhhhhhhhhhhh1ssssssccss111ssccfffffffcss111ssccffffcccccss11hh
scccccccccccccccss1ssssssscffbbfffffcss111111ssssss1hhhhhhhhhhhhhhhhhhhhhhhhhh11ssssssss1111sssccccfffccs1111scccffffccccss11hhh
sccfffcccccccccs1111ssssssccfffffffccsss11111ssssss1hhhhhhhhhhhhhhhhhhhhhh1111111sssssss111ssssscccccccss11h1sccccfffccccss1hhhh
sccffffcccccccss1111sssssscccffffffccssss1111111ss11hhhhhhhhhhhhhhhhhhhhh11111111ssssss1111sssssscccccsss1111scccfffffcccss1hhhh
ssccfffcffffccs11111ssscccsccfffffffcssss11111111s11hhhhhhhhhhhhhhhhhhhh111111111ssssss1111sssssscccccsss1111scfcfffffcccss11hhh
1scccfffffffccss1111sssccssscffffbbffcccss1111111111hhhhhhhhhhhhhhhhh1111111ss1111111s1111sssssssccccssss111sccfffffffcccsss111h
1ssscfffffffcccssssssssssssccfffbbbbfffccs11hhhhhh11hhhhhhhhhhhhhhhh1111111ssss1111111111ssssssssccccss1111ssccfffffffccccssss11
11sscffffffccccssssssssssssccffbbbbffffccs1hhhhhhhh1hhhhhhhhhhhhhhh11sss11sssss1111h1111sssssssssccccsss11sssccffffffcccccssss11
11ssccfffffccccsssssssssssccffbbbbfffffcss1hhhhhhhhhhhhhhhhhhhhhhh11sssssssssss111h11111ssssscsssscccsssssssccfffffcccccccss1111
111ssccffffccccssssssssssccffbbbbfffffccs111hhhhhhhhhhhhhhhhhhhhh11ssccsssss1111111111111sscccccsccccccsssssccfffffccccccsss1111
111ssscfffcccccsssssscccccfbbbbbbffcfcccss1111hhhhhh11hhhhhhhhhhh1sscccss1111111111111111scccfffcfffccccccccccfffffccssssss11111
111s1sccffccccsscccscccccffbbbbbbffffccssss1111hhhh1ss111hhhhhhh1ssssss1111111s1111111s1sscffffffbbbbbfffffccffffffccsss11111111
11111sccccccccssscccccccccffbbbbbfffcccssss111111111ss111hhhhhhhh1sss111hhhh1111hh1111sssccfffbbb3333333bbfffffffffccss1ss111111
h1111scccccsssssssccsssccfffffbbbfffccsssss111111111s1111hhhhhhhh11s11hhhhhhhhhhhh1111ssscffbb333666633333bfffffffcccsssss111111
hh111ssccccssssssssssssccffffbbbbbffccsssss111111111111111hhhhhhhh1111hhhhhhhhhhh111111sscfbb3366666636663bffffffcccsssss111h111
hh1111sccccssssssssssscccffffbbbbbfffccsss1111111111111111hhhhhhhh11111hhhhhhhhh1111hh11scbb33366666666633bffffffccssssss11hh111
hh1111sscccssssssssssscccffffbbbbbffffcsss111111111ss11111hhhhhhhhh1111hhhhhhhhh1111hh11scb333366666666333bfffccccssscsss11hh111
h11111sscccccccccccssssccfffffffbfffffcssss111111sssss111hhhhh111hh1111hhhhhhhhh1111hh11scb33333366666333bbfffcccssscccsss111111
h111111scccccfcccccsssscffffffffbfffffcssssssssssssssss111111111111111hhhhhhhhhhh11111sscfb3333333333333bbbfffcssssscccsss1hh111
1111111ssccccfccsccsssccffffffffbbfbffcsssssssssssssssss1111sssssss111hhhhhhhhhhh11ssssscfb33333bb333333bbfffccssscccssss11hhh11
1111111sscccfccsssssssccfffffffbbbbbfccsccssccssssssssssssssssssssss111111111h11111ssssscfbb3333bbbb333bbffffccssccssssss1111111
111hhh11scccccsssssssscffffffffbbbbbfccscsscccsssssccssssscsssssssss11111111111111sssssscfbbbbbbbbb333bbbffccccssssss1sss1111111
11hhhhh1scccccs11ssssccffffffffbbbbbffccccccccsssscccsssscccsssssssssssssssssssssssssssscfbbbbbbfbbbbbbbffccccccsssss1ss111sss11
11hhhh1scccccs11111ssccffffffffbb33bbfccccccccsssscccsssssssssssssssssssssccssssssssssssscfbbbbbbbbbbbfffccsscccsssss1ss11sssss1
111111sccccccs11111scccffffffffbb3333bffccccccsssccccccsssssssssssssssssccccccccssssssssscfbbbbbbbbbbfffccssssssssssssssssccccss
1111sssccccccsssssssccffbbbbffbb33633bbffffccccccccccccccsssssssssssssssscccccccssssssssscfbbbbbbbffffcccss11sssscccsssssccffccc
1111ssccccccccsssssccffbbbbbbbb3366633bfffffffffcfffffffcccccccsssssssssscccccccssssssssscfbbbbbfffffccsss111sssscccsscccccfffcc
h111sscccccccccccsscfffbbbbbb333366633bfffffffffffffffffffffffcccccsssssscccccccssssssssccfffffffffcccss11111sssscccsccccccccccs
h1111scccfcccccccccccffbbb3b3333366333bffffffbbffffbbbbbbbbbbbfffcccccccsccccfcsssssscccsccfffffffcccss11111sssssscssccccccccccs
h1111sccccccccccfccccfffbb3bb333366633bbfffffbbbfffbbbbbbbbbbbbbffccccccccccffcssssscccccccffffffccccs111111ssssssssscccccccccss
1111ssccccccccccccccccfffbbbb333666663bbbffffbbbfffbbbbb3333333bbffffcccccccffccssscccccccffffbfccsssss11111sssssscsccccccsccsss
11sssssccccssssssccsccfffbbbb333366633bbbbffffbbbbb33333333333bbffffccccccffffccssscccccccffffffccsssss11111ssssssssssssssssccss
1sssssscccccsss1sssssccffbbbbbb3336333bbbbfffffbbbb33333333333bbfffcccccccffffcccccccccccccfffffccsssss11111ssssssssssssssssccss
11sssscccccccs111111sscffbfffbbbb3333bbbbfcccffffbb33333633333bbfffccccccccffffcccccccccccccffffcccsss11111sssssss11ssssssssssss
h11sssccccccss11111h1sscffffffffbb33bbbbffcccccfffbbb336663333bbbffcccccccccfffccccccccccccfffffcccccss1111ssssss111sss1ssssssss
h1sssccccccsss1hhhhh11sccffffffffb33bbfffcsssccccffbbb33663333bbffcccccsssccffffccccccccccfffbffcffcccss11ssssssss11sss1ssssssss
11sscccccccss11hhhhh11sscccccffffbbbbfffcsssscccccffbb33333333bbfccccccssscccffffffcccccccfbbbbfffffcccsssssscssssssssssssssssss
1sscccccccsss11hhhhh111sssscccffffffffffcsssscccccfffbbbbb33333bfccccccsssccffffffffffffcfbb33bbfffffcccssssccsss1111111111sssss
1scccccssssss1hhhhhhh1111ssssccccfffffffcsssscccccccffffbbb3333bffcccccccccffbffffffffffffb33333bbbffcccssssccss111hhh111h11sss1
sscccccssscss1hhhhhhhhhh111ssscccccfffffccsssccccccccccfffbbbbbbffcccccccccffbfffffffbbffbb33333bbbbfffccsssscss11hhhhhhhhh11s11
sscccccssscss1hhhhhhhhhhhhh1sscccccffffccccssccssssssccffffbbbbbffccsscccccffffffffcffbffbbb3333bbbbbffcccsssss111hhhhhhhhh11111
sscccfcccccs1hhhhhhhhhhhhhh11sscccfffcccccccccsssssssccffffffffffcccsssccccfffffffccfffffbbbb333bbbbbbffcccsss111hhhhhhhhhhhhh11
sscccccccccs11hhhhhhhhhhhhh11sssccccccccccccsssssssssscccccccfffcccssssccccfffffffccffffffbbbbbbbbbbbbfcccssss1111hhhhhhhhhhhh11
1scccccccccss11hhhhhhhhhhhh11ssssccccccccsssssssssssssscccssccffccssssccccccccffcccffbbbbfffffbbbffffffccsssss1111hhhhhhhhhhhh11
1scccfffffccss11hhhhhhhhhhh11ssscccccsssssssssssscccssssss1sssccccsssccfccccccccccfffbbbbffffffffffffcccss111s11111hhhhhhhhhhhhh
1scccfffffccss11111hhhhhhhh11ssscccccssss11ss1sssccccssss1111ssccccsccffccccccccccfffbbbfffcccccfffccccss1111111111hhhhhhhhhhhhh
1sccccfffcccs111111hhhhhhhh1sssscccccsss1ssss11ssccccssss111sssscccccfffccffcccccccfffffffcccccccffccssss111111111hhhhhhhhhhhhhh
1sscccccccccs11111hhhhhhhh111ssssccccssssssss1sssccccssss111sssscccfffffcccccccccccfffffcccccccccccccss111111111111hhhhhhhhhhhhh
1ssccccccccss11111hhhhhhhh111sssscccccssssssssssssccccssss111ssccccfffffccccccccccccfffcccsccccccccccss111111111111hhhhhhhhhhhhh
h1ssssssssss11111hhhhhhhh111sssssccccsssccccccccsssccccsss1111sccccffffffffccccccccccccccsssssscccccccs1111h111111111hhhhhhhhhhh
h1ssssssssss11hhhh1hhhh11sssssssscccssssccccccsssssccccsss11h11sccccffffffffffcccccssssss11111ssccccccs111hhhh1hhh1111hhhhhhhhhh
h11ssssss1ss11hhh1111111sssssssssssssssssccccssssssscccsss1hhh11sssccfffffbbbfccccsssss111hh11sscccccss11hhhhhhhhh1111hhhhhhhhhh
h11111ss1111111hh111hh11sscssssssss11111sscccsssssssccsss11hhhh1sssccfffffbbbffcccss11111hhhhh1sssscsss11hhhhhhhhh1111hhhhhhhhhh
hh1111s1111111hh111hhh1sscccccss111111111sssscsssssssssss11hhhhh1sscccfffffbbffcccs11111hhhhhhh11sssss111hhhhhhhhhh1111hhhhhhhhh
hhh11111111111hh11hhhh1ssccccccs11111hhh111sssssssssssss111hhhhh1sscccfffffbbbfcccs11111hhhhhhhh11111111hhhhhhhhhhh111hhhhhhhhhh
hhhh1111hh1111hh1hhhhh1ssccccccs11hhhhhhh1111ssss11sssss111hhh111sccccfccffbbffcccss11111hhhhhhhh111111hhhhhhhhhh1111hhhhhhhhhhh
hhhhh11hhhhh11hh11111111ssscccccs1hhhhhhh11hhh111111ssss111hh11ssccccfcccfffffccccccs1111hhhhhhh111111hhhhhh11hhh1111hhhhhhhhhhh
hhhhhhhhhhhhhhhhhh11111ssssccffcs1hhhhhh11hhhhhhhhh11sss1111111ssccccccccfffffccccccss111hhh111111111hhhhhhh111hhh111hhhhhhhhhhh
hhhhhhhhhhhhhhhhhh11111ssssccffcs1hhhhhhhhhhhhhhhhhh111ss111111ssscccccccccfffccccccss1111h111111111hhhhhhh11111hhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhh11111ssssccfcss1hhhhhhhhhhhhhhhhh1111ss111s11sssccccccccccccccssssss111111111111hhhhhh11111111hhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhh11111111sssccccs11hhhh11hhhhhhhhh111111ssssss11ssscccsssssccccsssssss111111111111hhhhhh11111111hhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhh11111111ssccccs111hh11111hh111111111111ssssss11ssssss11sssssssssssss111111111111hhhhh11ss1111111hhhhhhhhhhhhh


__meta:cart_info_start__
cart_type: game
# Embed: 750 x 680
game_name: Terrain Generator
# Leave blank to use game-name
game_slug: 
jam_info: []
tagline: Generate terrain using Perlin noise
time_left: '0:0:0'
develop_time: ''
description: |
  Generate terrain using [Perlin noise](https://en.wikipedia.org/wiki/Perlin_noise)
controls:
  - inputs: [X]
    desc: Regenerate terrain
hints: ''
acknowledgements: ''
to_do: []
version: 0.1.0
img_alt: A chain of islands in an ocean
about_extra: ''
number_players: [1]
__meta:cart_info_end__
