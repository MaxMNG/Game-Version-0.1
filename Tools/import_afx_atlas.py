"""Импорт атласа Arcada Effector в игру (прогон Этапа 1.6, F5).

Цикл: Effector (вкладка Atlas -> Export PNG) -> положить PNG рядом с
исходником Game/assets/effects/src/<name>.png -> ::

    python Tools/import_afx_atlas.py wipe_screen
    python Tools/import_afx_atlas.py upgrade_cutscene

Сетка (cols/rows/frames/cell) читается из `exp`-блока исходного JSON
(см. Tools/make_afx_src.py), поэтому рассинхрон сетки исключён.
На выходе:
  Game/assets/effects/<name>.png          — копия атласа
  Game/assets/effects/<name>.frames.tres  — SpriteFrames с нарезкой
  Game/resources/configs/fx/<name>.tres   — frames привязывается к нарезке
Ручной нарезки атласа быть не должно (см. ROADMAP, K7).
"""
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "Game" / "assets" / "effects" / "src"
DST_DIR = ROOT / "Game" / "assets" / "effects"
FX_DIR = ROOT / "Game" / "resources" / "configs" / "fx"


def build_frames_tres(name: str, exp: dict) -> str:
    """Текст SpriteFrames.tres с AtlasTexture-нарезкой по сетке exp."""
    cols = int(exp["cols"])
    rows = int(exp["rows"])
    frames = int(exp["frames"])
    cell_w = int(exp["cellW"])
    cell_h = int(exp["cellH"])
    lines = [
        "[gd_resource type=\"SpriteFrames\" load_steps=%d format=3]" % (frames + 2),
        "",
        "[ext_resource type=\"Texture2D\" "
        f"path=\"res://assets/effects/{name}.png\" id=\"1_atlas\"]",
        "",
    ]
    for i in range(frames):
        cx = (i % cols) * cell_w
        cy = (i // cols) * cell_h
        lines += [
            f"[sub_resource type=\"AtlasTexture\" id=\"frame_{i}\"]",
            "atlas = ExtResource(\"1_atlas\")",
            f"region = Rect2({cx}, 0, {cell_w}, {cell_h})".replace(
                ", 0,", f", {cy},"),
            "",
        ]
    refs = ", ".join(f'SubResource("frame_{i}")' for i in range(frames))
    lines += [
        "[resource]",
        "animations = [{",
        "\"name\": &\"default\",",
        f"\"frames\": [{refs}],",
        "\"loop\": false,",
        "\"speed\": 12.0",
        "}]",
        "",
    ]
    return "\n".join(lines)


def _link_frames(fx_tres: Path, name: str) -> None:
    """Привязать frames конфига к сгенерированной нарезке (идемпотентно)."""
    text = fx_tres.read_text(encoding="utf-8")
    if f"assets/effects/{name}.frames.tres" in text:
        return
    ext_line = (
        "[ext_resource type=\"Resource\" "
        f"path=\"res://assets/effects/{name}.frames.tres\" id=\"1_frames\"]\n"
    )
    if "[ext_resource" in text:
        head, tail = text.split("[ext_resource", 1)
        text = head + ext_line + "[ext_resource" + tail
    else:
        text = text.replace("[resource]", ext_line + "\n[resource]", 1)
    text = text.rstrip("\n") + "\nframes = ExtResource(\"1_frames\")\n"
    fx_tres.write_text(text, encoding="utf-8")


def main(name: str) -> int:
    src_json = SRC_DIR / f"{name}.json"
    src_png = SRC_DIR / f"{name}.png"
    if not src_json.exists():
        print(f"нет исходника: {src_json}")
        return 1
    if not src_png.exists():
        print(f"нет PNG из Effector: {src_png} "
              "(вкладка Atlas -> Export, положить рядом с JSON)")
        return 1
    exp = json.loads(src_json.read_text(encoding="utf-8"))["doc"]["exp"]
    dst_png = DST_DIR / f"{name}.png"
    shutil.copyfile(src_png, dst_png)
    frames_tres = DST_DIR / f"{name}.frames.tres"
    frames_tres.write_text(build_frames_tres(name, exp), encoding="utf-8")
    fx_tres = FX_DIR / f"{name}.tres"
    if fx_tres.exists():
        _link_frames(fx_tres, name)
    print(f"ok: {dst_png.name} + {frames_tres.name} "
          f"(сетка {exp['cols']}x{exp['rows']}, кадров {exp['frames']}, "
          f"ячейка {exp['cellW']}x{exp['cellH']})")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: python Tools/import_afx_atlas.py <name>")
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
