import json

with open('./survey_u8.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

records = data['data']['data']
fields = data['data']['fields']  # list of strings (field names)
total = len(records)

print(f"Total records: {total}")
print()

# Define which columns are select-type (by index, from schema analysis)
# Options are Likert: 非常认同/比较认同/中立/比较不认同/非常不认同
likert_cols = {
    2: "我明白如何制作家具、摆放家具和标记家具配方",
    4: "我享受野外探索当前的难度",
    5: "总体而言，我享受家园的游玩体验",
    10: "游玩过后，我对后续内容感到期待",
    12: "我喜欢家园里的水獭哥哥",
    18: "总体而言，我享受野外的游玩体验",
    20: "在野外探索时，我明白如何操作角色移动、拾取物品以及冲刺",
    21: "总体来说，我认为游戏的操作方式是容易的、符合直觉的",
    23: "我想要把家园装修得更漂亮",
    30: "我喜欢家园和家具的视觉效果和氛围",
    31: "我喜欢野外的视觉效果和氛围",
}

other_select = {
    3: "你平时经常玩游戏吗？",
    9: "如果游戏发售，你会考虑购买吗？",
    15: "你的年龄",
    22: "你经常使用什么设备玩游戏？",
    17: "以下游戏类型中，你游玩过并最喜欢的有哪些？",
    32: "你的性别",
}

difficulty_col = 24
open_comment_col = 19

print("=== Likert Scale Questions (非常认同/比较认同/中立/比较不认同/非常不认同) ===")
for col, name in sorted(likert_cols.items()):
    counts = {}
    for r in records:
        v = r[col] if col < len(r) else None
        if v and isinstance(v, list) and len(v) > 0:
            v = v[0]
        if v:
            key = v if isinstance(v, str) else v.get('name', str(v))
            counts[key] = counts.get(key, 0) + 1
    
    # Calculate positive rate
    positive = counts.get("非常认同", 0) + counts.get("比较认同", 0)
    pct = round(positive / total * 100)
    
    print(f"\n--- {name} ---")
    for k in ["非常认同", "比较认同", "中立", "比较不认同", "非常不认同"]:
        c = counts.get(k, 0)
        print(f"  {k}: {c} ({round(c/total*100)}%)")
    print(f"  >>> 正面率(非常+比较): {positive}/{total} = {pct}%")

print("\n\n=== Other Select Questions ===")
for col, name in sorted(other_select.items()):
    counts = {}
    for r in records:
        v = r[col] if col < len(r) else None
        if v:
            if isinstance(v, list):
                for vv in v:
                    key = vv if isinstance(vv, str) else vv.get('name', str(vv))
                    counts[key] = counts.get(key, 0) + 1
            else:
                key = v if isinstance(v, str) else v.get('name', str(v))
                counts[key] = counts.get(key, 0) + 1
    if counts:
        print(f"\n--- {name} ---")
        for k, c in sorted(counts.items(), key=lambda x: -x[1]):
            print(f"  {k}: {c} ({round(c/total*100)}%)")

# Difficulty score
print("\n\n=== Difficulty Score ===")
scores = []
for r in records:
    v = r[difficulty_col] if difficulty_col < len(r) else None
    if v is not None and v != '' and v != 'None':
        try:
            scores.append(int(v))
        except:
            pass
if scores:
    print(f"Average: {sum(scores)/len(scores):.2f}")
    dist = {}
    for s in scores:
        dist[s] = dist.get(s, 0) + 1
    for k in sorted(dist.keys()):
        print(f"  Score {k}: {dist[k]} ({round(dist[k]/len(scores)*100)}%)")

# Open comments
print("\n\n=== 想对我们说 (Open Comments) ===")
for r in records:
    v = r[open_comment_col] if open_comment_col < len(r) else None
    if v:
        if isinstance(v, list):
            v = ', '.join([str(x) for x in v])
        v = str(v)
        if v and v != 'None' and v.strip():
            print(f"  - {v}")

# "对上一题陈述的看法" text columns
print("\n\n=== 开放式看法 (selected) ===")
open_indices = [1, 6, 7, 10, 12, 13, 14, 15, 23, 24, 25, 26]
for idx in open_indices:
    name = fields[idx] if idx < len(fields) else f"col_{idx}"
    comments = []
    for r in records:
        v = r[idx] if idx < len(r) else None
        if v:
            if isinstance(v, list):
                v = ', '.join([str(x) for x in v])
            v = str(v)
            if v and v != 'None' and v.strip():
                comments.append(v)
    if comments:
        print(f"\n--- {name} ---")
        for c in comments:
            print(f"  - {c}")
