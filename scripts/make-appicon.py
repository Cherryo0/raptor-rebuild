#!/usr/bin/env python3
"""Generate the Raptor AppIcon set (1024 master + all macOS sizes).

Design: lime "R" on near-black, sitting on a glossy Xbox-green orb
(the Xbox sphere vibe), with a bold white X in the top-right corner
where the claw slashes used to be.

Re-run any time the design changes:
    python3 scripts/make-appicon.py
Then run `bash scripts/check.sh` to verify the catalog.
"""
import os
import struct
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SIZE = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "App", "Assets.xcassets",
                   "AppIcon.appiconset")
ICNS_OUT = os.path.join(os.path.dirname(__file__), "..", "App", "Resources",
                        "Raptor.icns")

BG = (11, 11, 13)          # near-black
LIME = (198, 242, 78)      # #C6F24E — Raptor green
XBOX_TOP = (82, 210, 115)  # bright Xbox green
XBOX_MID = (16, 124, 16)   # Xbox green #107C10
XBOX_BOT = (8, 68, 10)     # deep green
FONT = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"

SIZES = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
]


def vertical_gradient(size, top, mid, bottom):
    """RGB image blending top -> mid -> bottom vertically."""
    img = Image.new("RGB", (1, size))
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        if t < 0.5:
            a, b, u = top, mid, t / 0.5
        else:
            a, b, u = mid, bottom, (t - 0.5) / 0.5
        px[0, y] = tuple(round(a[i] + (b[i] - a[i]) * u) for i in range(3))
    return img.resize((size, size))


def build_icns(master):
    """Pack the icon PNGs into a macOS .icns (PNG elements only).

    iconutil is macOS-only, so this builds the container by hand:
    'icns' magic + total size, then one element per size — 4-char type,
    4-byte big-endian length (header included), raw PNG bytes.
    Types: icp4=16, icp5=32, icp6=64, ic07=128, ic08=256, ic09=512,
    ic10=1024. The installer copies this into the placeholder app
    bundle so /Applications/Raptor.app shows the icon without an
    Xcode build.
    """
    elements = [
        ("icp4", 16), ("icp5", 32), ("icp6", 64), ("ic07", 128),
        ("ic08", 256), ("ic09", 512), ("ic10", 1024),
    ]
    body = b""
    for ostype, px in elements:
        png = master.resize((px, px), Image.LANCZOS)
        buf = __import__("io").BytesIO()
        png.save(buf, format="PNG")
        data = buf.getvalue()
        body += ostype.encode("ascii") + struct.pack(">I", len(data) + 8) + data
    icns = b"icns" + struct.pack(">I", len(body) + 8) + body
    os.makedirs(os.path.dirname(ICNS_OUT), exist_ok=True)
    with open(ICNS_OUT, "wb") as f:
        f.write(icns)
    print(f"wrote {ICNS_OUT} ({len(icns)} bytes)")


def main():
    base = Image.new("RGB", (SIZE, SIZE), BG)

    # --- soft green glow behind the orb ---
    glow = Image.new("L", (SIZE, SIZE), 0)
    gd = ImageDraw.Draw(glow)
    gd.ellipse([112, 160, 912, 960], fill=110)
    glow = glow.filter(ImageFilter.GaussianBlur(70))
    green_glow = Image.new("RGB", (SIZE, SIZE), XBOX_MID)
    base.paste(green_glow, (0, 0), glow)

    # --- Xbox orb: gradient sphere behind the R ---
    orb = vertical_gradient(SIZE, XBOX_TOP, XBOX_MID, XBOX_BOT)
    mask = Image.new("L", (SIZE, SIZE), 0)
    md = ImageDraw.Draw(mask)
    md.ellipse([132, 180, 892, 940], fill=255)
    base.paste(orb, (0, 0), mask)

    # --- glossy highlight, top-left of the orb ---
    hi = Image.new("L", (SIZE, SIZE), 0)
    hd = ImageDraw.Draw(hi)
    hd.ellipse([230, 210, 560, 420], fill=100)
    hi = hi.filter(ImageFilter.GaussianBlur(28))
    white = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
    base.paste(white, (0, 0), hi)

    draw = ImageDraw.Draw(base)

    # --- lime R, centred on the orb ---
    font = ImageFont.truetype(FONT, 640)
    bbox = draw.textbbox((0, 0), "R", font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(((SIZE - w) / 2 - bbox[0], (SIZE - h) / 2 - bbox[1] + 20),
              "R", font=font, fill=LIME)

    # --- bold white X, top-right (Xbox mark) ---
    x_layer = Image.new("RGBA", (260, 260), (0, 0, 0, 0))
    xd = ImageDraw.Draw(x_layer)
    for (x0, y0, x1, y1) in [(40, 40, 220, 220), (220, 40, 40, 220)]:
        xd.line([x0, y0, x1, y1], fill=(255, 255, 255, 255), width=30)
        for cx, cy in [(x0, y0), (x1, y1)]:
            xd.ellipse([cx - 15, cy - 15, cx + 15, cy + 15],
                       fill=(255, 255, 255, 255))
    x_layer = x_layer.rotate(0, resample=Image.BICUBIC)
    base.paste(x_layer, (700, 90), x_layer)

    os.makedirs(OUT, exist_ok=True)
    master = os.path.join(OUT, "icon_1024x1024.png")
    base.save(master)
    for name, px in SIZES:
        base.resize((px, px), Image.LANCZOS).save(os.path.join(OUT, name))
    print(f"wrote master + {len(SIZES)} sizes to {OUT}")
    build_icns(base)


if __name__ == "__main__":
    main()
