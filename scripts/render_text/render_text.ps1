&lt;#
.SYNOPSIS
    文字转 PNG 图片 —— 交互式脚本，再也不用记命令行参数。

.DESCRIPTION
    运行后会逐步提示你输入文字、选择字体、字号、是否加粗、颜色，
    然后自动调用 text_to_png.py 生成透明底 PNG。

    两个本地字体:
      1) 汉仪神奇图鉴 (标题/装饰用)
      2) All Seto (正文/CJK 通用)

.EXAMPLE
    .\render_text.ps1
    直接运行，按提示操作即可。
#&gt;

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjRoot  = Resolve-Path "$ScriptDir\.."
$FontDir   = "$ProjRoot\assets\fonts"
$Python    = "$ProjRoot\.venv\Scripts\python.exe"
$Tool      = "$ScriptDir\text_to_png.py"

# ── 字体预设 ──────────────────────────────────────────
$Fonts = @(
    @{ Name = "汉仪神奇图鉴 (标题/装饰)"; Path = "$FontDir\HanYiShenQiTuJian.ttf" },
    @{ Name = "All Seto (正文/CJK)";       Path = "$FontDir\cjkFonts_allseto_v1.11.ttf" }
)

# ── 颜色预设 ──────────────────────────────────────────
$Colors = @(
    @{ Name = "白色 (默认)";   Code = "#FFFFFF" },
    @{ Name = "黑色";          Code = "#000000" },
    @{ Name = "金色";          Code = "#FFD700" },
    @{ Name = "自定义...";     Code = $null }
)

Write-Host "`n══════════════════════════════════" -ForegroundColor Cyan
Write-Host "  文字 → 透明 PNG 生成器" -ForegroundColor Cyan
Write-Host "══════════════════════════════════`n" -ForegroundColor Cyan

# ── 1. 输入文字 ──────────────────────────────────────
$Text = Read-Host "请输入文字内容"
if ([string]::IsNullOrWhiteSpace($Text)) {
    Write-Host "文字不能为空，已取消。" -ForegroundColor Red
    exit 1
}

# ── 2. 选择字体 ──────────────────────────────────────
Write-Host "`n可用字体:" -ForegroundColor Yellow
for ($i = 0; $i -lt $Fonts.Count; $i++) {
    Write-Host "  [$($i + 1)] $($Fonts[$i].Name)"
}
$FontChoice = Read-Host "选择字体 (1-$($Fonts.Count)，默认 1)"
if ([string]::IsNullOrWhiteSpace($FontChoice)) { $FontChoice = 1 }
$FontIdx = [int]$FontChoice - 1
if ($FontIdx -lt 0 -or $FontIdx -ge $Fonts.Count) {
    Write-Host "无效选择，已取消。" -ForegroundColor Red
    exit 1
}
$FontPath = $Fonts[$FontIdx].Path

# ── 3. 字号 ──────────────────────────────────────────
$Size = Read-Host "`n字号 (px, 默认 96)"
if ([string]::IsNullOrWhiteSpace($Size)) { $Size = 96 }

# ── 4. 加粗 ──────────────────────────────────────────
$BoldInput = Read-Host "`n加粗? (y/n, 默认 n)"
$Bold = ($BoldInput -eq "y" -or $BoldInput -eq "Y")

# ── 5. 颜色 ──────────────────────────────────────────
Write-Host "`n颜色:" -ForegroundColor Yellow
for ($i = 0; $i -lt $Colors.Count; $i++) {
    Write-Host "  [$($i + 1)] $($Colors[$i].Name)"
}
$ColorChoice = Read-Host "选择颜色 (1-$($Colors.Count)，默认 1)"
if ([string]::IsNullOrWhiteSpace($ColorChoice)) { $ColorChoice = 1 }
$ColorIdx = [int]$ColorChoice - 1
if ($ColorIdx -lt 0 -or $ColorIdx -ge $Colors.Count) {
    Write-Host "无效选择，已取消。" -ForegroundColor Red
    exit 1
}
$ColorCode = $Colors[$ColorIdx].Code
if ($null -eq $ColorCode) {
    $ColorCode = Read-Host "请输入 hex 颜色代码 (如 #FF5733)"
}

# ── 6. 构建命令并执行 ────────────────────────────────
$BoldFlag = if ($Bold) { "--bold" } else { "" }
$ArgsList = @(
    "`"$Tool`"",
    "`"$Text`"",
    "--font", "`"$FontPath`"",
    "--size", "$Size",
    "--color", "$ColorCode"
)
if ($Bold) { $ArgsList += "--bold" }

$Cmd = "& `"$Python`" $($ArgsList -join ' ')"
Write-Host "`n执行: $Cmd`n" -ForegroundColor DarkGray

Invoke-Expression $Cmd

Write-Host "`n完成! 图片保存在 output/ 目录下。`n" -ForegroundColor Green
