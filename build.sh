#!/bin/bash

set -e

echo "🚀 Building Snap - macOS Screenshot App..."

if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed. Please install Xcode or Swift toolchain."
    exit 1
fi

SWIFT_VERSION=$(swift --version | head -n 1)
echo "✅ Found Swift: $SWIFT_VERSION"

echo "📦 Resolving dependencies..."
swift package resolve

echo "🔨 Building in release mode..."
swift build -c release

echo "✅ Build completed successfully!"
echo ""
echo "📍 Binary location:"
swift build -c release --show-bin-path

echo ""
echo "🎯 To run the app:"
echo "   swift run"
echo ""
echo "📝 Note: On first run, the app will request Screen Recording permission."
echo "   Go to: System Settings → Privacy & Security → Screen Recording"
