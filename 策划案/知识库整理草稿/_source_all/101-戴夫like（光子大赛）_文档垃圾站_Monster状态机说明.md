---
title: Monster状态机说明
path: 戴夫like（光子大赛）/文档垃圾站/Monster状态机说明
token: POHGd2OrmofPGOxoNH4cvX6VncO
type: docx
---

<title>Monster状态机说明</title>

# Monster 状态机说明文档

## 概述

Monster通过五个状态来控制其行为：Idle（闲置）、Listening（倾听）、Chasing（追逐）、Lost（失去目标）、Returning（返回）。Monster会根据玩家的位置和时间条件在这些状态之间切换。

---

## 五个状态

### 🟢 Idle（闲置）

**行为：**

- `currentSpeed = 0`（不移动）
- `targetPosition = transform.position`（目标位置为当前位置）

**进入条件：**

- 游戏开始时的初始状态
- 从Returning状态返回到起始位置（`distanceToStart < 0.1f`）

**状态转换：**

- 玩家进入感知范围（`DetectingRange`） → **Listening**

---

### 🟡 Listening（倾听）

**行为：**

- `currentSpeed = 0`（静止不动）
- `targetPosition = transform.position`（保持当前位置）
- `listeningTimer` 在进入时重置为 `0f`

**进入条件：**

- 从Idle状态检测到玩家进入感知范围
- 从Returning状态检测到玩家进入感知范围

**计时器规则：**

- **玩家在范围内**：`listeningTimer += deltaTime`（递增）

  - `listeningTimer >= myData.ListeningTime` → **Chasing**
- **玩家离开范围**：`listeningTimer -= deltaTime`（递减）

  - `listeningTimer <= 0f` → **Returning**

**说明：** 玩家离开范围后计时器不会立即归零，而是开始倒计时，玩家重新进入范围则继续递增。

---

### 🔴 Chasing（追逐）

**行为：**

- `currentSpeed = myData.ChaseSpeedMultiplier * playerMoveModel.MoveSpeed`
- `targetPosition = playerMoveModel.Position`（实时追踪玩家位置）
- `chasingTimer` 在进入时重置为 `0f`

**进入条件：**

- 从Listening状态且 `listeningTimer >= myData.ListeningTime`

**状态转换：**

- `!playerInRange`（玩家离开感知范围） → **Lost**
- `chasingTimer >= myData.ChaseTime`（追逐超时） → **Lost**

**碰撞检测：**

- 与Player层的GameObject发生碰撞 → 触发 `PlayerDeadCommand`

---

### 🟠 Lost（失去目标）

**行为：**

- 当从 `Chasing` 状态失去玩家或追逐超时，会进入 `Lost` 状态并开始计时（`lostTimer` 置为 0）。
- 在 `Lost` 状态中，怪物停下（`currentSpeed = 0`），等待一段时间：`lostTimer += deltaTime`。
- 若 `lostTimer >= myData.LostTime`，则转入 `Returning`（返回起始点）。

**进入条件：**

- 从 `Chasing` 状态且 `!playerInRange`（玩家离开感知范围）或 `chaseTimer >= ChaseTime`（追逐超时）。

**状态转换：**

- `player re-enter range` → **Chasing**
- `lostTimer >= myData.LostTime` → **Returning**

---

### 🟠 Returning（返回）

**行为：**

- `currentSpeed = myData.ReturnSpeedMultiplier * playerMoveModel.MoveSpeed`
- `targetPosition = startPosition`（起始位置）

**进入条件：**

- 从Listening状态且 `listeningTimer <= 0f`
- 从Chasing状态且玩家离开感知范围或追逐超时

**状态转换：**

- `distanceToStart < 0.1f`（到达起始位置） → **Idle**
- 途中玩家进入感知范围 → **Listening**

---

## 状态转换流程图

<whiteboard token="SLO4wkAlthSibbbQ3cAcXehmn4c"></whiteboard>

---

## 关键参数说明

| 参数名 | 类型 | 说明 | 使用位置 |
|-|-|-|-|
| **DetectingRange** | float | 感知范围半径 | 检测玩家是否在范围内 |
| **ListeningTime** | float | 倾听时间阈值 | `listeningTimer >= ListeningTime` 时进入Chasing |
| **ChaseTime** | float | 追逐时间限制 | `chasingTimer >= ChaseTime` 时返回 |
| **LostTime** | float | 失去玩家后在 Lost 状态的等待时长 | `lostTimer >= LostTime` 时进入 Returning |
| **ChaseSpeedMultiplier** | float | 追逐速度倍数 | `currentSpeed = ChaseSpeedMultiplier * 玩家移速` |
| **ReturnSpeedMultiplier** | float | 返回速度倍数 | `currentSpeed = ReturnSpeedMultiplier * 玩家移速` |

**注意：** 所有速度倍数都是相对于 `playerMoveModel.MoveSpeed`（玩家的实际移速）

---

## 检测机制

### 玩家检测方式

使用 `Physics2D.OverlapCircle` 检测 **"PlayerDetection"** 层：

- 检测中心：Monster当前位置
- 检测半径：`myData.DetectingRange`
- 目标层：`LayerMask.GetMask("PlayerDetection")`

### 碰撞检测

使用 `OnCollisionEnter2D` 检测与 **"Player"** 层的碰撞：

- 触发 `PlayerDeadCommand`（游戏结束命令）

---

## 实现细节

### 移动实现

```C#
transform.position = Vector3.MoveTowards(
    transform.position, 
    targetPosition, 
    currentSpeed * Time.deltaTime
);
```

在 `FixedUpdate` 中每帧移动，使用 `Vector3.MoveTowards` 平滑移动到目标位置。

### 状态切换时机

- **进入新状态**时调用 `OnStateChange(MonsterState newState)`
- 重置相关计时器和速度
- 设置目标位置

### 返回判定

```C#
float distanceToStart = Vector3.Distance(transform.position, startPosition);
if (distanceToStart < 0.1f)
```

当距离起始位置小于 **0.1单位** 时，视为已到达。

---

## 代码结构

### 主要文件

- **控制器**：`Assets/Scripts/Explore/Controllers/MonsterController.cs`
- **数据定义**：`Assets/Scripts/Explore/Models/MonsterData/MonsterData.cs`
- **系统**：`Assets/Scripts/Explore/Systems/MonsterSystem.cs`

### 关键字段

```C#
// 序列化字段
[SerializeField] private MonsterType monsterType;
[SerializeField] private CircleCollider2D detectingCollider;
[SerializeField] private TextMeshProUGUI monsterStateTMP;

// 计时器
private float listeningTimer = 0f;
private float chasingTimer = 0f;

// 状态和位置
protected BindableProperty<MonsterState> currentState;
protected Vector3 startPosition;
protected Vector3 targetPosition;

// 检测
private bool playerInRange = false;
```

### 主要方法

- `DetectPlayerUpdate()`：每帧检测玩家是否在感知范围
- `OnStateChange(MonsterState newState)`：状态切换时的回调
- `IdleUpdate()`：Idle状态的更新逻辑
- `ListeningUpdate(float deltaTime)`：Listening状态的更新逻辑
- `ChasingUpdate(float deltaTime)`：Chasing状态的更新逻辑
- `ReturningUpdate()`：Returning状态的更新逻辑
- `OnPlayerEnterRange()`：玩家进入感知范围的回调
- `OnPlayerExitRange()`：玩家离开感知范围的回调

---

## 调试功能

### Inspector显示

将 `TextMeshProUGUI` 组件赋值给 `monsterStateTMP` 字段，可在游戏中实时显示当前状态。

### Scene视图Gizmos

选中Monster GameObject时，Scene视图会绘制红色圆圈表示感知范围：

```C#
Gizmos.color = Color.red;
Gizmos.DrawWireSphere(transform.position, myData.DetectingRange);
```

### Console日志

代码中包含以下日志输出：

- 状态切换：`"Monster {ID} changed state to {newState}"`
- 检测到玩家：`"Monster {ID} detected the player!"`
- 失去玩家：`"Monster {ID} lost sight of the player!"`
- 追逐失败：`"Monster {ID} lost the player, returning to start position."`
- 追逐超时：`"Monster {ID} chase timeout, returning to start position."`
- 返回成功：`"Monster {ID} returned to start position."`
- 碰撞玩家：`"Monster {ID} collided with the player!"`

---

## Unity设置要求

### Layer设置

1. 创建 **"PlayerDetection"** 层（用于玩家脚步声范围检测）
2. 创建 **"Player"** 层（用于玩家实际碰撞体）

### Collider配置

**Monster**:

- `CircleCollider2D`（detectingCollider）
- Is Trigger: ✓

**Player**:

- 脚步声范围：`CircleCollider2D`，Is Trigger: ✓，Layer: PlayerDetection
- 实际碰撞体：`Collider2D`，Is Trigger: ✗，Layer: Player

### Physics 2D设置

Edit → Project Settings → Physics 2D → Layer Collision Matrix

- 取消勾选 **PlayerDetection** 与所有其他层的碰撞，确保脚步声范围不产生物理碰撞

---

**文档版本：1.0**  
**最后更新：2026年1月26日**  
**基于代码版本：MonsterController.cs (271行)**
