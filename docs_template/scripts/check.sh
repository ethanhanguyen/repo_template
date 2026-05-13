#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass()  { echo -e "${GREEN}PASS${NC} $1"; }
fail()  { echo -e "${RED}FAIL${NC} $1"; exit 1; }

echo "=== Lint ==="
{lint_cmd} && pass "lint" || fail "lint"

echo "=== Typecheck ==="
{typecheck_cmd} && pass "typecheck" || fail "typecheck"

echo "=== Tests + Coverage ==="
{test_cmd} && pass "tests" || fail "tests"

echo "=== Build ==="
{build_cmd} && pass "build" || fail "build"

echo "=== Debug prints ==="
grep -rn "{debug_print_pattern}" src/ {source_include} \
  && fail "debug prints found" \
  || pass "no debug prints"

echo "=== TODOs ==="
grep -rn "{todo_pattern}" src/ {source_include} || true

echo "=== Env reads outside config ==="
grep -rn "{env_read_pattern}" src/ {source_include} --exclude-dir={config_dir} \
  && fail "raw env reads outside {config_dir}" \
  || pass "env reads clean"

echo "=== Secrets ==="
grep -rnE "(api[_-]?key|secret|password|token)\s*=" src/ {source_include} --exclude-dir={config_dir} \
  && fail "secrets found in source" \
  || pass "no secrets"

echo -e "\n${GREEN}All gates passed${NC}"
