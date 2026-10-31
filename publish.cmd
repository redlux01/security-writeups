@echo off
chcp 65001 >nul
setlocal

if "%~1"=="" (
  echo Usage: .\publish.cmd "thm: room name"
  echo Example: .\publish.cmd "thm: offensive security intro"
  exit /b 1
)

cd /d "%~dp0"

echo.
echo [1/4] Updating stats...
python scripts\update_stats.py
if errorlevel 1 echo    ! stats script failed, continuing anyway

echo [2/4] Staging changes...
git add -A

git diff --cached --quiet
if not errorlevel 1 (
  echo.
  echo Nothing to commit - no changes since last publish.
  exit /b 0
)

echo [3/4] Committing...
git commit -m "%~1"
if errorlevel 1 exit /b 1

echo [4/4] Pushing...
git push
if errorlevel 1 (
  echo.
  echo Push failed. Check your connection or run: git push
  exit /b 1
)

echo.
echo Done: https://github.com/redlux01/security-writeups
