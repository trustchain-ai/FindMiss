# FindAction · ROADMAP

> 北极星：Agent 说"做完了"——让你看到它到底做了什么。黑盒变白盒。

---

## 路线总览

| 版本 | 主题 | 状态 |
|------|------|------|
| v0.1 | 7 条规则 + 三节点执行流程 | ✅ 已完成 |
| **v0.2** | **15-run baseline · 建立精度基线** | 🔄 进行中 |
| v0.3 | 规则调优（基于 v0.2 数据） | 📋 计划 |
| v1.0 | 跨模型验证 · 规则冻结 | 📋 计划 |

---

## v0.2 — 15 条真实闭环 · 建立精度基线

**为什么做 v0.2**：v0.1 的 7 条规则是设计出来的，从未在真实 Agent 执行记录上跑过。不知道哪条规则能命中、哪条是噪声、哪条假阳严重。

**核心交付**（4 件，不多不少）：

1. **判定协议** `dogfood/protocol.md`
   - TP/FP/UNCERTAIN 定义
   - 7 条规则各自的 TP 充分条件
   - FP 分类（工具链副产物 / 探测性失败 / 粒度不匹配 / 代码风格级决策）
   - 边界 case 处理规则

2. **15 条真实 `/fa` 记录** `dogfood/runs/001-015`
   - 5 类场景各 >= 2 条（code / refactor / debug / ops / multi）
   - >= 8 条有明确计划，>= 4 条无计划
   - >= 3 条工具调用 > 15 次的长会话
   - 每条标注：命中项 × TP/FP/UNCERTAIN + 判定理由

3. **基线报告** `dogfood/baseline.md`
   - 7 条规则各自的：命中次数 / TP / FP / precision
   - 总量聚合
   - 精度最低的 2 条规则 + v0.3 调优方向

4. **ROADMAP 回填**
   - 用基线数据修正 v0.3 退出条件

**不做**：
- ❌ 不调规则（先跑后调）
- ❌ 不砍规则（砍需要数据支撑）
- ❌ 不加规则（现有规则还没验证）
- ❌ 不改输出格式
- ❌ 不做外部灰度
- ❌ 不做 recall 估算
- ❌ 不建预期副产物白名单（先收集数据再建）
- ❌ 不做三件套联动

**退出条件**（全部 true 才算完）：

```bash
test -f dogfood/protocol.md && echo PASS
find dogfood/runs/ -name "*.md" | wc -l               # >= 15
for type in code refactor debug ops multi; do
  ls dogfood/runs/*-${type}-*.md 2>/dev/null | wc -l   # 每类 >= 2
done
grep -cE "A-STEP|A-SKIP|A-ORDER|A-RETRY|A-SILENT|A-SCOPE|A-DECIDE" \
  dogfood/baseline.md                                   # >= 7
grep -c "collected: true" dogfood/runs/*.md             # == 记录总数
grep -c "退出条件" ROADMAP.md                            # >= 2
```

**工期**：3 周（W1 搭建+跑5条 / W2 跑5条+中期检查 / W3 跑5条+出报告）

---

## v0.3 — 规则调优（基于 v0.2 数据）

**启动条件**：v0.2 退出条件全部达成

**预判调优方向**（v0.2 基线数据出来后修正）：
- A-SCOPE：增加预期副产物识别，降低工具链噪声
- A-DECIDE：收窄到架构/库/方案级决策，排除代码风格级
- A-SKIP / A-STEP：评估是否合并

**退出条件**：待 v0.2 基线数据回填

---

## v1.0 — 跨模型验证 · 规则冻结

**启动条件**：v0.3 退出条件全部达成

**核心范围**：
- 规则冻结（连续 2 个版本无精度回归）
- 跨模型验证（>= 3 个不同 LLM）
- 累计真实 `/fa` 记录 >= 50 条
