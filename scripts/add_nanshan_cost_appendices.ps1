param([string]$PptPath='')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if(-not $PptPath){$PptPath=Join-Path $repo '比赛材料\2026南山创业之星\虫虫家装_现有路演PPT参考稿.pptx'}
$PptPath=(Resolve-Path $PptPath).Path
$backup=Join-Path (Split-Path $PptPath) ('虫虫家装_现有路演PPT参考稿_成本改版前备份_'+(Get-Date -Format 'yyyyMMdd_HHmmss')+'.pptx')
Copy-Item -LiteralPath $PptPath -Destination $backup
$W=3840.0;$H=2160.0;$C=@{Ink=0x303318;Deep=0x28270F;Forest=0x484B17;Mint=0xB7D677;Cream=0xDEF1F7;Paper=0xF4FDFF;Coral=0x6878EF;Gold=0x68CBEF;White=0xFFFFFF;Gray=0x737765;Pale=0xE4ECDD}
function T($s,$text,$x,$y,$w,$h,$size=48,$color=0x303318,$bold=$false,$align=1){$q=$s.Shapes.AddTextbox(1,$x,$y,$w,$h);$q.TextFrame.MarginLeft=0;$q.TextFrame.MarginRight=0;$q.TextFrame.MarginTop=0;$q.TextFrame.MarginBottom=0;$q.TextFrame.WordWrap=-1;$q.TextFrame.TextRange.Text=$text;$q.TextFrame.TextRange.Font.Name='Microsoft YaHei';$q.TextFrame.TextRange.Font.NameFarEast='Microsoft YaHei';$q.TextFrame.TextRange.Font.Size=$size;$q.TextFrame.TextRange.Font.Color.RGB=$color;$q.TextFrame.TextRange.Font.Bold=$(if($bold){-1}else{0});$q.TextFrame.TextRange.ParagraphFormat.Alignment=$align;return $q}
function B($s,$x,$y,$w,$h,$fill,$round=$true,$line=-1){$q=$s.Shapes.AddShape($(if($round){5}else{1}),$x,$y,$w,$h);$q.Fill.ForeColor.RGB=$fill;if($line -lt 0){$q.Line.Visible=0}else{$q.Line.ForeColor.RGB=$line;$q.Line.Weight=3};return $q}
function ClearSlide($s){for($i=$s.Shapes.Count;$i -ge 1;$i--){$s.Shapes.Item($i).Delete()}}
function Header($s,$num,$title,$sub=''){T $s $num 170 115 160 70 30 $C.Coral $true|Out-Null;T $s 'APPENDIX' 370 115 650 70 30 $C.Gray $true|Out-Null;T $s $title 170 245 3450 140 74 $C.Ink $true|Out-Null;if($sub){T $s $sub 175 410 3300 70 32 $C.Gray|Out-Null};B $s 170 510 3500 8 $C.Mint $false|Out-Null}
function Footer($s,$text){T $s $text 170 2070 3000 38 21 $C.Gray|Out-Null;T $s '甲壳虫工作室｜《虫虫家装》' 3170 2070 500 38 21 $C.Gray $false 3|Out-Null}

$app=$null;$p=$null
try{
 $app=New-Object -ComObject PowerPoint.Application;$p=$app.Presentations.Open($PptPath,$false,$false,$false)
 $wish=$null;$fund=$null
 foreach($sl in $p.Slides){$txt='';foreach($sh in $sl.Shapes){if($sh.HasTextFrame -eq -1-and $sh.TextFrame.HasText -eq -1){$txt+=' '+$sh.TextFrame.TextRange.Text}};if($txt-match 'WISHLIST ENGINE'){$wish=$sl};if($txt-match '每一项都能从人数'){$fund=$sl}}
 if(-not $wish-or-not $fund){throw 'Main wishlist/funding slides not found'}

 # Rebuild wishlist page with evidence-based paid CAC.
 ClearSlide $wish;B $wish 0 0 $W $H $C.Cream $false|Out-Null
 T $wish '08' 170 115 140 70 30 $C.Coral $true|Out-Null;T $wish 'WISHLIST ENGINE' 360 115 900 70 30 $C.Gray $true|Out-Null
 T $wish '5万基础愿望单：用真实数据决定发行投入' 170 245 3400 140 78 $C.Ink $true|Out-Null
 T $wish '这是Beta结束前的经营观察目标，不是融资交付、行业安全线或销量承诺。' 175 410 3300 70 32 $C.Gray|Out-Null;B $wish 170 510 3500 8 $C.Mint $false|Out-Null
 $steps=@(@('商店页上线','建立基线','素材与标签测试'),@('公开Demo','验证转化','短视频、开发日志、社群'),@('Steam新品节','放大验证','直播、KOL与媒体扩散'),@('Beta结束','5万','基础经营观察目标'))
 for($i=0;$i-lt4;$i++){$x=170+$i*900;B $wish $x 650 790 400 $(if($i-eq3){$C.Forest}else{$C.Paper}) $true $(if($i-eq3){-1}else{$C.Pale})|Out-Null;T $wish $steps[$i][0] ($x+60) 710 650 55 40 $(if($i-eq3){$C.White}else{$C.Ink}) $true|Out-Null;T $wish $steps[$i][1] ($x+60) 805 650 95 75 $(if($i-eq3){$C.Gold}else{$C.Coral}) $true|Out-Null;T $wish $steps[$i][2] ($x+60) 930 650 65 29 $(if($i-eq3){$C.Pale}else{$C.Gray})|Out-Null}
 B $wish 170 1180 1680 600 $C.Paper $true $C.Pale|Out-Null;T $wish '付费CAC：先测，再放大' 260 1270 900 70 50 $C.Forest $true|Out-Null
 T $wish "公开案例：约4—18元/愿望单`n内部首轮规划：5—12元/个`n直接归因测试预算：20万元`n预计可归因愿望单：1.7—4万" 260 1400 1400 280 42 $C.Ink|Out-Null
 B $wish 1970 1180 1670 600 $C.Paper $true $C.Pale|Out-Null;T $wish '5万基础目标的判断条件' 2060 1270 1100 70 50 $C.Coral $true|Out-Null
 T $wish '来源可追踪' 2060 1430 430 70 42 $C.Gray $true|Out-Null;T $wish 'Demo行为正向' 2540 1430 430 70 42 $C.Forest $true|Out-Null;T $wish '地区与定价匹配' 3020 1430 430 70 42 $C.Coral $true|Out-Null
 T $wish '愿望单用于校准发行决策，不以统一转化率承诺销量。' 2060 1580 1350 100 32 $C.Gray|Out-Null
 Footer $wish '公开案例为开发者/服务商复盘；项目CAC须用Steamworks UTM和总愿望单增量实测。'

 # Rebuild funding page for 2 full-time + 5 part-time, total 300.
 ClearSlide $fund;B $fund 0 0 $W $H $C.Cream $false|Out-Null
 T $fund '11' 170 115 140 70 30 $C.Coral $true|Out-Null;T $fund 'MILESTONE & FUNDING' 360 115 1100 70 30 $C.Gray $true|Out-Null
 T $fund '融资300万元：按2人全职、5人兼职重算' 170 245 3400 140 78 $C.Ink $true|Out-Null
 T $fund '18个月（2026Q4—2028Q1）；每个数字均由市场价、工作量与缓冲假设组成。' 175 410 3300 70 32 $C.Gray|Out-Null;B $fund 170 510 3500 8 $C.Mint $false|Out-Null
 $rows=@(@('2人全职薪酬及单位成本','2 × 1.5万/月 × 18月 + 约27%用工附加','69万',$C.Forest),@('5人兼职阶段报酬','按岗位交付物与验收节点','40万',$C.Mint),@('QA/本地化/内容外包','QA 6 + 本地化 6 + 峰值内容12','24万',$C.Gold),@('工具、设备及AI/云','Unity Pro、设备、服务与授权','25万',$C.Gray),@('发行与增长','其中20万用于可归因付费测试','60万',$C.Coral),@('法务、运营与储备','法务运营17 + 风险/管理缓冲65','82万',$C.Gray))
 for($i=0;$i-lt6;$i++){$y=620+$i*205;B $fund 180 $y 3460 155 $C.Paper $true $C.Pale|Out-Null;B $fund 180 $y 28 155 $rows[$i][3] $false|Out-Null;T $fund $rows[$i][0] 260 ($y+38) 1050 65 39 $C.Ink $true|Out-Null;T $fund $rows[$i][1] 1370 ($y+42) 1450 60 33 $C.Gray|Out-Null;T $fund $rows[$i][2] 3050 ($y+35) 450 70 44 $rows[$i][3] $true 3|Out-Null}
 B $fund 180 1900 3460 120 $C.Forest $true|Out-Null;T $fund '合计' 280 1930 400 55 38 $C.White $true|Out-Null;T $fund '300万元' 2940 1920 560 65 50 $C.Gold $true 3|Out-Null
 Footer $fund '详细假设、市场价及250/300/350万元三档方案见附录与《南山半决赛_成本与获客核算明细.md》。'

 # Appendix A1: full reference table.
 $s=$p.Slides.Add($p.Slides.Count+1,12);B $s 0 0 $W $H $C.Cream $false|Out-Null;Header $s 'A1' 'Steam参考游戏原始样本' '愿望单、销量及收入均为第三方估算快照；价格为采集时Steam商店标价。'
 $hdr=@('游戏','愿望单','估算销量','价格','备注');$xs=@(180,1370,1980,2570,2950);$ws=@(1120,520,520,300,690)
 for($i=0;$i-lt5;$i++){B $s $xs[$i] 600 $ws[$i] 100 $C.Forest $false|Out-Null;T $s $hdr[$i] ($xs[$i]+25) 628 ($ws[$i]-50) 45 30 $C.White $true $(if($i-eq0-or$i-eq4){1}else{2})|Out-Null}
 $data=@(@('Unbox the Room','29,380','19,490','$7.99','2D像素'),@('淘淘旧货铺','84,890','35,480','$12.99','2D像素复古'),@('观鸟笔记','104,790','62,370','$9.99','装修+放置'),@('我的小绿屋','112,190','31,320','$11.99','3D'),@('Furnish Master','256,430','68,950','$14.99','3D'),@('林间暖巢','407,550','88,180','$19.98','2D'),@('呓语小镇','466,430','258,290','$14.99','主要愿望单参照'),@('Hozy','574,780','322,620','$14.99','3D'),@('Unpacking','904,070','663,040','$19.99','品类头部'))
 for($r=0;$r-lt$data.Count;$r++){$y=700+$r*135;$fill=$(if($r-eq6){0xE4ECDD}else{$C.Paper});for($i=0;$i-lt5;$i++){B $s $xs[$i] $y $ws[$i] 125 $fill $false $C.Pale|Out-Null;T $s $data[$r][$i] ($xs[$i]+20) ($y+35) ($ws[$i]-40) 55 27 $(if($r-eq6){$C.Coral}else{$C.Ink}) $(if($r-eq6){$true}else{$false}) $(if($i-eq0-or$i-eq4){1}else{2})|Out-Null}}
 T $s '相邻玩法补充：潜水员戴夫 244万愿望单/517万估算销量；逃离鸭科夫 141万愿望单/449万估算销量。两者不进入9款装修样本中位数。' 180 1950 3450 60 27 $C.Gray|Out-Null
 Footer $s '来源：《参考游戏数据统计 - Steam游戏.csv》，团队整理，截至2026-08-18；非Steam官方销量。';$s.SlideShowTransition.Hidden=-1

 # Appendix A2: cost table.
 $s=$p.Slides.Add($p.Slides.Count+1,12);B $s 0 0 $W $H $C.Cream $false|Out-Null;Header $s 'A2' '300万元预算：市场价 × 工作量 × 周期' '推荐基准；精益下限250万元，若第3人转全职或增加移植/内容外包，上限350万元。'
 $cost=@(@('2人全职工资','2 × 1.5万 × 18月','54'),@('单位用工附加','工资 × 约27%','15'),@('5人兼职','岗位交付物预算','40'),@('QA','60人天 × 800元','6'),@('本地化与LQA','3万字 × 英/日 + LQA','6'),@('峰值内容外包','最多3—4批','12'),@('工具设备及AI/云','明细预算','25'),@('发行与增长','付费测试20万在内','60'),@('法务基础运营','合同/软著/财税等','17'),@('现金与管理缓冲','里程碑后释放','65'))
 B $s 170 580 3480 110 $C.Forest $false|Out-Null;T $s '科目' 200 610 1100 55 32 $C.White $true|Out-Null;T $s '公式/假设' 1400 610 1500 55 32 $C.White $true|Out-Null;T $s '万元' 3150 610 400 55 32 $C.White $true 3|Out-Null
 for($r=0;$r-lt$cost.Count;$r++){$y=700+$r*120;B $s 170 $y 3480 110 $(if($r%2-eq0){$C.Paper}else{0xE4ECDD}) $false|Out-Null;T $s $cost[$r][0] 220 ($y+30) 1050 50 29 $C.Ink $(if($r-lt2){$true}else{$false})|Out-Null;T $s $cost[$r][1] 1400 ($y+30) 1450 50 29 $C.Gray|Out-Null;T $s $cost[$r][2] 3150 ($y+25) 350 55 34 $(if($r-eq7){$C.Coral}else{$C.Forest}) $true 3|Out-Null}
 B $s 170 1920 3480 100 $C.Forest $false|Out-Null;T $s '合计' 220 1945 500 50 32 $C.White $true|Out-Null;T $s '300' 3150 1940 350 55 38 $C.Gold $true 3|Out-Null;Footer $s '完整市场价、来源和风险说明见《南山半决赛_成本与获客核算明细.md》。';$s.SlideShowTransition.Hidden=-1

 # Appendix A3: public paid wishlist benchmarks.
 $s=$p.Slides.Add($p.Slides.Count+1,12);B $s 0 0 $W $H $C.Cream $false|Out-Null;Header $s 'A3' '付费愿望单CAC：公开案例约4—18元/个' '不存在Valve官方行业均价；不同品类、地区、素材、商店页和归因方法会造成数量级差异。'
 $cases=@(@('Yes, My Queen','Reddit广告','$0.60','开发者复盘'),@("Loki's Revenge",'Reddit广告','$0.73','开发者复盘'),@('独立开发者案例','Facebook','$0.90','开发者复盘'),@('This Grand Life 2','Reddit广告','$0.80—2.50','完整复盘'),@('Danchi Days','Reddit广告','$1.70—2.20','长期复盘'),@('The Bus','创作者短视频','$0.15','服务商优秀个案'))
 $heads=@('案例','渠道','成本/愿望单','证据性质');$xs=@(180,1350,2250,2950);$ws=@(1100,800,620,690)
 for($i=0;$i-lt4;$i++){B $s $xs[$i] 630 $ws[$i] 110 $C.Forest $false|Out-Null;T $s $heads[$i] ($xs[$i]+25) 662 ($ws[$i]-50) 45 31 $C.White $true $(if($i-eq0-or$i-eq3){1}else{2})|Out-Null}
 for($r=0;$r-lt$cases.Count;$r++){$y=750+$r*170;for($i=0;$i-lt4;$i++){B $s $xs[$i] $y $ws[$i] 155 $(if($r%2-eq0){$C.Paper}else{0xE4ECDD}) $false|Out-Null;T $s $cases[$r][$i] ($xs[$i]+25) ($y+48) ($ws[$i]-50) 55 31 $(if($i-eq2){$C.Coral}else{$C.Ink}) $(if($i-eq2){$true}else{$false}) $(if($i-eq0-or$i-eq3){1}else{2})|Out-Null}}
 B $s 180 1820 3460 180 $C.Deep $true|Out-Null;T $s '本项目首轮：按5—12元/个规划，20万元预算预计获得1.7—4万可归因愿望单；达不到阈值就停止扩量。' 270 1872 3280 70 38 $C.White $true 2|Out-Null
 Footer $s '来源链接与归因限制详见成本核算Markdown；Steam UTM只覆盖满足追踪条件的部分转化。';$s.SlideShowTransition.Hidden=-1

 $p.Save();Write-Output "UPDATED=$PptPath";Write-Output "BACKUP=$backup"
}finally{
 if($p){try{$p.Close()}catch{};[Runtime.InteropServices.Marshal]::ReleaseComObject($p)|Out-Null}
 if($app){try{$app.Quit()}catch{};[Runtime.InteropServices.Marshal]::ReleaseComObject($app)|Out-Null}
 [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
