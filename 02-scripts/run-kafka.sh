#!/bin/bash
# 02-scripts/run-kafka.sh

# Run Kafka using the local JDK
KAFKA_FOLDER="kafka"
JDK_FOLDER="jdk"
LOG_FILE="kafka.log"
PORT=9092

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
PATH="$JAVA_HOME/bin:$(pwd)/$KAFKA_FOLDER/bin:$PATH"

echo "🚀 Using temporary JAVA_HOME=$JAVA_HOME"

# Ensure Kafka install exists
if [ ! -f "$KAFKA_FOLDER/bin/kafka-server-start.sh" ]; then
    echo "❌ Kafka installation not found. Please run install-kafka.sh first."
    exit 1
fi

# Check if port is already in use
if lsof -i :$PORT &> /dev/null; then
    echo "⚠️ Port $PORT is already in use."
    echo "Stopping existing Kafka process..."
    pkill -f kafka.Kafka || true
    sleep 2
fi

# Check for existing Kafka process (prevent accidental duplicates)
if pgrep -f kafka.Kafka > /dev/null; then
    echo "⚠️ Kafka is already running."
    echo "Use './kafka/bin/kafka-server-stop.sh' to stop it before restarting."
    exit 1
fi

# Set log rotation (limit log file size to prevent disk overflow)
if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S)"
fi

# Start Kafka broker in an isolated environment (use KRaft mode)
echo "📢 Starting Kafka broker..."
nohup "$KAFKA_FOLDER/bin/kafka-server-start.sh" "$KAFKA_FOLDER/config/server.properties" > "$LOG_FILE" 2>&1 &

# Wait for Kafka to start
sleep 5

# Check if Kafka is running
if pgrep -f kafka.Kafka > /dev/null; then
    echo "✅ Kafka broker is running on port $PORT."
    echo "➡️ Log file: $LOG_FILE"
else
    echo "❌ Kafka broker failed to start. Check $LOG_FILE for details."
    exit 1
fi

# Instructions for stopping Kafka
echo ""
echo "➡️ To stop Kafka:"
echo "./kafka/bin/kafka-server-stop.sh"
echo ""
echo "➡️ To list Kafka topics:"
echo "./kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:$PORT"
echo ""

# Keep the script open to allow logs to stream
echo "➡️ Press Ctrl + C to stop streaming logs."
tail -f "$LOG_FILE"
