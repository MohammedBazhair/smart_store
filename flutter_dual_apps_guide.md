# 📘 دليل تشغيل تطبيقين Flutter (Client + Admin)

## 🎯 الفكرة
لدينا تطبيق واحد Flutter، لكن نريد تشغيله كتطبيقين منفصلين:

- 🟢 Client App (تطبيق المستخدم)
- 🔴 Admin App (تطبيق الإدارة)

كل واحد:
- اسم مختلف
- Package مختلف
- إصدار مختلف
- يمكن تثبيتهما معًا على نفس الجهاز

---

## 1️⃣ إنشاء flavors

في ملف:
android/app/build.gradle.kts

```gradle
flavorDimensions += "app"

productFlavors {

    create("client") {
        dimension = "app"
        applicationId = "com.example.smart_store"
        versionCode = 5
        versionName = "1.0.4"
        resValue("string", "app_name", "المتجر الذكي")
    }

    create("admin") {
        dimension = "app"
        applicationId = "com.example.smart_store_admin"
        versionCode = 1
        versionName = "1.0.0"
        resValue("string", "app_name", "المتجر الذكي - ادارة")
    }
}
```

---

## 2️⃣ تعديل اسم التطبيق

android/app/src/main/AndroidManifest.xml

```xml
android:label="@string/app_name"
```

---

## 3️⃣ ملفات التشغيل

lib/

- main_client.dart
- main_admin.dart

---

## 4️⃣ التشغيل

### Client
```bash
flutter run --flavor client -t lib/main_client.dart
```

### Admin
```bash
flutter run --flavor admin -t lib/main_admin.dart
```

---

## 5️⃣ تشغيل على جهاز محدد

```bash
flutter devices
flutter run -d DEVICE_ID --flavor admin -t lib/main_admin.dart
```

---

## 6️⃣ بناء APK

### Client
```bash
flutter build apk --flavor client -t lib/main_client.dart
```

### Admin
```bash
flutter build apk --flavor admin -t lib/main_admin.dart
```

---

## 7️⃣ ملاحظات مهمة

- pubspec.yaml لا يتحكم بإصدارات flavors
- كل تطبيق يمكن تثبيته بشكل مستقل
- applicationId هو ما يفرق بين التطبيقات

---

## 🚀 خلاصة

✔ تطبيق واحد  
✔ تطبيقين منفصلين  
✔ إعداد flavors  
✔ تشغيل وبناء مستقل لكل تطبيق  
