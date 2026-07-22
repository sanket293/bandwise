#!/usr/bin/env python3
"""Generates BandWise brand assets (app icon + splash sources) with Pillow.

Mark concept: four ascending rounded bars (rising band scores) with a single
glowing marker dot on the tallest — echoing "your score on the conversion
chart" — on a rich teal→indigo gradient with depth (soft shadow + highlight).

Outputs to assets/branding/:
  icon.png              1024  full-bleed (iOS / legacy Android launcher)
  icon_foreground.png   1024  transparent, safe-zone padded (Android adaptive fg)
  icon_background.png   1024  gradient only (Android adaptive bg)
  splash_logo.png       1024  white mark on transparent (native splash)
  splash_logo_dark.png  1024  white mark on transparent (native splash, dark)
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
os.makedirs(OUT, exist_ok=True)

SS = 4  # supersample factor for crisp edges

# Richer, more vibrant brand gradient.
TEAL = (23, 195, 178)     # bright teal (top-left)
MID = (46, 120, 190)      # transitional blue
INDIGO = (67, 56, 202)    # indigo (bottom-right)
AMBER = (251, 191, 36)
WHITE = (255, 255, 255)


def gradient3(size, c1, c2, c3):
    """Diagonal 3-stop gradient (top-left→center→bottom-right) as RGBA."""
    n = size
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    t = (x + y) / (2 * (n - 1))  # 0..1 along the diagonal
    c1, c2, c3 = (np.array(c, np.float32) for c in (c1, c2, c3))
    lo = c1 + (c2 - c1) * (t[..., None] / 0.5).clip(0, 1)
    hi = c2 + (c3 - c2) * ((t[..., None] - 0.5) / 0.5).clip(0, 1)
    rgb = np.where(t[..., None] < 0.5, lo, hi).astype(np.uint8)
    a = np.full((n, n, 1), 255, np.uint8)
    return Image.fromarray(np.concatenate([rgb, a], axis=2))


def radial_glow(size, center, radius, color, max_alpha):
    """A soft radial highlight, returned as an RGBA layer."""
    n = size
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    cx, cy = center
    d = np.sqrt((x - cx) ** 2 + (y - cy) ** 2) / radius
    a = (1 - d).clip(0, 1) ** 2 * max_alpha
    layer = np.zeros((n, n, 4), np.uint8)
    layer[..., 0] = color[0]
    layer[..., 1] = color[1]
    layer[..., 2] = color[2]
    layer[..., 3] = a.astype(np.uint8)
    return Image.fromarray(layer)


def _bar_boxes(cx, cy, mark_w, mark_h):
    n = 4
    gap = mark_w * 0.075
    bw = (mark_w - gap * (n - 1)) / n
    heights = [0.42, 0.60, 0.78, 1.0]
    left0 = cx - mark_w / 2
    bottom = cy + mark_h / 2
    boxes = []
    for i, hf in enumerate(heights):
        bh = mark_h * hf
        left = left0 + i * (bw + gap)
        boxes.append((left, bottom - bh, left + bw, bottom, bw))
    return boxes, bw


def draw_mark(img, cx, cy, mark_w, mark_h, *, shadow=True, glow=True,
              marker=True, bar_color=WHITE):
    """Draw the ascending-bars mark with optional depth (shadow + glow)."""
    boxes, bw = _bar_boxes(cx, cy, mark_w, mark_h)
    size = img.size[0]

    # Soft drop shadow beneath the bars for depth.
    if shadow:
        sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(sh)
        off = mark_h * 0.03
        for (l, t, r, b, w) in boxes:
            sd.rounded_rectangle([l, t + off, r, b + off], radius=w / 2,
                                 fill=(10, 20, 40, 120))
        sh = sh.filter(ImageFilter.GaussianBlur(mark_w * 0.02))
        img.alpha_composite(sh)

    # Glow behind the marker.
    tallest = boxes[-1]
    mx, my = (tallest[0] + tallest[2]) / 2, tallest[1]
    if glow and marker:
        g = Image.new("RGBA", img.size, (0, 0, 0, 0))
        gd = ImageDraw.Draw(g)
        gr = bw * 1.6
        gd.ellipse([mx - gr, my - gr, mx + gr, my + gr],
                   fill=(*AMBER, 150))
        g = g.filter(ImageFilter.GaussianBlur(mark_w * 0.03))
        img.alpha_composite(g)

    d = ImageDraw.Draw(img)
    # Bars with a subtle top→bottom sheen (lighter at the top).
    for (l, t, r, b, w) in boxes:
        d.rounded_rectangle([l, t, r, b], radius=w / 2, fill=(*bar_color, 255))
        # gentle highlight near the top of each bar
        d.rounded_rectangle([l, t, r, t + (b - t) * 0.28], radius=w / 2,
                            fill=(255, 255, 255, 60))

    # Marker dot: amber with a thin white ring + inner highlight.
    if marker:
        rr = bw * 0.78
        d.ellipse([mx - rr * 1.18, my - rr * 1.18, mx + rr * 1.18, my + rr * 1.18],
                  fill=(*WHITE, 255))
        d.ellipse([mx - rr, my - rr, mx + rr, my + rr], fill=(*AMBER, 255))
        d.ellipse([mx - rr * 0.5, my - rr * 0.55, mx - rr * 0.05, my - rr * 0.1],
                  fill=(255, 255, 255, 140))


def make_background(size):
    bg = gradient3(size, TEAL, MID, INDIGO)
    bg.alpha_composite(radial_glow(size, (size * 0.28, size * 0.22),
                                   size * 0.7, WHITE, 60))
    bg.alpha_composite(radial_glow(size, (size * 0.85, size * 0.9),
                                   size * 0.6, (20, 15, 60), 70))
    return bg


def save(img, name):
    img.resize((1024, 1024), Image.LANCZOS).save(os.path.join(OUT, name))
    print("wrote", name)


def make_icon():
    s = 1024 * SS
    img = make_background(s)
    draw_mark(img, s / 2, s / 2 + s * 0.02, mark_w=s * 0.52, mark_h=s * 0.46)
    save(img, "icon.png")


def make_adaptive():
    s = 1024 * SS
    save(make_background(s), "icon_background.png")
    fg = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    # Keep within the adaptive safe zone (~66% centre).
    draw_mark(fg, s / 2, s / 2 + s * 0.01, mark_w=s * 0.40, mark_h=s * 0.36)
    save(fg, "icon_foreground.png")


def make_splash():
    s = 1024 * SS
    logo = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_mark(logo, s / 2, s / 2 + s * 0.02, mark_w=s * 0.46, mark_h=s * 0.40,
              shadow=False)
    save(logo, "splash_logo.png")
    save(logo, "splash_logo_dark.png")


if __name__ == "__main__":
    make_icon()
    make_adaptive()
    make_splash()
    print("done")
