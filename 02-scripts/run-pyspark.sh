#!/bin/bash
# 02-scripts/run-pyspark.sh

# Run PySpark using the local JDK and Spark install

SPARK_FOLDER="spark"
JDK_FOLDER="jdk"
LOG_FILE="pyspark.log"
DRIVER_MEMORY="2g"
EXECUTOR_MEMORY="2g"

# Fail fast on errors
set -e

# Detect platform (macOS, Linux, WSL)
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    PLATFORM="osx"
elif [ "$OS" = "Linux" ]; then
    PLATFORM="linux"
else
    echo "❌ Unsupported platform: $OS"
    exit 1
fi

# Set JAVA_HOME only for this session (NOT exported)
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$(pwd)/$SPARK_FOLDER/bin:$PATH"

echo "🚀 Using temporary JAVA_HOME=$JAVA_HOME"

# Ensure Spark install exists
if [ ! -f "$SPARK_FOLDER/bin/pyspark" ]; then
    echo "❌ PySpark installation not found. Please run install-pyspark.sh first."
    exit 1
fi

# Check if PySpark is already running
if pgrep -f org.apache.spark.deploy.SparkSubmit > /dev/null; then
    echo "⚠️ PySpark is already running."
    echo "Use 'pkill -f pyspark' to stop it before restarting."
    exit 1
fi

# Adjust memory settings based on available system memory (if needed)
TOTAL_MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || sysctl -n hw.memsize 2>/dev/null || echo "0")

if [[ "$TOTAL_MEM" -gt 8000 ]]; then
    DRIVER_MEMORY="4g"
    EXECUTOR_MEMORY="4g"
elif [[ "$TOTAL_MEM" -gt 16000 ]]; then
    DRIVER_MEMORY="8g"
    EXECUTOR_MEMORY="8g"
fi

echo "📢 Starting PySpark with driver memory: $DRIVER_MEMORY and executor memory: $EXECUTOR_MEMORY..."

# Set log rotation (limit log size to avoid overflow)
if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S)"
fi

# Start PySpark (in local mode)
nohup "$SPARK_FOLDER/bin/pyspark" \
    --master local[*] \
    --driver-memory "$DRIVER_MEMORY" \
    --executor-memory "$EXECUTOR_MEMORY" > "$LOG_FILE" 2>&1 &

# Wait for PySpark to start
sleep 5

# Check if PySpark is actually running
if pgrep -f org.apache.spark.deploy.SparkSubmit > /dev/null; then
    echo "✅ PySpark is running."
    echo "➡️ Log file: $LOG_FILE"
else
    echo "❌ PySpark failed to start. Check $LOG_FILE for details."
    exit 1
fi

# Instructions for stopping PySpark
echo ""
echo "➡️ To stop PySpark:"
echo "pkill -f pyspark"
echo ""
echo "➡️ To test PySpark in the shell:"
echo "./$SPARK_FOLDER/bin/pyspark"
echo ""

# Keep the script open to allow logs to stream
echo "➡️ Press Ctrl + C to stop streaming logs."
tail -f "$LOG_FILE"
