---
title: Wanderer（漫游者）特性说明
path: 戴夫like（光子大赛）/文档垃圾站/Monster状态机说明/Wanderer（漫游者）特性说明
token: BCzJdnKaAovrT8xnuBicqbsqnKc
type: docx
---

# Wanderer（漫游者）特性说明

（本文档由AI根据代码生成）

## **概述**

Wanderer是MonsterController的子类，在基础状态机之上添加了**Idle状态下的随机漫游行为**。



---



## **特有行为**



### **Idle状态的漫游逻辑**



与基类不同，Wanderer在Idle状态下**不是静止不动**的，而是在起始位置周围随机漫游。



**漫游流程：**

1. 在起始位置（`startPosition`）周围随机选择一个目标点
2. 向目标点移动
3. 到达目标点后等待一段随机时间
4. 重复步骤1

---



## **Idle状态重写**



### **速度设置**

```C#
currentSpeed = wandererData.WanderSpeedMultiplier * playerMoveModel.MoveSpeed;
```

- 不同于基类的 `currentSpeed = 0`
- 使用 `WanderSpeedMultiplier` 参数控制漫游速度

### **移动逻辑（IdleUpdate）**

```C#
protected override void IdleUpdate()
{
    if (Vector3.Distance(transform.position, targetPosition) < 0.1f)
    {
        // 到达目标点，开始等待
        waitTimer -= Time.deltaTime;
        if (waitTimer <= 0)
        {
            ResetWanderDestination(); // 重新选择目标点
        }
    }
}
```



**判定条件：**

\- 距离目标点 < **0.1单位** 视为到达

- 等待计时器倒计时到0后重新选择目标

---



## **特有参数**



| 参数名 | 类型 | 说明 | 默认值 |
|-|-|-|-|

| **WanderSpeedMultiplier** | float | 漫游速度倍数（相对玩家移速） | - |

| **WanderRadius** | float | 漫游范围半径（从起始位置算起） | - |

| **MinWaitTime** | float | 到达目标点后的最小等待时间（秒） | 1f |

| **MaxWaitTime** | float | 到达目标点后的最大等待时间（秒） | 3f |



---



## **目标点选择算法**



### **ResetWanderDestination 方法**

```C#
private void ResetWanderDestination()
{
    // 1. 在单位圆内随机选点
    Vector2 randomCircle = Random.insideUnitCircle * wandererData.WanderRadius;
    
    // 2. 转换为3D向量（XY平面）
    Vector3 randomOffset = new Vector3(randomCircle.x, randomCircle.y, 0);
    
    // 3. 基于起始位置计算目标点
    targetPosition = startPosition + randomOffset;
    
    // 4. 设置随机等待时间
    waitTimer = Random.Range(wandererData.MinWaitTime, wandererData.MaxWaitTime);
}
```



**算法特点：**

- 使用 `Random.insideUnitCircle` 均匀分布在圆形区域内
- 目标点始终在以 `startPosition` 为圆心、`WanderRadius` 为半径的圆内
- 等待时间在 `[MinWaitTime, MaxWaitTime]` 范围内随机

---



## **Gizmos可视化**



### **Scene视图显示**

选中Wanderer GameObject时会显示两个圆圈：



**红色圆圈**（继承自基类）：

- 表示感知范围（`DetectingRange`）
- 用于检测玩家

**蓝色圆圈**（Wanderer特有）：

```C#
Gizmos.color = Color.blue;
Gizmos.DrawWireSphere(transform.position, wandererData.WanderRadius);
```

- 表示漫游范围（`WanderRadius`）
- 随Monster移动而移动（中心是当前位置，不是起始位置）

---



## **状态转换补充说明**



Wanderer的状态转换继承自MonsterController，**唯一区别是Idle状态**：



### **Idle → Listening**

- 与基类相同：玩家进入感知范围触发

\- **不同点**：触发时可能正在移动（漫游中）



### **Listening/Chasing/Returning → Idle**

- 完全继承基类逻辑

\- **回到Idle后立即开始漫游**（因为进入Idle时会重写speed）



---



## **数据配置**



### **ScriptableObject创建**

右键菜单路径：`Create → DataSO → MonsterData → WandererData`



### **继承关系**

```Plain Text
MonsterData (基类)
    ├─ 基础属性（DetectingRange, ListeningTime, ChaseTime等）
    └─ WandererData (子类)
        └─ 漫游属性（WanderSpeedMultiplier, WanderRadius等）
```



### **推荐配置**

```Plain Text
// 让Wanderer比玩家慢，增加可预测性
WanderSpeedMultiplier: 0.5 ~ 0.8

// 控制在合理范围内漫游
WanderRadius: 3 ~ 5单位

// 合理的停留时间
MinWaitTime: 1秒
MaxWaitTime: 3秒
```



---



## **关键字段**



```C#
// Wanderer特有字段
private float waitTimer = 0f;           // 等待计时器
private WandererData wandererData;      // 强类型数据引用
```



---



## **使用示例**



### **场景设置**

1. 创建GameObject，添加 `WandererController` 组件
2. 创建WandererData ScriptableObject并配置参数
3. 在Inspector中设置：

   - Monster Type: `Wanderer`
   - Detecting Collider: 自动添加的 `CircleCollider2D`
   - Monster State TMP: 可选的状态显示Text

### **观察漫游行为**

- Play模式下，Wanderer会在蓝色圆圈范围内随机移动
- 到达目标点后会短暂停留
- 玩家进入红色圆圈范围后会停止漫游，开始追逐流程

---



## **代码位置**

\- **控制器**：\`Assets/Scripts/Explore/Controllers/WandererController.cs\`

\- **数据类**：\`Assets/Scripts/Explore/Models/MonsterData/WandererData.cs\`



---



**文档版本：1.0**  

**最后更新：2026年1月26日**  

**基于代码版本：WandererController.cs (70行)**
