#!/bin/bash
# 01-setup/install-kafka.sh

# Download and install Apache Kafka to the project folder
# Kafka supports JDK 8, 11, 17, and 23.
# We'll use OpenJDK 17 for compatibility with Spark and Flink.

# See:
# - https://kafka.apache.org/documentation/#compatibility
# - https://kafka.apache.org/downloads

# TODO: Change KAFKA_VERSION and SCALA_VERSION to desired versions if needed
KAFKA_VERSION="3.8.0"   # Latest stable Kafka version
SCALA_VERSION="2.13"     # Scala version compatible with Kafka release
KAFKA_FOLDER="kafka"
JDK_FOLDER="jdk"

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

# Step 2: Install curl if missing
if ! command -v curl &> /dev/null; then
    echo "✅ Installing curl..."
    if [ "$PLATFORM" = "linux" ]; then
        sudo apt-get update && sudo apt-get install -y curl
    elif [ "$PLATFORM" = "osx" ]; then
        brew install curl
    fi
    echo "✅ curl installed successfully."
else
    echo "✅ curl is already installed."
fi

# Step 3: Create the Kafka installation folder if it doesn't exist
mkdir -p "$KAFKA_FOLDER"
echo "✅ Kafka folder created at: $(pwd)/$KAFKA_FOLDER"

# Step 4: Construct the download URL
DOWNLOAD_URL="https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz"
FILE_NAME="kafka-$KAFKA_VERSION.tgz"

echo "✅ Download URL:"
echo "$DOWNLOAD_URL"

# Step 5: Download Kafka if not already installed
if [ ! -f "$KAFKA_FOLDER/bin/kafka-server-start.sh" ]; then
    echo "✅ Downloading Apache Kafka $KAFKA_VERSION (Scala $SCALA_VERSION)..."
    curl -L -o "$FILE_NAME" "$DOWNLOAD_URL"

    # ✅ Verify that the downloaded file is a valid gzip archive
    echo "✅ Verifying file type..."
    if file "$FILE_NAME" | grep -q 'gzip compressed data'; then
        echo "✅ File is a valid gzip archive."
        
        # Step 6: Extract Kafka
        echo "✅ Extracting Kafka..."
        tar -xzf "$FILE_NAME" -C "$KAFKA_FOLDER" --strip-components=1
        
        echo "✅ Kafka extracted successfully."
    else
        echo "ERROR: Downloaded file is not a valid gzip archive. Please check the URL or network connection."
        rm "$FILE_NAME"
        exit 1
    fi

    # Step 7: Remove tar file after extraction
    rm "$FILE_NAME"
    echo "✅ Kafka archive removed."
else
    echo "✅ Kafka $KAFKA_VERSION is already installed."
fi

# Step 8: Confirm that Kafka binary exists
if [ ! -f "$KAFKA_FOLDER/bin/kafka-server-start.sh" ]; then
    echo "ERROR: Kafka installation failed. Cleaning up..."
    rm -rf "$KAFKA_FOLDER"
    exit 1
fi

# Step 9: Set temporary JAVA_HOME and PATH for Kafka
JAVA_HOME="$(pwd)/$JDK_FOLDER"
PATH="$JAVA_HOME/bin:$(pwd)/$KAFKA_FOLDER/bin:$PATH"
echo "✅ JAVA_HOME set to: $JAVA_HOME"

# Step 10: Test Kafka installation (optional)
# Note: Kafka requires the server to be running for most commands.
echo "✅ Testing Kafka installation..."
if kafka-topics.sh --version; then
    echo "✅ Kafka $KAFKA_VERSION installed correctly."
else
    echo "Kafka is installed but not running. Start the server to verify."
fi

# Step 11: Display instructions for starting Kafka
echo ""
echo "To start Kafka server:"
echo "./$KAFKA_FOLDER/bin/kafka-server-start.sh $KAFKA_FOLDER/config/server.properties"

echo ""
echo "To create a new Kafka topic:"
echo "./$KAFKA_FOLDER/bin/kafka-topics.sh --create --topic test --bootstrap-server localhost:9092"

echo "✅ Kafka installation complete!"
