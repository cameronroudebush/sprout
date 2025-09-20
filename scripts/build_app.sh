#!/bin/bash

# A script to build Flutter Android artifacts (APK or App Bundle)
# using a version name from `git describe` and a version code
# from the total git commit count.
#
# Usage:
#   ./build.sh appbundle
#   ./build.sh apk

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Validate Input ---
BUILD_TYPE=$1
if [[ "$BUILD_TYPE" != "apk" && "$BUILD_TYPE" != "appbundle" ]]; then
  echo "Error: Invalid build type '$BUILD_TYPE'."
  echo "Usage: $0 [apk|appbundle]"
  exit 1
fi

# --- Get Version Info ---

# Total number of commits used as our build number
BUILD_NUMBER=$(git rev-list --count HEAD)

# Git describe gives us our string formatted version
BUILD_NAME=$(git describe --tags --always)


# --- Sanity Check ---
if [ -z "$BUILD_NAME" ]; then
  echo "Error: Could not generate a build name from git describe."
  echo "Please ensure you have at least one tag in your git history (e.g., v1.0.0)."
  exit 1
fi

# --- Set GitHub Actions Output ---
# This allows the CI workflow to use these values in subsequent steps.
# It checks if GITHUB_OUTPUT environment variable is available.
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "build_name=${BUILD_NAME}" >> "$GITHUB_OUTPUT"
  echo "build_number=${BUILD_NUMBER}" >> "$GITHUB_OUTPUT"
fi

echo "---------------------------------"
echo " Starting Flutter Build"
echo "   Build Type:   $BUILD_TYPE"
echo "   Build Name:   $BUILD_NAME"
echo "   Build Number: $BUILD_NUMBER"
echo "---------------------------------"


# --- Run the Flutter Build Command ---

flutter build $BUILD_TYPE \
  --release \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER" \
  --no-tree-shake-icons

# --- Provide summary ---
echo ""
echo "✅ Build complete!"
if [ "$BUILD_TYPE" == "apk" ]; then
    echo "   Artifact: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "   Artifact: build/app/outputs/bundle/release/app-release.aab"
fi
