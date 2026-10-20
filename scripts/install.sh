#!/bin/sh
# Builds Itsycal.app with xcodebuild into build/, copies it to PREFIX (/Applications by default) and opens it,
# quitting any running copy first.
#
# Signing comes from Local.xcconfig, copied from Local.xcconfig.example if missing (see BUILD.md). Its default is
# ad hoc, and macOS ties the Calendars grant to the signature, so each rebuild asks again; Option 2 in that file,
# a stable identity, keeps the grant.
# CONFIG is the Xcode configuration, Release or Debug.
# DEPLOYMENT_TARGET is the oldest macOS the build runs on, by default the running one: the project's own target
# is macOS 27, which would keep it from launching on anything earlier.
set -eu

cd "$(dirname "$0")/.."

CONFIG=${CONFIG:-Release}
PREFIX=${PREFIX:-/Applications}
DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:-$(sw_vers -productVersion | cut -d. -f1-2)}
APP=build/Build/Products/$CONFIG/Itsycal.app

[ -f Local.xcconfig ] || cp Local.xcconfig.example Local.xcconfig

xcodebuild -quiet -project Itsycal.xcodeproj -scheme Itsycal -configuration "$CONFIG" -derivedDataPath build \
    MACOSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" build

pkill -x Itsycal || true
while pgrep -x Itsycal >/dev/null; do sleep 0.1; done

mkdir -p "$PREFIX"
rm -rf "$PREFIX/Itsycal.app"
cp -R "$APP" "$PREFIX/"
open "$PREFIX/Itsycal.app"
echo "Installed $PREFIX/Itsycal.app"
