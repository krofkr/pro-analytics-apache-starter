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
#!/bin/bash
JDK_VERSION="17.0.10"
JDK_FOLDER="jdk"

set -e

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

# Install curl if missing
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    if [ "$PLATFORM" = "linux" ]; then
        sudo apt-get update && sudo apt-get install -y curl
    elif [ "$PLATFORM" = "osx" ]; then
        brew install curl
    fi
fi

DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VERSION}%2B7/OpenJDK17U-jdk_${PLATFORM}_${ARCH_SUFFIX}_hotspot_${JDK_VERSION}_7.tar.gz"

mkdir -p "$JDK_FOLDER"

if [ ! -d "$JDK_FOLDER/bin" ]; then
    echo "Downloading OpenJDK $JDK_VERSION..."
    curl -L -o jdk.tar.gz "$DOWNLOAD_URL"
    
    echo "Extracting JDK..."
    tar -xvzf jdk.tar.gz -C "$JDK_FOLDER" --strip-components=1
    rm jdk.tar.gz
fi

JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$PATH"

if java -version; then
    echo "✅ JDK $JDK_VERSION installed successfully."
else
    echo "❌ JDK install failed. Cleaning up..."
    rm -rf "$JDK_FOLDER"
    exit 1
fi
