from PIL import Image
import argparse
import os

def overlay_images(background_path, foreground_path, output_path):
    try:
        # Open the background and foreground images
        background = Image.open(background_path).convert("RGBA")
        foreground = Image.open(foreground_path).convert("RGBA")

        # Ensure the foreground is the same size as the background, or resize if needed
        # Optional: foreground = foreground.resize(background.size, Image.Resampling.LANCZOS)
        
        # Combine the images
        # The third parameter acts as a mask
        background.paste(foreground, (0, 0), foreground)

        # Save the result
        # Convert to RGB if saving as JPEG, otherwise keep RGBA for PNG
        if output_path.lower().endswith(('.jpg', '.jpeg')):
            background.convert("RGB").save(output_path, "JPEG")
        else:
            background.save(output_path, "PNG")
            
        print(f"Successfully created overlay image at: {output_path}")

    except Exception as e:
        print(f"Error occurred: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Overlay a transparent image onto a background.")
    parser.add_argument("background", help="Path to the background image")
    parser.add_argument("foreground", help="Path to the foreground image (transparent PNG)")
    parser.add_argument("-o", "--output", default="output_overlay.png", help="Path for the output image (default: output_overlay.png)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.background):
        print(f"Background image not found: {args.background}")
    elif not os.path.exists(args.foreground):
        print(f"Foreground image not found: {args.foreground}")
    else:
        overlay_images(args.background, args.foreground, args.output)