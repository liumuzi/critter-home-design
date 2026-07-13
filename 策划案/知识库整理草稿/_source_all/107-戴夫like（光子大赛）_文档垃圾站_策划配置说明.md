---
title: 策划配置说明
path: 戴夫like（光子大赛）/文档垃圾站/策划配置说明
token: Sz1RdHMl4obhrfxTGEucCTj4nJd
type: docx
---

# 策划配置说明

（本文档由AI根据代码生成）

> 版本：v0.1  
> 更新日期：2026-01-27  
> 适用对象：策划、数值设计师

---

## 📋 目录

1. 快速开始
2. 玩家配置
3. 怪物配置
4. 场景配置
5. UI配置
6. 输入配置

---

## 快速开始

### 配置文件位置

所有配置数据存储在Unity的ScriptableObject资源中，位于：

```Plaintext
Assets/Resources/DataSO/
├── PlayerData/         # 玩家相关配置
└── MonsterData/        # 怪物相关配置
```

### 如何修改配置

1. 在Unity编辑器的Project窗口中找到对应的`.asset`文件
2. 单击选中该文件
3. 在Inspector窗口中直接修改数值
4. 修改会自动保存，无需额外操作

⚠️ **注意**：修改后需要重新运行游戏才能看到效果。

---

## 玩家配置

### 配置文件路径

```Plaintext
Assets/Resources/DataSO/PlayerData/DefaultPlayerData.asset
```

### 代码定义位置

```Plaintext
Assets/Scripts/Core/Models/PlayerData.cs
```

### 可配置参数

#### 1. 移动参数

| 参数名 | 类型 | 默认值 | 说明 |
|-|-|-|-|
| **MoveSpeed** | float | 5.0 | 玩家移动速度（单位/秒） |
| **Acceleration** | float | 20.0 | 加速度。值越大，启动越快 |
| **Deceleration** | float | 25.0 | 减速度。值越大，停止越快 |
| **InputSmoothing** | float | 0.1 | 输入平滑程度（0-1），越大越平滑 |

**调整建议**：

- 灵活敏捷的感觉：`Acceleration: 30`, `Deceleration: 35`
- 有重量感：`Acceleration: 10`, `Deceleration: 15`
- 滑冰效果：`Acceleration: 15`, `Deceleration: 5`

#### 2. 检测范围

| 参数名 | 类型 | 默认值 | 说明 |
|-|-|-|-|
| **stepRange** | float | 1.0 | 玩家脚步声检测范围（半径） |

**说明**：怪物在此范围内可以"听到"玩家移动。

#### 3. 隐身系统

| 参数名 | 类型 | 默认值 | 说明 |
|-|-|-|-|
| **maxStealthEnergy** | float | 100.0 | 隐身能量上限 |
| **stealthRegenRate** | float | 6.6 | 能量恢复速率（每秒） |
| **stealthDrainRate** | float | 16.0 | 隐身持续消耗（每秒） |
| **stealthActivationCost** | float | 20.0 | 激活隐身的一次性消耗 |

**计算参考**：

- 满能量可持续隐身时间：`(100 - 20) / 16 = 5秒`
- 从空到满的恢复时间：`100 / 6.6 ≈ 15秒`
- 激活隐身后剩余能量：`100 - 20 = 80`

**平衡建议**：

- 提高难度：增加`stealthDrainRate`或`stealthActivationCost`，降低`stealthRegenRate`
- 降低难度：降低`stealthDrainRate`或`stealthActivationCost`，增加`stealthRegenRate`

---

## 怪物配置

### 配置文件结构

```Plaintext
Assets/Resources/DataSO/MonsterData/
└── （在此文件夹创建怪物配置）
```

### 创建新怪物配置

1. 在Project窗口右键点击`MonsterData`文件夹
2. 选择 `Create > DataSO > MonsterData > WandererData`
3. 命名配置文件（如：`Wanderer_Fast`）
4. 在Inspector中配置参数

### 怪物基础参数

**代码定义**：`Assets/Scripts/Explore/Models/MonsterData/MonsterData.cs`

| 参数名 | 类型 | 说明 |
|-|-|-|
| **ID** | int | 怪物唯一标识（由系统自动分配） |
| **Type** | MonsterType | 怪物类型（当前只有Wanderer） |
| **chaseSpeedMultiplier** | float | 追击速度倍数（相对玩家移速） |
| **returnSpeedMultiplier** | float | 返回速度倍数（相对玩家移速） |
| **listeningTime** | float | 监听时长（秒），进入追击前的等待 |
| **chaseTime** | float | 追击持续时长（秒） |
| **detectingRange** | float | 检测范围（半径） |

**速度计算公式**：

- 追击速度 = `玩家MoveSpeed × chaseSpeedMultiplier`
- 返回速度 = `玩家MoveSpeed × returnSpeedMultiplier`

**示例配置**：

```Plaintext
玩家速度 = 5.0
chaseSpeedMultiplier = 1.2
→ 怪物追击速度 = 5.0 × 1.2 = 6.0（比玩家快）
```

### Wanderer（漫游者）特有参数

**代码定义**：`Assets/Scripts/Explore/Models/MonsterData/WandererData.cs`

| 参数名 | 类型 | 说明 |
|-|-|-|
| **wanderSpeedMultiplier** | float | 漫游速度倍数（相对玩家移速） |
| **wanderRadius** | float | 漫游范围半径（从出生点计算） |
| **minWaitTime** | float | 漫游等待最短时间（秒） |
| **maxWaitTime** | float | 漫游等待最长时间（秒） |

**行为说明**：

- Wanderer在Idle状态会随机漫游
- 每次移动到随机位置后等待`[minWaitTime, maxWaitTime]`秒
- 漫游不会超出`wanderRadius`范围

---

## 场景配置

### 地图边界设置

**配置位置**：场景中的GameObject组件

1. 在场景Hierarchy中找到地图边界对象
2. 添加`SceneBoundsInitializer`组件
3. 配置以下参数：

| 参数名 | 类型 | 说明 |
|-|-|-|
| **mapId** | string | 地图唯一标识 |
| **mapBounds** | Rect | 地图边界矩形（X, Y, Width, Height） |

**或者使用自动计算**：

- 勾选`Use Colliders`
- 系统会自动从子对象的Collider2D计算边界

**可视化**：

- 在Scene视图中会显示绿色线框（地图边界）
- 绿色半透明区域表示可移动范围

---

## UI配置

### 隐身能量条

**组件位置**：Canvas下的能量条UI对象

**代码定义**：`Assets/Scripts/Core/Controllers/UI/StealthEnergyBar.cs`

| 参数名 | 类型 | 默认值 | 说明 |
|-|-|-|-|
| **energySlider** | Slider | - | UI Slider组件引用 |
| **fillImage** | Image | - | 填充条的Image组件 |
| **normalColor** | Color | 青蓝色 | 正常状态颜色（能量充足） |
| **lowEnergyColor** | Color | 红色 | 低能量警告颜色 |
| **stealthActiveColor** | Color | 紫色 | 隐身激活时颜色 |

**颜色状态说明**：

- 🟦 **青蓝色**：能量 ≥ 激活消耗量（可以激活隐身）
- 🟥 **红色**：能量 < 激活消耗量（无法激活隐身）
- 🟪 **紫色**：隐身激活中

---

## 输入配置

### 输入动作映射

**配置文件**：

```Plaintext
Assets/Input/PlayerInputActions.inputactions
```

可在Unity的Input Actions编辑器中修改：

1. 双击`.inputactions`文件
2. 在Input Actions窗口中编辑

### 当前映射

#### 移动（Move）

- WASD键
- 方向键

#### 隐身（Stealth）

- 左Shift
- 右Shift

**修改方式**：

1. 选择对应的Action
2. 在Bindings中添加/删除/修改按键
3. 保存后会自动生成C#代码

---

## 📊 数值平衡建议

### 难度调整方案

#### 简单难度

```Plaintext
玩家：
- MoveSpeed: 6.0
- maxStealthEnergy: 120
- stealthDrainRate: 12

怪物：
- chaseSpeedMultiplier: 1.1（略快于玩家）
- listeningTime: 1.5
- chaseTime: 8
```

#### 普通难度（当前默认值）

```Plaintext
玩家：
- MoveSpeed: 5.0
- maxStealthEnergy: 100
- stealthDrainRate: 16

怪物：
- chaseSpeedMultiplier: 1.2
- listeningTime: 1.0
- chaseTime: 10
```

#### 困难难度

```Plaintext
玩家：
- MoveSpeed: 5.0
- maxStealthEnergy: 80
- stealthDrainRate: 20

怪物：
- chaseSpeedMultiplier: 1.4（明显快于玩家）
- listeningTime: 0.5
- chaseTime: 15
- detectingRange: +20%
```

---

## 🔧 测试工具

### 实时调试信息

运行游戏时，可在Console中查看：

- 隐身激活/关闭日志
- 怪物状态变化日志

### 推荐测试流程

1. **移动手感测试**

   - 调整`Acceleration`和`Deceleration`
   - 测试不同`InputSmoothing`值
   - 找到最舒适的手感
2. **隐身平衡测试**

   - 测试满能量持续时间是否合理
   - 测试能量恢复速度是否合理
   - 测试激活消耗是否合适
3. **怪物难度测试**

   - 测试是否能被追上
   - 测试追击持续时间
   - 测试检测范围是否合理

---

## 📞 技术支持

如需添加新的配置参数或遇到问题，请联系程序：

- 新增配置需要修改对应的`Data.cs`脚本
- 配置不生效请检查是否引用了正确的配置文件
- 数值建议可以开issue讨论

---

## 更新日志

### v0.1 (2026-01-27)

- 初始版本
- 完成玩家移动系统配置
- 完成隐身系统配置
- 完成怪物基础配置
- 完成Wanderer配置
