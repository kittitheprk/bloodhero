# 📱 Blood Hero - Android App Version

โฟลเดอร์สำหรับเวอร์ชันแอปพลิเคชันมือถือ Android

---

## 📂 รายการไฟล์ในโฟลเดอร์ `app/`

- **`BloodHero-VampireWarrior.apk`**: ไฟล์แอปพลิเคชันสำหรับติดตั้งบนมือถือ Android (ขนาด ~1.2 MB, Signed v2/v3)
- **`build_apk.ps1`**: สคริปต์คอมไพล์ซอร์สโค้ดและสร้างไฟล์ APK ใหม่ด้วย Android Build-Tools
- **`android-build/`**: โฟลเดอร์สำหรับกระบวนการคอมไพล์ของ Android (Manifest, Java classes, Resource, Assets, Keystore)

---

## 📲 วิธีการติดตั้งบนมือถือ

1. คัดลอกไฟล์ **`BloodHero-VampireWarrior.apk`** ไปยังมือถือ Android
2. แตะที่ไฟล์เพื่อทำการติดตั้ง (หากระบบถาม ให้เปิดอนุญาต "Install unknown apps")
3. เปิดแอปและสนุกกับเกมได้ทันทีแบบแนวนอนเต็มจอ (Fullscreen Immersive Mode)

---

## 🛠️ วิธีการคอมไพล์ APK ใหม่ (Build Pipeline)

หากมีการแก้ไขไฟล์เกมใน `web/` สามารถสั่งรันสคริปต์เพื่อสร้าง APK ใหม่ได้ง่าย ๆ:

```powershell
powershell -ExecutionPolicy Bypass -File .\build_apk.ps1
```
