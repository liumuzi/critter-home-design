# 《虫虫装修》项目概览 One-Page

> **面向对象**：团队内部开发人员（美术、音乐及新加入成员）
> **文档目的**：明确项目方向、核心玩法及游戏架构，帮助团队快速理解游戏整体概况

---

## 一、我们的初心：为什么要做这款游戏？

### 核心情感体验

**在荒芜中经营希望与羁绊**——这是一款主打**极致治愈**和**情绪价值**的游戏。

我们想要传递的体验：
- 🏠 **装修的温暖**：在末日废土中，一点点把冰冷的废墟填满温度
- 💝 **供养的满足**：作为最弱小的瓢虫，却是最伟大的守护者
- 🤝 **陪伴的羁绊**：与AI小动物建立真实的情感连接，每一件家具都承载着回忆

### 核心吸引力

```svg
<svg viewBox="0 0 800 300" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="800" height="300" fill="#f8f9fa"/>

  <!-- Title -->
  <text x="400" y="35" font-size="24" font-weight="bold" text-anchor="middle" fill="#2c3e50">
    核心吸引力三角
  </text>

  <!-- Triangle -->
  <polygon points="400,80 200,250 600,250" fill="none" stroke="#3498db" stroke-width="3"/>

  <!-- Nodes -->
  <circle cx="400" cy="80" r="50" fill="#e74c3c" opacity="0.9"/>
  <circle cx="200" cy="250" r="50" fill="#2ecc71" opacity="0.9"/>
  <circle cx="600" cy="250" r="50" fill="#f39c12" opacity="0.9"/>

  <!-- Labels -->
  <text x="400" y="75" font-size="16" font-weight="bold" text-anchor="middle" fill="white">极致反差</text>
  <text x="400" y="95" font-size="12" text-anchor="middle" fill="white">外险内暖</text>

  <text x="200" y="245" font-size="16" font-weight="bold" text-anchor="middle" fill="white">供养感</text>
  <text x="200" y="265" font-size="12" text-anchor="middle" fill="white">双向救赎</text>

  <text x="600" y="245" font-size="16" font-weight="bold" text-anchor="middle" fill="white">活着的羁绊</text>
  <text x="600" y="265" font-size="12" text-anchor="middle" fill="white">AI情感养成</text>
</svg>
```

---

## 二、游戏是什么？一句话说明

**一款融合"家园装修 × 野外探索 × AI情感叙事"的模拟经营休闲游戏**

玩家扮演一只瓢虫，在人类离去后的"静止"世界中，冒险探索废墟收集资源，为收养的水獭一家装修温暖的家园，在危险的废土上建立情感羁绊。

---

## 三、核心玩法循环

```svg
<svg viewBox="0 0 900 400" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="900" height="400" fill="#f8f9fa"/>

  <!-- Title -->
  <text x="450" y="35" font-size="24" font-weight="bold" text-anchor="middle" fill="#2c3e50">
    核心游戏循环
  </text>

  <!-- Main Loop Circle -->
  <circle cx="450" cy="220" r="140" fill="none" stroke="#95a5a6" stroke-width="2" stroke-dasharray="5,5"/>

  <!-- Step 1: 探索 -->
  <circle cx="450" cy="80" r="45" fill="#e74c3c" opacity="0.9"/>
  <text x="450" y="80" font-size="18" font-weight="bold" text-anchor="middle" fill="white">野外探索</text>
  <text x="450" y="100" font-size="12" text-anchor="middle" fill="white">收集·冒险</text>

  <!-- Step 2: 制作 -->
  <circle cx="650" cy="180" r="45" fill="#3498db" opacity="0.9"/>
  <text x="650" y="180" font-size="18" font-weight="bold" text-anchor="middle" fill="white">工作台</text>
  <text x="650" y="200" font-size="12" text-anchor="middle" fill="white">合成·制作</text>

  <!-- Step 3: 装修 -->
  <circle cx="550" cy="330" r="45" fill="#f39c12" opacity="0.9"/>
  <text x="550" y="330" font-size="18" font-weight="bold" text-anchor="middle" fill="white">装修布置</text>
  <text x="550" y="350" font-size="12" text-anchor="middle" fill="white">摆放·美化</text>

  <!-- Step 4: 互动 -->
  <circle cx="350" cy="330" r="45" fill="#2ecc71" opacity="0.9"/>
  <text x="350" y="330" font-size="18" font-weight="bold" text-anchor="middle" fill="white">情感互动</text>
  <text x="350" y="350" font-size="12" text-anchor="middle" fill="white">对话·送礼</text>

  <!-- Step 5: 成长 -->
  <circle cx="250" cy="180" r="45" fill="#9b59b6" opacity="0.9"/>
  <text x="250" y="180" font-size="18" font-weight="bold" text-anchor="middle" fill="white">解锁成长</text>
  <text x="250" y="200" font-size="12" text-anchor="middle" fill="white">能力·区域</text>

  <!-- Arrows -->
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="#34495e"/>
    </marker>
  </defs>

  <path d="M 480,115 L 620,155" stroke="#34495e" stroke-width="3" fill="none" marker-end="url(#arrowhead)"/>
  <path d="M 640,225 L 580,295" stroke="#34495e" stroke-width="3" fill="none" marker-end="url(#arrowhead)"/>
  <path d="M 515,330 L 390,330" stroke="#34495e" stroke-width="3" fill="none" marker-end="url(#arrowhead)"/>
  <path d="M 320,305 L 280,210" stroke="#34495e" stroke-width="3" fill="none" marker-end="url(#arrowhead)"/>
  <path d="M 280,150 L 420,100" stroke="#34495e" stroke-width="3" fill="none" marker-end="url(#arrowhead)"/>
</svg>
```

### 循环说明

1. **野外探索**：玩家前往废墟探索，收集家具、材料和饰品，躲避变异植物的追击
2. **工作台制作**：使用收集的材料，在工作台合成更高级的家具
3. **装修布置**：为小动物们布置温馨的房间，提升家园舒适度
4. **情感互动**：与小动物对话、送礼，提升信任度，解锁剧情
5. **解锁成长**：通过信任度和任务，解锁新能力、新区域、新小动物

---

## 四、游戏世界观

### 时空背景

**人类离去后的"静止"世界**
- 到处是废墟和不再运转的机械
- 自然重新占领世界，一切被绿色覆盖
- 变异植物在此生根，充满资源也充满危险

### 角色设定

**玩家**：一只瓢虫，弱小但勇敢，作为"连接者"将废墟的遗留物变成小动物生活的一部分

**小动物**：以水獭一家为例
- 哥哥：外向乐观、收集癖、凑活就行
- 妹妹：外表强壮内心温柔、喜欢可爱的东西、怕黑
- 姐姐：外表小巧内心强大、真正的靠山

---

## 五、游戏系统架构图

```svg
<svg viewBox="0 0 1000 700" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="1000" height="700" fill="#f8f9fa"/>

  <!-- Title -->
  <text x="500" y="35" font-size="26" font-weight="bold" text-anchor="middle" fill="#2c3e50">
    游戏系统架构
  </text>

  <!-- Main Systems -->
  <rect x="50" y="70" width="400" height="280" fill="#e8f4f8" stroke="#3498db" stroke-width="3" rx="10"/>
  <text x="250" y="100" font-size="22" font-weight="bold" text-anchor="middle" fill="#2c3e50">野外探索系统</text>

  <rect x="550" y="70" width="400" height="280" fill="#f0f8e8" stroke="#2ecc71" stroke-width="3" rx="10"/>
  <text x="750" y="100" font-size="22" font-weight="bold" text-anchor="middle" fill="#2c3e50">家园经营系统</text>

  <!-- 野外系统模块 -->
  <rect x="70" y="130" width="160" height="70" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="150" y="160" font-size="14" font-weight="bold" text-anchor="middle" fill="white">采集系统</text>
  <text x="150" y="180" font-size="11" text-anchor="middle" fill="white">开宝箱收集家具材料</text>

  <rect x="270" y="130" width="160" height="70" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="350" y="160" font-size="14" font-weight="bold" text-anchor="middle" fill="white">追逐战斗</text>
  <text x="350" y="180" font-size="11" text-anchor="middle" fill="white">躲避变异植物追击</text>

  <rect x="70" y="220" width="160" height="70" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="150" y="250" font-size="14" font-weight="bold" text-anchor="middle" fill="white">背包管理</text>
  <text x="150" y="270" font-size="11" text-anchor="middle" fill="white">负重影响移速和隐蔽</text>

  <rect x="270" y="220" width="160" height="70" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="350" y="250" font-size="14" font-weight="bold" text-anchor="middle" fill="white">主角能力</text>
  <text x="350" y="270" font-size="11" text-anchor="middle" fill="white">隐身·护甲·图腾·饰品</text>

  <!-- 家园系统模块 -->
  <rect x="570" y="130" width="160" height="70" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="650" y="160" font-size="14" font-weight="bold" text-anchor="middle" fill="white">装修系统</text>
  <text x="650" y="180" font-size="11" text-anchor="middle" fill="white">家具摆放与风格搭配</text>

  <rect x="770" y="130" width="160" height="70" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="850" y="160" font-size="14" font-weight="bold" text-anchor="middle" fill="white">工作台</text>
  <text x="850" y="180" font-size="11" text-anchor="middle" fill="white">合成升级家具</text>

  <rect x="570" y="220" width="160" height="70" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="650" y="250" font-size="14" font-weight="bold" text-anchor="middle" fill="white">小动物互动</text>
  <text x="650" y="270" font-size="11" text-anchor="middle" fill="white">对话·送礼·AI情感</text>

  <rect x="770" y="220" width="160" height="70" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="850" y="250" font-size="14" font-weight="bold" text-anchor="middle" fill="white">信任系统</text>
  <text x="850" y="270" font-size="11" text-anchor="middle" fill="white">解锁剧情与新内容</text>

  <!-- 共享系统 -->
  <text x="500" y="390" font-size="22" font-weight="bold" text-anchor="middle" fill="#2c3e50">核心共享系统</text>

  <rect x="100" y="420" width="180" height="90" fill="#f39c12" opacity="0.8" rx="5"/>
  <text x="190" y="450" font-size="16" font-weight="bold" text-anchor="middle" fill="white">任务系统</text>
  <text x="190" y="475" font-size="12" text-anchor="middle" fill="white">主线·支线·信任任务</text>
  <text x="190" y="495" font-size="11" text-anchor="middle" fill="white">驱动游戏进度推进</text>

  <rect x="320" y="420" width="180" height="90" fill="#9b59b6" opacity="0.8" rx="5"/>
  <text x="410" y="450" font-size="16" font-weight="bold" text-anchor="middle" fill="white">物品系统</text>
  <text x="410" y="475" font-size="12" text-anchor="middle" fill="white">家具·饰品·材料</text>
  <text x="410" y="495" font-size="11" text-anchor="middle" fill="white">统一管理所有道具</text>

  <rect x="540" y="420" width="180" height="90" fill="#e67e22" opacity="0.8" rx="5"/>
  <text x="630" y="450" font-size="16" font-weight="bold" text-anchor="middle" fill="white">成长系统</text>
  <text x="630" y="475" font-size="12" text-anchor="middle" fill="white">能力养成·区域解锁</text>
  <text x="630" y="495" font-size="11" text-anchor="middle" fill="white">提供长线目标</text>

  <rect x="760" y="420" width="180" height="90" fill="#1abc9c" opacity="0.8" rx="5"/>
  <text x="850" y="450" font-size="16" font-weight="bold" text-anchor="middle" fill="white">怪物AI</text>
  <text x="850" y="475" font-size="12" text-anchor="middle" fill="white">视野·听觉·追击</text>
  <text x="850" y="495" font-size="11" text-anchor="middle" fill="white">提供探索张力</text>

  <!-- 底层技术支撑 -->
  <rect x="200" y="560" width="600" height="80" fill="#34495e" opacity="0.9" rx="5"/>
  <text x="500" y="590" font-size="18" font-weight="bold" text-anchor="middle" fill="white">AI技术支撑层</text>
  <text x="500" y="615" font-size="13" text-anchor="middle" fill="white">AI对话生成 · AI情感记忆 · AI行为决策 · 动态内容生成</text>
</svg>
```

---

## 六、各系统简述

### 6.1 野外探索系统

**定位**：提供紧张刺激的探索体验，是资源的主要来源

| 子系统 | 作用 |
|--------|------|
| **采集系统** | 玩家在废墟中开启宝箱，收集家具、材料和饰品，每次探索都有不同收获 |
| **追逐战斗** | 变异植物会发现并追击玩家，通过视野和听觉进行侦测，玩家需灵活躲避 |
| **背包管理** | 负重影响移动速度和被发现概率，玩家需权衡收益与风险 |
| **主角能力** | 瓢虫可装备护甲、饰品、图腾，使用隐身等主动技能提升生存能力 |

### 6.2 家园经营系统

**定位**：情感核心和治愈来源，玩家投入时间占比≥45%

| 子系统 | 作用 |
|--------|------|
| **装修系统** | 为小动物房间摆放家具，通过风格搭配和空间布置表达关怀 |
| **工作台** | 使用材料合成中高级家具，通过舒适度解锁新内容 |
| **小动物互动** | 与AI小动物对话、送礼、查看日记，建立真实的情感连接 |
| **信任系统** | 通过互动提升信任度，解锁小动物的背景故事和新功能 |

### 6.3 核心共享系统

| 系统 | 作用 |
|------|------|
| **任务系统** | 分为主线、支线和信任任务，主线推进游戏进度，支线丰富剧情内容 |
| **物品系统** | 统一管理家具（初级/中级/高级）、饰品（增强能力）、材料（合成原料） |
| **成长系统** | 玩家通过装备升级、能力解锁、新区域开放实现长线成长 |
| **怪物AI** | 变异植物具有视野、听觉、警觉、追击、搜索等状态，提供探索张力 |

---

## 七、游戏情绪曲线

```svg
<svg viewBox="0 0 900 400" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="900" height="400" fill="#f8f9fa"/>

  <!-- Title -->
  <text x="450" y="35" font-size="24" font-weight="bold" text-anchor="middle" fill="#2c3e50">
    单局游戏情绪曲线
  </text>

  <!-- Axes -->
  <line x1="80" y1="350" x2="850" y2="350" stroke="#34495e" stroke-width="2"/>
  <line x1="80" y1="80" x2="80" y2="350" stroke="#34495e" stroke-width="2"/>

  <!-- Y-axis labels -->
  <text x="60" y="90" font-size="12" text-anchor="end" fill="#34495e">紧张</text>
  <text x="60" y="220" font-size="12" text-anchor="end" fill="#34495e">平静</text>
  <text x="60" y="350" font-size="12" text-anchor="end" fill="#34495e">治愈</text>

  <!-- Curve -->
  <path d="M 80,300 L 180,280 L 280,200 L 380,120 L 480,140 L 580,100 L 680,250 L 780,320 L 850,330"
        stroke="#e74c3c" stroke-width="4" fill="none"/>

  <!-- Areas -->
  <rect x="100" y="250" width="150" height="40" fill="#2ecc71" opacity="0.2" rx="3"/>
  <rect x="270" y="100" width="180" height="40" fill="#e74c3c" opacity="0.2" rx="3"/>
  <rect x="470" y="90" width="180" height="40" fill="#f39c12" opacity="0.2" rx="3"/>
  <rect x="670" y="270" width="150" height="40" fill="#3498db" opacity="0.2" rx="3"/>

  <!-- Phase labels -->
  <text x="175" y="240" font-size="13" font-weight="bold" text-anchor="middle" fill="#27ae60">准备出发</text>
  <text x="175" y="260" font-size="11" text-anchor="middle" fill="#27ae60">家园整理</text>

  <text x="360" y="90" font-size="13" font-weight="bold" text-anchor="middle" fill="#c0392b">野外探索</text>
  <text x="360" y="110" font-size="11" text-anchor="middle" fill="#c0392b">收集与躲避</text>

  <text x="560" y="80" font-size="13" font-weight="bold" text-anchor="middle" fill="#d68910">惊险逃脱</text>
  <text x="560" y="100" font-size="11" text-anchor="middle" fill="#d68910">满载而归</text>

  <text x="745" y="260" font-size="13" font-weight="bold" text-anchor="middle" fill="#2874a6">回家装修</text>
  <text x="745" y="280" font-size="11" text-anchor="middle" fill="#2874a6">温馨互动</text>

  <!-- Time axis labels -->
  <text x="80" y="375" font-size="12" text-anchor="middle" fill="#34495e">0</text>
  <text x="280" y="375" font-size="12" text-anchor="middle" fill="#34495e">5min</text>
  <text x="480" y="375" font-size="12" text-anchor="middle" fill="#34495e">10min</text>
  <text x="680" y="375" font-size="12" text-anchor="middle" fill="#34495e">15min</text>
  <text x="850" y="375" font-size="12" text-anchor="middle" fill="#34495e">20min</text>
</svg>
```

---

## 八、设计原则与理念

### 核心原则

1. **情绪价值优先**：系统复杂度永远让位于情绪体验
2. **真实的情感连接**：AI小动物不是工具，而是有温度的家人
3. **温和的挑战**：紧张但不折磨，有风险但可控制
4. **表达而非评分**：装修是情感表达的媒介，不是追求高分的任务

### 节奏设计

- **野外**：轻度紧张，心流体验（平静探索→发现风险→短暂紧张→成功脱身）
- **家园**：治愈放松，情感沉浸（装修→互动→反馈→期待）
- **整体节奏**：40分钟Demo中，家园操作占比≥45%

---

## 九、技术特色：AI驱动的情感体验

### AI系统的核心作用

```svg
<svg viewBox="0 0 800 350" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="800" height="350" fill="#f8f9fa"/>

  <!-- Title -->
  <text x="400" y="30" font-size="22" font-weight="bold" text-anchor="middle" fill="#2c3e50">
    AI情感系统
  </text>

  <!-- Center: AI Core -->
  <circle cx="400" cy="180" r="60" fill="#9b59b6" opacity="0.9"/>
  <text x="400" y="175" font-size="16" font-weight="bold" text-anchor="middle" fill="white">AI引擎</text>
  <text x="400" y="195" font-size="12" text-anchor="middle" fill="white">情感记忆</text>

  <!-- Input factors -->
  <rect x="50" y="100" width="150" height="50" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="125" y="130" font-size="13" text-anchor="middle" fill="white">家具摆放情况</text>

  <rect x="50" y="180" width="150" height="50" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="125" y="210" font-size="13" text-anchor="middle" fill="white">任务完成进度</text>

  <rect x="50" y="260" width="150" height="50" fill="#3498db" opacity="0.8" rx="5"/>
  <text x="125" y="290" font-size="13" text-anchor="middle" fill="white">玩家行为历史</text>

  <!-- Output behaviors -->
  <rect x="600" y="100" width="150" height="50" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="675" y="130" font-size="13" text-anchor="middle" fill="white">动态对话生成</text>

  <rect x="600" y="180" width="150" height="50" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="675" y="210" font-size="13" text-anchor="middle" fill="white">情绪与心情</text>

  <rect x="600" y="260" width="150" height="50" fill="#2ecc71" opacity="0.8" rx="5"/>
  <text x="675" y="290" font-size="13" text-anchor="middle" fill="white">行为反应</text>

  <!-- Arrows -->
  <defs>
    <marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="#34495e"/>
    </marker>
  </defs>

  <path d="M 200,125 L 340,160" stroke="#34495e" stroke-width="2" fill="none" marker-end="url(#arrow)"/>
  <path d="M 200,205 L 340,185" stroke="#34495e" stroke-width="2" fill="none" marker-end="url(#arrow)"/>
  <path d="M 200,285 L 340,210" stroke="#34495e" stroke-width="2" fill="none" marker-end="url(#arrow)"/>

  <path d="M 460,160 L 600,125" stroke="#34495e" stroke-width="2" fill="none" marker-end="url(#arrow)"/>
  <path d="M 460,185 L 600,205" stroke="#34495e" stroke-width="2" fill="none" marker-end="url(#arrow)"/>
  <path d="M 460,210 L 600,285" stroke="#34495e" stroke-width="2" fill="none" marker-end="url(#arrow)"/>
</svg>
```

小动物会：
- 记住与玩家的互动历史和记忆点
- 根据装修风格给出真实反应
- 在不同心情下展现不同性格
- 主动表达需求和情感

---

## 十、目标玩家画像与体验目标

### 目标玩家

喜欢**装修类游戏**、渴望**情感连接**、享受**供养与保护**小动物的玩家

### 期望体验

- 🎨 **装修的乐趣**：自由布置，看到小动物们使用家具的温馨场景
- 💗 **陪伴的温暖**：与AI小动物建立羁绊，感受双向奔赴的情感
- ⚡ **探索的刺激**：适度紧张的野外冒险，逃脱后的成就感
- 🏡 **归属的满足**：在末日废土中，一点点建立起属于自己的温暖小家

---

## 附录：快速参考

### 关键数值参考

- **Demo时长**：40分钟
- **家园操作占比**：≥45%
- **主线任务数**：约11次探索
- **小动物初始数量**：3只（水獭一家）
- **家具等级**：装饰物、初级、中级、高级、特殊
- **背包初始容量**：6格（可扩展至9格）

### 美术风格关键词

**自然元素 · 色彩鲜艳 · 温暖治愈 · 废墟与生机对比**

### 音乐情绪定位

**家园**：温暖、舒缓、治愈
**野外**：轻度紧张、神秘、冒险感
**高潮**：紧迫、惊险、心跳加速

---

## 结语

这是一款关于**在末日废土中建立温暖小家**的游戏。

我们不做黑暗残酷的生存，而做**治愈与希望**。
我们不做冷冰冰的模拟器，而做**有温度的情感连接**。

每一次野外的冒险，都是为了给小动物们带回一个更好的家。
每一件捡回的旧物，都在这里重新拥有了心跳。

**这就是我们的初心，也是我们的方向。**

---

> 📌 **后续链接**（待添加）
> - [野外探索系统详细文档](./策划案/markdown/野外机制.md)
> - [家园系统详细文档](./策划案/markdown/家园文档.md)
> - [小动物互动详细文档](./策划案/markdown/小动物系统.md)
> - [任务系统详细文档](./策划案/markdown/任务系统.md)
> - [物品系统详细文档](./策划案/markdown/物品系统.md)
> - [主角能力详细文档](./策划案/markdown/主角能力设计文档.md)

---

**文档版本**：v1.0
**最后更新**：2026-05-24
**维护者**：策划组
