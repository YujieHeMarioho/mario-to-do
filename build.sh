#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
APP="build/Mario To Do.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
xcrun swiftc src/Main.swift -o "$APP/Contents/MacOS/MarioToDo" -framework Cocoa -framework WebKit -framework UserNotifications -O
cp src/index.html src/style.css src/app.js src/landscape.svg "$APP/Contents/Resources/"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleExecutable</key><string>MarioToDo</string><key>CFBundleIdentifier</key><string>com.mario.todo</string><key>CFBundleName</key><string>Mario To Do</string><key>CFBundleDisplayName</key><string>Mario To Do</string><key>CFBundleVersion</key><string>1</string><key>CFBundleShortVersionString</key><string>1.0</string><key>CFBundlePackageType</key><string>APPL</string><key>LSMinimumSystemVersion</key><string>13.0</string><key>NSHighResolutionCapable</key><true/><key>CFBundleIconFile</key><string>AppIcon</string></dict></plist>
PLIST
if [ -f src/AppIcon.icns ]; then cp src/AppIcon.icns "$APP/Contents/Resources/"; fi
codesign --force --deep --sign - "$APP"
printf 'Built %s\n' "$APP"
