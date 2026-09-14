import sys
import os
try:
    from PIL import Image
except ImportError:
    print("ERROR: Please install Pillow by running: pip install pillow")
    sys.exit(1)

def convert_image(input_path, output_hex_path, size=(512, 512)):
    print(f"Opening {input_path}...")
    try:
        img = Image.open(input_path)
    except Exception as e:
        print(f"Failed to open image: {e}")
        sys.exit(1)
        
    # Convert to Grayscale and resize
    img = img.convert('L')
    img = img.resize(size)
    
    # Save a copy of the resized image for comparison
    resized_path = os.path.join(os.path.dirname(input_path), "input_resized.jpg")
    img.save(resized_path)
    print(f"Saved resized reference image to {resized_path}")

    # Extract pixels and write to hex file
    pixels = list(img.getdata())
    with open(output_hex_path, 'w') as f:
        for p in pixels:
            # Write 8-bit hex value (e.g., "ff", "0a")
            f.write(f"{p:02x}\n")
            
    print(f"Successfully wrote {len(pixels)} pixels to {output_hex_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python img2hex.py <input_image.jpg>")
        sys.exit(1)
        
    input_file = sys.argv[1]
    # Ensure sim directory exists
    sim_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'sim'))
    os.makedirs(sim_dir, exist_ok=True)
    
    output_file = os.path.join(sim_dir, "input.hex")
    
    convert_image(input_file, output_file)
