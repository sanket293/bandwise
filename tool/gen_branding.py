#!/usr/bin/env python3
"""Generates BandWise brand assets (app icon + splash sources) with Pillow.

Mark concept: a clean, confident "B" monogram in white with a single small
accent dot — the "strong band" green from the app's semantic band scale — set on
the app's own calm teal (seed #2C7A7B) as a subtle vertical gradient. No glow,
no vignette: the identity matches the calm Material-3 teal app it launches into.

Outputs to assets/branding/:
  icon.png              1024  full-bleed (iOS / legacy Android launcher)
  icon_foreground.png   1024  transparent, safe-zone padded (Android adaptive fg)
  icon_background.png   1024  gradient only (Android adaptive bg)
  splash_logo.png       1024  white mark + accent dot on transparent (native splash)
  splash_logo_dark.png  1024  same (native splash, dark)
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
os.makedirs(OUT, exist_ok=True)

SS = 4  # supersample factor for crisp edges

# App identity (matches lib/core/theme/app_theme.dart).
TEAL_HI = (58, 156, 156)   # lighter teal (gradient top)
TEAL_LO = (28, 84, 86)     # deeper teal (gradient bottom)
GREEN = (102, 164, 69)     # "strong band" accent (#66A445)
WHITE = (255, 255, 255)


def vgradient(size, top, bot):
    """Subtle top→bottom vertical gradient as RGBA."""
    ramp = np.linspace(0, 1, size, dtype=np.float32)[:, None, None]
    rgb = np.array(top, np.float32) + (np.array(bot, np.float32) - np.array(top, np.float32)) * ramp
    tile = np.repeat(rgb, size, axis=1).astype(np.uint8)
    a = np.full((size, size, 1), 255, np.uint8)
    return Image.fromarray(np.concatenate([tile, a], axis=2))


def _font(px):
    for p in ("/System/Library/Fonts/Supplemental/Arial Bold.ttf",
              "/System/Library/Fonts/Helvetica.ttc",
              "/Library/Fonts/Arial.ttf"):
        try:
            return ImageFont.truetype(p, px)
        except OSError:
            continue
    return ImageFont.load_default()


def draw_mark(img, *, glyph_frac, dot=True, glyph_col=WHITE, dot_col=GREEN):
    """Draw the centred 'B' monogram (+ optional accent dot) on `img`.

    glyph_frac: cap height of the B as a fraction of the canvas."""
    s = img.size[0]
    d = ImageDraw.Draw(img)
    f = _font(int(s * glyph_frac / 0.72))  # font px ≈ cap-height / 0.72
    bb = d.textbbox((0, 0), "B", font=f)
    gw, gh = bb[2] - bb[0], bb[3] - bb[1]
    x = (s - gw) / 2 - bb[0]
    y = (s - gh) / 2 - bb[1]
    d.text((x, y), "B", font=f, fill=(*glyph_col[:3], 255))
    if dot:
        # small dot tucked at the B's upper-right shoulder
        dr = s * glyph_frac * 0.16
        dcx = x + bb[0] + gw + dr * 0.1
        dcy = y + bb[1] + gh * 0.18
        d.ellipse([dcx - dr, dcy - dr, dcx + dr, dcy + dr], fill=(*dot_col[:3], 255))


def make_background(size):
    return vgradient(size, TEAL_HI, TEAL_LO)


def save(img, name):
    img.resize((1024, 1024), Image.LANCZOS).save(os.path.join(OUT, name))
    print("wrote", name)


def make_icon():
    s = 1024 * SS
    img = make_background(s)
    draw_mark(img, glyph_frac=0.50)
    save(img, "icon.png")


def make_adaptive():
    s = 1024 * SS
    save(make_background(s), "icon_background.png")
    fg = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    # Keep within the adaptive safe zone (~66% centre).
    draw_mark(fg, glyph_frac=0.34)
    save(fg, "icon_foreground.png")


def make_splash():
    s = 1024 * SS
    logo = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_mark(logo, glyph_frac=0.46)
    save(logo, "splash_logo.png")
    save(logo, "splash_logo_dark.png")


if __name__ == "__main__":
    make_icon()
    make_adaptive()
    make_splash()
    print("done")
