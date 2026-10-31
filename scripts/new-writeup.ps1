param(
    [Parameter(Mandatory = $true, HelpMessage = "Папка, например thm\pre-security")]
    [string]$Area,

    [Parameter(Mandatory = $true, HelpMessage = "Название комнаты, например 'Offensive Security Intro'")]
    [string]$Name,

    [switch]$NoOpen
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $root "TEMPLATE.md"

if (-not (Test-Path $templatePath)) {
    Write-Host "Не найден TEMPLATE.md в $root" -ForegroundColor Red
    exit 1
}

$date = Get-Date -Format "yyyy-MM-dd"
$slug = ($Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
if ([string]::IsNullOrWhiteSpace($slug)) { $slug = "room" }

$dir = Join-Path $root $Area
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$file = Join-Path $dir "$date-$slug.md"
if (Test-Path $file) {
    Write-Host "Файл уже существует: $file" -ForegroundColor Yellow
    if (-not $NoOpen) { & code $file }
    exit 0
}

$content = Get-Content $templatePath -Raw
$content = $content -replace '\{\{ROOM_NAME\}\}', $Name
$content = $content -replace '\{\{DATE\}\}', $date
$content = $content -replace '\{\{AREA\}\}', ($Area -replace '\\', '/')

Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline

$rel = Resolve-Path -Relative $file
Write-Host ""
Write-Host "  Создано: $rel" -ForegroundColor Green
Write-Host ""

if (-not $NoOpen) {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        & code $file
    }
    else {
        Start-Process notepad $file
    }
}

Write-Host "  Дальше:" -ForegroundColor Cyan
Write-Host "    1. Заполни файл (раздел «Где я застрял» не пропускай)"
Write-Host "    2. .\publish.cmd `"thm: $slug`""
Write-Host ""
