#!/bin/bash
# 01-setup/install-pyspark.sh

# Download and install Apache Spark to the project folder
# Spark supports JDK 8, 11, and 17 (NOT 18 or later).
# We'll use OpenJDK 17 for compatibility with Kafka and Flink.

# See:
# - https://spark.apache.org/downloads.html
# - https://community.cloudera.com/t5/Community-Articles/Spark-and-Java-versions-Supportability-Matrix/ta-p/383669

# TODO: Change the JDK version in the 01-setup/download-jdk.sh script
# TODO: Change the SPARK_VERSION to the desired version if needed
SPARK_VERSION="3.5.5"
HADOOP_VERSION="3"
SPARK_FOLDER="spark"
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
mkdir -p "$SPARK_FOLDER"

# Construct download URL
DOWNLOAD_URL="https://downloads.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"

# Download Spark if not already present
if [ ! -f "$SPARK_FOLDER/bin/spark-shell" ]; then
    echo "📥 Downloading Apache Spark $SPARK_VERSION (Hadoop $HADOOP_VERSION)..."
    curl -L -o spark.tgz "$DOWNLOAD_URL"

    echo "📦 Extracting Spark..."
    tar -xvf spark.tgz -C "$SPARK_FOLDER" --strip-components=1
    rm spark.tgz
    echo "✅ Spark $SPARK_VERSION installed successfully."
else
    echo "✅ Spark $SPARK_VERSION already installed."
fi

# Confirm Spark binary exists
if [ ! -f "$SPARK_FOLDER/bin/spark-shell" ]; then
    echo "❌ Spark installation failed. Cleaning up..."
    rm -rf "$SPARK_FOLDER"
    exit 1
fi

# Set temporary JAVA_HOME (NOT exported)
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$(pwd)/$SPARK_FOLDER/bin:$PATH"

echo "🚀 Using temporary JAVA_HOME=$JAVA_HOME"

# Test Spark shell version
if spark-shell --version; then
    echo "✅ Spark $SPARK_VERSION is working correctly."
else
    echo "❌ Spark configuration failed. Check logs for details."
    exit 1
fi

# Display quick instructions for starting Spark shell and PySpark
echo ""
echo "➡️ To start Spark shell:"
echo "./$SPARK_FOLDER/bin/spark-shell"
echo ""
echo "➡️ To start PySpark:"
echo "./$SPARK_FOLDER/bin/pyspark"
