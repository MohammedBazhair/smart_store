# دليل الإعداد والتشغيل

## المتطلبات الأساسية

- Flutter SDK (3.0.0 أو أحدث)
- Dart SDK
- Android Studio / VS Code
- Android SDK (للتطوير على Android)
- Xcode (للتطوير على iOS - macOS فقط)

## خطوات الإعداد

### 1. تثبيت الحزم

```bash
flutter pub get
```

### 2. إنشاء ملفات Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. تشغيل التطبيق

```bash
# Android
flutter run

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

## بناء نسخة الإنتاج

### Android

```bash
flutter build apk --release
# أو
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## الأذونات المطلوبة

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>نحتاج إلى الكاميرا لمسح الباركود</string>
```

## ملاحظات مهمة

1. **قاعدة البيانات**: يتم إنشاء قاعدة البيانات SQLite تلقائيًا عند أول تشغيل للتطبيق
2. **التنبيهات**: تأكد من تفعيل أذونات الإشعارات في إعدادات الجهاز
3. **النسخ الاحتياطي**: يتم حفظ النسخ الاحتياطية في مجلد Documents الخاص بالتطبيق

## استكشاف الأخطاء

### مشكلة في Code Generation

إذا واجهت مشاكل في إنشاء ملفات `.g.dart`:

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### مشكلة في الحزم

```bash
flutter pub upgrade
flutter pub get
```

### مشكلة في البناء

```bash
flutter clean
flutter pub get
flutter run
```

## الدعم

للحصول على المساعدة، يرجى فتح issue في المستودع.

