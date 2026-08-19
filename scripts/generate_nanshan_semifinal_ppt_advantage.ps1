param(
    [string]$OutputPath = ''
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repo '比赛材料\2026南山创业之星\甲壳虫工作室+虫虫家装+半决赛路演PPT_产品优势重构版.pptx'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $repo $OutputPath
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

$cover = Join-Path $repo 'assets\images\cover_art_2x.png'
$logo = Join-Path $repo 'assets\images\TeamLOGO.png'
$screens = Join-Path $repo 'assets\screen_shots'
$videoDir = Join-Path $repo 'assets\video'
$pitchVideo = Join-Path $videoDir '光子答辩宣传视频.mp4'
$appendixSource = Join-Path $repo '比赛材料\2026南山创业之星\其他PPT（废稿与参考）\甲壳虫工作室+虫虫家装+半决赛路演PPT_商业计划书同步版.pptx'
$referenceTextureDir = Join-Path $repo 'assets\ppt\reference_textures'
$blueBrushVertical = Join-Path $referenceTextureDir 'blue_brush_vertical.png'
$blueBrushCorner = Join-Path $referenceTextureDir 'blue_brush_corner.png'

$shotDark = Join-Path $screens '3a463cb5299046160efc83f9455813ed.jpg'
$shotHome = Join-Path $screens 'b1a80e1491b420082aacd149f477b5ad.jpg'
$shotMenu = Join-Path $screens '25892105d31321dd39931d415e9d6e5c.jpg'
$shotEmpty = Join-Path $screens '211c5238fdb812c4f3f70b23e72709c1.jpg'
$shotDream = Join-Path $screens 'ef9911999fd6ca217e0c32815a0887a4.jpg'
$character = Join-Path $screens '微信图片_20260510174124_3122_157.jpg'
$gifGather = Join-Path $videoDir '采集.gif'
$gifChase = Join-Path $videoDir '追逃机制.gif'
$gifBuild = Join-Path $videoDir '建造模式.gif'
$gifCompanion = Join-Path $videoDir '沉浸模式.gif'

foreach ($required in @(
    $cover, $logo, $pitchVideo, $appendixSource,
    $blueBrushVertical, $blueBrushCorner,
    $shotDark, $shotHome, $shotMenu, $shotEmpty, $shotDream, $character,
    $gifGather, $gifChase, $gifBuild, $gifCompanion
)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Missing asset: $required" }
}

$W = 960.0
$H = 540.0
# Same restrained palette as the approved visual-refinement deck.
# Office stores RGB values in BGR integer order.
$C = @{
    Ink = 0x383226       # #263238
    Deep = 0x403617      # #173640
    Forest = 0x5B4E21    # #214E5B
    Mint = 0xA0A67F      # #7FA6A0
    Cream = 0xEEF4F7     # #F7F4EE
    Paper = 0xEEF4F7
    Coral = 0x3D6AC6     # #C66A3D
    Gold = 0x5AB6E1      # #E1B65A
    DarkRed = 0x3851A9
    White = 0xFFFFFF
    Gray = 0x7A7566
    Pale = 0xE9E8DC
    Black = 0x403617
    TrueBlack = 0x111111
}

function Add-Text(
    $slide, [string]$text, [double]$x, [double]$y, [double]$w, [double]$h,
    [double]$size = 20, [int]$color = 0x383226, [bool]$bold = $false,
    [int]$align = 1, [string]$font = 'Microsoft YaHei'
) {
    $shape = $slide.Shapes.AddTextbox(1, $x, $y, $w, $h)
    $shape.TextFrame.MarginLeft = 0
    $shape.TextFrame.MarginRight = 0
    $shape.TextFrame.MarginTop = 0
    $shape.TextFrame.MarginBottom = 0
    $shape.TextFrame.WordWrap = -1
    $shape.TextFrame.TextRange.Text = $text
    $shape.TextFrame.TextRange.Font.Name = $font
    $shape.TextFrame.TextRange.Font.NameFarEast = $font
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

function Add-PaperBackground($slide) {
    Add-Box $slide 0 0 $W $H $C.Paper | Out-Null
    $topBrush = Add-PictureFit $slide $blueBrushVertical 827 -74 247 173
    $topBrush.Rotation = -45
    $bottomBrush = Add-PictureFit $slide $blueBrushCorner -55 385 245 171
    $bottomBrush.Rotation = -90
}

function Add-PageNumber($slide, [int]$number, [int]$color = 0x7A7566) {
    Add-Text $slide ("{0:D2}" -f $number) 902 500 30 16 8 $color $true 3 | Out-Null
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

function Add-Dot($slide, [double]$x, [double]$y, [double]$size, [int]$fill) {
    $dot = $slide.Shapes.AddShape(9, $x, $y, $size, $size)
    $dot.Fill.ForeColor.RGB = $fill
    $dot.Line.Visible = 0
    return $dot
}

$ppt = $null
$pres = $null
try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $ppt.Visible = -1
    $pres = $ppt.Presentations.Add()
    $pres.PageSetup.SlideWidth = $W
    $pres.PageSetup.SlideHeight = $H

    # 1. Product promise, not project status.
    $s = $pres.Slides.Add(1, 12)
    Add-PictureFit $s $cover 0 0 $W $H | Out-Null
    Add-Box $s 0 0 540 $H $C.Deep 0.08 | Out-Null
    Add-Text $s '虫虫家装' 48 78 430 82 50 $C.White $true | Out-Null
    Add-Text $s "去危险的废墟搜集，`n把破木屋装成末世最幸福的家。" 52 180 450 100 25 $C.Gold $true | Out-Null
    Add-Text $s '一款让“出门冒险”与“回家生活”互相放大的休闲游戏' 52 304 430 46 13 $C.White $true | Out-Null
    Add-Box $s 52 390 5 34 $C.Coral | Out-Null
    Add-Text $s '甲壳虫工作室｜木子' 70 395 250 24 13 $C.White $true | Out-Null
    Add-Text $s '2026 南山“创业之星”游戏产业专项赛 · 团队组半决赛' 52 462 420 18 8 $C.Pale $false | Out-Null
    Add-Note $s '15秒。大家好，我们是甲壳虫工作室。《虫虫家装》不是把两个热门玩法贴在一起，而是让玩家每一次冒险都有一个想回去的地方：去危险的废墟搜集，把破木屋装成末世最幸福的家。'

    # 2. Show the complete emotional loop before explaining it.
    $s = $pres.Slides.Add(2, 12)
    Add-Box $s 0 0 $W $H $C.Black | Out-Null
    try {
        $media = $s.Shapes.AddMediaObject2($pitchVideo, 0, -1, 0, 0, $W, $H)
        $media.AnimationSettings.PlaySettings.PlayOnEntry = -1
    }
    catch {
        Add-PictureFit $s $shotMenu 0 0 $W $H | Out-Null
    }
    Add-Box $s 0 0 $W 62 $C.Deep 0.12 | Out-Null
    Add-Text $s '先看一轮完整体验' 34 18 420 34 22 $C.White $true | Out-Null
    Add-Box $s 0 493 $W 47 $C.Deep 0.08 | Out-Null
    Add-Text $s '出门搜集  →  被发现  →  逃回家  →  把家变好' 160 505 640 22 12 $C.Gold $true 2 | Out-Null
    Add-Note $s '45秒。先请大家看一轮完整体验。视频结束后只说一句：外面的危险让资源有价值，家里的伙伴让每次冒险有意义。'

    # 3. The core advantage is an emotional system, not a genre label.
    $s = $pres.Slides.Add(3, 12)
    Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-Text $s '危险，不是为了更硬核。' 46 28 850 42 26 $C.White $true | Out-Null
    Add-Text $s '它是为了让“回家”更幸福。' 46 72 850 48 30 $C.Gold $true | Out-Null
    Add-PictureFit $s $shotDark 42 148 418 235 | Out-Null
    Add-PictureFit $s $shotHome 500 148 418 235 | Out-Null
    Add-Box $s 42 383 418 4 $C.Coral | Out-Null
    Add-Box $s 500 383 418 4 $C.Gold | Out-Null
    Add-Text $s '资源越难带回来，' 48 414 350 26 17 $C.Coral $true | Out-Null
    Add-Text $s '家里的变化越有分量。' 506 414 350 26 17 $C.Gold $true | Out-Null
    Add-Text $s '“外紧内松”不是节奏包装，而是整款游戏的情绪发动机。' 185 478 590 24 13 $C.Pale $true 2 | Out-Null
    Add-PageNumber $s 3 $C.Pale
    Add-Note $s '40秒。传统搜打撤把收获变成战力，我们把收获变成生活。玩家在外面越紧张，回到家看见伙伴和房间变化时就越放松。这种危险与温暖互相放大的情绪，不是两个标签的拼接，而是整款游戏的发动机。'

    # 4. Make the causal loop explicit and let the live GIFs do most of the work.
    $s = $pres.Slides.Add(4, 12)
    Add-PaperBackground $s
    Add-Text $s '不是“搜打撤 + 装修”，而是一条因果循环' 42 22 830 44 27 $C.Ink $true | Out-Null
    $moments = @(
        @($gifGather, 66, 80, '找到一件想带回家的东西', $C.Forest),
        @($gifChase, 509, 80, '风险逼你决定：贪，还是撤', $C.Coral),
        @($gifBuild, 66, 310, '把收获真正放进生活空间', $C.Gold),
        @($gifCompanion, 509, 310, '伙伴回应，再产生新的心愿', $C.Forest)
    )
    foreach ($m in $moments) {
        Add-PictureFit $s $m[0] $m[1] $m[2] 385 217 | Out-Null
        Add-Box $s $m[1] ($m[2] + 177) 385 40 $C.Deep 0.10 | Out-Null
        Add-Text $s $m[3] ($m[1] + 14) ($m[2] + 187) 355 22 11 $(if ($m[4] -eq $C.Gold) { $C.Gold } else { $C.White }) $true | Out-Null
    }
    Add-PageNumber $s 4
    Add-Note $s '50秒。一次循环只有四件事：找到真正想带回家的东西；在风险上升时做取舍；把收获放进自己的空间；得到伙伴回应和新的心愿。野外与家园不是并列模块，前一步永远在制造下一步的理由。'

    # 5. The strongest differentiator: decoration becomes relationship language.
    $s = $pres.Slides.Add(5, 12)
    Add-Box $s 0 0 $W $H $C.TrueBlack | Out-Null
    Add-PictureFit $s $character 560 72 360 380 | Out-Null
    Add-Text $s '装修的终点，不是“好看”。' 46 48 520 44 26 $C.White $true | Out-Null
    Add-Text $s '是有人记得你做过什么。' 46 92 520 50 30 $C.Gold $true | Out-Null

    Add-Dot $s 52 184 10 $C.Coral | Out-Null
    Add-Text $s '玩家摆下一件家具' 78 174 360 28 16 $C.White $true | Out-Null
    Add-Box $s 56 210 2 35 $C.Forest | Out-Null
    Add-Dot $s 52 250 10 $C.Forest | Out-Null
    Add-Text $s '规则层记录：谁、何时、关系阶段' 78 240 410 28 16 $C.White $true | Out-Null
    Add-Box $s 56 276 2 35 $C.Forest | Out-Null
    Add-Dot $s 52 316 10 $C.Gold | Out-Null
    Add-Text $s '伙伴按性格回应，并留下共同记忆' 78 306 420 28 16 $C.White $true | Out-Null
    Add-Box $s 56 342 2 35 $C.Forest | Out-Null
    Add-Dot $s 52 382 10 $C.Mint | Out-Null
    Add-Text $s '新的心愿推动下一次探索' 78 372 380 28 16 $C.White $true | Out-Null

    Add-Box $s 48 442 470 42 $C.Forest 0.02 | Out-Null
    Add-Text $s '模型可替换 · 输出有校验 · 断网有模板兜底' 65 453 435 20 11 $C.Pale $true 2 | Out-Null
    Add-PageNumber $s 5 $C.Pale
    Add-Note $s '55秒。装修游戏通常在摆放完成时结束，我们让它从这里开始。系统会记录玩家放下了什么、当时是谁在家、关系发展到哪一步；伙伴再按自己的性格回应，并把这段经历写进后续记忆和心愿。AI只负责受约束的短反馈，事实由规则管理，所以它不是聊天噱头，而是让装修变成关系表达。'

    # 6. Show transformation and the shareable content engine.
    $s = $pres.Slides.Add(6, 12)
    Add-PaperBackground $s
    Add-Text $s '每个玩家，都会拥有一间不一样的家' 42 24 820 44 28 $C.Ink $true | Out-Null
    Add-Text $s '房间变化本身，就是最容易被看见和分享的内容。' 45 73 620 24 13 $C.Gray $true | Out-Null
    Add-PictureFit $s $shotEmpty 42 126 412 238 | Out-Null
    Add-PictureFit $s $shotDream 506 126 412 238 | Out-Null
    Add-Box $s 42 364 412 40 $C.Forest | Out-Null
    Add-Text $s '当前实机｜一间等待被改变的空房' 56 374 384 20 11 $C.White $true 2 | Out-Null
    Add-Box $s 506 364 412 40 $C.Coral | Out-Null
    Add-Text $s '房间概念｜家具、性格与生活痕迹' 520 374 384 20 11 $C.White $true 2 | Out-Null
    Add-Text $s '改造前后' 115 448 130 26 16 $C.Forest $true 2 | Out-Null
    Add-Text $s '＋' 260 446 40 28 17 $C.Gray $true 2 | Out-Null
    Add-Text $s '家具组合' 310 448 130 26 16 $C.Forest $true 2 | Out-Null
    Add-Text $s '＋' 455 446 40 28 17 $C.Gray $true 2 | Out-Null
    Add-Text $s '伙伴反应' 505 448 130 26 16 $C.Forest $true 2 | Out-Null
    Add-Text $s '＝ 天然的截图 / 短视频 / UGC' 645 448 240 26 15 $C.Coral $true 2 | Out-Null
    Add-PageNumber $s 6
    Add-Note $s '40秒。家不是一张固定地图，而是玩家持续表达自己的空间。改造前后、家具组合以及伙伴反应，都天然适合截图、直播和短视频。这里右侧是房间概念图，代表我们要达到的生活密度；左侧是当前实机，明确区分完成度与目标。'

    # 7. Position the project in the whitespace between mature player needs.
    $s = $pres.Slides.Add(7, 12)
    Add-PaperBackground $s
    Add-Text $s '我们占的是两类成熟需求之间的空位' 42 26 820 44 28 $C.Ink $true | Out-Null
    Add-Text $s '给温馨玩家一个敢出门的理由；给冒险玩家一个想回家的地方。' 45 75 760 24 13 $C.Gray $true | Out-Null

    $xAxis = $s.Shapes.AddLine(190, 416, 865, 416)
    $xAxis.Line.ForeColor.RGB = $C.Forest
    $xAxis.Line.Weight = 2
    $xAxis.Line.EndArrowheadStyle = 3
    $yAxis = $s.Shapes.AddLine(190, 416, 190, 126)
    $yAxis.Line.ForeColor.RGB = $C.Forest
    $yAxis.Line.Weight = 2
    $yAxis.Line.EndArrowheadStyle = 3
    Add-Text $s '功能成长' 124 438 140 22 11 $C.Gray $true 2 | Out-Null
    Add-Text $s '空间与关系表达' 735 438 165 22 11 $C.Gray $true 2 | Out-Null
    Add-Text $s "风险收益`n更强" 95 120 75 45 10 $C.Gray $true 2 | Out-Null
    Add-Text $s "日常放松`n更强" 95 370 75 45 10 $C.Gray $true 2 | Out-Null

    Add-Dot $s 278 190 18 $C.Gray | Out-Null
    Add-Text $s '硬核搜打撤' 305 183 145 26 13 $C.Gray $true | Out-Null
    Add-Dot $s 658 348 18 $C.Mint | Out-Null
    Add-Text $s '温馨装修' 685 341 130 26 13 $C.Forest $true | Out-Null
    Add-Dot $s 474 283 18 $C.Gold | Out-Null
    Add-Text $s '探索经营' 501 276 130 26 13 $C.Gray $true | Out-Null
    Add-Dot $s 675 168 32 $C.Coral | Out-Null
    Add-Text $s '虫虫家装' 716 168 150 28 17 $C.Coral $true | Out-Null
    Add-Text $s '轻量风险循环' 716 198 160 22 11 $C.Ink $true | Out-Null
    Add-Text $s '＋ 自由装修' 716 220 160 22 11 $C.Ink $true | Out-Null
    Add-Text $s '＋ 伙伴情感反馈' 716 242 170 22 11 $C.Ink $true | Out-Null
    Add-PageNumber $s 7
    Add-Note $s '45秒。我们不是和硬核射击产品争夺同一批玩家，也不是做另一款纯装修工具。我们站在两个已经成立的需求之间：用轻量风险循环给温馨玩家一个愿意出门的理由，再用自由装修和伙伴关系给冒险玩家一个真正想回去的地方。'

    # 8. Team-market fit: foreground the uncommon combination of skills.
    $s = $pres.Slides.Add(8, 12)
    Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-Text $s '这个组合，刚好能把它做出来' 44 34 760 50 30 $C.White $true | Out-Null
    Add-PictureFit $s $logo 828 30 78 88 | Out-Null

    Add-Box $s 50 126 5 48 $C.Coral | Out-Null
    Add-Text $s '产品与工程' 68 146 220 30 19 $C.Gold $true | Out-Null
    Add-Text $s "木子｜制作人 / 程序 / AI`n香港中文大学计算机科学`n米哈游 4 年算法经历" 68 204 220 104 14 $C.White $true | Out-Null
    Add-Box $s 68 330 196 2 $C.Mint | Out-Null
    Add-Text $s "佩玖｜主策划`n一线出海游戏公司" 68 350 210 54 12 $C.Pale $true | Out-Null

    Add-Box $s 330 124 1 292 $C.Forest | Out-Null
    Add-Box $s 350 126 5 48 $C.Gold | Out-Null
    Add-Text $s '原创表达' 368 146 220 30 19 $C.Gold $true | Out-Null
    Add-Text $s "粥粥｜美术 / 动画 / 发行`n四川美术学院动画`n字节跳动经历" 368 204 220 104 14 $C.White $true | Out-Null
    Add-Box $s 368 330 196 2 $C.Mint | Out-Null
    Add-Text $s "概念设计 + 动画`nUI/UX｜华东师大数码艺术" 368 350 220 54 12 $C.Pale $true | Out-Null

    Add-Box $s 630 124 1 292 $C.Forest | Out-Null
    Add-Box $s 650 126 5 48 $C.Mint | Out-Null
    Add-Text $s '完整制作能力' 668 146 220 30 19 $C.Gold $true | Out-Null
    Add-Text $s "音频｜伯克利音乐学院`n程序、策划、美术、动画`nUIUX、音频完整覆盖" 668 204 220 104 14 $C.White $true | Out-Null
    Add-Box $s 668 330 196 2 $C.Mint | Out-Null
    Add-Text $s "GMTK 叙事 Top 1.5%`n已共同交付可玩 Demo" 668 350 220 54 12 $C.Pale $true | Out-Null

    Add-Text $s '不是为比赛临时拼出的履历，而是一支已经共同交付过作品的跨职能团队。' 130 460 700 26 13 $C.Mint $true 2 | Out-Null
    Add-PageNumber $s 8 $C.Pale
    Add-Note $s '45秒。这个项目需要同时理解轻量玩法、AI工程和手绘表达。制作人有港中大计算机背景和米哈游四年算法经历，主策来自一线出海游戏公司；美术负责人来自川美并有字节经历，团队还覆盖概念、动画、UIUX和伯克利音乐学院音频。更重要的是，我们已经共同交付过Game Jam作品和《虫虫家装》可玩Demo。'

    # 9. Funding converts validated differentiation into shippable content.
    $s = $pres.Slides.Add(9, 12)
    Add-PaperBackground $s
    Add-Text $s '300万，不是用来寻找方向' 44 32 650 48 29 $C.Ink $true | Out-Null
    Add-Text $s '而是把已跑通的优势，做成可发行内容。' 44 78 760 48 28 $C.Coral $true | Out-Null
    Add-Text $s '21个月｜一次承诺，按里程碑分三期拨付' 48 135 530 24 12 $C.Gray $true | Out-Null

    Add-Text $s '120万' 66 206 180 45 29 $C.Forest $true | Out-Null
    Add-Text $s 'Alpha' 70 255 160 26 16 $C.Ink $true | Out-Null
    Add-Text $s "完整系统`n内容管线" 70 294 160 50 12 $C.Gray $false | Out-Null

    Add-Box $s 292 202 2 160 $C.Mint | Out-Null
    Add-Text $s '100万' 348 206 180 45 29 $C.Gold $true | Out-Null
    Add-Text $s 'Beta' 352 255 160 26 16 $C.Ink $true | Out-Null
    Add-Text $s "约15小时内容`nQA与本地化" 352 294 180 50 12 $C.Gray $false | Out-Null

    Add-Box $s 588 202 2 160 $C.Mint | Out-Null
    Add-Text $s '80万' 646 206 180 45 29 $C.Coral $true | Out-Null
    Add-Text $s 'Gold / 发售' 650 255 190 26 16 $C.Ink $true | Out-Null
    Add-Text $s "平台审核与推广`n首发后90天维护" 650 294 190 50 12 $C.Gray $false | Out-Null

    Add-Box $s 54 406 852 62 $C.Forest | Out-Null
    Add-Text $s '已有证据' 72 418 100 20 11 $C.Gold $true | Out-Null
    Add-Text $s '可玩双循环  ·  AI情感原型  ·  光子概念赛道银奖  ·  19份早期方向信号' 174 418 700 20 11 $C.White $true | Out-Null
    Add-Text $s '详细里程碑、问卷与经营情景移至答辩附录。' 174 443 700 16 9 $C.Pale $false | Out-Null
    Add-PageNumber $s 9
    Add-Note $s '50秒。我们融资三百万元，不是为了继续寻找产品方向，而是把已经跑通的方向做成十五小时左右、可以全球发行的完整内容。第一期完成系统和内容管线，第二期完成Beta内容、QA与本地化，第三期完成Gold、发售和九十天维护。Demo、AI原型、赛事和早期反馈只作为项目已经启动的证据，详细数据放在答辩附录。'

    # 10. Close on the product promise and the concrete local ask.
    $s = $pres.Slides.Add(10, 12)
    Add-PictureFit $s $cover 0 0 $W $H | Out-Null
    Add-Box $s 0 0 $W $H $C.Deep 0.15 | Out-Null
    Add-Text $s '让“回家”成为玩家' 50 55 650 52 31 $C.White $true | Out-Null
    Add-Text $s '下一次出发的理由。' 50 108 650 58 35 $C.Gold $true | Out-Null
    Add-Text $s '我们需要' 54 218 120 24 12 $C.Mint $true | Out-Null
    Add-Text $s '发行增长' 54 258 190 36 22 $C.White $true | Out-Null
    Add-Text $s '技术合规' 270 258 190 36 22 $C.White $true | Out-Null
    Add-Text $s '孵化落地' 486 258 190 36 22 $C.White $true | Out-Null
    Add-Box $s 50 342 680 62 $C.Gold 0.02 | Out-Null
    Add-Text $s '融资按协议到位后，项目运营主体迁入南山区。' 68 359 645 28 16 $C.Deep $true 2 | Out-Null
    Add-Box $s 52 440 5 34 $C.Coral | Out-Null
    Add-Text $s '谢谢' 70 444 80 28 16 $C.White $true | Out-Null
    Add-Text $s '甲壳虫工作室 ·《虫虫家装》' 164 447 320 24 12 $C.Mint $true | Out-Null
    Add-Note $s '25秒。我们希望获得发行增长、技术合规和孵化落地支持，让回家成为玩家下一次出发的理由，把这间破木屋真正推进到Steam发售。本轮融资按协议到位后，项目运营主体迁入南山区。谢谢各位评委。'

    # 11. Hidden Q&A slide: generic progress evidence is available, but no longer leads the pitch.
    $s = $pres.Slides.Add(11, 12)
    Add-PaperBackground $s
    Add-Text $s '答辩备用｜当前进展与下一步验证' 42 30 820 46 27 $C.Ink $true | Out-Null
    Add-PictureFit $s $shotMenu 52 108 430 242 | Out-Null
    Add-Text $s '已经完成' 548 108 240 28 17 $C.Forest $true | Out-Null
    Add-Text $s "可玩双循环`nAI情感反馈原型`n展会与定向试玩`n光子概念赛道银奖" 548 151 300 126 14 $C.Ink $true | Out-Null
    Add-Text $s '早期方向信号（n=19）' 548 302 260 25 14 $C.Coral $true | Out-Null
    Add-Text $s '18人想继续装修｜17人野外体验正向｜16人对同类价格或更高购买持开放态度' 548 337 325 66 11 $C.Gray $false | Out-Null
    Add-Box $s 52 428 820 3 $C.Forest | Out-Null
    Add-Text $s '下一步：扩大试玩 → Steam商店页 → 公开Demo行为 → 愿望单与创作者反馈' 72 451 780 24 13 $C.Ink $true 2 | Out-Null
    Add-Text $s '小样本只用于方向判断，不作为市场结论。' 180 488 600 18 9 $C.Gray $false 2 | Out-Null
    Add-Note $s '答辩备用。被问到项目进展或用户验证时再展示。明确说明19份问卷是早期方向信号，不是市场验证结论。'
    $s.SlideShowTransition.Hidden = -1

    # Append the three existing detailed financial slides for Q&A.
    $inserted = $pres.Slides.InsertFromFile($appendixSource, $pres.Slides.Count, 13, 15)
    if ($inserted -ne 3) { throw "Expected 3 appendix slides, inserted $inserted" }
    foreach ($index in 12..14) { $pres.Slides.Item($index).SlideShowTransition.Hidden = -1 }

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
