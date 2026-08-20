[CmdletBinding()]
param(
    [switch]$KeepBuildFiles
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$competitionRoot = Split-Path -Parent $scriptRoot
$sourceMarkdown = Join-Path $competitionRoot '虫虫家装_商业计划书_半决赛.md'
$templatePath = Join-Path $scriptRoot 'business-plan-template.tex'
$filterPath = Join-Path $scriptRoot 'print-layout.lua'
$texPath = Join-Path $scriptRoot '虫虫家装_商业计划书_半决赛.tex'
$pdfPath = Join-Path $scriptRoot '虫虫家装_商业计划书_半决赛.pdf'

# IDE terminals and activated virtual environments can retain the PATH value
# from before Pandoc/MiKTeX was installed. Merge the latest registered Windows
# paths without dropping the active virtual-environment entries.
$registeredPaths = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine')
    [Environment]::GetEnvironmentVariable('Path', 'User')
) -join [IO.Path]::PathSeparator
$env:Path = @($env:Path, $registeredPaths) -join [IO.Path]::PathSeparator

foreach ($requiredCommand in @('pandoc', 'latexmk', 'xelatex')) {
    if (-not (Get-Command $requiredCommand -ErrorAction SilentlyContinue)) {
        throw "缺少构建命令：$requiredCommand。请安装 Pandoc，以及包含 XeLaTeX/latexmk 的 MiKTeX 或 TeX Live。"
    }
}

foreach ($requiredFile in @($sourceMarkdown, $templatePath, $filterPath)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "缺少构建文件：$requiredFile"
    }
}

& pandoc $sourceMarkdown `
        --from='gfm' `
        --to='latex' `
        --standalone `
        --template=$templatePath `
        --lua-filter=$filterPath `
        --wrap='none' `
    --output=$texPath

if ($LASTEXITCODE -ne 0) {
    throw "Pandoc 转换失败，退出码：$LASTEXITCODE"
}

Push-Location $scriptRoot
try {
    & latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error (Split-Path -Leaf $texPath)
    if ($LASTEXITCODE -ne 0) {
        throw "XeLaTeX 编译失败，退出码：$LASTEXITCODE"
    }

    if (-not $KeepBuildFiles) {
        & latexmk -c (Split-Path -Leaf $texPath) | Out-Null
    }
}
finally {
    Pop-Location
}
if (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) {
    throw "构建完成但未找到 PDF：$pdfPath"
}

$pdf = Get-Item -LiteralPath $pdfPath
Write-Host "已生成：$($pdf.FullName)"
Write-Host ("文件大小：{0:N1} KB" -f ($pdf.Length / 1KB))
