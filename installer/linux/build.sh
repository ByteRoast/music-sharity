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
    echo ""
    echo "Note: Debug builds only create the Flutter bundle, not .deb/.rpm packages."
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
SOURCE_DIR="$PROJECT_ROOT/build/linux/x64/$TARGET/bundle"
OUTPUT_DIR="$PROJECT_ROOT/dist/linux/x64"
PUBSPEC_PATH="$PROJECT_ROOT/pubspec.yaml"
VERSION=$(grep -oP 'version:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$PUBSPEC_PATH")
BUILD_NUMBER=$(grep -oP 'version:\s*[0-9]+\.[0-9]+\.[0-9]+\+\K[0-9]+' "$PUBSPEC_PATH")

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from pubspec.yaml" >&2
    exit 1
fi

echo -e "\033[36m=== Music Sharity Linux Builder ===\033[0m"
echo -e "\033[90mVersion: $VERSION+$BUILD_NUMBER\033[0m"
echo -e "\033[90mTarget: $TARGET | Clean: $CLEAN\033[0m"
echo ""

if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/build.log"

if [ "$TARGET" = "release" ]; then
    # Steps: [clean], build, deb, rpm, checksums, cleanup
    if [ "$CLEAN" = "true" ]; then
        TOTAL_STEPS=6
    else
        TOTAL_STEPS=5
    fi
else
    # Steps: [clean], build
    if [ "$CLEAN" = "true" ]; then
        TOTAL_STEPS=2
    else
        TOTAL_STEPS=1
    fi
fi

STEP=1

cd "$PROJECT_ROOT"

if [ "$CLEAN" = "true" ]; then
    echo -e "\033[33m[$STEP/$TOTAL_STEPS] Cleaning project...\033[0m"
    flutter clean
    echo ""
    STEP=$((STEP + 1))
fi

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Building Flutter Linux app ($TARGET)...\033[0m"
echo -e "\033[90mLog file: $LOG_FILE\033[0m"

flutter pub get

if [ "$TARGET" = "release" ]; then
    flutter build linux --release --verbose &> "$LOG_FILE"
else
    flutter build linux --debug --verbose &> "$LOG_FILE"
fi

echo ""

if [ ! -f "$SOURCE_DIR/music_sharity" ]; then
    echo -e "\033[31mError: Build not found after build!\033[0m" >&2
    exit 1
fi

if [ "$TARGET" = "debug" ]; then
    echo ""
    echo -e "\033[32m=== Debug build completed successfully! ===\033[0m"
    echo -e "\033[36mBundle location:\033[0m"
    echo -e "  - \033[36m$SOURCE_DIR\033[0m"
    echo ""
    echo -e "\033[90mNote: Debug builds don't create .deb/.rpm packages.\033[0m"
    exit 0
fi

STEP=$((STEP + 1))

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Creating .deb package...\033[0m"

DEB_DIR="$OUTPUT_DIR/deb"
DEB_NAME="music-sharity-${VERSION}+${BUILD_NUMBER}-amd64"
DEB_PACKAGE_DIR="$DEB_DIR/$DEB_NAME"

mkdir -p "$DEB_PACKAGE_DIR/DEBIAN"
mkdir -p "$DEB_PACKAGE_DIR/usr/bin"
mkdir -p "$DEB_PACKAGE_DIR/usr/lib/music-sharity"
mkdir -p "$DEB_PACKAGE_DIR/usr/share/applications"
mkdir -p "$DEB_PACKAGE_DIR/usr/share/pixmaps"
mkdir -p "$DEB_PACKAGE_DIR/usr/share/doc/music-sharity"
mkdir -p "$DEB_PACKAGE_DIR/usr/share/metainfo"

sed "s/VERSION_PLACEHOLDER/$VERSION+$BUILD_NUMBER/g" "$SCRIPT_DIR/control.template" > "$DEB_PACKAGE_DIR/DEBIAN/control"

cp "$SCRIPT_DIR/music-sharity.desktop" "$DEB_PACKAGE_DIR/usr/share/applications/music-sharity.desktop"

sed -e "s/VERSION_PLACEHOLDER/$VERSION/g" -e "s/DATE_PLACEHOLDER/$(date +%Y-%m-%d)/g" \
    "$SCRIPT_DIR/fr.byteroast.music-sharity.metainfo.xml" > "$DEB_PACKAGE_DIR/usr/share/metainfo/fr.byteroast.music-sharity.metainfo.xml"

cp -r "$SOURCE_DIR"/* "$DEB_PACKAGE_DIR/usr/lib/music-sharity/"
cp "$SCRIPT_DIR/music-sharity-wrapper.sh" "$DEB_PACKAGE_DIR/usr/bin/music-sharity"

chmod +x "$DEB_PACKAGE_DIR/usr/bin/music-sharity"

if [ -f "$PROJECT_ROOT/assets/images/brandings/logo.png" ]; then
    cp "$PROJECT_ROOT/assets/images/brandings/logo.png" "$DEB_PACKAGE_DIR/usr/share/pixmaps/music-sharity.png"
fi

cp "$SCRIPT_DIR/../common/copyright" "$DEB_PACKAGE_DIR/usr/share/doc/music-sharity/copyright"
cp "$SCRIPT_DIR/deb-post.sh" "$DEB_PACKAGE_DIR/DEBIAN/postinst"

chmod +x "$DEB_PACKAGE_DIR/DEBIAN/postinst"

dpkg-deb --build "$DEB_PACKAGE_DIR" "$OUTPUT_DIR/$DEB_NAME.deb"

echo ""

STEP=$((STEP + 1))

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Creating .rpm package...\033[0m"

RPM_DIR="$OUTPUT_DIR/rpm"
RPM_BUILD_DIR="$RPM_DIR/rpmbuild"
RPM_NAME="music-sharity-${VERSION}-${BUILD_NUMBER}.x86_64"

mkdir -p "$RPM_BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$RPM_BUILD_DIR/BUILD/music-sharity-$VERSION"

cp -r "$SOURCE_DIR"/* "$RPM_BUILD_DIR/BUILD/music-sharity-$VERSION/"

sed -e "s/VERSION_PLACEHOLDER/$VERSION/g" -e "s/DATE_PLACEHOLDER/$(date +%Y-%m-%d)/g" \
    "$SCRIPT_DIR/fr.byteroast.music-sharity.metainfo.xml" > "$RPM_BUILD_DIR/music-sharity.metainfo.xml"

LOGO_INSTALL=""

if [ -f "$PROJECT_ROOT/assets/images/brandings/logo.png" ]; then
    LOGO_INSTALL="cp $PROJECT_ROOT/assets/images/brandings/logo.png %{buildroot}/usr/share/pixmaps/music-sharity.png"
fi

POST_SCRIPT=$(cat "$SCRIPT_DIR/rpm-post.sh")

sed -e "s|VERSION_PLACEHOLDER|$VERSION|g" \
    -e "s|BUILD_NUMBER_PLACEHOLDER|$BUILD_NUMBER|g" \
    -e "s|RPM_BUILD_DIR_PLACEHOLDER|$RPM_BUILD_DIR|g" \
    -e "s|SCRIPT_DIR_PLACEHOLDER|$SCRIPT_DIR|g" \
    -e "s|LOGO_INSTALL_PLACEHOLDER|$LOGO_INSTALL|g" \
    "$SCRIPT_DIR/music-sharity.spec.template" > "$RPM_BUILD_DIR/SPECS/music-sharity.spec.tmp"

awk -v post_script="$POST_SCRIPT" '{
    if ($0 == "POST_SCRIPT_PLACEHOLDER") {
        print post_script
    } else {
        print $0
    }
}' "$RPM_BUILD_DIR/SPECS/music-sharity.spec.tmp" > "$RPM_BUILD_DIR/SPECS/music-sharity.spec"

rm "$RPM_BUILD_DIR/SPECS/music-sharity.spec.tmp"

rpmbuild --define "_topdir $RPM_BUILD_DIR" --define "dist %{nil}" -bb "$RPM_BUILD_DIR/SPECS/music-sharity.spec"

cp "$RPM_BUILD_DIR/RPMS/x86_64/$RPM_NAME.rpm" "$OUTPUT_DIR/"

echo ""

STEP=$((STEP + 1))

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Generating SHA-1 checksums...\033[0m"

cd "$OUTPUT_DIR"

sha1sum "$DEB_NAME.deb" > "$DEB_NAME.deb.sha1"
sha1sum "$RPM_NAME.rpm" > "$RPM_NAME.rpm.sha1"

echo ""

STEP=$((STEP + 1))

echo -e "\033[33m[$STEP/$TOTAL_STEPS] Cleaning up...\033[0m"

rm -rf "$DEB_DIR"
rm -rf "$RPM_DIR"

echo ""
echo -e "\033[32m=== Build completed successfully! ===\033[0m"
echo -e "\033[36mFiles:\033[0m"
echo -e "  - \033[36m$OUTPUT_DIR/$DEB_NAME.deb\033[0m"
echo -e "  - \033[36m$OUTPUT_DIR/$RPM_NAME.rpm\033[0m"
echo ""
echo -e "\033[90mChecksums:\033[0m"
echo -e "  - \033[90m$OUTPUT_DIR/$DEB_NAME.deb.sha1\033[0m"
echo -e "  - \033[90m$OUTPUT_DIR/$RPM_NAME.rpm.sha1\033[0m"
echo ""

DEB_SIZE=$(du -h "$OUTPUT_DIR/$DEB_NAME.deb" | cut -f1)
RPM_SIZE=$(du -h "$OUTPUT_DIR/$RPM_NAME.rpm" | cut -f1)
DEB_SHA1=$(cat "$OUTPUT_DIR/$DEB_NAME.deb.sha1" | cut -d' ' -f1)
RPM_SHA1=$(cat "$OUTPUT_DIR/$RPM_NAME.rpm.sha1" | cut -d' ' -f1)

echo -e "\033[90m.deb package:\033[0m"
echo -e "  Size: $DEB_SIZE"
echo -e "  SHA-1: $DEB_SHA1"
echo ""
echo -e "\033[90m.rpm package:\033[0m"
echo -e "  Size: $RPM_SIZE"
echo -e "  SHA-1: $RPM_SHA1"
