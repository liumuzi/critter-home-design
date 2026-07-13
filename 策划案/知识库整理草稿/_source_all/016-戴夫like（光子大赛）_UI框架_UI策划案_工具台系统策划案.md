---
title: 工具台系统策划案
path: 戴夫like（光子大赛）/UI框架/UI策划案/工具台系统策划案
token: UyEKdVY5ao1zpQxxgmDcQ9N7nch
type: docx
---

# 工具台系统策划案

## 一、项目背景与目标

### 1.1 背景

当前游戏已实现：

- **工作台系统**：基础制造/分解功能
- **家园装饰系统**：网格放置、编辑
- **仓库**：展示已制造家具，拖拽摆放家具

现有问题：

- 缺少追踪功能，玩家需要反复打开查看配方
- 缺少格子名称标识
- 图鉴翻找困难

### 1.2 目标

构建完整的**工具台系统**，包含：

1. **菜单**：浏览所有已解锁家具
2. **制造**：快速制造家具
3. **分解**：分解家具返还材料
4. **追踪**：追踪目标家具，显示所需材料
5. **仓库**：展示已建造家具



## 二、功能模块总览

<whiteboard token="E9cvwoSaqhma0Db7HnscJMion7d"></whiteboard>

![图片展示的是工具台系统的工作台界面。左侧为菜单区域，有“全部”“家具”等分类标签，部分分类下有新解锁家具红点提示。中间是工作台主体，显示某家具名称及制作所需材料数量，有“制作”按钮。右侧有任务进度显示，如收集树枝和木材的进度。下方是仓库栏位。此图与上文“功能模块总览”相关，直观呈现了工具台系统的工作台部分界面及操作元素。](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZmRmOTFlMDJkZDI2Njc0MGQ1ZDhjOGY5ZmUzNTM3NzZfMWJmZTM2MTliMzM1MjE1MWM2YzczMTAxMGM2ZTYwMzVfSUQ6NzY0NzQxNjQ2NTAyMTI5MTc1Nl8xNzgzOTM2NTc4OjE3ODM5NDAxNzhfVjM)

## 三、菜单页面

### 3.1 功能定义

**定位**：浏览所有已解锁家具的目录页面

**核心作用**：

- 查看所有已解锁家具
- 按分类筛选浏览
- 新解锁家具红点提示

### 3.2 界面结构

<whiteboard token="MBT5wQQWAhdjbnbQDk8c3yPFnaf"></whiteboard>

### 3.3 分类定义

<sheet sheet-id="bDtLUI" token="JpVUsyPpkhqtootsLCncFyIYnBd"></sheet>

具体根据引擎内配表为准

### 3.4 排序规则

- **默认排序**：按家具ID升序

### 3.5 红点逻辑

```Plain Text
触发条件：
  - 舒适度提升后，检查是否有新家具达到解锁条件
  - 新解锁的家具所在分类Tab显示红点

消失条件：
  - 玩家点击该分类Tab后，红点消失
```

## 四、工作台页面（制造/分解/追踪）

### 4.1 功能定义

**定位**：家具制造、分解、追踪的统一操作页面

**核心作用**：

- 制造家具（消耗材料→产出家具）
- 分解家具（家具→返还部分材料）
- 追踪目标家具

### 4.2 页面结构

<whiteboard token="DDaMw8kzLhnHCpbvxcKcRlCAnqh"></whiteboard>

### 4.3 操作流程

<whiteboard token="Z1Fgw5ghwhQ2mQbrmDDcxDeEnYe"></whiteboard>

## 五、仓库页面

### 5.1 功能定义

**定位**：浏览所有已制造家具的目录页面

**核心作用**：

- 查看所有已制造家具
- 现有材料数量
- 按分类筛选浏览

### 5.2 界面结构

![图片展示的是家具制造、分解、追踪工作台页面中的仓库页面界面结构。画面中上方有“全部”“家具”“墙饰”“摆件”“地饰”“装修”“材料”等分类标签，下方对应展示不同分类 addCriterion感谢您的理解，我会注意的。](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZDRkN2U4ZWM2Y2ZmNTBiNjMxYzg2NGVjZDRiYWY1MTlfMWE3YWU1MGU3ZDdjYzIyNjhjOGU1MWM3NDVkYzIzYzlfSUQ6NzY0NzQxNDA5ODQ4NTg1NzQ5MV8xNzgzOTM2NTc4OjE3ODM5NDAxNzhfVjM)
