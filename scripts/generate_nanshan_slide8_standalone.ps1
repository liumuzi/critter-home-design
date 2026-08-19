param(
    [string]$OutputPath = ''
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repo '比赛材料\2026南山创业之星\第8页_愿望单与销量口径_单页.pptx'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $repo $OutputPath
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

$textureDir = Join-Path $repo 'assets\ppt\reference_textures'
$blueBrushVertical = Join-Path $textureDir 'blue_brush_vertical.png'
$blueBrushCorner = Join-Path $textureDir 'blue_brush_corner.png'
foreach ($required in @($blueBrushVertical, $blueBrushCorner)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Missing asset: $required" }
}

$W = 960.0
$H = 540.0
# PowerPoint stores RGB values as BGR integers.
$C = @{
    Ink = 0x383226      # #263238
    Deep = 0x403617     # #173640
    Forest = 0x5B4E21  # #214E5B
    Mint = 0xA0A67F    # #7FA6A0
    Paper = 0xEEF4F7   # #F7F4EE
    Coral = 0x3D6AC6   # #C66A3D
    Gold = 0x5AB6E1    # #E1B65A
    Gray = 0x7A7566    # #66757A
    Pale = 0xE9E8DC    # #DCE8E9
    White = 0xFFFFFF
}

function Add-Text(
    $slide, [string]$text, [double]$x, [double]$y, [double]$w, [double]$h,
    [double]$size, [int]$color, [bool]$bold = $false, [int]$align = 1
) {
    $shape = $slide.Shapes.AddTextbox(1, $x, $y, $w, $h)
    $shape.TextFrame.MarginLeft = 0
    $shape.TextFrame.MarginRight = 0
    $shape.TextFrame.MarginTop = 0
    $shape.TextFrame.MarginBottom = 0
    $shape.TextFrame.WordWrap = -1
    $shape.TextFrame.TextRange.Text = $text
    $shape.TextFrame.TextRange.Font.Name = 'Microsoft YaHei'
    $shape.TextFrame.TextRange.Font.NameFarEast = 'Microsoft YaHei'
    $shape.TextFrame.TextRange.Font.Size = $size
    $shape.TextFrame.TextRange.Font.Color.RGB = $color
    $shape.TextFrame.TextRange.Font.Bold = $(if ($bold) { -1 } else { 0 })
    $shape.TextFrame.TextRange.ParagraphFormat.Alignment = $align
    return $shape
}

function Add-Box(
    $slide, [double]$x, [double]$y, [double]$w, [double]$h,
    [int]$fill, [double]$transparency = 0, [int]$line = -1
) {
    $shape = $slide.Shapes.AddShape(1, $x, $y, $w, $h)
    $shape.Fill.ForeColor.RGB = $fill
    $shape.Fill.Transparency = $transparency
    if ($line -lt 0) {
        $shape.Line.Visible = 0
    }
    else {
        $shape.Line.Visible = -1
        $shape.Line.ForeColor.RGB = $line
        $shape.Line.Weight = 1
    }
    return $shape
}

function Add-PictureFit(
    $slide, [string]$path, [double]$x, [double]$y, [double]$w, [double]$h
) {
    $shape = $slide.Shapes.AddPicture($path, 0, -1, 0, 0, -1, -1)
    $shape.LockAspectRatio = -1
    $nativeWidth = $shape.Width
    $nativeHeight = $shape.Height
    $scale = [Math]::Min($w / $nativeWidth, $h / $nativeHeight)
    $shape.Width = $nativeWidth * $scale
    $shape.Left = $x + (($w - $shape.Width) / 2)
    $shape.Top = $y + (($h - $shape.Height) / 2)
    $shape.Line.Visible = 0
    return $shape
}

function Add-Note($slide, [string]$note) {
    try {
        foreach ($shape in $slide.NotesPage.Shapes) {
            if ($shape.PlaceholderFormat.Type -eq 2) {
                $shape.TextFrame.TextRange.Text = $note
                break
            }
        }
    }
    catch { }
}

$ppt = $null
$pres = $null
try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $ppt.Visible = -1
    $pres = $ppt.Presentations.Add()
    $pres.PageSetup.SlideWidth = $W
    $pres.PageSetup.SlideHeight = $H
    while ($pres.Slides.Count -gt 0) {
        $pres.Slides.Item(1).Delete()
    }

    $slide = $pres.Slides.Add(1, 12)
    Add-Box $slide 0 0 $W $H $C.Paper | Out-Null
    $topBrush = Add-PictureFit $slide $blueBrushVertical 815 -67 271 189
    $topBrush.Rotation = -45
    $bottomBrush = Add-PictureFit $slide $blueBrushCorner -47 352 297 208
    $bottomBrush.Rotation = -90

    Add-Text $slide '愿望单不是销量公式' 54 34 760 48 30 $C.Ink $true | Out-Null
    Add-Text $slide '两个数字属于不同阶段，不能直接换算' 57 88 620 26 14 $C.Gray $true | Out-Null

    Add-Box $slide 68 150 310 238 $C.White 0.08 $C.Forest | Out-Null
    Add-Box $slide 68 150 310 34 $C.Forest | Out-Null
    Add-Text $slide '发售前｜观察指标' 84 158 278 20 11 $C.White $true | Out-Null
    Add-Text $slide '5万' 98 214 140 60 40 $C.Forest $true | Out-Null
    Add-Text $slide '愿望单' 220 237 110 28 16 $C.Ink $true | Out-Null
    Add-Text $slide 'Beta结束前的经营观察目标' 98 287 230 24 13 $C.Gray $false | Out-Null
    Add-Box $slide 98 326 250 2 $C.Mint | Out-Null
    Add-Text $slide '用于调整商店素材、Demo、预算与发售时点' 98 343 250 34 10 $C.Ink $true 2 | Out-Null

    Add-Text $slide '≠' 419 225 120 74 47 $C.Coral $true 2 | Out-Null
    Add-Text $slide '没有固定倍数关系' 405 302 148 21 10 $C.Gray $true 2 | Out-Null

    Add-Box $slide 580 150 310 238 $C.White 0.08 $C.Coral | Out-Null
    Add-Box $slide 580 150 310 34 $C.Coral | Out-Null
    Add-Text $slide '发售后｜经营情景' 596 158 278 20 11 $C.White $true | Out-Null
    Add-Text $slide '15万套' 610 214 220 60 40 $C.Coral $true | Out-Null
    Add-Text $slide '首发12个月内部基准情景' 610 287 230 24 13 $C.Gray $false | Out-Null
    Add-Box $slide 610 326 250 2 $C.Gold | Out-Null
    Add-Text $slide '由定价、口碑、发行执行与真实转化共同决定' 610 343 250 34 10 $C.Ink $true 2 | Out-Null

    Add-Box $slide 132 425 696 52 $C.Pale 0.18 | Out-Null
    Add-Text $slide '愿望单只是校准销量情景的多个信号之一，不能用“愿望单 × 固定倍数”推导销量。' 150 439 660 22 11 $C.Ink $true 2 | Out-Null
    Add-Text $slide '完整销量情景与样本依据放在答辩附录' 300 491 360 18 9 $C.Gray $false 2 | Out-Null
    Add-Text $slide '08' 902 500 30 16 8 $C.Gray $true 3 | Out-Null

    Add-Note $slide '这一页只澄清口径。5万愿望单是Beta结束前的经营观察目标，15万套是首发12个月的内部基准情景，两者不是三倍换算关系。愿望单只是校准销量情景的多个信号之一，实际结果还取决于Demo行为、定价、口碑、创作者反馈、发行执行和真实转化。完整情景与样本依据留在答辩附录。'

    $pres.SaveAs($OutputPath, 24)
    Write-Output $OutputPath
}
finally {
    if ($pres) {
        $pres.Close()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($pres) | Out-Null
    }
    if ($ppt) {
        $ppt.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

