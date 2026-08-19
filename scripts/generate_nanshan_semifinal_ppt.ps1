param(
    [string]$OutputPath = ""
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repo '比赛材料\2026南山创业之星\甲壳虫工作室+虫虫家装+半决赛路演PPT.pptx'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $repo $OutputPath
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

$cover = Join-Path $repo 'assets\images\cover_art_1x.png'
$logo = Join-Path $repo 'assets\images\TeamLOGO.png'
$screens = Join-Path $repo 'assets\screen_shots'
$video = Join-Path $repo 'assets\video\光子答辩宣传视频.mp4'
$jam = 'E:\Onedrive\Personal\website\muziliu.github.io\public\images\games\not-again-hero.png'
$shotFiles = @(Get-ChildItem -LiteralPath $screens -File | Sort-Object Name | Select-Object -ExpandProperty FullName)

foreach ($required in @($cover, $logo, $video, $jam)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Missing asset: $required" }
}

$W = 960.0; $H = 540.0
$C = @{
    # Office COM expects OLE/BGR integers rather than CSS-style RGB integers.
    Ink = 0x303318; Deep = 0x28270F; Forest = 0x484B17; Mint = 0xB7D677
    Cream = 0xDEF1F7; Paper = 0xF4FDFF; Coral = 0x6878EF; Gold = 0x68CBEF
    White = 0xFFFFFF; Gray = 0x737765; Pale = 0xE4ECDD; Black = 0x111111
}

function Add-Text($slide, [string]$text, [double]$x, [double]$y, [double]$w, [double]$h,
                  [double]$size = 20, [int]$color = 0x183330, [bool]$bold = $false,
                  [string]$font = 'Microsoft YaHei', [int]$align = 1) {
    $s = $slide.Shapes.AddTextbox(1, $x, $y, $w, $h)
    $s.TextFrame.MarginLeft = 0; $s.TextFrame.MarginRight = 0
    $s.TextFrame.MarginTop = 0; $s.TextFrame.MarginBottom = 0
    $s.TextFrame.WordWrap = -1
    $s.TextFrame.TextRange.Text = $text
    $s.TextFrame.TextRange.Font.Name = $font
    $s.TextFrame.TextRange.Font.NameFarEast = $font
    $s.TextFrame.TextRange.Font.Size = $size
    $s.TextFrame.TextRange.Font.Color.RGB = $color
    $s.TextFrame.TextRange.Font.Bold = $(if ($bold) { -1 } else { 0 })
    $s.TextFrame.TextRange.ParagraphFormat.Alignment = $align
    return $s
}

function Add-Box($slide, [double]$x, [double]$y, [double]$w, [double]$h,
                 [int]$fill, [double]$radius = 0, [int]$line = -1, [double]$transparency = 0) {
    $type = $(if ($radius -gt 0) { 5 } else { 1 })
    $s = $slide.Shapes.AddShape($type, $x, $y, $w, $h)
    $s.Fill.ForeColor.RGB = $fill; $s.Fill.Transparency = $transparency
    if ($line -lt 0) { $s.Line.Visible = 0 } else { $s.Line.ForeColor.RGB = $line; $s.Line.Weight = 1 }
    return $s
}

function Add-PictureFill($slide, [string]$path, [double]$x, [double]$y, [double]$w, [double]$h, [double]$dark = 0) {
    $pic = $slide.Shapes.AddPicture($path, 0, -1, $x, $y, $w, $h)
    if ($dark -gt 0) { Add-Box $slide $x $y $w $h $C.Deep 0 -1 $dark | Out-Null }
    return $pic
}

function Add-Header($slide, [int]$num, [string]$kicker, [string]$title, [string]$subtitle = '') {
    Add-Text $slide ("{0:D2}" -f $num) 40 27 42 22 10 $C.Coral $true | Out-Null
    Add-Text $slide $kicker.ToUpper() 84 27 250 22 10 $C.Gray $true | Out-Null
    Add-Text $slide $title 40 56 850 48 28 $C.Ink $true | Out-Null
    if ($subtitle) { Add-Text $slide $subtitle 42 105 830 30 12 $C.Gray $false | Out-Null }
    Add-Box $slide 40 126 880 2 $C.Mint | Out-Null
}

function Add-AppendixHeader($slide, [string]$num, [string]$title, [string]$subtitle = '') {
    Add-Text $slide $num 40 27 42 22 10 $C.Coral $true | Out-Null
    Add-Text $slide 'Q&A APPENDIX' 84 27 250 22 10 $C.Gray $true | Out-Null
    Add-Text $slide $title 40 56 850 48 28 $C.Ink $true | Out-Null
    if ($subtitle) { Add-Text $slide $subtitle 42 105 830 30 12 $C.Gray $false | Out-Null }
    Add-Box $slide 40 126 880 2 $C.Mint | Out-Null
}

function Add-Footer($slide, [string]$source = '') {
    if ($source) { Add-Text $slide $source 40 514 740 14 7 $C.Gray $false | Out-Null }
    Add-Text $slide '甲壳虫工作室｜《虫虫家装》' 780 514 140 14 7 $C.Gray $false 'Microsoft YaHei' 3 | Out-Null
}

function Add-Note($slide, [string]$note) {
    try {
        foreach ($shape in $slide.NotesPage.Shapes) {
            if ($shape.PlaceholderFormat.Type -eq 2) {
                $shape.TextFrame.TextRange.Text = $note
                break
            }
        }
    } catch { }
}

function Add-Stat($slide, [string]$big, [string]$label, [double]$x, [double]$y, [double]$w, [int]$accent) {
    Add-Box $slide $x $y $w 112 $C.Paper 12 $accent | Out-Null
    Add-Text $slide $big ($x+14) ($y+13) ($w-28) 48 28 $accent $true | Out-Null
    Add-Text $slide $label ($x+14) ($y+65) ($w-28) 34 10 $C.Gray $false | Out-Null
}

$ppt = $null; $pres = $null
try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $ppt.Visible = -1
    $pres = $ppt.Presentations.Add()
    $pres.PageSetup.SlideWidth = $W; $pres.PageSetup.SlideHeight = $H

    # 1 Cover
    $s = $pres.Slides.Add(1, 12)
    Add-PictureFill $s $cover 0 0 $W $H 0 | Out-Null
    Add-Box $s 0 0 500 $H $C.Deep 0 -1 0.12 | Out-Null
    Add-Text $s '2026 南山“创业之星”游戏产业专项赛｜团队组半决赛' 48 45 500 25 10 $C.Mint $true | Out-Null
    Add-Text $s '虫虫家装' 48 118 420 86 48 $C.White $true | Out-Null
    Add-Text $s '轻量搜打撤 × 治愈家园装修' 50 212 400 34 20 $C.Gold $true | Out-Null
    Add-Text $s "去危险的废墟搜集，`n把破木屋装成末世最幸福的家。" 50 267 410 70 18 $C.White $false | Out-Null
    Add-Box $s 48 388 232 42 $C.Coral 10 | Out-Null
    Add-Text $s '甲壳虫工作室｜木子' 66 399 200 22 12 $C.White $true | Out-Null
    Add-Text $s '8 MIN PITCH · 2026.08.20' 50 456 300 22 9 $C.Pale $false | Out-Null
    Add-Note $s '15秒。大家好，我们是甲壳虫工作室。《虫虫家装》是一款面向全球Steam玩家、把轻量搜打撤与治愈装修结合的PC独立游戏：去危险的废墟搜集，把破木屋装成末世最幸福的家。'

    # 2 Demo video
    $s = $pres.Slides.Add(2, 12); Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-Text $s '先看 35 秒：一次完整的“出门—取舍—回家”' 40 28 850 40 25 $C.White $true | Out-Null
    try {
        $media = $s.Shapes.AddMediaObject2($video, 0, -1, 75, 88, 810, 405)
        $media.AnimationSettings.PlaySettings.PlayOnEntry = -1
    } catch {
        Add-PictureFill $s $cover 75 88 810 405 0.25 | Out-Null
        Add-Text $s '▶ 现场播放：光子答辩宣传视频.mp4' 235 270 490 35 20 $C.White $true 'Microsoft YaHei' 2 | Out-Null
    }
    Add-Text $s '野外探索 → 风险取舍 → 成功撤离 → 制造与摆放 → 小动物回应' 105 497 750 24 11 $C.Mint $true 'Microsoft YaHei' 2 | Out-Null
    Add-Note $s '45秒。先不解释概念，请大家看一次完整循环。视频建议剪成30到35秒，播放后只补一句：野外给玩家目标和故事，家园把资源变成情感回报。'

    # 3 User gap
    $s = $pres.Slides.Add(3, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 3 'USER GAP' '休闲经营太平，硬核撤离太累' '目标玩家需要的不是更多数值，而是一种有松有紧、最后能够回家的节奏。'
    Add-Box $s 55 170 385 245 $C.Paper 16 $C.Pale | Out-Null
    Add-Text $s '纯休闲经营' 82 197 250 32 20 $C.Forest $true | Out-Null
    Add-Text $s "✓ 治愈、自由、低压力`n× 中后期目标感容易变弱`n× 资源获得缺少故事性" 82 250 310 110 15 $C.Ink $false | Out-Null
    Add-Box $s 520 170 385 245 $C.Paper 16 $C.Pale | Out-Null
    Add-Text $s '硬核搜打撤' 547 197 250 32 20 $C.Coral $true | Out-Null
    Add-Text $s "✓ 风险选择、紧张与成就`n× 学习成本与失败压力高`n× 不适合休闲玩家长期停留" 547 250 310 110 15 $C.Ink $false | Out-Null
    Add-Box $s 335 390 290 62 $C.Gold 12 | Out-Null
    Add-Text $s '我们的机会：轻冒险 × 深情感回报' 360 408 240 24 14 $C.Deep $true 'Microsoft YaHei' 2 | Out-Null
    Add-Footer $s
    Add-Note $s '35秒。我们观察到一个体验缺口：纯经营很治愈，但中后期容易缺少目标；硬核撤离有取舍和成就，却让休闲用户疲惫。我们不是把两个标签拼起来，而是把撤离的风险选择做轻，把回家的情感回报做深。'

    # 4 Product loop
    $s = $pres.Slides.Add(4, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 4 'PRODUCT LOOP' '一松一紧的双循环，彼此提供动力'
    $items = @(
        @('01','探索','找材料 · 看地图 · 管能量',$C.Forest),
        @('02','取舍','负重越高，撤离越危险',$C.Coral),
        @('03','回家','制造家具 · 自由摆放',$C.Gold),
        @('04','回应','小动物记住并回应改变',$C.Mint)
    )
    for($i=0;$i -lt 4;$i++){
        $x=42+$i*225; $it=$items[$i]
        Add-Box $s $x 176 198 215 $C.Paper 16 $it[3] | Out-Null
        Add-Text $s $it[0] ($x+18) 192 45 24 11 $it[3] $true | Out-Null
        Add-Text $s $it[1] ($x+18) 231 160 36 23 $C.Ink $true | Out-Null
        Add-Text $s $it[2] ($x+18) 288 160 62 13 $C.Gray $false | Out-Null
        if($i -lt 3){ Add-Text $s '→' ($x+196) 265 28 30 19 $C.Gray $true 'Microsoft YaHei' 2 | Out-Null }
    }
    Add-Text $s '野外提供目标与故事，家园把资源变成情感价值；角色反馈再推动下一次出门。' 135 431 690 32 16 $C.Forest $true 'Microsoft YaHei' 2 | Out-Null
    Add-Footer $s
    Add-Note $s '60秒。循环从探索开始：玩家获取原材料，同时管理能量、路线和负重；越贪越危险，带回家才算真正获得。材料被制造成家具，家具改变空间，小动物对变化产生反馈，再给玩家新的目标。这使两个循环不是并排存在，而是互相驱动。'

    # 5 Completion
    $s = $pres.Slides.Add(5, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 5 'BUILD STATUS' '它已经能玩：核心循环跑通，下一步是产品化'
    Add-PictureFill $s $shotFiles[2] 42 158 430 270 0 | Out-Null
    Add-Box $s 500 158 410 270 $C.Paper 16 $C.Pale | Out-Null
    Add-Text $s '已完成' 525 180 110 28 16 $C.Forest $true | Out-Null
    Add-Text $s "• 野外探索、采集与撤离`n• 负重/能量与追逃取舍`n• 家具制造、仓库与自由装修`n• 小动物事件反馈原型" 525 222 340 128 15 $C.Ink $false | Out-Null
    Add-Text $s '下一验证节点' 525 365 130 25 13 $C.Coral $true | Out-Null
    Add-Text $s '更大样本试玩 · Steam商店页 · Demo转化' 525 397 340 24 11 $C.Gray $false | Out-Null
    Add-Box $s 42 449 868 35 $C.Forest 8 | Out-Null
    Add-Text $s '可玩Demo + 2026光子游戏大赛概念赛道银奖' 68 458 810 19 11 $C.White $true 'Microsoft YaHei' 2 | Out-Null
    Add-Footer $s
    Add-Note $s '50秒。现在的Demo已经跑通野外探索、负重与撤离、家具制造和自由装修，小动物反馈也有可运行原型，并获得2026光子游戏大赛概念赛道银奖。下一阶段要验证更大样本试玩、Steam愿望单和Demo转化，并将已有系统推进为可发行内容。'

    # 6 Survey
    $s = $pres.Slides.Add(6, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 6 'EARLY SIGNAL' '19份试玩反馈：方向值得继续验证' '小样本、偏年轻女性与PC玩家；这是早期方向信号，不是市场结论。'
    Add-Stat $s '19/19' '期待后续内容' 42 172 200 $C.Forest
    Add-Stat $s '18/19' '想继续装修' 262 172 200 $C.Mint
    Add-Stat $s '18/19' '家园体验正向' 482 172 200 $C.Gold
    Add-Stat $s '16/19' '同类价格或更高购买开放' 702 172 216 $C.Coral
    Add-Box $s 42 315 876 120 $C.Paper 14 $C.Pale | Out-Null
    Add-Text $s '我们没有隐藏的保留意见' 68 338 260 27 15 $C.Ink $true | Out-Null
    Add-Text $s '野外体验17/19正向；1/19明确表示不考虑购买或游玩。下一轮将扩大样本，并用实际行为与愿望单转化校准。' 68 377 800 45 13 $C.Gray $false | Out-Null
    Add-Footer $s '来源：团队结构化试玩问卷，n=19，截至2026-08-18。'
    Add-Note $s '45秒。19份结构化反馈里，全部期待后续内容，18人想继续装修，18人对家园体验正向，16人对同类价格或更高价格购买持开放态度。我们也保留一条明确不购买反馈。样本偏年轻女性，所以这里只把它当作方向性早期信号，下一步会用更大样本和实际转化校准。'

    # 7 Market
    $s = $pres.Slides.Add(7, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 7 'MARKET RANGE' '相邻品类已被验证，我们用样本约束销量想象'
    Add-Stat $s '9款' 'Steam装修/治愈向参考样本' 42 166 250 $C.Forest
    Add-Stat $s '6.9万套' '样本估算销量中位数' 312 166 250 $C.Gold
    Add-Stat $s '$14.99' '样本价格中位数' 582 166 250 $C.Coral
    Add-Text $s '销量情景（首发12个月）' 42 310 280 28 16 $C.Ink $true | Out-Null
    $bars=@(@('保守',5, $C.Gray),@('基准',15,$C.Forest),@('乐观',30,$C.Coral))
    for($i=0;$i -lt 3;$i++){
        $y=355+$i*42; $b=$bars[$i]
        Add-Text $s $b[0] 42 $y 70 20 11 $C.Gray $true | Out-Null
        Add-Box $s 118 ($y+2) ($b[1]*23) 18 $b[2] 6 | Out-Null
        Add-Text $s ($b[1].ToString()+'万套') (130+$b[1]*23) $y 80 20 10 $C.Ink $true | Out-Null
    }
    Add-Box $s 610 320 280 120 $C.Paper 14 $C.Pale | Out-Null
    Add-Text $s '经营原则' 632 339 100 25 14 $C.Forest $true | Out-Null
    Add-Text $s "15万套是基准目标，`n不是已验证订单；`n将由愿望单与Demo转化逐级校准。" 632 375 230 55 12 $C.Ink $false | Out-Null
    Add-Footer $s '来源：Steam商店标价及第三方市场估算，团队整理，截至2026-08-18；非Steam官方销量。'
    Add-Note $s '40秒。我们整理了9款装修与治愈向Steam样本，第三方估算销量中位数约6.9万套，价格中位数14.99美元。它不能证明我们一定卖多少，但帮助我们约束5万、15万、25万套的情景区间。15万套是经营目标，之后会由愿望单和Demo转化逐级校准。'

    # 8 Business
    $s = $pres.Slides.Add(8, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 8 'GO TO MARKET' 'Steam买断制：先验证愿望单，再放大发售转化'
    $steps=@('商店页','公开Demo','新品节/KOL','2028Q1发售','DLC与平台拓展')
    for($i=0;$i -lt $steps.Count;$i++){
        $x=42+$i*176
        Add-Box $s $x 174 150 72 $(if($i -eq 3){$C.Coral}else{$C.Paper}) 12 $(if($i -eq 3){-1}else{$C.Pale}) | Out-Null
        Add-Text $s ("0{0}" -f ($i+1)) ($x+12) 185 28 16 9 $(if($i -eq 3){$C.White}else{$C.Gray}) $true | Out-Null
        Add-Text $s $steps[$i] ($x+12) 211 126 22 12 $(if($i -eq 3){$C.White}else{$C.Ink}) $true 'Microsoft YaHei' 2 | Out-Null
        if($i -lt 4){ Add-Text $s '→' ($x+150) 198 26 20 14 $C.Gray $true 'Microsoft YaHei' 2 | Out-Null }
    }
    Add-Stat $s '¥80' '平均含税成交额测算' 42 305 250 $C.Forest
    Add-Stat $s '5万' 'Beta结束前基础愿望单目标' 312 305 250 $C.Gold
    Add-Stat $s '15万套' '首发12个月基准目标' 582 305 250 $C.Coral
    Add-Footer $s '统一口径：Steam平台费30%；首发12个月=2028Q1首发后的连续12个月。'
    Add-Note $s '45秒。商业模式是Steam PC买断，后续通过内容DLC和平台拓展延长生命周期。发行不是等做完再宣传，而是商店页、Demo、新品节和创作者逐步积累愿望单。Beta结束前以5万愿望单作为经营观察目标；基准情景按平均成交额80元、首发12个月15万套测算。'

    # 9 AI + content
    $s = $pres.Slides.Add(9, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 9 'PRODUCTION MOAT' 'AI不是聊天噱头，而是可控的角色回应管线'
    $layers=@(@('规则模拟层','事件、关系、偏好与游戏事实',$C.Forest),@('叙事生成层','结构化上下文 + 可替换模型',$C.Gold),@('表现层','短反馈、日记与心愿任务',$C.Coral))
    for($i=0;$i -lt 3;$i++){
        $x=52+$i*300; $l=$layers[$i]
        Add-Box $s $x 176 255 120 $C.Paper 14 $l[2] | Out-Null
        Add-Text $s $l[0] ($x+18) 195 215 28 17 $l[2] $true | Out-Null
        Add-Text $s $l[1] ($x+18) 239 215 38 11 $C.Gray $false | Out-Null
        if($i -lt 2){ Add-Text $s '→' ($x+258) 220 38 28 19 $C.Gray $true 'Microsoft YaHei' 2 | Out-Null }
    }
    Add-Box $s 52 335 855 88 $C.Deep 14 | Out-Null
    Add-Text $s '生成 → 校验 → 重试 → 模板兜底' 78 355 420 26 18 $C.Mint $true | Out-Null
    Add-Text $s '模型不可用时，核心游戏仍可正常运行；标准化家具、地图和角色管线同步提升内容产能。' 78 390 780 22 11 $C.White $false | Out-Null
    Add-Footer $s
    Add-Note $s '40秒。AI的价值不是让玩家无限聊天，而是让角色能记住玩家的装修和互动。架构分规则、生成和表现三层，并有生成、校验、重试和模板兜底。模型可替换，即使服务不可用，核心游戏仍正常运行。'

    # 10 Team
    $s = $pres.Slides.Add(10, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 10 'TEAM' '不是临时组队：我们在搭建一家长期做原创游戏的工作室'
    Add-PictureFill $s $jam 42 158 335 220 0 | Out-Null
    Add-Box $s 55 320 310 46 $C.Black 8 -1 0.08 | Out-Null
    Add-Text $s 'Not Again, Hero｜GMTK 2025' 67 329 286 18 10 $C.White $true 'Microsoft YaHei' 2 | Out-Null
    Add-Text $s '叙事排名 #141 / 9562 · Top 1.5%' 67 347 286 16 9 $C.Gold $true 'Microsoft YaHei' 2 | Out-Null
    Add-Box $s 408 158 510 220 $C.Paper 14 $C.Pale | Out-Null
    Add-Text $s '合作证据链' 432 178 180 27 16 $C.Forest $true | Out-Null
    Add-Text $s "Game Jam限时协作`n↓`n《虫虫家装》可玩Demo`n↓`n19份试玩反馈 + 光子银奖" 432 218 205 132 13 $C.Ink $true 'Microsoft YaHei' 2 | Out-Null
    Add-Text $s '7人能力闭环' 684 178 170 27 16 $C.Coral $true | Out-Null
    Add-Text $s "2人全职 + 5人阶段投入`n制作 / 策划 / 程序 / 美术`n动画 / UI/UX / 音频`n米哈游 / 出海游戏 / 搜狐 / 字节" 684 220 200 116 11 $C.Gray $false | Out-Null
    Add-Box $s 42 405 876 67 $C.Forest 12 | Out-Null
    Add-Text $s '《虫虫家装》是第一款商业产品，不是最后一个项目。' 66 417 590 25 16 $C.White $true | Out-Null
    Add-Text $s '长期学习标杆：Klei Entertainment｜精干团队 · 原创表达 · 多款精品' 66 446 720 18 10 $C.Mint $false | Out-Null
    Add-Footer $s 'Game Jam资料来源：个人作品站与itch.io项目页；排名记录为GMTK 2025官方参赛结果。'
    Add-Note $s '40秒。早期投资也在投资团队。7名核心成员中，木子和粥粥全职，其余5人按阶段交付；团队覆盖制作、策划、程序、美术、动画、UI/UX和音频。我们共同完成Game Jam作品并把《虫虫家装》推进到可玩Demo、19份试玩反馈和光子概念赛道银奖。这是工作室的第一款商业产品。'

    # 11 Milestone finance
    $s = $pres.Slides.Add(11, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-Header $s 11 'MILESTONE & FUNDING' '融资300万元：分三期推进到2028 Q1发售'
    $ms=@(@('2026 Q4','垂直切片'),@('2027 Q2','Alpha'),@('2027 Q4','Beta'),@('2028 Q1','Steam发售'))
    for($i=0;$i -lt 4;$i++){
        $x=48+$i*218
        Add-Box $s $x 170 175 70 $(if($i -eq 3){$C.Coral}else{$C.Paper}) 12 $(if($i -eq 3){-1}else{$C.Pale}) | Out-Null
        Add-Text $s $ms[$i][0] ($x+12) 184 150 18 9 $(if($i -eq 3){$C.White}else{$C.Gray}) $true 'Microsoft YaHei' 2 | Out-Null
        Add-Text $s $ms[$i][1] ($x+12) 207 150 22 13 $(if($i -eq 3){$C.White}else{$C.Ink}) $true 'Microsoft YaHei' 2 | Out-Null
        if($i -lt 3){ Add-Text $s '→' ($x+177) 193 38 24 17 $C.Gray $true 'Microsoft YaHei' 2 | Out-Null }
    }
    Add-Text $s '融资用途' 48 291 100 25 15 $C.Ink $true | Out-Null
    $uses=@(@('人力与内容','48%',$C.Forest),@('研发工具/AI','8.3%',$C.Gold),@('发行与增长','20%',$C.Coral),@('运营及储备','23.7%',$C.Gray))
    $x=48
    foreach($u in $uses){
        $width=[double]$u[1].TrimEnd('%')*7.9
        Add-Box $s $x 332 $width 34 $u[2] 0 | Out-Null
        if($width -gt 90){ Add-Text $s ($u[0]+' '+$u[1]) ($x+7) 341 ($width-14) 17 9 $C.White $true 'Microsoft YaHei' 2 | Out-Null }
        $x += $width
    }
    Add-Text $s '研发工具 / AI / 云 8.3%' 390 369 145 14 8 $C.Gold $true 'Microsoft YaHei' 2 | Out-Null
    Add-Box $s 48 395 864 72 $C.Paper 12 $C.Pale | Out-Null
    Add-Text $s '21个月新增现金需求' 70 407 205 20 11 $C.Gray $true | Out-Null
    Add-Text $s '2026Q4—2028Q2' 70 433 205 20 13 $C.Forest $true | Out-Null
    Add-Text $s '分期拨付' 305 407 105 20 11 $C.Gray $true | Out-Null
    Add-Text $s '120万 + 100万 + 80万' 305 433 205 20 13 $C.Coral $true | Out-Null
    Add-Text $s '基准：15万套 / 流水1200万 / 税前回款840万 / 累计经营现金净额约400万' 530 419 355 34 11 $C.Ink $true | Out-Null
    Add-Footer $s '天使轮300万元；股权与估值结合Demo、愿望单实测和投资条款协商确定。'
    Add-Note $s '40秒。我们计划天使轮融资300万元，一次签署完整投资承诺，按120万、100万、80万分三期拨付。资金覆盖2026年第四季度到2028年第二季度共21个月，里程碑是今年十二月完成垂直切片、2027年完成Alpha和Beta、2028年一季度Steam首发。基准情景为首发12个月15万套，税前回款840万元，累计经营现金净额约400万元。'

    # 12 Ask
    $s = $pres.Slides.Add(12, 12); Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-Text $s '下一阶段：从可玩Demo，到可发行产品' 48 48 820 48 30 $C.White $true | Out-Null
    Add-Text $s '我们希望在南山找到三类关键支持' 50 108 500 28 14 $C.Mint $false | Out-Null
    $asks=@(@('01','发行与增长','Steam商店页、愿望单、Demo、新品节与海外推广'),@('02','技术与合规','AI/云成本、生成内容安全、软著与发行合规'),@('03','孵化与落地','适合小团队的产业空间、融资与主体方案'))
    for($i=0;$i -lt 3;$i++){
        $y=170+$i*86; $a=$asks[$i]
        Add-Box $s 50 $y 52 52 $(if($i -eq 2){$C.Coral}else{$C.Forest}) 12 | Out-Null
        Add-Text $s $a[0] 50 ($y+16) 52 20 11 $C.White $true 'Microsoft YaHei' 2 | Out-Null
        Add-Text $s $a[1] 122 ($y+2) 170 25 16 $C.White $true | Out-Null
        Add-Text $s $a[2] 122 ($y+32) 650 24 11 $C.Pale $false | Out-Null
    }
    Add-Box $s 48 432 864 66 $C.Gold 12 | Out-Null
    Add-Text $s '融资按协议到位后，项目运营主体迁入南山区。' 72 443 815 23 15 $C.Deep $true 'Microsoft YaHei' 2 | Out-Null
    Add-Text $s '迁入时间、办公安排与配套条件在投资及孵化协议中明确。' 72 469 815 18 10 $C.Deep $false 'Microsoft YaHei' 2 | Out-Null
    Add-Text $s '谢谢｜甲壳虫工作室 · 《虫虫家装》' 50 510 430 18 9 $C.Mint $false | Out-Null
    Add-Note $s '25秒。我们下一阶段最需要发行增长、AI与内容合规，以及适合小团队的孵化支持。本轮300万元融资按协议到位后，我们将项目运营主体迁入南山区，在当地推进研发管理、知识产权、发行结算与产业资源合作。谢谢各位评委。'

    # Hidden Q&A appendix: detailed use of funds.
    $s = $pres.Slides.Add(13, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-AppendixHeader $s 'A1' '300万元预算：每一项都有计算依据' '与半决赛商业计划书8.2节一致；金额单位：万元。'
    $budgetRows=@(
        @('2名全职薪酬及用工成本','80','26.7%',$C.Forest),
        @('5名兼职成员阶段报酬','40','13.3%',$C.Mint),
        @('QA、本地化及峰值内容外包','24','8.0%',$C.Gold),
        @('研发工具、设备及AI/云服务','25','8.3%',$C.Gray),
        @('发行与增长','60','20.0%',$C.Coral),
        @('法务、知识产权与基础运营','17','5.7%',$C.Gray),
        @('现金流与范围风险储备','40','13.3%',$C.Forest),
        @('未分配管理缓冲','14','4.7%',$C.Gray)
    )
    Add-Box $s 42 150 876 34 $C.Forest | Out-Null
    Add-Text $s '用途' 58 159 540 18 10 $C.White $true | Out-Null
    Add-Text $s '金额' 650 159 100 18 10 $C.White $true 'Microsoft YaHei' 2 | Out-Null
    Add-Text $s '占比' 790 159 100 18 10 $C.White $true 'Microsoft YaHei' 2 | Out-Null
    for($i=0;$i -lt $budgetRows.Count;$i++){
        $y=190+$i*36; $r=$budgetRows[$i]
        Add-Box $s 42 $y 876 31 $(if($i%2 -eq 0){$C.Paper}else{$C.Pale}) | Out-Null
        Add-Box $s 42 $y 8 31 $r[3] | Out-Null
        Add-Text $s $r[0] 62 ($y+7) 540 18 10 $C.Ink $(if($i -eq 4){$true}else{$false}) | Out-Null
        Add-Text $s $r[1] 650 ($y+6) 100 18 11 $r[3] $true 'Microsoft YaHei' 2 | Out-Null
        Add-Text $s $r[2] 790 ($y+7) 100 18 10 $C.Gray $true 'Microsoft YaHei' 2 | Out-Null
    }
    Add-Box $s 42 488 876 24 $C.Forest 6 | Out-Null
    Add-Text $s '合计 300万元｜人力与内容144万 · 工具与AI/云25万 · 发行增长60万 · 运营及储备71万' 58 493 845 14 9 $C.White $true 'Microsoft YaHei' 2 | Out-Null
    Add-Footer $s '预算覆盖2026Q4—2028Q2；实际支出按到岗、合同、验收和里程碑复盘执行。'
    $s.SlideShowTransition.Hidden = -1

    # Hidden Q&A appendix: milestone-based tranches.
    $s = $pres.Slides.Add(14, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-AppendixHeader $s 'A2' '一次承诺、三期拨付：用客观里程碑控制风险' '300万元完整投资承诺；120万 + 100万 + 80万。'
    $tranches=@(
        @('第一期','120万','2026 Q4','垂直切片收尾与Alpha生产','Alpha从头到尾可玩；核心系统、内容产能与预算报告通过验收',$C.Forest),
        @('第二期','100万','预计2027 Q3','Beta生产','首发内容完成；功能与范围冻结；发行与Gold计划通过',$C.Gold),
        @('第三期','80万','预计2028 Q1','Gold与首发','完成RC、平台审核、Steam首发及上线后90天维护',$C.Coral)
    )
    for($i=0;$i -lt 3;$i++){
        $x=42+$i*294; $r=$tranches[$i]
        Add-Box $s $x 158 272 300 $C.Paper 14 $r[5] | Out-Null
        Add-Text $s $r[0] ($x+18) 177 90 22 12 $C.Gray $true | Out-Null
        Add-Text $s $r[1] ($x+18) 204 120 42 26 $r[5] $true | Out-Null
        Add-Text $s $r[2] ($x+154) 214 95 18 9 $C.Gray $true 'Microsoft YaHei' 3 | Out-Null
        Add-Text $s $r[3] ($x+18) 258 230 44 15 $C.Ink $true | Out-Null
        Add-Text $s '验收依据' ($x+18) 326 110 18 10 $r[5] $true | Out-Null
        Add-Text $s $r[4] ($x+18) 352 230 72 10 $C.Gray $false | Out-Null
    }
    Add-Footer $s '验收材料包括可玩版本、内容范围与产能报告、预算执行报告以及Steam和Demo数据。'
    $s.SlideShowTransition.Hidden = -1

    # Hidden Q&A appendix: launch scenarios and break-even boundary.
    $s = $pres.Slides.Add(15, 12); Add-Box $s 0 0 $W $H $C.Cream | Out-Null
    Add-AppendixHeader $s 'A3' '首发12个月：约8万套为审慎经营保本线' '平均含税成交额80元；Steam平台费30%；每套平台费后税前回款约56元。'
    $scenarioRows=@(
        @('保守','5万套','400万','280万','约 -130万',$C.Gray),
        @('审慎保本','约8万套','约640万','约448万','约 0',$C.Gold),
        @('基准','15万套','1,200万','840万','约 400万',$C.Forest),
        @('乐观','30万套','2,400万','1,680万','约 1,160万',$C.Coral)
    )
    $headers=@('情景','销量','消费者支付','平台费后回款','累计经营现金净额')
    $xs=@(42,190,335,515,710); $ws=@(140,135,170,185,208)
    for($i=0;$i -lt $headers.Count;$i++){ Add-Box $s $xs[$i] 160 $ws[$i] 42 $C.Forest | Out-Null; Add-Text $s $headers[$i] ($xs[$i]+5) 172 ($ws[$i]-10) 18 10 $C.White $true 'Microsoft YaHei' 2 | Out-Null }
    for($r=0;$r -lt $scenarioRows.Count;$r++){
        $y=210+$r*61; $row=$scenarioRows[$r]
        for($i=0;$i -lt 5;$i++){ Add-Box $s $xs[$i] $y $ws[$i] 53 $(if($r%2 -eq 0){$C.Paper}else{$C.Pale}) | Out-Null; Add-Text $s $row[$i] ($xs[$i]+5) ($y+16) ($ws[$i]-10) 20 11 $(if($i -eq 0 -or $i -eq 4){$row[5]}else{$C.Ink}) $(if($r -eq 1 -or $r -eq 2){$true}else{$false}) 'Microsoft YaHei' 2 | Out-Null }
    }
    Add-Box $s 42 468 876 37 $C.Deep 8 | Out-Null
    Add-Text $s '现金基础372—410万元 → 税前经营保本6.6—7.3万套 → 预留税费及运营波动后，审慎按约8万套管理' 58 478 845 18 10 $C.Mint $true 'Microsoft YaHei' 2 | Out-Null
    Add-Footer $s '均为经营测算；销量目标将按愿望单、Demo、创作者反馈和首发数据滚动校准。'
    $s.SlideShowTransition.Hidden = -1

    # Save as an editable PowerPoint presentation.
    $pres.SaveAs($OutputPath, 24)
    Write-Output $OutputPath
}
finally {
    if ($pres) { $pres.Close(); [System.Runtime.InteropServices.Marshal]::ReleaseComObject($pres) | Out-Null }
    if ($ppt) { $ppt.Quit(); [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null }
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}
