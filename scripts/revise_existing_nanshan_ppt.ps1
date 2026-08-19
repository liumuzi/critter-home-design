param([string]$PptPath = '')

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $PptPath) { $PptPath = Join-Path $repo '比赛材料\2026南山创业之星\虫虫家装_现有路演PPT参考稿.pptx' }
$PptPath = (Resolve-Path $PptPath).Path
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backup = Join-Path (Split-Path $PptPath) ("虫虫家装_现有路演PPT参考稿_修改前备份_$stamp.pptx")
Copy-Item -LiteralPath $PptPath -Destination $backup

$W=3840.0; $H=2160.0
$C=@{ Ink=0x303318; Deep=0x28270F; Forest=0x484B17; Mint=0xB7D677; Cream=0xDEF1F7; Paper=0xF4FDFF; Coral=0x6878EF; Gold=0x68CBEF; White=0xFFFFFF; Gray=0x737765; Pale=0xE4ECDD }
function T($s,$text,$x,$y,$w,$h,$size=48,$color=0x303318,$bold=$false,$align=1){$q=$s.Shapes.AddTextbox(1,$x,$y,$w,$h);$q.TextFrame.MarginLeft=0;$q.TextFrame.MarginRight=0;$q.TextFrame.MarginTop=0;$q.TextFrame.MarginBottom=0;$q.TextFrame.WordWrap=-1;$q.TextFrame.TextRange.Text=$text;$q.TextFrame.TextRange.Font.Name='Microsoft YaHei';$q.TextFrame.TextRange.Font.NameFarEast='Microsoft YaHei';$q.TextFrame.TextRange.Font.Size=$size;$q.TextFrame.TextRange.Font.Color.RGB=$color;$q.TextFrame.TextRange.Font.Bold=$(if($bold){-1}else{0});$q.TextFrame.TextRange.ParagraphFormat.Alignment=$align;return $q}
function B($s,$x,$y,$w,$h,$fill,$round=$true,$line=-1){$q=$s.Shapes.AddShape($(if($round){5}else{1}),$x,$y,$w,$h);$q.Fill.ForeColor.RGB=$fill;if($line -lt 0){$q.Line.Visible=0}else{$q.Line.ForeColor.RGB=$line;$q.Line.Weight=3};return $q}
function ClearSlide($s){for($i=$s.Shapes.Count;$i -ge 1;$i--){$s.Shapes.Item($i).Delete()}}
function Header($s,$n,$tag,$title,$sub=''){T $s $n 170 115 140 70 30 $C.Coral $true|Out-Null;T $s $tag 360 115 800 70 30 $C.Gray $true|Out-Null;T $s $title 170 245 3400 150 80 $C.Ink $true|Out-Null;if($sub){T $s $sub 175 410 3300 80 34 $C.Gray $false|Out-Null};B $s 170 510 3500 8 $C.Mint $false|Out-Null}
function Footer($s,$text){T $s $text 170 2070 2950 38 22 $C.Gray $false|Out-Null;T $s '甲壳虫工作室｜《虫虫家装》' 3170 2070 500 38 22 $C.Gray $false 3|Out-Null}

$app=$null;$p=$null
try{
  $app=New-Object -ComObject PowerPoint.Application
  $p=$app.Presentations.Open($PptPath,$false,$false,$false)

  # Updated n=19 feedback page.
  $s=$p.Slides.Item(12);ClearSlide $s;B $s 0 0 $W $H $C.Cream $false|Out-Null
  Header $s '06' 'EARLY SIGNAL' '19份试玩反馈：方向值得继续验证' '统一更新为n=19；样本偏年轻、偏女性、偏PC玩家，不能外推为整体市场。'
  $stats=@(@('19/19','期待后续内容',$C.Forest),@('18/19','想继续装修',$C.Mint),@('18/19','家园体验正向',$C.Gold),@('16/19','购买意愿开放',$C.Coral))
  for($i=0;$i -lt 4;$i++){$x=180+$i*900;B $s $x 680 790 410 $C.Paper $true $stats[$i][2]|Out-Null;T $s $stats[$i][0] ($x+70) 750 650 150 105 $stats[$i][2] $true|Out-Null;T $s $stats[$i][1] ($x+70) 945 650 70 36 $C.Gray|Out-Null}
  B $s 180 1225 3460 500 $C.Paper $true $C.Pale|Out-Null
  T $s '证据边界' 290 1330 500 80 52 $C.Ink $true|Out-Null
  T $s "• 18/19家园体验正向，17/19野外体验正向`n• 1/19明确表示不考虑购买或游玩`n• 下一步用更大样本、Steam愿望单和Demo行为数据继续验证" 290 1450 3000 220 42 $C.Gray|Out-Null
  Footer $s '来源：团队结构化试玩问卷，n=19，截至2026-08-18；早期方向信号，不是市场验证结论。'

  # CSV evidence page with named samples.
  $s=$p.Slides.Item(15);ClearSlide $s;B $s 0 0 $W $H $C.Cream $false|Out-Null
  Header $s '07' 'MARKET EVIDENCE' '9款Steam相邻产品：我们的销量目标有参照，不是凭空填写' '销量与愿望单为第三方估算快照；用于定义情景区间，不代表Steam官方数据。'
  $games=@(@('Unbox the Room',1.95),@('淘淘旧货铺',3.55),@('观鸟笔记',6.24),@('我的小绿屋',3.13),@('Furnish Master',6.90),@('林间暖巢',8.82),@('呓语小镇',25.83),@('Hozy',32.26),@('Unpacking',66.30))
  T $s '估算累计销量（万套）' 190 620 700 60 38 $C.Ink $true|Out-Null
  for($i=0;$i -lt $games.Count;$i++){$y=730+$i*118;T $s $games[$i][0] 190 $y 640 50 29 $C.Gray $false 3|Out-Null;$bw=[Math]::Max(25,$games[$i][1]*27);B $s 880 ($y+6) $bw 42 $(if($i -eq 5){$C.Coral}else{$C.Forest}) $false|Out-Null;T $s ($games[$i][1].ToString('0.0')+'万') (910+$bw) $y 250 52 28 $C.Ink $true|Out-Null}
  B $s 2720 690 900 980 $C.Paper $true $C.Pale|Out-Null
  T $s '样本结论' 2810 790 650 80 52 $C.Forest $true|Out-Null
  T $s '6.9万套' 2810 920 650 120 90 $C.Gold $true|Out-Null;T $s '销量中位数' 2810 1045 650 55 34 $C.Gray|Out-Null
  T $s '$14.99' 2810 1160 650 120 90 $C.Coral $true|Out-Null;T $s '价格中位数' 2810 1285 650 55 34 $C.Gray|Out-Null
  T $s '经营情景`n保守 5万｜基准 15万｜乐观 25万' 2810 1420 650 150 35 $C.Ink $true|Out-Null
  Footer $s '来源：《参考游戏数据统计 - Steam游戏.csv》；Steam商店标价及第三方市场估算，团队整理，截至2026-08-18。'

  # Wishlist strategy and unit economics.
  $s=$p.Slides.Item(16);ClearSlide $s;B $s 0 0 $W $H $C.Cream $false|Out-Null
  Header $s '08' 'WISHLIST ENGINE' '5万基础愿望单：用真实数据决定发行投入' '这是Beta结束前的经营观察目标，不是融资交付、行业安全线或销量承诺。'
  $steps=@(@('商店页上线','建立基线','标签/素材A-B测试'),@('公开Demo','验证转化','短视频、开发日志、社群'),@('Steam新品节','放大验证','直播、KOL、媒体与玩家扩散'),@('Beta结束','5万','基础经营观察目标'))
  for($i=0;$i -lt 4;$i++){$x=170+$i*900;B $s $x 650 790 420 $(if($i -eq 3){$C.Forest}else{$C.Paper}) $true $(if($i -eq 3){-1}else{$C.Pale})|Out-Null;T $s $steps[$i][0] ($x+60) 715 650 60 42 $(if($i -eq 3){$C.White}else{$C.Ink}) $true|Out-Null;T $s $steps[$i][1] ($x+60) 805 650 100 80 $(if($i -eq 3){$C.Gold}else{$C.Coral}) $true|Out-Null;T $s $steps[$i][2] ($x+60) 945 650 70 30 $(if($i -eq 3){$C.Pale}else{$C.Gray})|Out-Null}
  B $s 170 1220 1700 580 $C.Paper $true $C.Pale|Out-Null
  T $s '营销预算与获客效率' 260 1310 800 70 50 $C.Forest $true|Out-Null
  T $s "总营销预算：60万元`n直接归因测试预算：20万元`n首轮规划：5—12元/愿望单`n预计可归因愿望单：1.7—4万" 260 1435 1450 240 42 $C.Ink|Out-Null
  B $s 1970 1220 1670 580 $C.Paper $true $C.Pale|Out-Null
  T $s '5万基础目标的判断条件' 2060 1310 1050 70 50 $C.Coral $true|Out-Null
  T $s '来源可追踪' 2060 1450 430 70 42 $C.Gray $true|Out-Null;T $s 'Demo行为正向' 2540 1450 430 70 42 $C.Forest $true|Out-Null;T $s '地区与定价匹配' 3020 1450 430 70 42 $C.Coral $true|Out-Null
  T $s '愿望单用于校准发行决策，不以统一转化率承诺销量。' 2060 1600 1350 70 32 $C.Gray|Out-Null
  Footer $s '内部增长模型：目标和转化率均待Steam商店页、Demo及新品节数据逐级校准。'

  # Team page: 7 people.
  $s=$p.Slides.Item(17)
  foreach($sh in $s.Shapes){if($sh.HasTextFrame -eq -1 -and $sh.TextFrame.HasText -eq -1){$sh.TextFrame.TextRange.Text=$sh.TextFrame.TextRange.Text.Replace('8人能力闭环','7人能力闭环').Replace('8人团队','7人团队')}}

  # Funding page rebuilt around 7-person calculation.
  $s=$p.Slides.Item(19);ClearSlide $s;B $s 0 0 $W $H $C.Cream $false|Out-Null
  Header $s '11' 'MILESTONE & FUNDING' '450万元：每一项都能从人数、周期和获客目标复算' '资金覆盖18个月（2026Q4—2028Q1），从Demo产品化推进至发售后3个月。'
  $rows=@(@('7人核心薪酬','7 × 23万/年 × 1.5年','约245万',$C.Forest),@('社保调薪/QA与短期外包','关键缺口与用工缓冲','55万',$C.Mint),@('工具与基础设施','Unity、设备、AI/云服务','35万',$C.Gold),@('发行与增长','物料、创作者、Demo与新品节','60万',$C.Coral),@('法务运营及现金储备','软著、合规、办公与应急','55万',$C.Gray))
  for($i=0;$i -lt 5;$i++){$y=650+$i*215;B $s 180 $y 3460 165 $C.Paper $true $C.Pale|Out-Null;B $s 180 $y 28 165 $rows[$i][3] $false|Out-Null;T $s $rows[$i][0] 260 ($y+42) 900 70 42 $C.Ink $true|Out-Null;T $s $rows[$i][1] 1230 ($y+46) 1450 65 36 $C.Gray|Out-Null;T $s $rows[$i][2] 3000 ($y+40) 500 75 48 $rows[$i][3] $true 3|Out-Null}
  B $s 180 1780 3460 150 $C.Forest $true|Out-Null;T $s '合计' 280 1822 400 65 42 $C.White $true|Out-Null;T $s '450万元' 2900 1810 600 80 58 $C.Gold $true 3|Out-Null
  Footer $s '内部预算模型；薪酬按人均23万元/年估算，实际支出按全职时间、社保与合同安排调整。'

  # Keep the 8-minute main flow to 14 visible slides; retain detail as hidden appendix.
  foreach($i in 1..$p.Slides.Count){$p.Slides.Item($i).SlideShowTransition.Hidden=0}
  foreach($i in @(3,7,9,13,14,18,21,22)){$p.Slides.Item($i).SlideShowTransition.Hidden=-1}

  $p.Save()
  Write-Output "UPDATED=$PptPath"
  Write-Output "BACKUP=$backup"
}
finally{if($p){$p.Close();[System.Runtime.InteropServices.Marshal]::ReleaseComObject($p)|Out-Null};if($app){$app.Quit();[System.Runtime.InteropServices.Marshal]::ReleaseComObject($app)|Out-Null};[GC]::Collect();[GC]::WaitForPendingFinalizers()}
