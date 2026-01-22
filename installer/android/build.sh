#!/bin/bash
# Music Sharity - Share music across all platforms
# Copyright (C) 2026 Sikelio (Byte Roast)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
set -e

TARGET="release"
CLEAN="true"

show_help() {
    echo "Usage: build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --target <release|debug>  Build target (default: release)"
    echo "  -c, --clean <true|false>      Run flutter clean before build (default: true)"
    echo "  -h, --help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh                        # Release build with clean"
    echo "  ./build.sh -t debug               # Debug build with clean"
    echo "  ./build.sh -t release -c false    # Release build without clean"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [[ "$TARGET" != "release" && "$TARGET" != "debug" ]]; then
    echo "Error: Invalid target '$TARGET'. Must be 'release' or 'debug'." >&2
    exit 1
fi

if [[ "$CLEAN" != "true" && "$CLEAN" != "false" ]]; then
    echo "Error: Invalid clean value '$CLEAN'. Must be 'true' or 'false'." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/dist/android"
APK_SOURCE_DIR="$PROJECT_ROOT/build/app/outputs/flutter-apk"
APPBUNDLE_SOURCE_DIR="$PROJECT_ROOT/build/app/outputs/bundle/release"
PUBSPEC_PATH="$PROJECT_ROOT/pubspec.yaml"
VERSION=$(grep -oP 'version:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$PUBSPEC_PATH")
BUILD_NUMBER=$(grep -oP 'version:\s*[0-9]+\.[0-9]+\.[0-9]+\+\K[0-9]+' "$PUBSPEC_PATH")

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from pubspec.yaml" >&2
    exit 1
fi

if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

APK_LOG_FILE="$OUTPUT_DIR/apk-build.log"
APPBUNDLE_LOG_FILE="$OUTPUT_DIR/appbundle-build.log"

cd "$PROJECT_ROOT"

echo -e "\033[36m=== Music Sharity Android Builder ===\033[0m"
echo -e "\033[90mVersion: $VERSION+$BUILD_NUMBER\033[0m"
echo -e "\033[90mTarget: $TARGET | Clean: $CLEAN\033[0m"
echo ""

STEP=1

if [ "$CLEAN" = "true" ]; then
    if [ "$TARGET" = "release" ]; then
        TOTAL_STEPS=5
    else
        TOTAL_STEPS=4
    fi

    echo -e "\033[33m[$STEP/$TOTAL_STEPS] Cleaning project...\033[0m"

    flutter clean

    echo ""

    STEP=$((STEP + 1))
else
    if [ "$TARGET" = "release" ]; then
        TOTAL_STEPS=4
    else
        TOTAL_STEPS=3
    fi
fi

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Installing dependencies...\033[0m"

flutter pub get

echo ""

STEP=$((STEP + 1))

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Building Android APK ($TARGET)...\033[0m"
echo -e "\033[90mLog file: $APK_LOG_FILE\033[0m"

if [ "$TARGET" = "release" ]; then
    flutter build apk --release --verbose &> "$APK_LOG_FILE"

    APK_FILE="app-release.apk"
else
    flutter build apk --debug --verbose &> "$APK_LOG_FILE"

    APK_FILE="app-debug.apk"
fi

echo ""

if [ ! -f "$APK_SOURCE_DIR/$APK_FILE" ]; then
    echo -e "\033[31mError: APK build not found after build!\033[0m" >&2
    exit 1
fi

STEP=$((STEP + 1))

if [ "$TARGET" = "release" ]; then
    echo -e "\033[33m[$STEP/$TOTAL_STEPS] Building Android AppBundle...\033[0m"
    echo -e "\033[90mLog file: $APPBUNDLE_LOG_FILE\033[0m"

    flutter build appbundle --release --verbose &> "$APPBUNDLE_LOG_FILE"

    echo ""

    if [ ! -f "$APPBUNDLE_SOURCE_DIR/app-release.aab" ]; then
        echo -e "\033[31mError: Release AppBundle build not found after build!\033[0m" >&2
        exit 1
    fi

    STEP=$((STEP + 1))
fi

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Moving build output files...\033[0m"

NAME="music-sharity-${VERSION}+${BUILD_NUMBER}"

if [ "$TARGET" = "release" ]; then
    mv "$APK_SOURCE_DIR/app-release.apk" "$OUTPUT_DIR/$NAME.apk"
    mv "$APK_SOURCE_DIR/app-release.apk.sha1" "$OUTPUT_DIR/$NAME.apk.sha1"
    mv "$APPBUNDLE_SOURCE_DIR/app-release.aab" "$OUTPUT_DIR/$NAME.aab"
else
    mv "$APK_SOURCE_DIR/app-debug.apk" "$OUTPUT_DIR/$NAME-debug.apk"
fi

echo ""
echo -e "\033[32m=== Build completed successfully! ===\033[0m"
echo -e "\033[36mFiles:\033[0m"

if [ "$TARGET" = "release" ]; then
    echo -e "  - \033[36m$OUTPUT_DIR/$NAME.apk\033[0m"
    echo -e "  - \033[36m$OUTPUT_DIR/$NAME.aab\033[0m"
    echo ""
    echo -e "\033[90mChecksums:\033[0m"
    echo -e "  - \033[90m$OUTPUT_DIR/$NAME.apk.sha1\033[0m"
    echo ""

    APK_SIZE=$(du -h "$OUTPUT_DIR/$NAME.apk" | cut -f1)
    APK_SHA1=$(cat "$OUTPUT_DIR/$NAME.apk.sha1" | cut -d' ' -f1)
    APPBUNDLE_SIZE=$(du -h "$OUTPUT_DIR/$NAME.aab" | cut -f1)

    echo -e "\033[90m.apk package:\033[0m"
    echo -e "  Size: $APK_SIZE"
    echo -e "  SHA-1: $APK_SHA1"
    echo ""
    echo -e "\033[90m.aab package:\033[0m"
    echo -e "  Size: $APPBUNDLE_SIZE"
else
    echo -e "  - \033[36m$OUTPUT_DIR/$NAME-debug.apk\033[0m"
    echo ""

    APK_SIZE=$(du -h "$OUTPUT_DIR/$NAME-debug.apk" | cut -f1)

    echo -e "\033[90m.apk package (debug):\033[0m"
    echo -e "  Size: $APK_SIZE"
fi
