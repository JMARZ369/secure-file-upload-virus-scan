#!/bin/bash

set -e  # Exit if any command fails

# Absolute path to the lambda folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAMBDA_DIR="$SCRIPT_DIR/../lambda"
PACKAGE_DIR="$LAMBDA_DIR/package"
ZIP_NAME="lambda_function.zip"
ZIP_PATH="$LAMBDA_DIR/$ZIP_NAME"

echo "Cleaning old build..."
rm -rf "$PACKAGE_DIR" "$ZIP_PATH"
mkdir -p "$PACKAGE_DIR"

echo "Installing Python dependencies to: $PACKAGE_DIR"
python3 -m pip install -r "$LAMBDA_DIR/requirements.txt" --target "$PACKAGE_DIR"

echo "Zipping dependencies into: $ZIP_PATH"
cd "$PACKAGE_DIR"
zip -r9 "$ZIP_PATH" . > /dev/null

cd "$LAMBDA_DIR"
echo "Adding handler.py and utils.py to zip..."
zip -g "$ZIP_NAME" handler.py utils.py > /dev/null

echo "Lambda package created at: $ZIP_PATH"
