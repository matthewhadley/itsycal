#!/bin/sh
# Builds Itsycal.app with xcodebuild into build/, copies it to PREFIX (/Applications by default) and opens it,
# quitting any running copy first.
#
# Signing comes from Local.xcconfig, copied from Local.xcconfig.example if missing (see BUILD.md). Its default is
# ad hoc, and macOS ties the Calendars grant to the signature, so each rebuild asks again; Option 2 in that file,
# a stable identity, keeps the grant.
# CONFIG is the Xcode configuration, Release or Debug.
set -eu

cd "$(dirname "$0")/.."

CONFIG=${CONFIG:-Release}
PREFIX=${PREFIX:-/Applications}
APP=build/Build/Products/$CONFIG/Itsycal.app

[ -f Local.xcconfig ] || cp Local.xcconfig.example Local.xcconfig

# The destination names this Mac's architecture: platform=macOS alone matches both "My Mac" and "Any Mac", and
# xcodebuild warns about picking one.
xcodebuild -quiet -project Itsycal.xcodeproj -scheme Itsycal -configuration "$CONFIG" -derivedDataPath build \
    -destination "platform=macOS,arch=$(uname -m)" build

pkill -x Itsycal || true
while pgrep -x Itsycal >/dev/null; do sleep 0.1; done

mkdir -p "$PREFIX"
rm -rf "$PREFIX/Itsycal.app"
cp -R "$APP" "$PREFIX/"
open "$PREFIX/Itsycal.app"
echo "Installed $PREFIX/Itsycal.app"
