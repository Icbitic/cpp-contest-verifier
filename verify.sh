#!/bin/bash
set -e

# Defaults
PREPEND_ONE=false
TIMEOUT=3
TESTS=100

usage() {
    echo "Usage: $0 [--prepend-one|-p] [--timeout seconds] [--tests number]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prepend-one|-p)
            PREPEND_ONE=true
            shift
            ;;
        --timeout)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                TIMEOUT="$2"
                shift 2
            else
                echo "Error: --timeout requires a numeric argument"
                usage
            fi
            ;;
        --tests)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                TESTS="$2"
                shift 2
            else
                echo "Error: --tests requires a numeric argument"
                usage
            fi
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
done

DIR="$(pwd)"
GEN="$DIR/gen.cpp"
MAIN="$DIR/main.cpp"
STD="$DIR/std.cpp"
GEN_EXE="$DIR/gen.o"
USR_EXE="$DIR/usr.o"
STD_EXE="$DIR/std.o"
INPUT="$DIR/input.txt"
USER_OUT="$DIR/user.txt"
STD_OUT="$DIR/std.txt"

clang++ -w "$GEN" -o "$GEN_EXE"
clang++ -w "$MAIN" -o "$USR_EXE"
clang++ -w "$STD" -o "$STD_EXE"

echo "[✓] All programs compiled."
echo "[i] Settings: prepend_one=$PREPEND_ONE, timeout=${TIMEOUT}s, tests=$TESTS"

# Variables to accumulate total time in nanoseconds
total_user_ns=0
total_std_ns=0

for ((i = 1; i <= TESTS; i++)); do
    echo "[→] Running test #$i"

    "$GEN_EXE" > "$DIR/gen_raw.txt"

    if $PREPEND_ONE; then
        echo "1" > "$INPUT"
        cat "$DIR/gen_raw.txt" >> "$INPUT"
    else
        cp "$DIR/gen_raw.txt" "$INPUT"
    fi

    # Time user solution
    start_user=$(date +%s%N)
    if ! gtimeout "${TIMEOUT}s" "$USR_EXE" < "$INPUT" > "$USER_OUT"; then
        echo "[✗] ❌ User solution timed out or crashed on test #$i"
        echo "=== Input ==="
        cat "$INPUT"
        exit 1
    fi
    end_user=$(date +%s%N)
    elapsed_user=$((end_user - start_user))
    total_user_ns=$((total_user_ns + elapsed_user))

    # Time standard solution
    start_std=$(date +%s%N)
    if ! gtimeout "${TIMEOUT}s" "$STD_EXE" < "$INPUT" > "$STD_OUT"; then
        echo "[✗] ❌ Standard solution timed out or crashed on test #$i"
        echo "=== Input ==="
        cat "$INPUT"
        exit 1
    fi
    end_std=$(date +%s%N)
    elapsed_std=$((end_std - start_std))
    total_std_ns=$((total_std_ns + elapsed_std))

    # Compare outputs
    if ! diff -q "$USER_OUT" "$STD_OUT" > /dev/null; then
        echo -e "\n[!] ❌ Mismatch found on test #$i"
        echo "=== Input ==="
        cat "$INPUT"
        echo "=== Your Output ==="
        cat "$USER_OUT"
        echo "=== Expected Output ==="
        cat "$STD_OUT"
        exit 1
    fi

    # Optional: print times per test if you want
    # echo "User time: $((elapsed_user / 1000000)) ms, Std time: $((elapsed_std / 1000000)) ms"
done

echo -e "\n[✓] All tests passed."

# Print total and average times in seconds with millisecond precision
total_user_sec=$(echo "scale=3; $total_user_ns / 1000000000" | bc)
total_std_sec=$(echo "scale=3; $total_std_ns / 1000000000" | bc)
avg_user_sec=$(echo "scale=3; $total_user_ns / $TESTS / 1000000000" | bc)
avg_std_sec=$(echo "scale=3; $total_std_ns / $TESTS / 1000000000" | bc)

echo "[i] User solution total time: ${total_user_sec}s, average per test: ${avg_user_sec}s"
echo "[i] Std solution total time: ${total_std_sec}s, average per test: ${avg_std_sec}s"