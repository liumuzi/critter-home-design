param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "Input file not found: $InputPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $inputItem = Get-Item -LiteralPath $InputPath
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputItem.Name)
    $ext = [System.IO.Path]::GetExtension($inputItem.Name)
    $OutputPath = Join-Path -Path $inputItem.DirectoryName -ChildPath ("{0}_1280x720{1}" -f $baseName, $ext)
}

$ffmpegFromPath = Get-Command ffmpeg -ErrorAction SilentlyContinue
$localFfmpeg = Join-Path -Path $PSScriptRoot -ChildPath "tools\ffmpeg\bin\ffmpeg.exe"

if ($ffmpegFromPath) {
    $ffmpegExe = $ffmpegFromPath.Source
} elseif (Test-Path -LiteralPath $localFfmpeg) {
    $ffmpegExe = $localFfmpeg
} else {
    throw "ffmpeg was not found in PATH or at $localFfmpeg"
}

Write-Host "Using ffmpeg: $ffmpegExe"
Write-Host "Input:  $InputPath"
Write-Host "Output: $OutputPath"

& $ffmpegExe -y -i $InputPath -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k $OutputPath

if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg failed with exit code $LASTEXITCODE"
}

Write-Host "Done. Output file created: $OutputPath"