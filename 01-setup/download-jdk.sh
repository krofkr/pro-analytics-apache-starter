#!/bin/bash
# 01-setup/download-jdk.sh

# Download OpenJDK 17 to the project folder
# Spark supports JDK 8, 11, and 17 (NOT 18 or later).
# Kafka 4.x supports JDK 8, 11, 17, and 23.
# We'll use OpenJDK 17 for both Spark and Kafka for maximum compatibility.
# UPDATE THE URLS as NEEDED for example, this will use:

# Linux x64:
# DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
# Linux aarch64 (ARM 64-bit):
# DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.10_7.tar.gz"
# macOS x64:
# DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_x64_mac_hotspot_17.0.10_7.tar.gz"
# For macOS aarch64 (Apple Silicon):
# DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_aarch64_mac_hotspot_17.0.10_7.tar.gz"
# For For WSL (Ubuntu) on Intel/AMD (x86_64):
# DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
# For WSL (Ubuntu) on ARM (aarch64):
# DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.10_7.tar.gz"
#

# See:
# - https://community.cloudera.com/t5/Community-Articles/Spark-and-Java-versions-Supportability-Matrix/ta-p/383669
# - https://kafka.apache.org/40/documentation/compatibility.html

# TODO: Change the JDK_VERSION to the desired version if needed
#!/bin/bash
#!/bin/bash

JDK_VERSION="17.0.10"
JDK_FOLDER="jdk"

set -e

echo "➡️  Step 1: Detecting OS and architecture..."
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

echo "✅ Detected platform: $PLATFORM-$ARCH_SUFFIX"

# Install curl if missing
if ! command -v curl &> /dev/null; then
    echo "➡️  Step 2: Installing curl..."
    if [ "$PLATFORM" = "linux" ]; then
        sudo apt-get update && sudo apt-get install -y curl
    elif [ "$PLATFORM" = "osx" ]; then
        brew install curl
    fi
    echo "✅ curl installed successfully."
else
    echo "✅ curl is already installed."
fi

DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VERSION}%2B7/OpenJDK17U-jdk_${ARCH_SUFFIX}_linux_hotspot_${JDK_VERSION}_7.tar.gz"
FILE_NAME="jdk-${JDK_VERSION}.tar.gz"

echo "➡️  Step 3: Creating JDK folder..."
mkdir -p "$JDK_FOLDER"
echo "✅ JDK folder created at: $(pwd)/$JDK_FOLDER"

if [ ! -d "$JDK_FOLDER/bin" ]; then
    echo "➡️  Step 4: Downloading OpenJDK from:"
    echo "$DOWNLOAD_URL"
    curl -L -o "$FILE_NAME" "$DOWNLOAD_URL"

    echo "✅ Downloaded file:"
    ls -lh "$FILE_NAME"

    echo "➡️  Step 5: Verifying file type..."
    file "$FILE_NAME"

    echo "➡️  Step 6: Extracting JDK..."
    if tar -xvzf "$FILE_NAME" -C "$JDK_FOLDER" --strip-components=1; then
        echo "✅ Extraction successful."
    else
        echo "❌ Extraction failed. Cleaning up..."
        rm "$FILE_NAME"
        rm -rf "$JDK_FOLDER"
        exit 1
    fi
    
    echo "➡️  Step 7: Removing tar file..."
    rm "$FILE_NAME"
else
    echo "✅ JDK already installed."
fi

echo "➡️  Step 8: Setting JAVA_HOME and PATH..."
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$PATH"
echo "✅ JAVA_HOME set to: $JAVA_HOME"

echo "➡️  Step 9: Testing JDK installation..."
if java -version; then
    echo "✅ JDK $JDK_VERSION installed successfully."
else
    echo "❌ JDK install failed. Cleaning up..."
    rm -rf "$JDK_FOLDER"
    exit 1
fi

echo "🚀 All steps completed successfully!"
