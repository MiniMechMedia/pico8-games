import glob

lua_code = ''

p8file = glob.glob('*.p8')[0]

slide_list = []
for slide in sorted(glob.glob('*.lua')):
    slide = slide.split('.')[0]
    slide_list.append(slide)
    lua_code += f'''\
#include '{slide}.lua'
{slide} = {{draw = draw}}
'''

slide_code = '\n'.join(slide_list)
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