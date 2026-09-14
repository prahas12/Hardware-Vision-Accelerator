import sys
import os
try:
    from PIL import Image
except ImportError:
    print("ERROR: Please install Pillow by running: pip install pillow")
    sys.exit(1)

def convert_hex(input_hex_path, output_image_path, size=(512, 512)):
    print(f"Opening {input_hex_path}...")
    try:
        with open(input_hex_path, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Failed to open hex file: {e}")
        sys.exit(1)
        
    pixels = []
    for line in lines:
        line = line.strip()
        if line:
            if 'x' in line.lower() or 'z' in line.lower():
                pixels.append(0)
            else:
                pixels.append(int(line, 16))
            
    # Note: The output image might be slightly smaller because the Sobel filter 
    # doesn't output valid pixels for the very first two rows due to the pipeline delay.
    # But for a simple demo, we will just pad it or load exactly what was generated.
    expected_pixels = size[0] * size[1]
    
    # Pad with zeros if the hardware didn't output enough pixels (due to pipeline latency)
    while len(pixels) < expected_pixels:
        pixels.append(0)
        
    # If it output too many, truncate
    pixels = pixels[:expected_pixels]

    img = Image.new('L', size)
    img.putdata(pixels)
    img.save(output_image_path)
    print(f"Successfully saved edge-detected image to {output_image_path}")

if __name__ == "__main__":
    # Ensure sim directory exists
    sim_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'sim'))
    input_file = os.path.join(sim_dir, "output.hex")
    
    img_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'images'))
    output_file = os.path.join(img_dir, "edge_detected_output.jpg")
    
    convert_hex(input_file, output_file)
