#!/usr/bin/env bash
# System integration tests for AIRA
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="$PROJECT_ROOT/tests/integration"

echo "🧪 Running AIRA System Tests"
echo "=============================="
echo ""

# Run all integration tests
FAILED_TESTS=0

run_test() {
    local test_script=$1
    local test_name=$(basename "$test_script" .sh)
    
    echo "Running: $test_name"
    if bash "$test_script"; then
        echo "✅ $test_name passed"
    else
        echo "❌ $test_name failed"
        ((FAILED_TESTS++))
    fi
    echo ""
}

# Run tests
if [ -d "$TEST_DIR" ]; then
    for test in "$TEST_DIR"/test_*.sh; do
        if [ -f "$test" ]; then
            run_test "$test"
        fi
    done
else
    echo "⚠️  No integration tests found"
fi

# Summary
echo "=============================="
if [ $FAILED_TESTS -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ $FAILED_TESTS test(s) failed"
    exit 1
fi
