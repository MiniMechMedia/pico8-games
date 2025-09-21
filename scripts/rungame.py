import sys
import subprocess
#print(sys.argv)
import logging

try:


    if sys.argv[1].endswith('.dyn'):
        subprocess.run(sys.argv[1], check=True)
    else:
        subprocess.run([
            '/home/pi/pico-8/pico8_dyn',
            '-run',
            sys.argv[1],
        ], check=True)

except Exception as e:
    logger = logging.getLogger(__name__)
    logger.exception(None)
    print('Press enter to quit')
    input()

