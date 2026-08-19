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
$temporaryMarkdown = Join-Path $scriptRoot '.business-plan-body.md'

foreach ($requiredCommand in @('pandoc', 'latexmk', 'xelatex')) {
    if (-not (Get-Command $requiredCommand -ErrorAction SilentlyContinue)) {
        throw "缺少构建命令：$requiredCommand。请先安装 Pandoc 与包含 XeLaTeX/latexmk 的 TeX Live。"
    }
}

foreach ($requiredFile in @($sourceMarkdown, $templatePath, $filterPath)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "缺少构建文件：$requiredFile"
    }
}

$sourceLines = Get-Content -LiteralPath $sourceMarkdown -Encoding UTF8
$separatorIndex = [Array]::IndexOf($sourceLines, '---')
if ($separatorIndex -lt 0 -or $separatorIndex -ge ($sourceLines.Count - 1)) {
    throw '未找到封面信息后的 Markdown 分隔线，无法可靠提取正文。'
}

$bodyLines = $sourceLines[($separatorIndex + 1)..($sourceLines.Count - 1)]
[System.IO.File]::WriteAllLines($temporaryMarkdown, $bodyLines, [System.Text.UTF8Encoding]::new($false))

try {
    & pandoc $temporaryMarkdown `
        --from='gfm' `
        --to='latex' `
        --standalone `
        --template=$templatePath `
        --lua-filter=$filterPath `
        --shift-heading-level-by=-1 `
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
}
finally {
    Remove-Item -LiteralPath $temporaryMarkdown -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) {
    throw "构建完成但未找到 PDF：$pdfPath"
}

$pdf = Get-Item -LiteralPath $pdfPath
Write-Host "已生成：$($pdf.FullName)"
Write-Host ("文件大小：{0:N1} KB" -f ($pdf.Length / 1KB))
