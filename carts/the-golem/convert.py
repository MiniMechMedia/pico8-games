from PIL import Image
import sys
import pyperclip
import os

# convert.py some-image.png

# Open the PNG image and read the pixel data
img_path = sys.argv[1]
img_filename = img_path.split('/')[-1]
image = Image.open(img_path) \
    .convert('L') \
    .convert('RGB')

# exe = '/Applications/Aseprite.app/Contents/MacOS/aseprite'
# os.system(f'{exe} -b {sys.argv[1]} --palette pico-8-1x.png --save-as testiasdf.png')
# os.system(f'{exe} -b index-to-palette.aseprite --palette=pico-8.gpl {sys.argv[1]} --save-as testiasdf.png')#--scale 0.125x0.125 --save-as testiasdf.png')
# os.system(f'{exe} -b {sys.argv[1]} --palette=pico-8-1x.png --scale 0.125x0.125 --save-as testiasdf.png')
# os.system(f'{exe} -b {sys.argv[1]} --resize 128x128 --save-as testiasdf.png')

# exit()


palette = '''
#000000
#1d2b53
#7e2553
#008751
#ab5236
#5f574f
#c2c3c7
#fff1e8
#ff004d
#ffa300
#ffec27
#00e436
#29adff
#83769c
#ff77a8
#ffccaa
#291814
#111d35
#422136
#125359
#742f29
#49333b
#a28879
#f3ef7d
#be1250
#ff6c24
#a8e72e
#00b543
#065ab5
#754665
#ff6e59
#ff9d81
'''.split()

img_palette=Image.open('pico-8-1x.png')
downscaled = image.resize((128,128))
quantized = downscaled.quantize(palette=img_palette)
final_image = f'processed_images/{img_filename}'
quantized.save(final_image)

image = Image.open(final_image).convert('RGB')

width, height = image.size
pixels = image.load()

palette = [(
    int(x[1:3], 16),
    int(x[3:5], 16),
    int(x[5:7], 16)
) for x in palette]
color_map = {color: index for index, color in enumerate(palette)}

# Convert each pixel to a hexadecimal digit
hex_string = ""
for y in range(height):
    for x in range(width):
        # Assign a hexadecimal digit to each color using a dictionary
        # print(pixels, pixels[0, 0])
        pixel = pixels[x, y]
        color = color_map[pixel]
        hex_val = hex(color)
        hex_string += hex_val[-1]
hex_string = f'"{hex_string}"'
# Print the hex string
print(hex_string)


# Copy the text to the clipboard
print('has been copied to clipboard')
pyperclip.copy(hex_string)