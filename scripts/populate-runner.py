import os
import glob
from pathlib import Path
import xml.etree.ElementTree as ET


def parse_game_xml(game_xml_path):
    print(f"Parsing game XML: {game_xml_path}")
    if not game_xml_path.exists():
        print(f"Game XML does not exist: {game_xml_path}")
        # raise Exception('game xml path does not exist')
        return {'desc': ''}
    else:
        print('Game XML DOES EXIST')
    
    try:
        tree = ET.parse(game_xml_path)
        root = tree.getroot()
        
        # Extract only the description from the game XML
        desc_elem = root.find("desc")
        if desc_elem is not None and desc_elem.text:
            raw_text = desc_elem.text.strip()
            lines = raw_text.split('\n')
            clean = '\n'.join(line.strip() for line in lines)
            return {"desc": clean}
        
        return None
    except Exception as e:
        print(f"Error parsing game XML: {e}")
        return None

def process_p8_file(file_path, game_name):
    # Replace this with your processing logic
    print(f"Processing file: {file_path}")
    with open(file_path, 'r') as f:
        contents = f.read()
    game_xml = Path(file_path).parent / 'export' / 'game.xml'
    game_xml_info = parse_game_xml(game_xml)

    label = contents.split('__label__')[1].split('__')[0].strip()
    lines = label.split('\n')
    lines = [line[::2] for line in lines[::2]]
    label = '\n'.join(lines)

    
    # with open('carts/pic8/images1.p8', 'r') as f:
    #     contents = f.read()
    #     preamble, bottom = contents.split('__gfx__')
    #     _, postamble = bottom.split('__meta:cart_info_start__')

    # with open('carts/pic8/images1.p8', 'w') as f:
    #     f.write(f'{preamble}__gfx__{label}__meta:cart_info_start__{postamble}')
    
    # .replace('\n', '')
    try:
        label_bytes = bytes.fromhex(label)
    except ValueError:
        label_bytes = b''

    label_string = ','.join(str(x) for x in label_bytes)

    pieces = game_name.split('-')
    spaced_out = []
    cur_piece = ''
    for piece in pieces:
        if len(cur_piece) + len(piece) > 15:
            spaced_out.append(cur_piece)
            cur_piece = piece
        else:
            cur_piece += ' ' + piece
    spaced_out.append(cur_piece)
    processed_game_name = '\n  '.join(spaced_out)

    return {
        'name': processed_game_name,
        'path': f'/{file_path}',
        'description': game_xml_info['desc'],
        # 'label': label_string,
        'label': '',
        'label_raw': label,
    }
    
    # Add your processing code here

def traverse_carts():
    # Get all directories in the carts folder
    cart_dirs = sorted([d for d in os.listdir('carts') if os.path.isdir(os.path.join('carts', d))])
    cart_dirs = [d for d in cart_dirs if d != 'pic8']
    games = []
    labels = []
    for i, folder_name in enumerate(cart_dirs):
        # Look for the p8 file with the same name as the folder
        p8_file_path = os.path.join('carts', folder_name, f"{folder_name}.p8")
        
        # Check if the file exists
        if os.path.isfile(p8_file_path):
            game_info = process_p8_file(p8_file_path, folder_name)
            games.append(game_info)
            labels.append(game_info['label_raw'])
        else:
            print(f"No matching p8 file found for folder: {folder_name}")
        if len(labels) == 4:
            cart_index = i//4 - 1

            # Split each multiline string into a list of lines
            lines1 = labels[0].splitlines()
            lines2 = labels[1].splitlines()
            lines3 = labels[2].splitlines()
            lines4 = labels[3].splitlines()

            # Combine line by line
            top = [a + b for a, b in zip(lines1, lines2)]
            bottom = [c + d for c, d in zip(lines3, lines4)]

            # Merge top and bottom
            result = "\n".join(top + bottom)

            with open(f'carts/pic8/images{cart_index}.p8', 'w') as f:
                f.write(f'''pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--pic8 images{cart_index}
--mini mech media

__gfx__
{result}''')
            labels = []
        elif len(labels) > 4:
            raise Exception('Missed it or something')
            
    return games

if __name__ == "__main__":
    games = traverse_carts()
    string = ''
    # for g in [games[0], games[2]]:
    for g in games:
        string += f'''
makeGame(
    {g['path']!r},
    {g['name']!r},
    {g['description']!r},
    {g['label']!r}),'''
    
    with open('carts/pic8/pic8.p8', 'r') as f:
        contents = f.read()
        
    # Replace the GAMES section with our generated games list
    start_marker = "-- START GAMES"
    end_marker = "-- END GAMES"
    start_index = contents.find(start_marker) + len(start_marker)
    end_index = contents.find(end_marker)
    
    if start_index >= 0 and end_index >= 0:
        new_contents = contents[:start_index] + string + contents[end_index:]
        with open('carts/pic8/pic8.p8', 'w') as f:
            f.write(new_contents)
    else:
        print("Error: Could not find GAMES markers in the file")
    # print(GAMES)
