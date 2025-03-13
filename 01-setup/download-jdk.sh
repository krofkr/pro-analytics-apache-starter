#!/bin/bash
# 01-setup/download-jdk.sh

# Download OpenJDK 17 to the project folder
# Spark supports JDK 8, 11, and 17 (NOT 18 or later).
# Kafka 4.x supports JDK 8, 11, 17, and 23.
# We'll use OpenJDK 17 for both Spark and Kafka for maximum compatibility.

# See:
# - https://community.cloudera.com/t5/Community-Articles/Spark-and-Java-versions-Supportability-Matrix/ta-p/383669
# - https://kafka.apache.org/40/documentation/compatibility.html

# TODO: Change the JDK_VERSION to the desired version if needed
JDK_VERSION="17.0.10"
JDK_FOLDER="jdk"

# Fail fast on errors
set -e

# Detect platform (macOS, Linux, WSL)
OS=$(uname -s)
ARCH=$(uname -m)

if [ "$OS" = "Darwin" ]; then
    PLATFORM="osx"
elif [ "$OS" = "Linux" ]; then
    PLATFORM="linux"
else
    echo "❌ Unsupported platform: $OS"
    exit 1
fi

if [ "$ARCH" = "arm64" ]; then
    ARCH_SUFFIX="aarch64"
else
    ARCH_SUFFIX="x64"
fi

DOWNLOAD_URL="https://download.java.net/java/GA/jdk17/$JDK_VERSION/GPL/openjdk-$JDK_VERSION_${PLATFORM}-${ARCH_SUFFIX}_bin.tar.gz"

# Create the folder if it doesn't exist
mkdir -p "$JDK_FOLDER"

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo "❌ 'curl' not installed. Please install it and try again."
    exit 1
fi

# Download JDK if not already present
if [ ! -d "$JDK_FOLDER/bin" ]; then
    echo "📥 Downloading OpenJDK $JDK_VERSION for $PLATFORM-$ARCH_SUFFIX..."
    curl -L -o jdk.tar.gz "$DOWNLOAD_URL"

    echo "📦 Extracting JDK..."
    tar -xvf jdk.tar.gz -C "$JDK_FOLDER" --strip-components=1
    rm jdk.tar.gz
    echo "✅ JDK $JDK_VERSION installed successfully."
else
    echo "✅ JDK $JDK_VERSION already installed."
fi

# Confirm JDK is working (TEMPORARY JAVA_HOME - NOT EXPORTED)
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$PATH"

echo "🚀 Using temporary JAVA_HOME=$JAVA_HOME"

# Test the JDK in this context only
if java -version; then
    echo "✅ JDK $JDK_VERSION is configured correctly."
else
    echo "❌ JDK configuration failed. Cleaning up..."
    rm -rf "$JDK_FOLDER"
    exit 1
fi
