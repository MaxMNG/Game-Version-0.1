"""Генератор исходников эффектов Arcada Effector (прогон Этапа 1.6, F5).

Пишет Game/assets/effects/src/*.json в разреженном формате Effector
(см. skills/afx-effect-authoring/SKILL.md). Проверяются валидатором:
node tools/validate.mjs <файл>  (в F:/Tools GD/Arcada Effector_1.0)
"""
import json
from pathlib import Path

SRC = Path(__file__).resolve().parent.parent / "Game" / "assets" / "effects" / "src"
SRC.mkdir(parents=True, exist_ok=True)

# Цвета палитры (Docs/Design/Style_guide/01_palette.md), [r, g, b].
WHITE = [255, 255, 255]
DANGER = [232, 58, 92]      # #E83A5C
HIDDEN = [155, 107, 242]    # #9B6BF2
CYAN = [89, 208, 243]        # #59D0F3
SAFE = [143, 211, 244]       # #8FD3F4
DARK_RED = [69, 33, 46]


def flash_layer(lid: str, color: list, peak_scale: float = 1.5) -> dict:
    """Короткая вспышка-подложка (спрайт-слой, явные opacity и scale)."""
    return {
        "id": lid, "type": "sprite", "name": "Flash",
        "on": True, "start": 0, "end": 0.35, "blend": "add",
        "opacity": {"keys": [
            {"t": 0, "v": 1, "i": {"m": "ease"}, "o": {"m": "ease"}},
            {"t": 0.05, "v": 1, "i": {"m": "ease"}, "o": {"m": "ease"}},
            {"t": 0.3, "v": 0, "i": {"m": "ease"}, "o": {"m": "ease"}},
        ]},
        "sp": {
            "sprite": {"kind": "shape", "id": "soft", "p": {}},
            "size": 160, "x": 0, "y": 0,
            "scale": {"keys": [
                {"t": 0, "v": 0.25, "i": {"m": "lin"}, "o": {"m": "ease"}},
                {"t": 0.16, "v": peak_scale, "i": {"m": "ease"}, "o": {"m": "ease"}},
            ]},
            "aspect": 1, "rot": 0, "color": color, "squash": 0,
            "glow": 0.8, "glowSize": 1.6, "glowBlur": 0.15,
        },
        "glowL": 0, "glowLR": 24,
    }


def sparks_layer(lid: str, seed: int, grad: list, grav_y: float,
                 burst_n: int = 60, speed: float = 560) -> dict:
    """Взрывной сноп искр (burst-эмиттер, streak + alignVel)."""
    return {
        "id": lid, "type": "emitter", "name": "Sparks",
        "on": True, "start": 0, "end": 0.8, "blend": "add", "opacity": 1,
        "em": {
            "x": 0, "y": 0, "shape": "point", "sx": 60, "sy": 60,
            "dir": "out", "angle": -90, "spread": 70,
            "speed": speed, "speedRnd": 0.6, "rate": 0,
            "bursts": [{"t": 0, "n": burst_n}], "seed": seed,
        },
        "pt": {
            "life": 0.5, "lifeRnd": 0.5,
            "sprite": {"kind": "shape", "id": "streak", "p": {}},
            "size": 44, "sizeRnd": 0.5,
            "sizeOL": {"pts": [
                {"t": 0, "v": 1}, {"t": 0.32, "v": 0.5}, {"t": 1, "v": 0.1}]},
            "opacityOL": {"pts": [
                {"t": 0, "v": 1}, {"t": 0.55, "v": 0.85}, {"t": 1, "v": 0}]},
            "grad": {"stops": grad},
            "rot": 0, "rotRnd": 1, "spin": 40, "spinRnd": 1,
            "alignVel": True, "stretch": 1.6,
            "gravX": 0, "gravY": grav_y, "drag": 1.5,
            "turbAmp": 0, "turbFreq": 1.5,
            "glow": 0.4, "glowSize": 1.6, "glowBlur": 0.15,
            "render": "sprite", "trailCore": 0, "zigzag": 0,
        },
        "glowL": 0, "glowLR": 24,
    }


def smoke_layer(lid: str, seed: int, grad: list) -> dict:
    """Тёмный дым-вуаль поверх (blend normal, всплывает)."""
    return {
        "id": lid, "type": "emitter", "name": "Smoke",
        "on": True, "start": 0, "end": 0.9, "blend": "normal", "opacity": 1,
        "em": {
            "x": 0, "y": 0, "shape": "point", "sx": 120, "sy": 120,
            "dir": "out", "angle": -90, "spread": 80,
            "speed": 120, "speedRnd": 0.5, "rate": 0,
            "bursts": [{"t": 0, "n": 14}], "seed": seed,
        },
        "pt": {
            "life": 0.8, "lifeRnd": 0.3,
            "sprite": {"kind": "shape", "id": "smoke", "p": {}},
            "size": 120, "sizeRnd": 0.4,
            "sizeOL": {"pts": [{"t": 0, "v": 0.3}, {"t": 1, "v": 1.4}]},
            "opacityOL": {"pts": [
                {"t": 0, "v": 0}, {"t": 0.3, "v": 0.2}, {"t": 1, "v": 0}]},
            "grad": {"stops": grad},
            "rot": 0, "rotRnd": 1, "spin": 30, "spinRnd": 1,
            "alignVel": False, "stretch": 0,
            "gravX": 0, "gravY": -60, "drag": 2.0,
            "turbAmp": 0, "turbFreq": 1.5,
            "glow": 0.0, "glowSize": 1.6, "glowBlur": 0.15,
            "render": "sprite", "trailCore": 0, "zigzag": 0,
        },
        "glowL": 0, "glowLR": 24,
    }


def ring_layer(lid: str, seed: int, color_note: str = "") -> dict:
    """Расширяющееся энерго-кольцо (спрайт ring, scale-раздувание)."""
    del seed, color_note
    return {
        "id": lid, "type": "sprite", "name": "Ring",
        "on": True, "start": 0.05, "end": 0.7, "blend": "add",
        "opacity": {"keys": [
            {"t": 0, "v": 0, "i": {"m": "ease"}, "o": {"m": "ease"}},
            {"t": 0.1, "v": 0.7, "i": {"m": "ease"}, "o": {"m": "ease"}},
            {"t": 0.6, "v": 0, "i": {"m": "ease"}, "o": {"m": "ease"}},
        ]},
        "sp": {
            "sprite": {"kind": "shape", "id": "ring", "p": {"th": 0.12}},
            "size": 200, "x": 0, "y": 0,
            "scale": {"keys": [
                {"t": 0, "v": 0.4, "i": {"m": "lin"}, "o": {"m": "ease"}},
                {"t": 0.6, "v": 2.4, "i": {"m": "ease"}, "o": {"m": "ease"}},
            ]},
            "aspect": 1, "rot": 0, "color": CYAN, "squash": 0,
            "glow": 0.6, "glowSize": 1.6, "glowBlur": 0.15,
        },
        "glowL": 0, "glowLR": 24,
    }


def doc(doc_id: str, name: str, layers: list) -> dict:
    return {
        "app": "arcadia-effects", "v": 1,
        "doc": {
            "v": 1, "id": doc_id, "name": name,
            "comp": {"w": 512, "h": 512, "dur": 0.9, "fps": 60},
            "cam": {"comp": 0},
            "exp": {"cols": 4, "rows": 2, "frames": 8,
                    "cellW": 256, "cellH": 256,
                    "t0": 0, "t1": -1, "mode": "rgba", "thr": 0},
            "textures": [],
            "layers": layers,
        },
        "tex": {},
    }


wipe = doc("fx_wipe_screen", "Wipe Screen", [
    flash_layer("lr_wipe_screen_1", DANGER),
    sparks_layer("lr_wipe_screen_2", 3, [
        {"t": 0, "c": WHITE}, {"t": 0.35, "c": DANGER},
        {"t": 0.7, "c": HIDDEN}, {"t": 1, "c": DARK_RED},
    ], 260.0),
    smoke_layer("lr_wipe_screen_3", 5, [
        {"t": 0, "c": DANGER}, {"t": 1, "c": DARK_RED},
    ]),
])

upgrade = doc("fx_upgrade_cutscene", "Upgrade Cutscene", [
    flash_layer("lr_upgrade_cutscene_1", CYAN),
    ring_layer("lr_upgrade_cutscene_2", 11),
    sparks_layer("lr_upgrade_cutscene_3", 4, [
        {"t": 0, "c": WHITE}, {"t": 0.3, "c": CYAN},
        {"t": 0.7, "c": SAFE}, {"t": 1, "c": CYAN},
    ], -160.0, burst_n=48, speed=480.0),
])

for name, payload in (("wipe_screen", wipe), ("upgrade_cutscene", upgrade)):
    path = SRC / f"{name}.json"
    path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
    print("wrote", path)
