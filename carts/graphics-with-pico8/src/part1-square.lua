function _draw()
	for point in all({
		{x=0,y=0},
		{x=0,y=1},
		{x=1,y=0},
		{x=1,y=1}
	}) do
		line(point.x, point.y)
	end
end