# voice-notes installer (Windows / PowerShell)
# Run from inside the cloned repo:  powershell -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = "Stop"

$root  = Split-Path -Parent $MyInvocation.MyCommand.Path
$skill = Join-Path $root  "skill\voice-notes"
$venv  = Join-Path $skill ".venv"
$req   = Join-Path $skill "requirements.txt"

Write-Host "[voice-notes] repo root : $root"
Write-Host "[voice-notes] skill dir : $skill"

# 1. check python
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
    Write-Host "[ERROR] Python not found."
    Write-Host "        Install it, e.g.:  winget install -e --id Python.Python.3.12"
    Write-Host "        Then reopen the terminal and run this script again."
    exit 1
}
Write-Host "[voice-notes] python    : $($py.Source)"

# 2. create venv
$venvPy = Join-Path $venv "Scripts\python.exe"
if (-not (Test-Path $venvPy)) {
    Write-Host "[voice-notes] creating venv ..."
    python -m venv $venv
}

# 3. install deps (local, offline engine)
Write-Host "[voice-notes] installing dependencies (faster-whisper, av) ... this may take a few minutes"
& $venvPy -m pip install --disable-pip-version-check --quiet --upgrade pip
& $venvPy -m pip install -r $req
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] pip install failed."; exit 1 }

# 4. link skill into ~/.claude/skills (junction so 'git pull' updates it live)
$skillsDir = Join-Path $HOME ".claude\skills"
if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir | Out-Null }
$link = Join-Path $skillsDir "voice-notes"
if (Test-Path $link) {
    $item = Get-Item $link -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        cmd /c rmdir "$link" | Out-Null        # removes the junction only, never the target
    } else {
        Write-Host "[ERROR] '$link' already exists and is NOT a junction."
        Write-Host "        Move/remove it yourself, then re-run."
        exit 1
    }
}
New-Item -ItemType Junction -Path $link -Target $skill | Out-Null
Write-Host "[voice-notes] linked    : $link  ->  $skill"

Write-Host ""
Write-Host "[voice-notes] DONE. Next:"
Write-Host "  1) Restart your Claude Code session (so it picks up the new skill)."
Write-Host "  2) Drop a recording file and say: transcribe this recording and make meeting minutes."
Write-Host "  (First run downloads the Whisper model, ~3GB, one time.)"
