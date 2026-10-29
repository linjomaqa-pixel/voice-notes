#!/bin/bash
# voice-notes installer (macOS / Linux)
# Run from inside the cloned repo:  bash ./install.command
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
skill="$root/skill/voice-notes"
venv="$skill/.venv"
req="$skill/requirements.txt"

echo "[voice-notes] repo root : $root"
echo "[voice-notes] skill dir : $skill"

# 1. check python3
if ! command -v python3 >/dev/null 2>&1; then
  echo "[ERROR] python3 not found. Install Python 3.9+ first (e.g. 'brew install python'), then re-run."
  exit 1
fi
echo "[voice-notes] python    : $(command -v python3)"

# 2. create venv
venv_py="$venv/bin/python"
if [ ! -x "$venv_py" ]; then
  echo "[voice-notes] creating venv ..."
  python3 -m venv "$venv"
fi

# 3. install deps (local, offline engine)
echo "[voice-notes] installing dependencies (faster-whisper, av) ... this may take a few minutes"
"$venv_py" -m pip install --disable-pip-version-check --quiet --upgrade pip
"$venv_py" -m pip install -r "$req"

# 4. link skill into ~/.claude/skills (symlink so 'git pull' updates it live)
skills_dir="$HOME/.claude/skills"
mkdir -p "$skills_dir"
link="$skills_dir/voice-notes"
if [ -e "$link" ] || [ -L "$link" ]; then
  if [ -L "$link" ]; then
    rm "$link"                      # remove old symlink only
  else
    echo "[ERROR] '$link' exists and is not a symlink. Move/remove it yourself, then re-run."
    exit 1
  fi
fi
ln -s "$skill" "$link"
echo "[voice-notes] linked    : $link  ->  $skill"

echo ""
echo "[voice-notes] DONE. Next:"
echo "  1) Restart your Claude Code session (so it picks up the new skill)."
echo "  2) Drop a recording file and say: transcribe this recording and make meeting minutes."
echo "  (First run downloads the Whisper model, ~3GB, one time.)"
