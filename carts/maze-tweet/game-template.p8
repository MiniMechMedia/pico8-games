pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--{GAMENAME}
--{AUTHORINFO} 



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

function _draw()
	cls(0)
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
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__meta:cart_info_start__
cart_type: game
# Embed: 750 x 680
game_name: Game Template
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: XX
    jam_url: null
    jam_theme: 'XXX'
tagline: XXXX
time_left: '0:0:0'
develop_time: ''
description: |
  
controls:
  - inputs: [X]
    desc: XXXX
hints: ''
acknowledgements: ''
to_do: []
version: 0.1.0
img_alt: XXXX
about_extra: ''
number_players: [1]
__meta:cart_info_end__


