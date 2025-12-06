#!/bin/bash

# Flutter Attendance App - Setup Script

echo "🚀 Setting up Flutter Attendance App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed!"
    echo "📥 Please install Flutter from: https://docs.flutter.dev/get-started/install"
    echo ""
    echo "For macOS with Homebrew:"
    echo "  brew install flutter"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Check Flutter doctor
echo ""
echo "🔍 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

# Run code generation
echo ""
echo "🔧 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

# Create necessary directories
echo ""
echo "📁 Creating asset directories..."
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts

# Success message
echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Configure Google OAuth credentials (see README.md)"
echo "2. Update API base URL in lib/src/core/constants/app_constants.dart"
echo "3. Run: flutter run"
echo ""
echo "📚 Documentation: See README.md for detailed setup instructions"
