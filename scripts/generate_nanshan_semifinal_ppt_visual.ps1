param(
    [string]$OutputPath = ''
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repo '比赛材料\2026南山创业之星\甲壳虫工作室+虫虫家装+半决赛路演PPT_视觉精修版.pptx'
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
$jam = 'E:\Onedrive\Personal\website\muziliu.github.io\public\images\games\not-again-hero.png'
$appendixSource = Join-Path $repo '比赛材料\2026南山创业之星\其他PPT（废稿与参考）\甲壳虫工作室+虫虫家装+半决赛路演PPT_商业计划书同步版.pptx'
$referenceTextureDir = Join-Path $repo 'assets\ppt\reference_textures'
$blueBrushVertical = Join-Path $referenceTextureDir 'blue_brush_vertical.png'
$blueBrushCorner = Join-Path $referenceTextureDir 'blue_brush_corner.png'

$shotDark = Join-Path $screens '3a463cb5299046160efc83f9455813ed.jpg'
$shotHome = Join-Path $screens 'b1a80e1491b420082aacd149f477b5ad.jpg'
$shotMenu = Join-Path $screens '25892105d31321dd39931d415e9d6e5c.jpg'
$character = Join-Path $screens '微信图片_20260510174124_3122_157.jpg'
$gifGather = Join-Path $videoDir '采集.gif'
$gifChase = Join-Path $videoDir '追逃机制.gif'
$gifBuild = Join-Path $videoDir '建造模式.gif'
$gifCompanion = Join-Path $videoDir '沉浸模式.gif'

foreach ($required in @(
    $cover, $logo, $pitchVideo, $jam, $appendixSource,
    $blueBrushVertical, $blueBrushCorner,
    $shotDark, $shotHome, $shotMenu, $character,
    $gifGather, $gifChase, $gifBuild, $gifCompanion
)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Missing asset: $required" }
}

$W = 960.0
$H = 540.0
# Office stores RGB values in BGR integer order. This restrained palette follows
# the existing business-plan brand colors and the game's watercolor artwork:
# #263238, #173640, #214E5B, #7FA6A0, #F7F4EE, #C66A3D, #E1B65A.
$C = @{
    Ink = 0x383226
    Deep = 0x403617
    Forest = 0x5B4E21
    Mint = 0xA0A67F
    Cream = 0xEEF4F7
    Paper = 0xEEF4F7
    Coral = 0x3D6AC6
    Gold = 0x5AB6E1
    DarkRed = 0x3851A9
    White = 0xFFFFFF
    Gray = 0x7A7566
    Pale = 0xE9E8DC
    Black = 0x403617
}

function Add-Text(
    $slide, [string]$text, [double]$x, [double]$y, [double]$w, [double]$h,
    [double]$size = 20, [int]$color = 0x183330, [bool]$bold = $false,
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
    # Insert at native aspect ratio, then scale uniformly into the target box.
    # PowerPoint's six-argument AddPicture stretches images when the box ratio differs.
    $shape = $slide.Shapes.AddPicture($path, 0, -1, 0, 0, -1, -1)
    $shape.LockAspectRatio = -1
    $nativeWidth = $shape.Width
    $nativeHeight = $shape.Height
    $scale = [Math]::Min($w / $nativeWidth, $h / $nativeHeight)
    # Setting width is sufficient while the aspect-ratio lock is enabled.
    # Reading Height after changing Width and multiplying again would scale twice.
    $shape.Width = $nativeWidth * $scale
    $shape.Left = $x + (($w - $shape.Width) / 2)
    $shape.Top = $y + (($h - $shape.Height) / 2)
    $shape.Line.Visible = 0
    return $shape
}

function Add-PaperBackground($slide) {
    Add-Box $slide 0 0 $W $H $C.Paper | Out-Null

    # Reuse the original reference deck's painterly blue edge elements. They
    # sit behind all content and add texture without turning into decoration.
    $topBrush = Add-PictureFit $slide $blueBrushVertical 815 -67 271 189
    $topBrush.Rotation = -45
    $bottomBrush = Add-PictureFit $slide $blueBrushCorner -47 352 297 208
    $bottomBrush.Rotation = -90
}

function Add-PageNumber($slide, [int]$number, [int]$color = 0x737765) {
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

$ppt = $null
$pres = $null
try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $ppt.Visible = -1
    $pres = $ppt.Presentations.Add()
    $pres.PageSetup.SlideWidth = $W
    $pres.PageSetup.SlideHeight = $H

    # 1. Cover: let the game's own artwork establish the visual language.
    $s = $pres.Slides.Add(1, 12)
    Add-PictureFit $s $cover 0 0 $W $H | Out-Null
    Add-Box $s 0 0 540 $H $C.Deep 0.08 | Out-Null
    Add-Text $s '虫虫家装' 48 88 430 82 50 $C.White $true | Out-Null
    Add-Text $s '把破木屋，装成末世最幸福的家！' 52 190 430 78 25 $C.Gold $true | Out-Null
    Add-Text $s '轻量搜打撤 × 治愈装修' 52 286 340 28 14 $C.White $true | Out-Null
    Add-Box $s 52 376 5 34 $C.Coral | Out-Null
    Add-Text $s '甲壳虫工作室｜木子' 70 381 250 24 13 $C.White $true | Out-Null
    Add-Text $s '2026 南山“创业之星”游戏产业专项赛 · 团队组半决赛' 52 462 420 18 8 $C.Pale $false | Out-Null
    Add-Note $s '15秒。大家好，我们是甲壳虫工作室。《虫虫家装》是一款轻量搜打撤和治愈装修结合的PC独立游戏。我们想让玩家去危险的废墟搜集，再把破木屋装成末世最幸福的家。'

    # 2. Full-screen demo. No explanatory framework before the audience sees the game.
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
    Add-Note $s '45秒。先不解释概念，请大家看一轮完整体验。视频结束后只说一句：外面的危险让资源有价值，家里的伙伴让每次冒险有意义。'

    # 3. Emotional contrast instead of a consultant-style problem statement.
    $s = $pres.Slides.Add(3, 12)
    Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-PictureFit $s $shotDark 36 112 432 243 | Out-Null
    Add-PictureFit $s $shotHome 492 112 432 243 | Out-Null
    Add-Text $s '外面很危险。家里有人等你。' 45 26 870 55 31 $C.White $true 2 | Out-Null
    Add-Box $s 36 355 432 4 $C.Coral | Out-Null
    Add-Box $s 492 355 432 4 $C.Gold | Out-Null
    Add-Text $s '被发现——快逃！' 42 382 310 30 19 $C.Coral $true | Out-Null
    Add-Text $s '回家，把日子过好。' 498 382 340 30 19 $C.Gold $true | Out-Null
    Add-Text $s '危险让资源有价值' 42 424 300 22 12 $C.Pale $false | Out-Null
    Add-Text $s '伙伴让每次冒险有意义' 498 424 340 22 12 $C.Pale $false | Out-Null
    Add-Text $s '这份“外紧内松”的反差，就是《虫虫家装》的记忆点。' 150 478 660 28 15 $C.Gold $true 2 | Out-Null
    Add-PageNumber $s 3 $C.Pale
    Add-Note $s '35秒。我们的体验核心不是两个玩法标签，而是一段情绪：在黑暗里寻找，被发现后逃回家，而家里有伙伴等你。外面的危险和里面的安全互相放大，这就是玩家容易记住的地方。'

    # 4. Four live game moments. The GIFs carry the explanation.
    $s = $pres.Slides.Add(4, 12)
    Add-PaperBackground $s
    Add-Text $s '每一次出门，都为了把家变好' 42 22 760 44 27 $C.Ink $true | Out-Null
    $moments = @(
        @($gifGather, 66, 78, '01  搜集', $C.Forest),
        @($gifChase, 509, 78, '02  取舍', $C.Coral),
        @($gifBuild, 66, 310, '03  装修', $C.Gold),
        @($gifCompanion, 509, 310, '04  回应', $C.Forest)
    )
    foreach ($m in $moments) {
        Add-PictureFit $s $m[0] $m[1] $m[2] 385 217 | Out-Null
        Add-Box $s $m[1] ($m[2] + 177) 385 40 $C.Deep 0.12 | Out-Null
        Add-Text $s $m[3] ($m[1] + 14) ($m[2] + 187) 150 22 12 $(if ($m[4] -eq $C.Gold) { $C.Gold } else { $C.White }) $true | Out-Null
    }
    Add-PageNumber $s 4
    Add-Note $s '50秒。一次循环只有四件事：找材料、判断要不要继续贪、成功撤离后装修、再得到小动物的回应。野外和家园不是两套并列玩法，它们在互相提供下一步的动力。'

    # 5. Explain AI through the player's feeling, not an architecture diagram.
    $s = $pres.Slides.Add(5, 12)
    Add-Box $s 0 0 $W $H $C.Black | Out-Null
    Add-PictureFit $s $character 510 62 430 410 | Out-Null
    Add-Text $s '小动物会记得，' 48 72 520 52 31 $C.White $true | Out-Null
    Add-Text $s '你为这个家做过什么。' 48 126 520 60 34 $C.Gold $true | Out-Null
    Add-Text $s "同一件家具，`n不同伙伴会有不同反应。" 52 232 410 72 20 $C.White $false | Out-Null
    Add-Text $s '记忆  ·  关系  ·  心愿' 52 337 360 28 15 $C.Mint $true | Out-Null
    Add-Box $s 52 409 400 2 $C.Forest | Out-Null
    Add-Text $s '规则负责事实，AI只生成受约束的短反馈；断网也能继续玩。' 52 430 420 32 11 $C.Pale $false | Out-Null
    Add-PageNumber $s 5 $C.Pale
    Add-Note $s '40秒。AI不是开放聊天功能，而是让小动物能记得玩家做过什么。事实和关系由游戏规则管理，模型只生成受约束的短反馈；结果会校验，服务不可用时由模板承接，所以核心游戏不依赖联网。'

    # 6. Proof of execution with one image and three facts.
    $s = $pres.Slides.Add(6, 12)
    Add-PaperBackground $s
    Add-PictureFit $s $shotMenu 36 88 560 315 | Out-Null
    Add-Text $s '不是概念图。' 628 74 280 38 22 $C.Gray $true | Out-Null
    Add-Text $s '已经有一版' 628 121 280 42 26 $C.Ink $true | Out-Null
    Add-Text $s '能玩的 Demo' 628 166 280 58 34 $C.Coral $true | Out-Null
    Add-Box $s 630 260 7 7 $C.Forest | Out-Null
    Add-Text $s '核心循环跑通' 654 250 230 26 15 $C.Ink $true | Out-Null
    Add-Box $s 630 316 7 7 $C.DarkRed | Out-Null
    Add-Text $s '光子概念赛道银奖' 654 306 250 26 15 $C.Ink $true | Out-Null
    Add-Box $s 630 372 7 7 $C.Coral | Out-Null
    Add-Text $s '2026.12 垂直切片' 654 362 245 26 15 $C.Ink $true | Out-Null
    Add-Text $s '下一步：把“能玩”推进到“能发行”。' 60 446 840 40 22 $C.Ink $true 2 | Out-Null
    Add-PageNumber $s 6
    Add-Note $s '40秒。现在已经有一版可以现场游玩的Demo，核心循环跑通，也获得了2026光子游戏大赛概念赛道银奖。我们不会把规划当成果，下一步是十二月完成垂直切片，再把能玩推进到能发行。'

    # 7. Early signal as large, memorable numbers—no dashboard cards.
    $s = $pres.Slides.Add(7, 12)
    Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-Text $s '19个人试玩后，18个还想继续装修。' 44 34 850 54 30 $C.White $true | Out-Null
    Add-Text $s '19/19' 64 140 230 74 43 $C.White $true | Out-Null
    Add-Text $s '期待后续' 70 218 200 24 13 $C.Pale $false | Out-Null
    Add-Text $s '18/19' 355 140 230 74 43 $C.Gold $true | Out-Null
    Add-Text $s '想继续装修' 362 218 200 24 13 $C.Pale $false | Out-Null
    Add-Text $s '17/19' 650 140 230 74 43 $C.Coral $true | Out-Null
    Add-Text $s '野外体验正向' 657 218 210 24 13 $C.Pale $false | Out-Null
    Add-Box $s 54 304 852 2 $C.Forest | Out-Null
    Add-Text $s '16/19' 64 338 180 54 31 $C.White $true | Out-Null
    Add-Text $s '愿意按同类价格或更高购买' 222 351 420 28 16 $C.White $false | Out-Null
    Add-Text $s '1/19 明确表示不考虑购买或游玩' 652 353 235 24 10 $C.Pale $false 3 | Out-Null
    Add-Text $s 'n=19，偏年轻、偏女性、偏PC玩家；这是早期方向信号，下一步用Steam愿望单与Demo行为继续验证。' 58 445 830 34 10 $C.Pale $false | Out-Null
    Add-PageNumber $s 7 $C.Pale
    Add-Note $s '45秒。19份结构化问卷里，全部期待后续内容，18人想继续装修，17人对野外体验正向，16人对同类价格或更高价格购买持开放态度。样本不大，也偏年轻女性，所以我们把它当作继续验证的信号，不当成市场结论。'

    # 8. One idea only: pre-launch measures demand; post-launch measures sales.
    $s = $pres.Slides.Add(8, 12)
    Add-PaperBackground $s
    Add-Text $s '两个阶段，两套指标' 44 31 780 54 31 $C.Ink $true | Out-Null
    Add-Text $s '发售前验证需求；发售后才验证销量' 47 88 620 28 14 $C.Gray $true | Out-Null

    Add-Box $s 62 146 318 244 $C.White 0.08 $C.Forest | Out-Null
    Add-Box $s 62 146 318 34 $C.Forest | Out-Null
    Add-Text $s '发售前｜Beta结束前' 78 154 286 20 11 $C.White $true | Out-Null
    Add-Text $s '5万' 91 210 146 64 42 $C.Forest $true | Out-Null
    Add-Text $s '愿望单' 213 235 110 28 16 $C.Ink $true | Out-Null
    Add-Text $s '经营观察目标' 92 282 230 26 13 $C.Gray $false | Out-Null
    Add-Box $s 91 326 258 2 $C.Mint | Out-Null
    Add-Text $s '商店页 → Demo → 新品节 / 创作者' 91 343 260 22 11 $C.Ink $true 2 | Out-Null

    Add-Text $s '2028 Q1' 405 214 130 25 13 $C.Coral $true 2 | Out-Null
    Add-Text $s 'Steam 发售' 405 241 130 25 14 $C.Ink $true 2 | Out-Null
    Add-Text $s '→' 424 271 92 54 36 $C.Coral $true 2 | Out-Null

    Add-Box $s 560 146 318 244 $C.White 0.08 $C.Coral | Out-Null
    Add-Box $s 560 146 318 34 $C.Coral | Out-Null
    Add-Text $s '发售后｜首发12个月' 576 154 286 20 11 $C.White $true | Out-Null
    Add-Text $s '15万套' 587 210 225 64 42 $C.Coral $true | Out-Null
    Add-Text $s '基准经营目标' 590 282 230 26 13 $C.Gray $false | Out-Null
    Add-Box $s 590 326 258 2 $C.Gold | Out-Null
    Add-Text $s '销量 / 退款率 / 好评率滚动校准' 590 343 260 22 11 $C.Ink $true 2 | Out-Null

    Add-Text $s '样本参照：团队选取的9款相邻游戏，第三方估算销量中位约6.9万。' 110 442 740 19 10 $C.Ink $true 2 | Out-Null
    Add-Text $s '它不是整个Steam装修市场中位数，也不是本项目销量预测。完整销量情景见隐藏附录。' 110 466 740 18 9 $C.Gray $false 2 | Out-Null
    Add-PageNumber $s 8
    Add-Note $s '40秒。这一页只区分两个阶段。发售前没有销量，我们用商店页、公开Demo和平台活动验证需求，Beta结束前以5万愿望单作为经营观察目标。2028年第一季度发售后，才进入付费销量统计，首发12个月基准经营目标为15万套。6.9万套只是团队选取的9款相邻参考游戏的第三方估算样本中位数，不是Steam装修市场中位数，也不是销量预测。完整情景留在答辩附录。'

    # 9. Team proof is a shared body of work, not a résumé wall.
    $s = $pres.Slides.Add(9, 12)
    Add-Box $s 0 0 $W $H $C.Deep | Out-Null
    Add-PictureFit $s $jam 36 86 510 287 | Out-Null
    Add-PictureFit $s $logo 452 302 88 110 | Out-Null
    Add-Text $s '7个人，已经一起把它做出来了。' 580 68 330 80 29 $C.White $true | Out-Null
    Add-Text $s '2人全职  +  5人阶段投入' 584 168 300 28 15 $C.Gold $true | Out-Null
    Add-Text $s "Game Jam作品`n↓`n可玩Demo与UGDAP试玩`n↓`n19份反馈与光子银奖" 585 230 290 150 17 $C.Pale $true 2 | Out-Null
    Add-Text $s 'GMTK 2025 叙事 #141 / 9562 · Top 1.5%' 60 400 455 22 11 $C.Gold $true 2 | Out-Null
    Add-Text $s '制作 / 策划 / 程序 / 美术 / 动画 / UIUX / 音频' 70 458 820 24 12 $C.Gold $true 2 | Out-Null
    Add-PageNumber $s 9 $C.Pale
    Add-Note $s '40秒。我们不是为比赛临时拼起来的团队。7名核心成员中2人全职、5人按阶段投入，覆盖游戏制作的主要职能。大家一起做过Game Jam作品，也共同把《虫虫家装》推进到Demo、展会试玩、19份反馈和光子银奖。'

    # 10. One funding ask, three tranches, one destination.
    $s = $pres.Slides.Add(10, 12)
    Add-PaperBackground $s
    Add-Text $s '300万' 46 42 350 105 62 $C.Coral $true | Out-Null
    Add-Text $s '把 Demo 做到 Steam 发售的21个月' 54 154 500 42 22 $C.Ink $true | Out-Null
    Add-Text $s '2人全职 + 5人阶段投入｜2026 Q4—2028 Q2' 57 207 500 24 11 $C.Gray $false | Out-Null
    Add-Box $s 610 40 3 410 $C.Forest | Out-Null
    Add-Text $s '120万' 660 72 190 44 29 $C.Ink $true | Out-Null
    Add-Text $s '垂直切片收尾 + Alpha' 660 119 230 22 12 $C.Gray $false | Out-Null
    Add-Text $s '100万' 660 190 190 44 29 $C.DarkRed $true | Out-Null
    Add-Text $s 'Beta内容生产与验证' 660 237 230 22 12 $C.Gray $false | Out-Null
    Add-Text $s '80万' 660 308 190 44 29 $C.Coral $true | Out-Null
    Add-Text $s 'Gold、发售与90天维护' 660 355 230 22 12 $C.Gray $false | Out-Null
    Add-Box $s 52 288 505 4 $C.Forest | Out-Null
    Add-Text $s '2026.12' 48 310 120 24 12 $C.Ink $true | Out-Null
    Add-Text $s '2027' 244 310 90 24 12 $C.Ink $true 2 | Out-Null
    Add-Text $s '2028 Q1' 450 310 110 24 12 $C.Coral $true 3 | Out-Null
    Add-Text $s '垂直切片' 48 344 120 24 15 $C.Ink $true | Out-Null
    Add-Text $s 'Alpha → Beta' 220 344 140 24 15 $C.Ink $true 2 | Out-Null
    Add-Text $s 'Steam发售' 430 344 130 24 15 $C.Coral $true 3 | Out-Null
    Add-Box $s 54 420 502 46 $C.Forest | Out-Null
    Add-Text $s '基准：15万套｜税前回款840万｜累计经营现金净额约400万' 70 433 470 20 11 $C.White $true 2 | Out-Null
    Add-PageNumber $s 10
    Add-Note $s '40秒。我们计划天使轮融资300万元，覆盖从2026年第四季度到2028年第二季度的21个月，一次签署完整承诺，按120万、100万、80万分三期拨付。三期分别对应Alpha、Beta、Gold与发售，每一阶段都有可玩版本、内容产能、市场数据和预算报告作为验收依据。'

    # 11. End on the same emotional image as the opening, with a concrete ask.
    $s = $pres.Slides.Add(11, 12)
    Add-PictureFit $s $cover 0 0 $W $H | Out-Null
    Add-Box $s 0 0 $W $H $C.Deep 0.16 | Out-Null
    Add-Text $s '让这间破木屋，' 50 54 610 52 31 $C.White $true | Out-Null
    Add-Text $s '真正走到 Steam 发售。' 50 106 680 60 35 $C.Gold $true | Out-Null
    Add-Text $s '我们需要' 54 214 120 24 12 $C.Gold $true | Out-Null
    Add-Text $s '发行增长' 54 254 190 36 22 $C.White $true | Out-Null
    Add-Text $s '技术合规' 270 254 190 36 22 $C.White $true | Out-Null
    Add-Text $s '孵化落地' 486 254 190 36 22 $C.White $true | Out-Null
    Add-Box $s 50 336 680 62 $C.Gold 0.02 | Out-Null
    Add-Text $s '融资按协议到位后，项目运营主体迁入南山区。' 68 353 645 28 16 $C.Deep $true 2 | Out-Null
    Add-Box $s 52 438 5 34 $C.Coral | Out-Null
    Add-Text $s '谢谢' 70 442 80 28 16 $C.White $true | Out-Null
    Add-Text $s '甲壳虫工作室 ·《虫虫家装》' 164 445 320 24 12 $C.Gold $true | Out-Null
    Add-Note $s '25秒。我们希望获得发行增长、技术合规和孵化落地三方面支持，把这间破木屋真正推进到Steam发售。本轮300万元融资按协议到位后，项目运营主体迁入南山区，在当地推进研发、知识产权和发行结算。谢谢各位评委。'

    # Keep detailed financial material available for Q&A without putting it in the main flow.
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
