#!/bin/bash

# totallynotacloud Xcode Projects Setup Script
# This script creates both iOS and macOS Xcode projects

set -e

echo "=== totallynotacloud Xcode Setup ==="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is not installed. Please install Xcode from App Store."
    exit 1
fi

echo "Creating iOS project..."

# Create iOS directory structure if it doesn't exist
mkdir -p iOS/totallynotacloud
mkdir -p iOS/totallynotacloud/App
mkdir -p iOS/totallynotacloud/Models
mkdir -p iOS/totallynotacloud/Services
mkdir -p iOS/totallynotacloud/Views

echo "Creating macOS project..."

# Create macOS directory structure if it doesn't exist
mkdir -p macOS/totallynotacloud
mkdir -p macOS/totallynotacloud/App
mkdir -p macOS/totallynotacloud/Views

echo ""
echo "Directory structure created!"
echo ""
echo "Next steps:"
echo ""
echo "1. For iOS:"
echo "   - Open iOS/totallynotacloud in Xcode"
echo "   - Create new iOS App project"
echo "   - Add the Swift files from iOS/ folder to the project"
echo ""
echo "2. For macOS:"
echo "   - Open macOS/totallynotacloud in Xcode"
echo "   - Create new macOS App project"
echo "   - Add the Swift files from macOS/ folder to the project"
echo ""
echo "3. See XCODE_SETUP.md for detailed instructions"
echo ""
