#!/bin/bash
# FindAction · Dogfood 记录模板生成器
# 自动创建下一条 run 记录文件，预填 frontmatter 和章节结构
#
# 用法: ./scripts/new-run.sh <type> <slug>
# 示例: ./scripts/new-run.sh code add-api-endpoint
#       ./scripts/new-run.sh debug fix-memory-leak
#
# type: code | refactor | debug | ops | multi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RUNS_DIR="$PROJECT_DIR/dogfood/runs"

if [ $# -lt 2 ]; then
  echo "用法: $0 <type> <slug>"
  echo "type: code | refactor | debug | ops | multi"
  echo "示例: $0 code add-api-endpoint"
  exit 1
fi

TYPE="$1"
SLUG="$2"

case "$TYPE" in
  code|refactor|debug|ops|multi) ;;
  *) echo "无效的 type: $TYPE (可选: code/refactor/debug/ops/multi)" && exit 1 ;;
esac

mkdir -p "$RUNS_DIR"

LAST_NUM=$(ls "$RUNS_DIR"/*.md 2>/dev/null | sed 's/.*\///' | grep -oE '^[0-9]+' | sort -n | tail -1 || echo "0")
NEXT_NUM=$(printf "%03d" $((10#${LAST_NUM:-0} + 1)))

TODAY=$(date -u +"%Y%m%d")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FILENAME="${NEXT_NUM}-${TYPE}-${SLUG}.md"
FILEPATH="$RUNS_DIR/$FILENAME"

cat > "$FILEPATH" <<EOF
---
runId: FA-${TODAY}-${NEXT_NUM}
project: FindAction
scannedAt: ${TIMESTAMP}
scannerVersion: "0.1.0"
strata: E1
source: self

input:
  type: execution
  summary: ""
  complexity: medium
  scenarioType: ${TYPE}
  agentModel: claude-opus-4
  toolCallCount: 0
  planExists: true

result:
  actionsReconstructed: 0
  anomaliesFound: 0
  totalHits: 0
  rulesTriggered: []
  redCount: 0
  orangeCount: 0
  yellowCount: 0

feedback:
  collected: false
  tp: 0
  fp: 0
  uncertain: 0
---

## 背景

Agent 被要求做什么？执行了多长时间？工具调用了多少次？

## FindAction 输出

\`\`\`
（粘贴完整的 /fa 输出）
\`\`\`

## 反馈

| # | 类型 | 命中描述 | 规则(内部) | 判定 | FP类别 | 理由 |
|---|------|---------|-----------|------|--------|------|
| 1 | | | | | — | |
EOF

echo "已创建: $FILEPATH"
