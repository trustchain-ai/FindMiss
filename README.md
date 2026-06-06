# FindMiss

**简体中文** | **English**

> **Agent 说"搞定了"——你的要求它真的全做了吗？**
> **The Agent says "done" — did it actually do everything you asked?**
>
> FindMiss 逐条比对你的原始要求和 Agent 的交付结果，找出遗漏的需求和未声明的隐藏假设。让你看到结果里藏着什么。
> FindMiss cross-checks your original requirements against the Agent's deliverables, surfaces missed requirements and hidden assumptions. Shows you what's buried in the result.

<p align="center">
  <a href="LICENSE">MIT</a> · <a href="CONTRIBUTING.md">Contribute</a>
</p>

---

## 它解决什么问题 / What problem it solves

Agent 交付了一份看起来完美的结果。但你不知道：
The Agent delivered seemingly perfect results. But you don't know:

- 你的 5 条要求它只做了 3 条？/ It only fulfilled 3 of your 5 requirements?
- 它默认用了 PostgreSQL 但你想要 MySQL？/ It defaulted to PostgreSQL when you wanted MySQL?
- 它跳过了所有错误处理？/ It skipped all error handling?
- 它假设了 UTC 时区但你的用户在中国？/ It assumed UTC but your users are in China?

FindMiss 让你看清楚。不判对错，只照出遗漏和假设。
FindMiss makes it visible. No judgment — just missed items and hidden assumptions.

## 现在就试 / Try it now

告诉你的 AI agent / Tell your AI agent:

> 帮我装上 github.com/290963249/FindMiss 的 FindMiss skill
> Install the FindMiss skill from github.com/290963249/FindMiss

或手动复制 `skill/FindMiss.skill.md` 到 skills 目录。
Or copy `skill/FindMiss.skill.md` into your skills directory.

```text
/findmiss 对比一下我的要求和实际交付
/fm 漏了什么
查遗漏
```

**适合：** Agent 交付了结果，你想知道它有没有漏掉什么。
**Use when:** After an Agent delivered results and you want to check if anything was missed.

**不适合：** 审 prompt 质量（用 FindGap）、审执行过程（用 FindAction）。
**Skip when:** Reviewing prompt quality (use FindGap) or auditing execution process (use FindAction).

## FindMiss 输出长什么样 / What the output looks like

```
FindMiss · 比对 5 条要求，发现 2 处遗漏，3 个隐藏假设

---

❌ 遗漏 · 密码错误锁定机制

原始要求："密码错误超过 3 次应锁定账号"
交付状态：未找到锁定逻辑的实现
影响范围：暴力破解攻击无防护

---

❌ 遗漏 · 单元测试

原始要求："写测试覆盖核心逻辑"
交付状态：未找到测试文件
影响范围：无法验证功能正确性

---

🔶 隐藏假设 · 数据库选型

Agent 的决定：使用 PostgreSQL
用户是否提到：未提到
影响：如果团队使用 MySQL，需要迁移成本
建议：确认此假设是否符合你的预期

---

🔶 隐藏假设 · 密码长度

Agent 的决定：密码最少 8 位
用户是否提到：未提到
影响：可能不符合企业安全策略要求
建议：确认此假设是否符合你的预期

---

📊 要求覆盖度

| 要求 | 状态 |
|-----|------|
| 用户登录功能 | ✅ 已覆盖 |
| 密码错误锁定 | ❌ 遗漏 |
| JWT 鉴权 | ✅ 已覆盖 |
| 写测试 | ❌ 遗漏 |
| 更新文档 | ✅ 已覆盖 |

覆盖 3/5（60%）
```

## 它怎么工作 / How it works

6 条内部规则提取原始要求 → 逐条比对交付 → 扫描隐藏假设 → 检查领域惯例。
6 internal rules extract original requirements → cross-check deliverables → scan hidden assumptions → check domain conventions.

- 每条遗漏必须追溯到原始要求原文 / Every miss traces back to original requirement text
- 隐藏假设必须指出 Agent 替你做了什么决定 / Hidden assumptions must state what the Agent decided for you
- 领域惯例标为"建议"不标为"遗漏" / Domain conventions are "suggestions," not "misses"
- 不判断对错，只陈述覆盖事实 / No judgment, just coverage facts

## 三节点家族 / The Trust Chain

```
FindGap    事前    你的请求缺了什么    /fg
FindAction 事中    Agent 做了什么      /fa
FindMiss   事后    结果漏了什么        /fm  ← 你在这里
```

> **让不可信变得可见。**
> FindGap 找出请求的缺口，FindAction 打开执行的黑盒，FindMiss 照出交付的遗漏。

## Contribute

FindMiss 抓到了真遗漏，或误报了？→ [Discussions](https://github.com/290963249/FindMiss/discussions)

改规则或加案例 → `skill/FindMiss.skill.md` → [CONTRIBUTING.md](CONTRIBUTING.md)

---

MIT · [GitHub](https://github.com/290963249/FindMiss) · v0.1
