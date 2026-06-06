# Dogfood 数据采集规范 · v0.2

---

## 文件命名

```
runs/{NNN}-{type}-{slug}.md
```

- `NNN`：三位编号，001 起，单调递增
- `type`：`code` / `refactor` / `debug` / `ops` / `multi`
- `slug`：场景 kebab-case 短描述

示例：`001-code-add-api-endpoint.md`、`005-debug-fix-memory-leak.md`

## 场景类型定义

| type | 含义 | 典型案例 |
|------|------|---------|
| code | 功能开发 | 加 API 端点、实现登录功能 |
| refactor | 重构 | 重构 auth 模块、class 改 hooks |
| debug | 调试修 bug | 测试报错修复、排查内存泄漏 |
| ops | 运维/配置 | 配置 CI/CD、升级依赖 |
| multi | 多步复杂任务 | 按 PRD 实现完整功能、迁移数据库 |

## 必填字段（YAML frontmatter）

```yaml
---
# === 通用字段 ===
runId: FA-YYYYMMDD-NNN
project: FindAction
scannedAt: ISO 8601 UTC
scannerVersion: "0.1.0"
strata: E1 | E2
source: self | ext

# === 输入描述 ===
input:
  type: execution
  summary: <一句话描述 Agent 被要求做什么>
  complexity: simple | medium | complex
  scenarioType: code | refactor | debug | ops | multi
  agentModel: claude-opus-4 | claude-sonnet-4 | other
  toolCallCount: N
  planExists: true | false

# === 结果摘要 ===
result:
  actionsReconstructed: N
  anomaliesFound: N
  totalHits: N
  rulesTriggered: [A-STEP, A-SKIP, ...]
  redCount: N
  orangeCount: N
  yellowCount: N

# === 反馈 ===
feedback:
  collected: true | false
  tp: N
  fp: N
  uncertain: N
---
```

## 正文章节

1. **背景**：Agent 被要求做什么？执行了多长时间？工具调用了多少次？
2. **FindAction 输出**：完整的 `/fa` 输出（原样粘贴）
3. **反馈**：逐条判定表

## 反馈表格式

```markdown
## 反馈

| # | 类型 | 命中描述 | 规则(内部) | 判定 | FP类别 | 理由 |
|---|------|---------|-----------|------|--------|------|
| 1 | 步骤跳过 | "更新 README"未执行 | A-STEP | TP | — | 确实无 README 相关工具调用 |
| 2 | 范围越界 | 修改了 package-lock.json | A-SCOPE | FP | 工具链副产物 | npm install 的预期行为 |
```

- `类型`：步骤跳过 / 静默失败 / 范围越界 / 未声明决策 / 顺序偏差 / 重试标注
- `FP类别`：仅 FP 时填写（工具链副产物 / 探测性失败 / 粒度不匹配 / 代码风格级决策 / 其他）
- `判定`：TP / FP / UNCERTAIN

## 素材合格标准

| 条件 | 要求 |
|------|------|
| 工具调用次数 | >= 3（推荐 >= 10，至少 3 条 run >= 15 次） |
| 执行完整性 | Agent 完成了任务（无论成功失败），不是中途被用户打断 |
| 记录可追溯 | 能回看完整的对话历史和工具调用记录 |
