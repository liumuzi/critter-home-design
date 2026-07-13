---
title: 怪物设计文档 V0.1
path: 戴夫like（光子大赛）/策划案/机制文档说明/怪物设计文档 V0.1
token: XMkddGP65ovf5PxcITbcfM8Onoe
type: docx
---

<title>怪物设计文档 V0.1</title>

# 怪物基础能力&行为

## 视力

怪物具备视野，当玩家出现在视野范围内时，触发怪物警觉，警觉后不同的怪物有不同的行为。

视野有多种形状，目前需制作锥形和圆形两种视野。

- 锥形视野：以怪物自身为中心，视野角度、视野距离支持配置。锥形视野始终朝向怪物面前的方向。锥形视野需要可视化，即玩家可以看到。
- 圆形视野：以怪物自身为中心，视野距离支持配置。圆形视野无方向要求，同样需要可视化。



一个怪物支持配置多种视野类型，配置多种时组合生效

视野范围需要支持墙壁判定，即视野不可穿过障碍物。

（策划备注：野外系统中有相似逻辑功能，可参考调用）

---

## 听力

怪物具备听力，当玩家在听力范围内做出有响动的行为，触发怪物警觉。警觉后不同的怪物有不同的行为。

听力必为以怪物为中心的圆形，且不受墙壁阻隔。每种怪物的听力范围支持配置（圆形半径）。



当前听力设计上仅支持依据是否发出声响，而不依据声音响度。后续支持修改为响度判定。

（策划备注：建议初版开发时就留声音响度的接口）



听觉范围不需要可视化，以一个高透明度且圆周较为明显的圆形作为指示。

---

## 原地静止（基础能力，区别于状态机中的idle态）

原地状态，不位移。

---

## 旋转

怪物以自身为圆心旋转。旋转样式支持曲线配置：

![图片是一张曲线图，横轴为时间t（s），纵轴为角速度ω（rad/s）。图中展示了角速度随时间变化的曲线，曲线呈现阶梯状，从0开始，先上升至正向最大值，随后下降至负向最大值，再回到0，之后重复此过程。该图与上下文紧密相关，是对旋转样式中曲线配置的示例说明，直观呈现了横轴到达最大时间后，角速度按曲线方式运动的情况。](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=NmViYjYyYjViYzQ1NmRhYjA3MzljYWVlZDFjM2NiZDhfYzBkMDJiMGU4NTdlY2JiYjJkMzgwZWUwOGU2MTNmZjhfSUQ6NzYxODYzNTUyMDg5NzI1NjYyOF8xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)

横轴到达最大时间后，返回0点并继续按照曲线方式运动。

旋转可以与移动相叠加，构成巡逻。

---

## 移动

移动是巡逻、追击等状态的底层能力，每帧update移动的速度和方向。



具体的速度大小计算规则为：

需要获取玩家当前速度大小，当前目标速度=玩家当前基础移速\*（100±10）%

公式备注：玩家当前基础移速包括玩家本体速度，叠加鞋子和图腾的移速，主动技能开启疾跑后不包括在内。

100±10%是随机速度范围，支持配置。

追击过程中，每2秒随机一次当前**目标速度**大小。

（策划备注：随机速度的时间间隔需要可调整，后续可能变化为根据与玩家的距离做速度计算）

速度变化的过程中，以最大2m/s²的加速度（支持配置）进行速度变化。

（策划备注：建议补充最低移速和最高移速的功能，保证速度区间在设计范围内；当前的地图单位为worldunit，换算为1WU=1m）

由于怪物移速很快，为了降低难度，需要给怪物设置一定的惯性，设置方法如下：



**目标速度**方向始终朝向当前目标点的最短寻路路径上，但速度实际变化过程中，需要用向量叠加的方式，用加速度来改变速度。

---

## 报警

支持配置一个报警范围，触发报警行为后，n秒内每秒一次，向半径r范围内的所有怪物发出报警信号和玩家位置信息，收到报警信号的怪物立刻将警觉值设为100并向玩家位置展开追击。

单次报警行为持续N秒，这个N支持根据怪物种类进行配置。

---

# 怪物基础状态

## idle态/巡逻态

idle状态即空状态。可以原地静止不动，也可以巡逻，从设计上来说二者处于相同的地位，因此后文的状态机中不会做区分。

或者可以理解成，idle其实就是原地不动的巡逻态。



巡逻：怪物需要初始出生的打点，也就是巡逻的起点。

巡逻有两种模式：折返巡逻和圆周巡逻，支持配置。

折返巡逻，以打点ABCD为例，巡逻点的顺序为A-B-C-D-C-B-A---

圆周巡逻，以打点ABCD为例，巡逻点的顺序为A-B-C-D-A---

每个打点除了支持位置配置外，还要支持在此处停留多久（原地静止）。

巡逻过程的速度就是上文提到的移动，并以下一个打点作为移动的目标点。

巡逻过程中的旋就是上文提到的旋转。



当只配置了A点时，永久在A点静止。

所有巡逻配置中，A点就是该怪物在地图中的出生点。







## 警觉态



首先定义警觉值及其规则：

警觉值是一个正整数，会累计，累计满100点后立刻获取玩家当前位置并展开追击。

当玩家处于视野范围内时，警觉值累计公式为：每秒警觉值累计=（1-玩家与怪物的距离/怪物视野范围） \* 警觉值增加系数

每种怪物支持配置警觉值增加系数。

当玩家处于听觉范围内时，玩家每次发生响动行为，累计n点警觉值。

每种怪物支持配置n。

当警觉值满时，立刻将玩家位置暴露给该怪物，进入追击状态。



警觉值＞0时，开始一个计时，10秒内（支持配置）玩家没有做出让警觉值提升的行为，警觉值开始下降。10秒内若玩家做出了提升警觉值的行为，则保持警觉值为100点，并重置先前的计时。



再定义警觉态：

当警觉值＞0时，立刻停止巡逻的移动和旋转行为，原地静止不动，并将朝向转向沿怪物当前位置到玩家当前位置的路径方向。



警觉值需要一个可视化UI，提示100的充能进度。

警觉值=0时，不显示该UI

0＜警觉值＜100时，UI为一个按比例充能的问号。

警觉值=100时，UI显示一个叹号。





## 追击

警觉值达到100时，触发追击行为，以前文提到的基础移动方式，持续向玩家当前位置寻路前进。



10秒到时，警觉值由100开始下降，暂定5点/秒，支持配置。

警觉值＜100时，进入搜索状态。

警觉值≥100时，持续追击状态。





## 搜索

警觉值掉下100时，以玩家当前位置为圆心，30m为半径，开始搜索行为。

在半径30m的圆周上随机取点，并向该点寻路，并保持听力和视力搜寻玩家。

第一次取点无规则限制，第二次及以后的取点，要和前一个点至少间隔60°（左右两边，共120°，这个值要支持配置）



搜索过程中玩家行为也会正常累计警觉值，如果警觉值回到100则进入追击状态。

搜索过程的速度大小也使用追击状态下的随机公式。

 

警觉值归零后，进入返回阶段。



## 返回

怪物从当前位置，开始寻路并返回初始地图打点的生成位置。回点后，返回idle态。

---

# 怪物设计与状态机



怪物形象设计为，被植物感染的小动物/昆虫。

（策划备注：此设计当前已重构）



## 怪物A

![图片展示的是怪物A的形象设计，为被寄生的鸟类。其身体呈灰黑色，长有长喙，头顶寄生着形似木耳的白色物体，眼神突出。上下文提到怪物A是视觉怪，强调眼睛，具有20m、90°的锥形视野范围和5m的听觉范围，视觉警戒值增加系数为33，听觉警戒值单次增加值为30 。怪物B的形象设计可以上述怪物A图片为原型，是被木耳感染的昆虫，并强化木耳概念。](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=NWYyMGJhYjcxNDUzOGFkMzNkYjMwNmFkYmY4ZmRmODBfM2Y3YWZjZWFhMjI2NmY3Mzg2N2NlOTQ1YzM5MTdiNzFfSUQ6NzYxODY0NTQ3OTcxNDI5NDk3Ml8xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)

怪物形象设计：被寄生的鸟类，鸟类一般视觉较好，作为一只视觉怪，强调一下眼睛。



视觉类型，存在较远锥形视野范围和较弱的听觉范围。

视觉范围：锥形视野，20m，90°

听觉范围：5m



视觉警戒值增加系数：33

听觉警戒值单次增加值：30



状态机：

![图片展示的是怪物状态机。包含idle/巡逻、警觉态、追击态、搜索态四个状态。idle/巡逻状态下，警觉值增加时进入警觉态，警觉值归零且寻路返回时回到idle/巡逻状态；警觉态下，警觉 addCriterion图片展示的是怪物状态机。包含idle/巡逻、警觉态、追击态、搜索态四个状态。idle/巡逻状态下，警觉值增加时进入警觉态，警觉值归零且寻箭头指向的寻路返回时回到idle/巡逻状态；警觉态下，警觉值满100时进入追击态，不满100时回到有箭头指向的 addCriterion图片 addCriterion图片展示的是](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZDI5MzAxYjAxZjcyOTQyY2ZmZjliZGI4Y2M2ZmViNGJfZjE3MzhjYTU4YTk1MTc3NWFmNTQ1OTBmM2ZiOTE1NWJfSUQ6NzYxODY0MjA2NTQ0NzUyMTIxOF8xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)







## 怪物B

![图片展示了一只被木耳感染的的昆虫形象，作为怪物B0的原型。昆虫身体呈蓝绿色，头部有红色触角，身上长有橙色、黄色的蘑菇状物体。其视觉范围为锥形视野，5m，120° addCriterion°](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=N2M5OWY2ZmFjZDYzMzllMTA5NTQ0MDlmMGE0OWYzZTRfMDI3NzBlMWMyNGRmNjcwNWUxYTA2YWRkMGVhOTU2YWRfSUQ6NzYxODY0NTc0NjMwMDA3OTA0NF8xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)

怪物形象设计：可以以上图为原型，被木耳感染的某种昆虫，因为强调是听觉怪，所以木耳这个概念设计可以进行一定程度的强化。



存在较强听觉范围和较近的锥形视野范围

视觉范围：锥形视野，5m，120°

听觉范围：15m



视觉警戒值增加系数：20

听觉警戒值单次增加值：50



状态机：

![图片展示的是怪物C的状态机。状态机包含idle/巡逻、警觉态、追击态和搜索态四个状态。idle/巡逻状态下，警觉值增加时进入警觉态，警觉值归零且寻路 addCriterion\[heading1\]](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ODUwY2Y4MTA0NjNmNWMyZTg3MjU1ZmM4YjNmNjY1NTBfMjk3MzMyOWEzMDhkZWJlY2U4ZTdkZDg3Yjk3MGZiZWNfSUQ6NzYxODY0MjUyNjAyMjUxOTc2NF8xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)



## 怪物C

![图片展示的是一只蛐蛐，其身体呈棕褐色，有着细长的触角，背部纹理清晰，后腿较为粗壮且布满尖刺。这张图片位于怪物设计文档中关于怪物C的描述部分，上下文提到怪物C的形象设计为被蘑菇感染的蛐蛐，此图片即为蛐蛐的原型，可作为怪物C基础形象设计的参考，后续可在此基础上添加蘑菇感染相关元素以完成怪物C的设计。](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=Mjk3OGQ2MTlkNWYyM2Q0ODY0Y2M2ZDBlMTU3N2IzOTdfZTYyZWUxZWYzMjFiMDQyOThhNzVjODVlMGQ1YmRkMjhfSUQ6NzYxODY0NTI1MzY4NzQ5NTYyMF8xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)



怪物形象设计：被蘑菇感染的蛐蛐。这个怪主要是警戒并报警给其他怪物，蘑菇可以做成类似雷达的样子？蛐蛐叫声很大，用来通知周围的怪物。



原地报警的怪物。存在中等听觉和较近的圆形视野。

视觉范围：圆形视野，7m

听觉范围：10m



视觉警戒值增加系数：30

听觉警戒值单次增加值：40



报警持续时间：10秒



状态机：

![图片展示的是](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZTgxMzcwMzY1ZjA0MDBkNDc3ZGNlNWI0YjllZTcwNTJfYzhlYWMxZTE1NzYzNjdmMjBmYWUyNmY2ZTg5NGExMThfSUQ6NzYxODY0NDM4MDE5MDE2NjIzM18xNzgzOTM2NTczOjE3ODM5NDAxNzNfVjM)
