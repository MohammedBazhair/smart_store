````md
# 📘 دليل تشغيل وإصدار تطبيقين Flutter (Client + Admin)

## 🎯 الفكرة

لدينا مشروع Flutter واحد يحتوي على Flavorين:

- 🟢 Client App (تطبيق المستخدم)
- 🔴 Admin App (تطبيق الإدارة)

لكل تطبيق:

- اسم مختلف
- Application ID مختلف
- إصدار (Version) مستقل
- يمكن تثبيتهما معًا على نفس الجهاز
- Release مستقل عبر GitHub Actions

---

# 1️⃣ إنشاء Flavors

في الملف:

`android/app/build.gradle.kts`

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
        resValue("string", "app_name", "المتجر الذكي - إدارة")
    }
}
```

---

# 2️⃣ تعديل اسم التطبيق

في:

`android/app/src/main/AndroidManifest.xml`

```xml
android:label="@string/app_name"
```

---

# 3️⃣ ملفات التشغيل

داخل مجلد `lib`

```
main_client.dart
main_admin.dart
```

---

# 4️⃣ تشغيل التطبيق

## Client

```bash
flutter run --flavor client -t lib/main_client.dart
```

## Admin

```bash
flutter run --flavor admin -t lib/main_admin.dart
```

---

# 5️⃣ التشغيل على جهاز محدد

```bash
flutter devices
```

ثم

```bash
flutter run -d DEVICE_ID --flavor admin -t lib/main_admin.dart
```

---

# 6️⃣ بناء APK

## Client

```bash
flutter build apk --release --flavor client -t lib/main_client.dart
```

## Admin

```bash
flutter build apk --release --flavor admin -t lib/main_admin.dart
```

---

# 7️⃣ GitHub Actions (CI/CD)

يستخدم المشروع GitHub Actions لإنشاء Release تلقائيًا.

ملف الـ Workflow موجود في:

```
.github/workflows/flutter_release.yml
```

ويتم تشغيله **عند إنشاء Git Tag**.

---

# 8️⃣ إنشاء Release

## إصدار نسخة العميل

```bash
git tag client-v1.0.0
git push origin client-v1.0.0
```

سيقوم GitHub Actions تلقائيًا بـ:

- بناء Flavor `client`
- إنشاء Release باسم

```
client-v1.0.0
```

- رفع ملف APK إلى صفحة Releases.

---

## إصدار نسخة الإدارة

```bash
git tag admin-v1.0.0
git push origin admin-v1.0.0
```

سيقوم GitHub Actions تلقائيًا بـ:

- بناء Flavor `admin`
- إنشاء Release باسم

```
admin-v1.0.0
```

- رفع ملف APK إلى صفحة Releases.

---

# 9️⃣ تحديث إصدار التطبيق

قبل إنشاء Release جديد يجب تحديث:

```kotlin
versionCode
versionName
```

داخل الـ Flavor المناسب في:

```
android/app/build.gradle.kts
```

مثال:

```kotlin
create("client") {
    versionCode = 6
    versionName = "1.0.5"
}
```

ثم إنشاء Tag جديد:

```bash
git tag client-v1.0.5
git push origin client-v1.0.5
```

---

# 🔟 ملاحظات مهمة

- `pubspec.yaml` لا يتحكم في إصدار كل Flavor.
- لكل Flavor إصدار مستقل.
- لكل Flavor `applicationId` مستقل.
- يمكن تثبيت التطبيقين معًا على نفس الجهاز.
- لا يتم إنشاء Release إلا للـ Flavor الموجود في اسم الـ Tag.
- لا حاجة لإنشاء فرع (`branch`) لكل تطبيق، يكفي استخدام فرع `main`.

---

# 🚀 مثال لسير العمل

تطوير نسخة العميل:

```text
تعديل الكود
      │
      ▼
Push إلى main
      │
      ▼
git tag client-v1.0.5
      │
      ▼
git push origin client-v1.0.5
      │
      ▼
GitHub Actions
      │
      ▼
Build Client APK
      │
      ▼
Create GitHub Release
```

أما نسخة الإدارة فتتبع نفس الخطوات باستخدام:

```text
admin-v1.0.0
admin-v1.0.1
admin-v1.1.0
...
```

---

# ✅ الخلاصة

- مشروع Flutter واحد.
- Flavorان (Client + Admin).
- تشغيل مستقل لكل تطبيق.
- بناء APK مستقل لكل تطبيق.
- GitHub Actions يبني التطبيق المناسب تلقائيًا حسب اسم الـ Tag.
- Releases مستقلة لكل من العميل والإدارة.
````
