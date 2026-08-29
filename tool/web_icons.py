#!/usr/bin/env python3
"""Иконки веб-версии из assets/icon/app_icon_source.png.

Портрет занимает весь кадр: любые поля вокруг него превращаются в белые
полосы, которые видно на плитке PWA (особенно на iOS, где маска только
скругляет углы). Масштаб чуть больше кадра, чтобы круглая маска Android
резала фон, а не лицо.
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/icon/app_icon_source.png"
BACKGROUND = (255, 255, 255, 255)
ZOOM = 1.15

# Размер -> путь. 180 - apple-touch-icon, 32 - фавиконка.
TARGETS = {
    512: ROOT / "web/icons/Icon-512.png",
    192: ROOT / "web/icons/Icon-192.png",
    180: ROOT / "web/icons/Icon-apple-180.png",
    32: ROOT / "web/favicon.png",
}


def frame() -> Image.Image:
    source = Image.open(SOURCE).convert("RGBA")
    side = round(source.width * ZOOM)
    canvas = Image.new("RGBA", source.size, BACKGROUND)
    offset = (source.width - side) // 2
    canvas.alpha_composite(source.resize((side, side), Image.LANCZOS), (offset, offset))
    return canvas


def main() -> None:
    full = frame()
    for size, path in TARGETS.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        icon = full.resize((size, size), Image.LANCZOS)
        # iOS не показывает прозрачность в apple-touch-icon.
        icon.convert("RGB" if size == 180 else "RGBA").save(path)
        print(f"{path.relative_to(ROOT)} {size}x{size}")


if __name__ == "__main__":
    main()
