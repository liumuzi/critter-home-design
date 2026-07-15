Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ConfirmPreference = "None"

$toolsDir = Join-Path -Path $PSScriptRoot -ChildPath "tools"
$zipPath = Join-Path -Path $toolsDir -ChildPath "ffmpeg-release-essentials.zip"
$tmpDir = Join-Path -Path $toolsDir -ChildPath "ffmpeg_tmp"
$finalDir = Join-Path -Path $toolsDir -ChildPath "ffmpeg"

New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

Invoke-WebRequest -UseBasicParsing -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile $zipPath

if (Test-Path -LiteralPath $finalDir) {
    Remove-Item -LiteralPath $finalDir -Recurse -Force
}

if (Test-Path -LiteralPath $tmpDir) {
    Remove-Item -LiteralPath $tmpDir -Recurse -Force
}

Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force

$root = Get-ChildItem -LiteralPath $tmpDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if (-not $root) {
    throw "Failed to locate extracted ffmpeg folder."
}

New-Item -ItemType Directory -Force -Path $finalDir | Out-Null
Get-ChildItem -LiteralPath $root.FullName | ForEach-Object {
    Move-Item -LiteralPath $_.FullName -Destination $finalDir -Force
}

Remove-Item -LiteralPath $tmpDir -Recurse -Force
Remove-Item -LiteralPath $zipPath -Force

Write-Output "LOCAL_FFMPEG_READY"