# چراغ — اپلیکیشن هیئت بابالحوائج زمان‌آباد

اپلیکیشن Flutter + Firebase طبق پرامپت اولیه پروژه، شامل:
اپ اصلی کاربران + پنل مدیریت کامل (CRUD، اعلان، پرداخت‌ها).

## پیش‌نیازها
- نصب [Flutter SDK](https://docs.flutter.dev/get-started/install) (آخرین نسخه پایدار)
- یک حساب [Firebase](https://console.firebase.google.com) و پروژه ساخته‌شده در آن
- نصب FlutterFire CLI:
  ```
  dart pub global activate flutterfire_cli
  ```

## راه‌اندازی
1. وابستگی‌ها را نصب کنید:
   ```
   flutter pub get
   ```
2. پروژه Firebase را متصل کنید (این دستور فایل `lib/core/config/firebase_options.dart`
   را با کلیدهای واقعی جایگزین می‌کند):
   ```
   flutterfire configure
   ```
3. در Firebase Console این سرویس‌ها را فعال کنید:
   - Authentication (روش Email/Password)
   - Cloud Firestore
   - Storage
   - Cloud Messaging
   - Analytics
4. محتوای فایل `firestore.rules` را در بخش Rules پروژه Firestore خود قرار دهید.
5. برای تعیین یک کاربر به‌عنوان ادمین، یک سند در collection `admins` با
   شناسه (Document ID) برابر با UID همان کاربر بسازید (خالی هم می‌تواند باشد،
   صرفاً وجودش کافی است).
6. فونت وزیرمتن (Vazirmatn) را در مسیر `assets/fonts/` قرار دهید یا از
   `google_fonts` (که در پروژه فعال است) استفاده کنید — در این صورت نیازی
   به فایل فونت محلی نیست.
7. اجرای برنامه:
   ```
   flutter run
   ```

## ساختار پروژه
```
lib/
  core/          تنظیمات، ثابت‌ها، تم
  models/        مدل‌های داده (هر کدام فایل جداگانه)
  services/      ارتباط با Firebase (Auth, Firestore, Storage, FCM)
  providers/     مدیریت State با Provider
  pages/         تمام صفحات کاربر و پنل مدیریت
  widgets/       ویجت‌های قابل استفاده مجدد
  routes/        مسیرهای برنامه
```

## وضعیت تکمیل پروژه
پنل مدیریت اکنون کامل است و شامل ۹ بخش می‌شود: مدیریت کاربران (با قابلیت
اعطا/لغو دسترسی مدیر)، مدیریت اطلاعیه‌ها، مدیریت برنامه‌ها، مدیریت فایل‌های
صوتی (آپلود مستقیم فایل)، مدیریت تصاویر گالری، مدیریت پرداخت‌ها (تایید/رد
رسید با مشاهده تصویر)، ارسال اعلان (فوری/گروهی/زمان‌بندی‌شده)، مدیریت
تنظیمات (لوگو، رنگ اصلی/ثانویه برنامه، شماره کارت، اطلاعات تماس) و مشاهده
آمار. صفحه «کمک‌های مالی» و «تماس با ما» اکنون مقادیر خود را به‌صورت زنده از
collection `settings` می‌خوانند، و صفحه «درباره هیئت» گالری واقعی را از
collection `gallery` نمایش می‌دهد. صفحه «اعلان‌ها»ی کاربر با آیکون زنگ در
صفحه اصلی در دسترس است.

## نکات مهم برای استقرار نهایی (Production)
- ارسال Push Notification واقعی (نمایش نوتیفیکیشن سیستمی به‌محض ارسال) نیاز
  به Cloud Functions یا سرور با FCM Admin SDK دارد. در حال حاضر ارسال اعلان
  از پنل مدیریت آن را در Firestore (collection `notifications`) ثبت می‌کند
  و بلافاصله در صفحه «اعلان‌ها»ی همه کاربران نمایش داده می‌شود؛ برای Push
  واقعی یک Cloud Function بنویسید که با ثبت هر سند جدید در این collection،
  از FCM Admin SDK برای ارسال به topic `all_users` (یا گروه انتخابی) استفاده
  کند.
- برای انتخاب فایل صوتی در «مدیریت فایل‌های صوتی» از پکیج `file_picker`
  استفاده شده؛ روی iOS ممکن است نیاز به تنظیم دسترسی `NSPhotoLibraryUsageDescription`
  و مشابه آن در `Info.plist` داشته باشید (برای انتخاب تصویر/رسید هم همینطور).
- برای تعیین اولین ادمین سیستم، طبق مرحله بالا مستقیماً در Firebase Console
  یک سند در collection `admins` بسازید؛ پس از آن ادمین‌های بعدی را می‌توان
  از همان پنل («مدیریت کاربران») تعیین کرد.
- برای آیکون و لوگوی واقعی اپ از پکیج `flutter_launcher_icons` استفاده کنید.
- برای Splash Screen بومی (نه فقط صفحه اول) از پکیج `flutter_native_splash`
  استفاده کنید.

## انتشار
```
flutter build appbundle   # برای Google Play
flutter build ipa         # برای App Store (نیاز به macOS و Xcode)
```
