#!/bin/bash
# Запускать на Mac в папке проекта ПОСЛЕ `npx cap add ios`.
set -e
[ -d ios/App ] || { echo "Сначала выполните: npx cap add ios"; exit 1; }
APPID=$(grep -o '"appId": *"[^"]*"' capacitor.config.json | sed 's/.*: *"\(.*\)"/\1/')
GROUP="group.$APPID"
echo "App Group: $GROUP"

cp native/WidgetBridgePlugin.swift native/ViewController.swift ios/App/App/
cp native/BalanceWidget.swift ios/BalanceWidget.swift
sed -i '' "s/group.com.example.finance/$GROUP/g" ios/App/App/WidgetBridgePlugin.swift ios/BalanceWidget.swift

# iOS 17+ и только iPhone
[ -f ios/App/Podfile ] && sed -i '' "s/platform :ios, '[0-9.]*'/platform :ios, '17.0'/" ios/App/Podfile
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*;/IPHONEOS_DEPLOYMENT_TARGET = 17.0;/g; s/TARGETED_DEVICE_FAMILY = "1,2";/TARGETED_DEVICE_FAMILY = 1;/g' ios/App/App.xcodeproj/project.pbxproj

# URL-схема finance://
PLIST=ios/App/App/Info.plist
if ! /usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes" "$PLIST" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string finance" "$PLIST"
fi

# Главный экран использует наш ViewController
SB=ios/App/App/Base.lproj/Main.storyboard
if grep -q 'customClass="CAPBridgeViewController"' "$SB"; then
  sed -i '' 's/customClass="CAPBridgeViewController" customModule="Capacitor"/customClass="ViewController" customModule="App"/' "$SB"
else
  echo "ВНИМАНИЕ: в Main.storyboard задайте класс экрана ViewController (модуль App) вручную."
fi

# Подключаем Swift-файлы к цели App
ruby <<'RUBY' || echo "Не удалось подключить файлы автоматически: перетащите WidgetBridgePlugin.swift и ViewController.swift в группу App в Xcode."
require 'xcodeproj'
proj = Xcodeproj::Project.open('ios/App/App.xcodeproj')
target = proj.targets.find { |t| t.name == 'App' }
group = proj.main_group['App']
%w[WidgetBridgePlugin.swift ViewController.swift].each do |f|
  next if group.files.any? { |r| r.path == f }
  target.add_file_references([group.new_reference(f)])
end
proj.save
RUBY
echo "Готово. Дальше: README, шаги 2-4."
