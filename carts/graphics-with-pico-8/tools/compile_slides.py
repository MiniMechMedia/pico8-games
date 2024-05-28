import glob
import pathlib
lua_code = ''

p8file = glob.glob('*.p8')[0]

slide_list = []
for index, slide in enumerate(sorted(glob.glob('slide*.lua'))):
    new_file_name = f'slide_{str(index+1).zfill(3)}_{slide[10:]}'
    pathlib.Path(slide).rename(new_file_name)
    slide = new_file_name
    with open(slide) as file:
        contents = file.read()
    slide = slide.split('.')[0]
    slide_list.append(slide)
    init_fun = 'emptyinit'
    if 'function init()' in contents:
        init_fun = 'init'
        
    lua_code += f'''\
#include {slide}.lua
{slide} = {{draw = draw, init={init_fun}, name = '{slide}'}}
'''

slide_code = ',\n'.join(slide_list)
lua_code += f'''\
slides = {{
{slide_code}
}}\
'''
with open(p8file) as f:
    p8file_content = f.read()
prefix, middle = p8file_content.split('-- BEGIN SLIDES')
# print(middle)
_, suffix = middle.split('-- END SLIDES')


p8file_content = f'''\
{prefix[0:-1]}
-- BEGIN SLIDES
{lua_code}
-- END SLIDES\
{suffix}'''

with open(p8file, 'w') as f:
    f.write(p8file_content)