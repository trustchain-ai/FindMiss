# Contributing to FindMiss

FindMiss 抓到了真遗漏，或误报了？欢迎贡献。

## 怎么贡献

### 报告误判或漏判

在 [Discussions](https://github.com/trustchain-ai/FindMiss/discussions) 中提供：

1. 用户的原始要求（prompt）
2. Agent 的交付结果
3. FindMiss 的输出
4. 你认为它判对了还是判错了，以及理由

### 改进规则

编辑 `skill/FindMiss.skill.md`，提交 PR。

规则修改需说明：
- 改了哪条规则
- 为什么改（附真实案例）
- 改完后的预期效果

### 添加案例

在 `examples/` 下添加真实的 FindMiss 输出案例。格式参考已有文件。

## 原则

- 不引入新规则，除非有真实案例证明需要
- 不扩大 FindMiss 的职责范围（只找遗漏和假设，不判对错）
- 不破坏红线（每条遗漏必须追溯原文、不凭空发明需求）
