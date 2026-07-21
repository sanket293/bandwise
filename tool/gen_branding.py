#!/usr/bin/env python3
"""Generates BandWise brand assets (app icon + splash sources) with Pillow.

Mark concept: four ascending rounded bars (rising band scores) with a single
highlighted marker dot on the tallest bar — echoing the app's "your score on the
conversion chart" idea. Teal -> indigo brand gradient.

Outputs to assets/branding/:
  icon.png              1024  full-bleed (iOS / legacy Android launcher)
  icon_foreground.png   1024  transparent, safe-zone padded (Android adaptive fg)
  icon_background.png   1024  gradient only (Android adaptive bg)
  splash_logo.png       1024  white mark on transparent (native splash, light)
  splash_logo_dark.png  1024  white mark on transparent (native splash, dark)
"""
import os
import numpy as np
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
os.makedirs(OUT, exist_ok=True)

SS = 4  # supersample factor for crisp edges

TEAL = (30, 150, 150)
INDIGO = (60, 58, 160)
AMBER = (246, 196, 83)
WHITE = (255, 255, 255)


def gradient(size, c1, c2):
    """Diagonal (top-left -> bottom-right) linear gradient RGBA image."""
    n = size
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    t = (x + y) / (2 * (n - 1))  # 0..1 along the diagonal
    t = t[..., None]
    c1 = np.array(c1, np.float32)
    c2 = np.array(c2, np.float32)
    rgb = (c1 * (1 - t) + c2 * t).astype(np.uint8)
    a = np.full((n, n, 1), 255, np.uint8)
    return Image.fromarray(np.concatenate([rgb, a], axis=2), "RGBA")


def rounded_rect(draw, box, r, fill):
    draw.rounded_rectangle(box, radius=r, fill=fill)


def draw_mark(img, cx, cy, mark_w, mark_h, bar_fill, marker=True, marker_fill=AMBER,
              marker_ring=None):
    """Draw the ascending-bars mark centred at (cx, cy)."""
    d = ImageDraw.Draw(img)
    n = 4
    gap = mark_w * 0.075
    bw = (mark_w - gap * (n - 1)) / n
    heights = [0.42, 0.60, 0.78, 1.0]
    left0 = cx - mark_w / 2
    bottom = cy + mark_h / 2
    tallest_top = None
    tallest_cx = None
    for i, hf in enumerate(heights):
        bh = mark_h * hf
        left = left0 + i * (bw + gap)
        top = bottom - bh
        # front bar full white, rear bars slightly translucent for depth
        if isinstance(bar_fill, tuple) and len(bar_fill) == 3:
            alpha = 255 if i == n - 1 else 210 - (n - 1 - i) * 22
            fill = bar_fill + (alpha,)
        else:
            fill = bar_fill
        rounded_rect(d, [left, top, left + bw, bottom], r=bw / 2, fill=fill)
        if i == n - 1:
            tallest_top = top
            tallest_cx = left + bw / 2
    if marker and tallest_top is not None:
        rr = bw * 0.72
        mx, my = tallest_cx, tallest_top
        if marker_ring is not None:
            d.ellipse([mx - rr * 1.42, my - rr * 1.42, mx + rr * 1.42, my + rr * 1.42],
                      fill=marker_ring)
        d.ellipse([mx - rr, my - rr, mx + rr, my + rr], fill=marker_fill)


def save(img, name):
    img = img.resize((1024, 1024), Image.LANCZOS)
    img.save(os.path.join(OUT, name))
    print("wrote", name)


def make_icon():
    s = 1024 * SS
    bg = gradient(s, TEAL, INDIGO)
    draw_mark(bg, s / 2, s / 2 + s * 0.02, mark_w=s * 0.52, mark_h=s * 0.46,
              bar_fill=WHITE, marker=True, marker_fill=AMBER,
              marker_ring=(30, 150, 150, 255))
    save(bg, "icon.png")


def make_adaptive():
    s = 1024 * SS
    # Background layer: gradient only.
    save(gradient(s, TEAL, INDIGO), "icon_background.png")
    # Foreground layer: mark within the adaptive safe zone (~66% centre circle).
    fg = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_mark(fg, s / 2, s / 2 + s * 0.01, mark_w=s * 0.40, mark_h=s * 0.36,
              bar_fill=WHITE, marker=True, marker_fill=AMBER,
              marker_ring=(0, 0, 0, 0))
    save(fg, "icon_foreground.png")


def make_splash():
    s = 1024 * SS
    logo = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_mark(logo, s / 2, s / 2 + s * 0.02, mark_w=s * 0.46, mark_h=s * 0.40,
              bar_fill=WHITE, marker=True, marker_fill=AMBER, marker_ring=None)
    save(logo, "splash_logo.png")
    # Dark variant is identical (white mark reads on the dark splash colour).
    save(logo, "splash_logo_dark.png")


if __name__ == "__main__":
    make_icon()
    make_adaptive()
    make_splash()
    print("done")
