# FindAction · CHANGELOG

## v0.2.0 — 2026-06-06 · 15-run baseline · 精度基线

### 核心转向

**FROM**：设计驱动（规则是设计出来的，从未在真实场景验证）
**TO**：数据驱动（15 条真实 `/fa` 记录建立精度基线）

### 核心变更

- 新增 `dogfood/` 体系：protocol.md（判定协议）+ conventions.md（记录规范）
- 新增 ROADMAP.md
- 新增 CHANGELOG.md
- 15 条真实 `/fa` 记录（进行中）

### 不变

- 7 条规则文本不变（先跑后调）
- 输出格式不变
- 4 条红线不变

---

## v0.1.0 — 2026-06-06 · 首次发布

### 核心发布

- 7 条审查规则（A-STEP / A-SKIP / A-ORDER / A-RETRY / A-SILENT / A-SCOPE / A-DECIDE）
- 三节点执行流程：采（收集证据）→ 审（还原+比对）→ 出结果（动作清单）
- 4 条红线：只审过程不审内容、缺证据默认未执行、self-report≠proof、不替用户判断
- Trust Chain 第二节点

### 真实状态

规则设计完成，未经生产验证。
