# C++ Contest Verifier

A bash script for automatically testing C++ competitive programming solutions by comparing them against a standard solution using randomly generated test cases.

## Features

- **Automated Testing**: Runs multiple test cases automatically
- **Performance Timing**: Measures execution time for both user and standard solutions
- **Flexible Configuration**: Customizable timeout, test count, and input format
- **Detailed Output**: Shows mismatched inputs/outputs when tests fail
- **Cross-platform**: Works on macOS and Linux

## Files

- `verify.sh` - Main verification script
- `gen.cpp` - Test case generator
- `main.cpp` - Your solution to be tested
- `std.cpp` - Standard/reference solution

## Usage

1. **Setup your files**:
   - Modify `gen.cpp` to generate test cases for your problem
   - Implement your solution in `main.cpp`
   - Implement the correct solution in `std.cpp`

2. **Make the script executable**:
   ```bash
   chmod +x verify.sh
   ```

3. **Run the verifier**:
   ```bash
   ./verify.sh
   ```

## Command Line Options

- `--prepend-one` or `-p`: Prepend "1" to each generated test case (useful for problems with multiple test cases)
- `--timeout <seconds>`: Set timeout for each test (default: 3 seconds)
- `--tests <number>`: Set number of test cases to run (default: 100)

### Examples

```bash
# Run with default settings
./verify.sh

# Run 500 tests with 5-second timeout
./verify.sh --tests 500 --timeout 5

# Prepend "1" to each test case and run 50 tests
./verify.sh --prepend-one --tests 50
```

## Requirements

- `clang++` compiler
- `gtimeout` command (install with `brew install coreutils` on macOS)
- `bc` calculator (usually pre-installed)

## How It Works

1. Compiles all three C++ files (`gen.cpp`, `main.cpp`, `std.cpp`)
2. For each test:
   - Generates input using `gen.cpp`
   - Runs both solutions with the same input
   - Compares outputs
   - Measures execution times
3. Reports results and timing statistics

## Example Problem

The included example files implement a simple addition problem:
- Generator creates two random integers
- Both solutions add them together
- Perfect for testing the verifier setup

## Troubleshooting

- **Compilation errors**: Check your C++ syntax in the source files
- **Timeout errors**: Increase timeout or optimize your solution
- **gtimeout not found**: Install coreutils (`brew install coreutils` on macOS)
- **Permission denied**: Make sure the script is executable (`chmod +x verify.sh`)