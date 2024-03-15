# Navigate to the root directory
echo "Navigate to the root directory"
cd ..

# Clean the project
echo "Clean the project"
flutter clean

# Binaries are generated for 32 bit architecture
echo "Binaries 32-bit"
flutter build apk --release --target-platform=android-arm

# Binaries are generated for 64 bit architecture
echo "Binaries 64-bit"
flutter build apk --release --target-platform=android-arm64

# Generate bundle to upload to Google Play Store
echo "App bundle"
flutter build appbundle