#!/usr/bin/env bash
# Create a local venv in python/.venv. Add packages to requirements.txt if needed.
cd "$(dirname "$0")/.." && python3 -m venv .venv && echo "now: source python/.venv/bin/activate"
