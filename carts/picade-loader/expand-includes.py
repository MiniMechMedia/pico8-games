import glob

shim_code = open('shim.lua').read()

for game in glob.glob('*.p8'):
	game_text = open(game).read()
	game_text = game_text.replace('#include shim.lua', shim_code)
	with open('expanded/' + game, 'w') as file:
		file.write(game_text)
