#!/bin/bash
echo "Starting Data Processor..."
# Legacy argument parsing
ARGS=("api" "--port" "5000")
python3 app.py "${ARGS[@]}"
