#!/bin/bash
# 02-scripts/run-pyspark.sh

# Run PySpark using the local JDK and Spark install
# This script sets JAVA_HOME only for this session (NOT exported)
# Works on Linux, macOS, and WSL

SPARK_FOLDER="spark"
JDK_FOLDER="jdk"
LOG_FILE="pyspark.log"
DRIVER_MEMORY="2g"
EXECUTOR_MEMORY="2g"

# Fail fast on any errors
set -e

# Step 1: Detect platform (macOS, Linux, WSL)
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    PLATFORM="osx"
elif [ "$OS" = "Linux" ]; then
    PLATFORM="linux"
else
    echo "ERROR: Unsupported platform: $OS"
    exit 1
fi

echo "✅ Detected platform: $PLATFORM"

# Step 2: Confirm Spark installation
if [ ! -f "$SPARK_FOLDER/bin/pyspark" ]; then
    echo "ERROR: PySpark installation not found in $SPARK_FOLDER."
    echo "Please install Spark and try again."
    exit 1
fi
echo "✅ Spark installation detected in $SPARK_FOLDER"

# Step 3: Confirm Java installation
# Set temporary JAVA_HOME (not exported)
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$(pwd)/$SPARK_FOLDER/bin:$PATH"

# Test Java works locally without modifying system-wide settings
if ! "$JAVA_HOME/bin/java" -version &> /dev/null; then
    echo "ERROR: JAVA_HOME is not set correctly or Java installation is invalid."
    echo "Confirm JDK is installed at $JAVA_HOME or try reinstalling JDK."
    exit 1
fi
echo "✅ Java detected at $JAVA_HOME"

# Step 4: Check if PySpark is already running
if pgrep -f org.apache.spark.deploy.SparkSubmit > /dev/null; then
    echo "PySpark is already running."
    echo "Use 'pkill -f pyspark' to stop it before restarting."
    exit 1
fi

# Step 5: Adjust memory settings based on available system memory
# Use available memory to configure driver and executor settings
TOTAL_MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || sysctl -n hw.memsize 2>/dev/null || echo "0")

if [[ "$TOTAL_MEM" -gt 8000 ]]; then
    DRIVER_MEMORY="4g"
    EXECUTOR_MEMORY="4g"
elif [[ "$TOTAL_MEM" -gt 16000 ]]; then
    DRIVER_MEMORY="8g"
    EXECUTOR_MEMORY="8g"
fi

echo "✅ Starting PySpark with driver memory: $DRIVER_MEMORY and executor memory: $EXECUTOR_MEMORY..."

# Step 6: Handle log rotation (to prevent log overflow)
if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S)"
    echo "✅ Rotated old log file."
fi

# Step 7: Start PySpark (in local mode)
echo "✅ Starting PySpark with driver memory: $DRIVER_MEMORY and executor memory: $EXECUTOR_MEMORY..."
echo "➡️ PySpark will open in your default browser at http://localhost:4040"
"$SPARK_FOLDER/bin/pyspark" \
    --master local[*] \
    --driver-memory "$DRIVER_MEMORY" \
    --executor-memory "$EXECUTOR_MEMORY" > "$LOG_FILE" 2>&1

# Step 8: Wait for PySpark to start
sleep 5

# Step 9: Check if PySpark actually started
if pgrep -f org.apache.spark.deploy.SparkSubmit > /dev/null; then
    echo "✅ PySpark is running."
    echo "Log file: $LOG_FILE"
else
    echo "ERROR: PySpark failed to start. Check the log for details:"
    echo "$LOG_FILE"
    exit 1
fi

# Step 10: Instructions for stopping PySpark
echo ""
echo "To stop PySpark:"
echo "pkill -f pyspark"
echo ""
echo "To test PySpark in the shell:"
echo "./$SPARK_FOLDER/bin/pyspark"
echo ""

# Step 11: Stream logs (Press Ctrl + C to exit)
echo "Streaming logs. Press Ctrl + C to stop."
tail -f "$LOG_FILE"
