#!/bin/bash

# Make script exit if any command fails
set -e

# Change to project directory (if needed)
cd "$(dirname "$0")/.."

# Run Flutter with verbose flags but filter output
flutter run "$@" 2>&1 | grep -i -E '(MenciMeter|error:|exception:)' 