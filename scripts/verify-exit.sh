#!/bin/bash
# FindAction · 退出条件验证器
# 一键检查 v0.2 ROADMAP 中定义的所有退出条件
#
# 用法: ./scripts/verify-exit.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0
TOTAL=0

check() {
  local name="$1"
  local result="$2"
  local expect="$3"
  TOTAL=$((TOTAL + 1))

  if [ "$result" -ge "$expect" ] 2>/dev/null; then
    echo "  ✅ $name: $result (>= $expect)"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $name: $result (需要 >= $expect)"
    FAIL=$((FAIL + 1))
  fi
}

check_eq() {
  local name="$1"
  local result="$2"
  local expect="$3"
  TOTAL=$((TOTAL + 1))

  if [ "$result" -eq "$expect" ] 2>/dev/null; then
    echo "  ✅ $name: $result == $expect"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $name: $result (需要 == $expect)"
    FAIL=$((FAIL + 1))
  fi
}

echo "FindAction v0.2 退出条件验证"
echo "=============================="
echo ""

# 1. 判定协议存在
TOTAL=$((TOTAL + 1))
if [ -f "$PROJECT_DIR/dogfood/protocol.md" ]; then
  echo "  ✅ 判定协议存在"
  PASS=$((PASS + 1))
else
  echo "  ❌ 判定协议不存在"
  FAIL=$((FAIL + 1))
fi

# 2. >= 15 条记录
run_count=$(find "$PROJECT_DIR/dogfood/runs/" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
check "记录数" "$run_count" 15

# 3. 5 类场景各 >= 2 条
for type in code refactor debug ops multi; do
  c=$(ls "$PROJECT_DIR/dogfood/runs/"*-${type}-*.md 2>/dev/null | wc -l | tr -d ' ')
  check "场景 ${type}" "$c" 2
done

# 4. 基线报告含 7 条规则
if [ -f "$PROJECT_DIR/dogfood/baseline.md" ]; then
  rule_count=$(grep -cE "A-STEP|A-SKIP|A-ORDER|A-RETRY|A-SILENT|A-SCOPE|A-DECIDE" "$PROJECT_DIR/dogfood/baseline.md" 2>/dev/null || echo "0")
  check "基线报告规则覆盖" "$rule_count" 7
else
  TOTAL=$((TOTAL + 1))
  echo "  ❌ 基线报告不存在 (dogfood/baseline.md)"
  FAIL=$((FAIL + 1))
fi

# 5. 有计划 >= 8 条，无计划 >= 4 条
plan_true=$(grep -rl "planExists: true" "$PROJECT_DIR/dogfood/runs/"*.md 2>/dev/null | wc -l | tr -d ' ')
plan_false=$(grep -rl "planExists: false" "$PROJECT_DIR/dogfood/runs/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "有计划记录" "$plan_true" 8
check "无计划记录" "$plan_false" 4

# 6. 反馈完整率
feedback_count=$(grep -rl "collected: true" "$PROJECT_DIR/dogfood/runs/"*.md 2>/dev/null | wc -l | tr -d ' ')
check_eq "反馈完整率" "$feedback_count" "$run_count"

# 7. ROADMAP v0.3 有退出条件
roadmap_exit=$(grep -c "退出条件" "$PROJECT_DIR/ROADMAP.md" 2>/dev/null || echo "0")
check "ROADMAP 退出条件" "$roadmap_exit" 2

echo ""
echo "=============================="
echo "结果: $PASS/$TOTAL 通过, $FAIL 未通过"

if [ "$FAIL" -eq 0 ]; then
  echo "🎉 v0.2 退出条件全部达成！"
  exit 0
else
  echo "⏳ v0.2 尚未完成，$FAIL 项待达成"
  exit 1
fi
