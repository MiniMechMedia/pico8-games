import pathlib
import subprocess
import traceback
import glob
import shutil

try:
	abs_file = pathlib.Path(__file__).absolute()
	git_repo_root = abs_file.parent.parent.resolve()

	subprocess.run(
		'git pull origin master'.split(),
		cwd=str(git_repo_root),
		check=True
		)

	games_root = git_repo_root.parent / 'games'

	gameListXml = '<gameList>'

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

except:
	traceback.print_exc()

print('Press enter to continue')
input()
