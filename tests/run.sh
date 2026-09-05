#!/usr/bin/env bash
# End-to-end proof that the ProductFlow CLI behaves as specified.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$ROOT/skills/productflow/scripts"
SANDBOX="$(mktemp -d)"
TODAY="$(date +%Y-%m-%d)"
CASE="startup"

cleanup() { rm -rf "$SANDBOX"; }
trap cleanup EXIT

fail() {
  echo "FAILED: $CASE"
  echo "  $1"
  exit 1
}

# Run a pf-* script in the sandbox, capturing output and exit code.
run() {
  local cmd="$1"; shift
  set +e
  OUT="$("$SCRIPTS/$cmd" "$@" 2>"$SANDBOX/.stderr")"
  CODE=$?
  set -e
  ERR="$(cat "$SANDBOX/.stderr")"
}

expect_code() {
  [ "$CODE" -eq "$1" ] || fail "expected exit $1, got $CODE (stdout: $OUT) (stderr: $ERR)"
}

expect_file() {
  [ -f "$1" ] || fail "expected file to exist: $1"
}

expect_dir() {
  [ -d "$1" ] || fail "expected directory to exist: $1"
}

expect_contains() {
  grep -q -- "$2" "$1" || fail "expected $1 to contain: $2"
}

expect_stdout_contains() {
  case "$OUT" in
    *"$1"*) ;;
    *) fail "expected stdout to contain: $1 (got: $OUT)" ;;
  esac
}

cd "$SANDBOX"
git init -q .

# --------------------------------------------------------------------------
CASE="1. pf-init creates the skeleton and is not silently repeatable"
# --------------------------------------------------------------------------
run pf-init --locale vi
expect_code 0
expect_file "$SANDBOX/.productflow/config.json"
expect_file "$SANDBOX/docs/product/PRD.md"
expect_file "$SANDBOX/docs/product/manifest.json"
expect_file "$SANDBOX/docs/product/index.md"
expect_contains "$SANDBOX/.gitignore" ".productflow/runs/"

run pf-init --locale vi
expect_code 3

# --------------------------------------------------------------------------
CASE="2. pf-new-change scaffolds, refuses duplicates and bad slugs"
# --------------------------------------------------------------------------
run pf-new-change add-invoice-pdf --design
expect_code 0
for f in change.md requirements.md design.md tasks.md; do
  expect_file "$SANDBOX/docs/changes/add-invoice-pdf/$f"
done

run pf-new-change add-invoice-pdf --design
expect_code 4

run pf-new-change Bad_Slug
expect_code 2

# --------------------------------------------------------------------------
CASE="3. pf-reqid allocates sequential IDs"
# --------------------------------------------------------------------------
run pf-reqid billing --count 2
expect_code 0
[ "$OUT" = "REQ-BILLING-001
REQ-BILLING-002" ] || fail "unexpected IDs: $OUT"

# --------------------------------------------------------------------------
CASE="4. pf-index maps a real PRD and its requirements"
# --------------------------------------------------------------------------
mkdir -p "$SANDBOX/docs/product/billing/invoicing"
cat > "$SANDBOX/docs/product/billing/invoicing/PRD.md" <<EOF
---
id: product.billing.invoicing
title: Invoicing
type: capability
domain: billing
parent: product.billing
status: active
owner: unassigned
updated: $TODAY
source_changes: []
implements: [src/billing/invoice.ts]
---

# Invoicing

## Summary
Khả năng xuất hoá đơn cho khách hàng.

## Problem & Goals
Khách hàng cần bản PDF để lưu trữ.

## Users & Use Cases
Kế toán tải hoá đơn đã phát hành.

## Requirements

### REQ-BILLING-001: Xuất hoá đơn PDF
**Status**: active
**Statement**: Hệ thống PHẢI cho phép người dùng tải hoá đơn ở định dạng PDF.

#### Scenario: Tải hoá đơn hợp lệ
- **WHEN** người dùng bấm "Tải PDF" trên một hoá đơn đã phát hành
- **THEN** hệ thống trả về file PDF chứa đúng số hoá đơn và tổng tiền

## Behavior Details
Sinh file đồng bộ, không gửi email.

## Interfaces & Data
GET /invoices/:id.pdf

## Out of Scope
Gửi hoá đơn qua email.

## Implementation Map
| Requirement | Code | Tests |
|---|---|---|
| REQ-BILLING-001 | \`src/billing/pdf.ts\` | \`tests/billing/pdf.test.ts\` |

## Open Questions
Không có

## Change Log
| Ngày | Change | Tóm tắt |
|---|---|---|
| $TODAY | add-invoice-pdf | Thêm REQ-BILLING-001 |
EOF

cat > "$SANDBOX/docs/changes/add-invoice-pdf/requirements.md" <<'EOF'
---
change: add-invoice-pdf
---

# Delta requirements

## ADDED Requirements

### REQ-BILLING-001: Xuất hoá đơn PDF
**Target**: product.billing.invoicing
**Status**: active
**Statement**: Hệ thống PHẢI cho phép người dùng tải hoá đơn ở định dạng PDF.

#### Scenario: Tải hoá đơn hợp lệ
- **WHEN** người dùng bấm "Tải PDF" trên một hoá đơn đã phát hành
- **THEN** hệ thống trả về file PDF chứa đúng số hoá đơn và tổng tiền

## MODIFIED Requirements

## REMOVED Requirements

## RENAMED Requirements
EOF

cat > "$SANDBOX/docs/changes/add-invoice-pdf/tasks.md" <<'EOF'
---
change: add-invoice-pdf
---

# Tasks

## 1. Renderer

- [ ] 1.1 Thêm hàm render PDF — verify: `echo ok`
  - Requirements: REQ-BILLING-001
  - Files: create `src/billing/pdf.ts`, create `tests/billing/pdf.test.ts`
  - Steps: viết test đỏ → chạy thấy fail → implement tối thiểu → chạy xanh → commit
EOF

run pf-index
expect_code 0
expect_contains "$SANDBOX/docs/product/manifest.json" "REQ-BILLING-001"
expect_contains "$SANDBOX/docs/product/manifest.json" '"scenarios": 1'
expect_contains "$SANDBOX/docs/product/index.md" "product.billing.invoicing"
expect_contains "$SANDBOX/docs/product/index.md" "generated by pf-index; do not edit"

# --------------------------------------------------------------------------
CASE="5. pf-validate passes clean, catches a broken scenario"
# --------------------------------------------------------------------------
run pf-validate --json
expect_code 0
expect_stdout_contains '"findings": []'

PRD="$SANDBOX/docs/product/billing/invoicing/PRD.md"
cp "$PRD" "$SANDBOX/.prd.bak"
grep -v '\*\*THEN\*\* hệ thống trả về file PDF' "$PRD" > "$SANDBOX/.prd.tmp"
mv "$SANDBOX/.prd.tmp" "$PRD"

run pf-validate
expect_code 1
expect_stdout_contains "scenario-no-when-then"

cp "$SANDBOX/.prd.bak" "$PRD"
run pf-validate
expect_code 0

# --------------------------------------------------------------------------
CASE="6. pf-archive blocks on open tasks, then archives"
# --------------------------------------------------------------------------
run pf-archive add-invoice-pdf
expect_code 5

sed 's/- \[ \]/- [x]/' "$SANDBOX/docs/changes/add-invoice-pdf/tasks.md" > "$SANDBOX/.tasks.tmp"
mv "$SANDBOX/.tasks.tmp" "$SANDBOX/docs/changes/add-invoice-pdf/tasks.md"

run pf-archive add-invoice-pdf
expect_code 0
expect_dir "$SANDBOX/docs/changes/archive/$TODAY-add-invoice-pdf"
expect_contains "$SANDBOX/docs/changes/archive/$TODAY-add-invoice-pdf/change.md" "status: archived"
expect_contains "$SANDBOX/docs/changes/archive/$TODAY-add-invoice-pdf/change.md" "archived: $TODAY"
[ ! -d "$SANDBOX/docs/changes/add-invoice-pdf" ] || fail "change folder should have been moved"

# --------------------------------------------------------------------------
CASE="7. pf-archive blocks when the delta was never merged"
# --------------------------------------------------------------------------
run pf-new-change add-invoice-email
expect_code 0
cat > "$SANDBOX/docs/changes/add-invoice-email/requirements.md" <<'EOF'
---
change: add-invoice-email
---

# Delta requirements

## ADDED Requirements

### REQ-BILLING-003: Gửi hoá đơn qua email
**Target**: product.billing.invoicing
**Status**: active
**Statement**: Hệ thống PHẢI gửi hoá đơn qua email sau khi phát hành.

#### Scenario: Gửi thành công
- **WHEN** một hoá đơn được phát hành
- **THEN** hệ thống gửi email kèm file PDF tới người mua

## MODIFIED Requirements

## REMOVED Requirements

## RENAMED Requirements
EOF

run pf-archive add-invoice-email
expect_code 6
case "$ERR" in
  *REQ-BILLING-003*) ;;
  *) fail "expected the unmerged ID in stderr, got: $ERR" ;;
esac

# --------------------------------------------------------------------------
echo "ALL TESTS PASSED"
exit 0
