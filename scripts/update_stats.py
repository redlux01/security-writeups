#!/usr/bin/env python3
"""Считает райтапы и обновляет блок статистики в README.md.

Запуск:  python scripts/update_stats.py
Блок обновляется между маркерами <!-- STATS:START --> и <!-- STATS:END -->.
"""

from __future__ import annotations

import datetime
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"

# Цели — меняй под себя, прогресс-бары считаются относительно них.
GOALS = {
    "thm": 50,
    "ctf": 30,
    "tools": 10,
}

AREAS = [
    ("thm", "🟥 TryHackMe"),
    ("ctf", "🚩 CTF"),
    ("tools", "🛠 Тулзы"),
]

START = "<!-- STATS:START -->"
END = "<!-- STATS:END -->"
BAR_WIDTH = 10


def count_entries(area: str) -> int:
    folder = ROOT / area
    if not folder.is_dir():
        return 0
    total = 0
    for path in folder.rglob("*.md"):
        name = path.name
        if name.upper() == "README.MD" or name.startswith("_"):
            continue
        total += 1
    return total


def bar(done: int, goal: int) -> str:
    goal = max(goal, 1)
    ratio = min(done / goal, 1.0)
    filled = round(ratio * BAR_WIDTH)
    empty = BAR_WIDTH - filled
    pct = round(ratio * 100)
    return f"`{'█' * filled}{'░' * empty}` {pct}%"


def build_block() -> str:
    rows = []
    total_done = 0
    total_goal = 0

    for key, label in AREAS:
        done = count_entries(key)
        goal = GOALS.get(key, 0)
        total_done += done
        total_goal += goal
        rows.append(f"| {label} | {done} | {goal} | {bar(done, goal)} |")

    rows.append(f"| **Всего** | **{total_done}** | **{total_goal}** | {bar(total_done, total_goal)} |")

    today = datetime.date.today().isoformat()

    return "\n".join(
        [
            START,
            "",
            "| Направление | Сделано | Цель | Прогресс |",
            "|:--|--:|--:|:--|",
            *rows,
            "",
            f"_Обновлено: {today}_",
            "",
            END,
        ]
    )


def main() -> None:
    if not README.is_file():
        raise SystemExit(f"README.md не найден: {README}")

    text = README.read_text(encoding="utf-8")
    if START not in text or END not in text:
        raise SystemExit("В README.md нет маркеров STATS:START / STATS:END")

    block = build_block()
    new_text = re.sub(
        re.escape(START) + r".*?" + re.escape(END),
        lambda _: block,
        text,
        flags=re.DOTALL,
    )

    if new_text == text:
        print("Статистика без изменений.")
        return

    README.write_text(new_text, encoding="utf-8")
    print("README.md обновлён.")


if __name__ == "__main__":
    main()
