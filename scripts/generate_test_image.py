import os
try:
    from PIL import Image, ImageDraw
except ImportError:
    print("ERROR: Pillow is required. Run: pip install pillow")
    exit(1)

# Create a 512x512 image with a black background
img = Image.new('L', (512, 512), color=0)
draw = ImageDraw.Draw(img)

# Draw some white shapes to create strong edges
draw.rectangle([100, 100, 400, 400], fill=255)
draw.ellipse([200, 200, 300, 300], fill=128)
draw.polygon([(50, 50), (90, 10), (10, 90)], fill=200)

img_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'images'))
os.makedirs(img_dir, exist_ok=True)
out_path = os.path.join(img_dir, 'sample_shapes.jpg')

img.save(out_path)
print(f"Generated test image at: {out_path}")
