#!/usr/bin/env python3
"""Génère docs/_sidebar.md depuis docs/agents/"""
import os, re
from pathlib import Path

DOCS = Path(__file__).parent.parent / "docs"
SIDEBAR = DOCS / "_sidebar.md"

lines = ["- [🏠 Dashboard](/)\n", "- [🔴 NUCLEUS](/agents/claude-code/NUCLEUS)\n\n---\n\n"]

ENTITY_ICONS = {
    "claude-code": "🤖",
    "openclaw": "📡",
    "memubot": "🧠",
    "autonomous-runner": "⚙️",
    "supervisor": "👁️",
}

agents_dir = DOCS / "agents"
if agents_dir.exists():
    for agent_dir in sorted(agents_dir.iterdir()):
        if not agent_dir.is_dir():
            continue
        agent = agent_dir.name
        icon = ENTITY_ICONS.get(agent, "🔹")
        lines.append(f"**{icon} {agent}**\n")
        lines.append(f"- [Vue d'ensemble](agents/{agent}/)\n")
        # Les 5 derniers logs par date
        logs = sorted([f for f in agent_dir.glob("*.md") if f.name not in ("README.md", "LATEST.md")], reverse=True)[:5]
        for log in logs:
            date = log.stem
            lines.append(f"- [{date}](agents/{agent}/{date})\n")
        lines.append("\n")

SIDEBAR.write_text("".join(lines))
print(f"Sidebar updated: {SIDEBAR}")
