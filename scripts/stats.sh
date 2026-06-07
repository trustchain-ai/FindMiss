#!/bin/bash
# FindAction · 基线统计生成器
# 从 dogfood/runs/*.md 中提取反馈数据，生成按规则的精度统计
#
# 用法: ./scripts/stats.sh [--output dogfood/baseline.md]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RUNS_DIR="$PROJECT_DIR/dogfood/runs"
OUTPUT="${1:---stdout}"

RULES=("A-STEP" "A-SKIP" "A-ORDER" "A-RETRY" "A-SILENT" "A-SCOPE" "A-DECIDE")

declare -A RULE_HIT RULE_TP RULE_FP RULE_UNCERTAIN
for r in "${RULES[@]}"; do
  RULE_HIT[$r]=0
  RULE_TP[$r]=0
  RULE_FP[$r]=0
  RULE_UNCERTAIN[$r]=0
done

TOTAL_RUNS=0
TOTAL_HITS=0
TOTAL_TP=0
TOTAL_FP=0
TOTAL_UNCERTAIN=0

if [ ! -d "$RUNS_DIR" ] || [ -z "$(ls "$RUNS_DIR"/*.md 2>/dev/null)" ]; then
  echo "未找到 dogfood/runs/*.md 记录文件。请先跑 /fa 记录。" >&2
  exit 1
fi

for run_file in "$RUNS_DIR"/*.md; do
  TOTAL_RUNS=$((TOTAL_RUNS + 1))

  run_tp=$(grep -oP 'tp:\s*\K\d+' "$run_file" 2>/dev/null | head -1 || echo "0")
  run_fp=$(grep -oP 'fp:\s*\K\d+' "$run_file" 2>/dev/null | head -1 || echo "0")
  run_uncertain=$(grep -oP 'uncertain:\s*\K\d+' "$run_file" 2>/dev/null | head -1 || echo "0")

  TOTAL_TP=$((TOTAL_TP + run_tp))
  TOTAL_FP=$((TOTAL_FP + run_fp))
  TOTAL_UNCERTAIN=$((TOTAL_UNCERTAIN + run_uncertain))

  for r in "${RULES[@]}"; do
    rule_hits=$(grep -c "$r" "$run_file" 2>/dev/null || true)
    rule_tp=$(grep "$r" "$run_file" 2>/dev/null | grep -c "TP" || true)
    rule_fp=$(grep "$r" "$run_file" 2>/dev/null | grep -c "FP" || true)
    rule_unc=$(grep "$r" "$run_file" 2>/dev/null | grep -c "UNCERTAIN" || true)

    RULE_HIT[$r]=$((${RULE_HIT[$r]} + rule_hits))
    RULE_TP[$r]=$((${RULE_TP[$r]} + rule_tp))
    RULE_FP[$r]=$((${RULE_FP[$r]} + rule_fp))
    RULE_UNCERTAIN[$r]=$((${RULE_UNCERTAIN[$r]} + rule_unc))
  done
done

TOTAL_HITS=$((TOTAL_TP + TOTAL_FP + TOTAL_UNCERTAIN))

if [ "$TOTAL_HITS" -gt 0 ]; then
  OVERALL_PRECISION=$(echo "scale=4; $TOTAL_TP / ($TOTAL_TP + $TOTAL_FP)" | bc 2>/dev/null || echo "N/A")
else
  OVERALL_PRECISION="N/A"
fi

generate_report() {
  cat <<REPORT
# FindAction v0.2 基线报告

> 样本：dogfood/runs/ 共 ${TOTAL_RUNS} 条真实 \`/fa\` 记录
>
> 口径：仅统计 7 条规则；按反馈表中的规则代号和判定计数
>
> 生成时间：$(date -u +"%Y-%m-%dT%H:%M:%SZ")

## 分规则结果

| 规则 | 命中 | TP | FP | UNCERTAIN | precision |
|------|-----:|---:|---:|----------:|----------:|
REPORT

  for r in "${RULES[@]}"; do
    hits=${RULE_HIT[$r]}
    tp=${RULE_TP[$r]}
    fp=${RULE_FP[$r]}
    unc=${RULE_UNCERTAIN[$r]}
    if [ $((tp + fp)) -gt 0 ]; then
      prec=$(echo "scale=4; $tp / ($tp + $fp)" | bc 2>/dev/null || echo "N/A")
    else
      prec="N/A"
    fi
    echo "| $r | $hits | $tp | $fp | $unc | $prec |"
  done

  cat <<REPORT

## 总量聚合

| 指标 | 数值 |
|------|-----:|
| runCount | ${TOTAL_RUNS} |
| totalHits | ${TOTAL_HITS} |
| totalTp | ${TOTAL_TP} |
| totalFp | ${TOTAL_FP} |
| totalUncertain | ${TOTAL_UNCERTAIN} |
| overall precision | ${OVERALL_PRECISION} |

## 需优先调优

（基于以上数据，precision 最低的 2 条规则）

## 高频模式

（从数据中归纳的 top-N 模式，手动补充）

## FP 分类统计

（从反馈表的 FP 类别列中聚合，手动补充）
REPORT
}

if [ "$OUTPUT" = "--stdout" ]; then
  generate_report
else
  output_file="${OUTPUT#--output }"
  generate_report > "$output_file"
  echo "基线报告已生成：$output_file"
fi
