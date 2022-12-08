from PIL import Image
import sys
import pyperclip

# convert.py some-image.png

# Open the PNG image and read the pixel data
image = Image.open(sys.argv[1])
width, height = image.size
pixels = image.load()


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
        hex_string += hex(color_map[pixels[x, y]])[-1]
hex_string = f'"{hex_string}"'
# Print the hex string
print(hex_string)


# Copy the text to the clipboard
print('has been copied to clipboard')
pyperclip.copy(hex_string)