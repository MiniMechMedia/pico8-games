import pathlib
import subprocess
import traceback
import glob
import shutil
import os

try:
	abs_file = pathlib.Path(__file__).absolute()
	git_repo_root = abs_file.parent.parent.resolve()
	
	print('Updating git repo at ' + str(git_repo_root))
	subprocess.run(
		'git pull origin master'.split(),
		cwd=str(git_repo_root),
		check=True
		)

	games_root = git_repo_root.parent / 'games'

	gameListXml = '<gameList>'

	print('Updating gamelist.xml')
	games = glob.glob(str(git_repo_root / 'carts/*/export/*.png'))
	print(f'found {len(games)} games')
	for game in games:
		print(game)
		shutil.copy(game, games_root)
		gamePath = pathlib.Path(game)
		with open(gamePath.parent / 'game.xml') as gameXml:
			gameListXml += gameXml.read()

	gameListXml += '</gameList>'

	with open('/opt/retropie/configs/all/emulationstation/gamelists/pico8/gamelist.xml', 'w') as f:
		f.write(gameListXml)

	print('Updating pico-8')
	downloads_root = git_repo_root.parent / 'downloads'
	try:
		shutil.rmtree(str(downloads_root))
	except:
		pass
	os.mkdir(str(downloads_root))

	subprocess.run(
		'wget https://www.lexaloffle.com/dl/7tiann/pico-8_0.2.6b_raspi.zip'.split(),
		cwd=str(downloads_root),
		check=True
		)

	for file in glob.glob(str(downloads_root / '*')):
		subprocess.run(
			[
				'unzip', 
				file
			],
			cwd=str(downloads_root),
			check=True
		)

	try:
		os.remove('/home/pi/pico-8/pico8_dyn')
	except:
		pass

	shutil.copy(downloads_root / 'pico-8' / 'pico8_dyn', '/home/pi/pico-8')


except:
	# traceback.print_exc()
	print("Something went wrong")
	print(traceback.format_exc())

print('Press enter to continue')
input()
