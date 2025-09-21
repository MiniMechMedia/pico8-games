#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

def process_all_p8_files():
    carts_dir = Path("/Users/nathandunn/Projects/pico8-games/carts")
    
    if not carts_dir.exists():
        print(f"Directory {carts_dir} does not exist!")
        return
    
    # Loop through all subdirectories in carts/
    for subdir in carts_dir.iterdir():
        if subdir.is_dir():
            print(f"Checking directory: {subdir}")
            
            # Find all .p8 files in this directory
            p8_files = list(subdir.glob("*.p8"))
            
            if p8_files:
                for p8_file in p8_files:
                    print(f"Processing: {p8_file}")
                    try:
                        # Run the p8export command
                        result = subprocess.run(
                            ["python", "-m", "src.p8export", str(p8_file)],
                            cwd="/Users/nathandunn/Projects/p8export3/p8export-fresh",
                            capture_output=True,
                            text=True
                        )
                        
                        if result.returncode == 0:
                            print(f"  ✓ Successfully processed {p8_file.name}")
                        else:
                            print(f"  ✗ Error processing {p8_file.name}: {result.stderr}")
                            
                    except Exception as e:
                        print(f"  ✗ Exception processing {p8_file.name}: {e}")
            else:
                print(f"  No .p8 files found in {subdir}")

if __name__ == "__main__":
    process_all_p8_files()
