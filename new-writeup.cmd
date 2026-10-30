@echo off
chcp 65001 >nul
REM Wrapper so you don't have to change the system ExecutionPolicy.
REM Usage:
REM   .\new-writeup.cmd -Area thm\pre-security -Name "Offensive Security Intro"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\new-writeup.ps1" %*
