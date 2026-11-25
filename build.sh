#!/bin/sh
# Builds Forchpad (sources in Sources/forchpad/) for Apple Silicon and
# Intel Macs, and wraps it in dist/Forchpad.app.
# Package.swift mirrors the same sources for SwiftPM-based editing and `swift build`
# on Apple Silicon; this script is the distribution build.
#
#   ./build.sh            build ./build/Forchpad and dist/Forchpad.app
#                         (signed for this Mac only)
#   ./build.sh release    also sign the app with your Developer ID, have Apple notarize it,
#                         and make dist/Forchpad.zip, which runs on any Mac without
#                         security warnings
#
# Ad-hoc signing changes the binary's identity on every build, which resets the Input
# Monitoring permission each time. To keep it while developing, create a self-signed
# code-signing certificate once (Keychain Access > Certificate Assistant > Create a
# Certificate, type Code Signing) and build with:
#
#   SIGN_IDENTITY="your certificate name" ./build.sh
set -e
mode="$1"
cd "$(dirname "$0")"
identity="${SIGN_IDENTITY:--}"

fail() {
    printf '\n  forchpad: %s\n\n' "$1" >&2
    exit 1
}

[ "$(uname -s)" = "Darwin" ] || fail "this builds on macOS only (it reads a Mac's trackpad)."

# /usr/bin/swiftc exists even without developer tools (it only offers to install them), so ask xcode-select.
{ xcode-select -p >/dev/null 2>&1 && command -v swiftc >/dev/null 2>&1; } || fail "Swift isn't installed. Install Apple's Command Line Tools:

    xcode-select --install

  then run ./build.sh again."

# Swift 5.7 or newer (Xcode 14 or later).
version=$(swiftc --version 2>/dev/null | sed -n 's/.*Swift version \([0-9]*\)\.\([0-9]*\).*/\1 \2/p')
set -- $version
if [ -z "$1" ] || [ "$1" -lt 5 ] || { [ "$1" -eq 5 ] && [ "$2" -lt 7 ]; }; then
    fail "this needs Swift 5.7 or newer, and found ${1:-?}.${2:-?}. Update Xcode or the Command Line Tools
  (Software Update, or: xcode-select --install)."
fi

mkdir -p build
sources=$(find Sources/forchpad -name '*.swift' | sort)

# One swiftc call per architecture, with per-arch deployment targets: SwiftPM only supports
# one platform version, but Intel needs macOS 13 (this toolchain's compatibility packs have
# no x86_64 slice for 12) while Apple Silicon runs fine on 12.
echo "building for Apple Silicon…"
# shellcheck disable=SC2086
swiftc -O -target arm64-apple-macos12 $sources -o build/Forchpad-arm64 \
    || fail "the Apple Silicon build failed (errors above). Make sure Xcode or the Command Line Tools are up to date."
echo "building for Intel…"
# shellcheck disable=SC2086
swiftc -O -target x86_64-apple-macos13 $sources -o build/Forchpad-x86_64 \
    || fail "the Intel build failed (errors above). Make sure Xcode or the Command Line Tools are up to date."

lipo -create build/Forchpad-arm64 build/Forchpad-x86_64 -output build/Forchpad
codesign -s "$identity" -f build/Forchpad 2>/dev/null
echo "built build/Forchpad ($(lipo -archs build/Forchpad))"

app=dist/Forchpad.app
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp build/Forchpad "$app/Contents/MacOS/Forchpad"
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
for lang in en zh-Hans zh-Hant ja ko fr es ar; do
    mkdir -p "$app/Contents/Resources/$lang.lproj"
    cp "Resources/$lang.lproj/Localizable.strings" "$app/Contents/Resources/$lang.lproj/Localizable.strings"
done
codesign -s "$identity" -f "$app"
echo "wrapped $app — double-click it, or run: open $app"

[ "$mode" = "release" ] || exit 0

# Release: Developer ID signature (with the hardened runtime Apple requires), then notarization.
identity=$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application:[^"]*\)".*/\1/p' | head -n 1)
[ -n "$identity" ] || fail "no Developer ID Application certificate in your keychain. Add one in Xcode:
  Settings > Accounts > your team > Manage Certificates > + > Developer ID Application,
  then run ./build.sh release again."

profile="${NOTARY_PROFILE:-forchpad}"
xcrun notarytool history --keychain-profile "$profile" >/dev/null 2>&1 || fail "no saved notary sign-in called \"$profile\". Save one once (it asks for an app-specific password,
  made at account.apple.com > Sign-In and Security > App-Specific Passwords):

    xcrun notarytool store-credentials $profile --apple-id <your Apple ID> --team-id <your team ID>

  then run ./build.sh release again."

echo "signing with $identity…"
codesign --force --options runtime --timestamp --sign "$identity" "$app"
codesign --verify --strict "$app"

rm -f dist/Forchpad.zip
ditto -c -k --norsrc --noextattr --keepParent "$app" dist/Forchpad.zip

echo "sending to Apple for notarization (usually a minute or two)…"
xcrun notarytool submit dist/Forchpad.zip --keychain-profile "$profile" --wait \
    || fail "notarization didn't pass. See why with: xcrun notarytool log <submission id> --keychain-profile $profile"

xcrun stapler staple "$app" || fail "Apple accepted it, but stapling the ticket failed. Try again in a minute."
codesign --verify --strict -R="notarized" --check-notarization "$app" \
    || fail "Apple accepted it, but macOS can't confirm the notarization yet. Try again in a minute."
echo "released: dist/Forchpad.zip, signed and notarized. Attach it to the GitHub release."
