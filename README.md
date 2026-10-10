# 🩸 Vampire Warrior · Blood Hero

เกมแอ็กชัน 2D แวมไพร์ล่าเลือด กราฟิกเรโทรยุค 90s พร้อมระบบการ์ดบัฟ Perk สุ่มพลัง, บอส 5 ตัวไม่ซ้ำแบบ, ระบบเซฟเกม, และเสียงพากย์ภาษาไทย

---

## 📁 โครงสร้างโฟลเดอร์โครงการ (Project Structure)

```
bloodhero/
├── 📱 app/                    # โฟลเดอร์สำหรับ Android App
│   ├── BloodHero-VampireWarrior.apk   # ไฟล์ติดตั้ง APK สำหรับมือถือ Android
│   ├── build_apk.ps1                  # สคริปต์คอมไพล์และ Sign APK อัตโนมัติ
│   └── README.md                      # วิธีการติดตั้งและการบิลด์แอป
│
├── 🌐 web/                    # โฟลเดอร์สำหรับ Web Browser
│   ├── index.html                     # ไฟล์หลักสำหรับเปิดเล่นหรืออัปขึ้นเว็บโฮสติ้ง
│   ├── vampire_warrior_blood_hero.html# ไฟล์เกมเวอร์ชันเต็ม
│   ├── manifest.json                  # รองรับการติดตั้งเป็น PWA Web App
│   ├── sw.js                          # Service Worker เล่นแบบ Offline
│   ├── hero_sprites.js                # สไปรต์ตัวละครแบบ Base64
│   ├── sprite-animation-128x128-frames/ # เฟรมสไปรต์ตัวละคร
│   ├── run_web.ps1                    # สคริปต์รัน Local Web Server ทดสอบ
│   └── README.md                      # วิธีการเล่นและการควบคุมบนเว็บ
│
├── 📦 assets_src/             # ไฟล์ Resource และสคริปต์เสียงพากย์ต้นฉบับ
│   ├── Survivors RPG Starter Pack v1.0-free pack/
│   └── bloodhero_vo_script.md
│
├── BloodHero-VampireWarrior.apk # ไฟล์ APK ล่าสุด (วางไว้ที่ Root เพื่อความสะดวก)
└── index.html                 # ลิงก์เข้าสู่เวอร์ชัน Web
```

---

## 🚀 วิธีการใช้งานอย่างรวดเร็ว

### 1. เล่นเวอร์ชันมือถือ (Android APK)
- นำไฟล์ `app/BloodHero-VampireWarrior.apk` ไปติดตั้งบนมือถือ Android
- ควบคุมด้วย **Virtual Analog Floating Joystick** ทางซ้าย และปุ่ม **ATTACK / DASH** ทางขวา
- มีปุ่ม **⚙️ OPTION** มุมขวาบนเพื่อหยุดเกม, เซฟความคืบหน้า, และปรับระดับเสียง

### 2. เล่นเวอร์ชันเว็บเบราว์เซอร์ (PC / Mac / Tablet)
- ดับเบิลคลิกไฟล์ `web/index.html` หรือรันสคริปต์ `web/run_web.ps1`
- รองรับการแสดงผลเต็มจอ (กดปุ่ม `F` หรือ `⛶ เต็มจอ`)
- เคลื่อนที่ด้วย `WASD` / ลูกศร, เล็งด้วยเมาส์, ยิงด้วยคลิกซ้าย, แดชด้วย `Spacebar`
