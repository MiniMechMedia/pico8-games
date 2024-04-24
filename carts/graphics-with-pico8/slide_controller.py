import time
import os
def open_slide(file_name):
    os.system(f'"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" -b {file_name}')

# Clear
with open('index_list.txt', 'w'):
    pass

def infinite_loop():
    last_line_count = 0
    while True:
        with open('index_list.txt', 'r') as file:
            lines = file.readlines()
            current_line_count = len(lines)
            if current_line_count > last_line_count:
                new_line = lines[-1].strip()  # Get the last line
                open_slide(new_line)
                last_line_count = current_line_count
        time.sleep(0.25)

# Call the function to start the loop
infinite_loop()
