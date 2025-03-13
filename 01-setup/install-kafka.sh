#!/bin/bash
# 01-setup/install-kafka.sh

# Download and install Apache Kafka to the project folder
# Kafka supports JDK 8, 11, 17, and 23.
# We'll use OpenJDK 17 for compatibility with Spark and Flink.

# See:
# - https://kafka.apache.org/documentation/#compatibility
# - https://kafka.apache.org/downloads

# TODO: Change KAFKA_VERSION to the desired version if needed
KAFKA_VERSION="4.0.0"
SCALA_VERSION="2.13"
KAFKA_FOLDER="kafka"
JDK_FOLDER="jdk"

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

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo "❌ 'curl' not installed. Please install it and try again."
    exit 1
fi

# Create the folder if it doesn't exist
mkdir -p "$KAFKA_FOLDER"

# Construct download URL
DOWNLOAD_URL="https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz"

# Download Kafka if not already present
if [ ! -f "$KAFKA_FOLDER/bin/kafka-server-start.sh" ]; then
    echo "📥 Downloading Apache Kafka $KAFKA_VERSION (Scala $SCALA_VERSION)..."
    curl -L -o kafka.tgz "$DOWNLOAD_URL"

    echo "📦 Extracting Kafka..."
    tar -xvf kafka.tgz -C "$KAFKA_FOLDER" --strip-components=1
    rm kafka.tgz
    echo "✅ Kafka $KAFKA_VERSION installed successfully."
else
    echo "✅ Kafka $KAFKA_VERSION already installed."
fi

# Confirm Kafka binary exists
if [ ! -f "$KAFKA_FOLDER/bin/kafka-server-start.sh" ]; then
    echo "❌ Kafka installation failed. Cleaning up..."
    rm -rf "$KAFKA_FOLDER"
    exit 1
fi

# Set temporary JAVA_HOME (NOT exported)
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$(pwd)/$KAFKA_FOLDER/bin:$PATH"

echo "🚀 Using temporary JAVA_HOME=$JAVA_HOME"

# Test the Kafka install (list existing topics)
if kafka-topics.sh --list --bootstrap-server localhost:9092; then
    echo "✅ Kafka $KAFKA_VERSION installed and working correctly."
else
    echo "⚠️ Kafka is installed but not running. Start the server to verify."
fi

# Display quick instructions for starting Kafka
echo ""
echo "➡️ To start Kafka server:"
echo "./$KAFKA_FOLDER/bin/kafka-server-start.sh $KAFKA_FOLDER/config/server.properties"

