#!/bin/bash
# Builds RemoveMacAI.app from the same binary as the command-line tool.
#
#   tools/build-app.sh            -> .build/RemoveMacAI.app
#
# Opened from Finder the binary shows the app; with arguments it is the CLI.
set -euo pipefail
cd "$(dirname "$0")/.."

sdk="${SDKROOT:-$(xcrun --show-sdk-path)}"
swift build -c release --arch arm64 --sdk "$sdk"
bin="$(swift build -c release --arch arm64 --sdk "$sdk" --show-bin-path)/removemacai"
version="$("$bin" --version)"

app=".build/RemoveMacAI 中文版.app"
rm -rf "$app" .build/AppIcon.iconset
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin" "$app/Contents/MacOS/RemoveMacAI"
cp LICENSE THIRD-PARTY-NOTICES.md "$app/Contents/Resources/"

mkdir -p .build/AppIcon.iconset
for size in 16 32 128 256 512; do
  sips -z $size $size tools/AppIcon.png --out ".build/AppIcon.iconset/icon_${size}x${size}.png" >/dev/null
  sips -z $((size * 2)) $((size * 2)) tools/AppIcon.png --out ".build/AppIcon.iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns .build/AppIcon.iconset -o "$app/Contents/Resources/AppIcon.icns"

cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>zh-Hans</string>
  <key>CFBundleLocalizations</key><array><string>zh-Hans</string></array>
  <key>CFBundleExecutable</key><string>RemoveMacAI</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleIdentifier</key><string>io.github.omlahore.removemacai.zh-Hans.app</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>RemoveMacAI 中文版</string>
  <key>CFBundleDisplayName</key><string>RemoveMacAI 中文版</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$version</string>
  <key>CFBundleVersion</key><string>$version</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>LSMinimumSystemVersion</key><string>26.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>MIT License. Apple Intelligence removal builds on pared by 4evy.</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$app"
codesign --verify --strict "$app"
echo "$app ($version)"
