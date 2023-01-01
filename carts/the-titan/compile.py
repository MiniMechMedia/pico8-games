import glob

import os

try:
	os.mkdir('compiled')
except:
	pass


def get_contents(included_file):
	with open(included_file) as included:
		return included.read()

def compile_file(filename, p8file):
	with open(f'compiled/{filename}', 'w') as output:
		for line in p8file:
			if line.startswith('#include'):
				included = line.replace('#include', '').strip()
				expanded = get_contents(included)
				output.write(f'\n{expanded}\n')
			else:
				output.write(line)


for file in glob.glob('*.p8'):
	with open(file) as p8file:
		compile_file(file, p8file)



