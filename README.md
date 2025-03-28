# 🎓 Engky - แอปพลิเคชันฝึกการฟังและพูดคำศัพท์ภาษาอังกฤษ

<div align="center">
  
![Engky Logo](https://img.shields.io/badge/-%F0%9F%94%8A%20ENGKY-7F00FF?style=for-the-badge)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

**แอปพลิเคชันฝึกภาษาอังกฤษที่ช่วยให้ผู้ใช้ฝึกทักษะการฟังและพูดผ่านการเรียนรู้คำศัพท์**

</div>

## 📱 ภาพหน้าจอ

<div align="center">
  <table>
    <tr>
      <td><img src="assets/screens/main_screen.png" alt="หน้าหลัก" width="250"/></td>
      <td><img src="assets/screens/correct_answer.png" alt="คำตอบถูก" width="250"/></td>
      <td><img src="assets/screens/wrong_answer.png" alt="คำตอบผิด" width="250"/></td>
    </tr>
    <tr>
      <td align="center">หน้าหลัก</td>
      <td align="center">คำตอบถูก</td>
      <td align="center">คำตอบผิด</td>
    </tr>
  </table>
</div>

## ✨ คุณสมบัติ

- 🔤 แสดงคำศัพท์ภาษาอังกฤษพร้อมคำแปลภาษาไทย
- 🔊 ฟังก์ชันออกเสียงคำศัพท์ด้วย Text-to-Speech
- 🎙️ ฟังก์ชันฝึกพูดด้วย Speech-to-Text พร้อมระบบจับเวลา 5 วินาที
- ⏭️ ระบบสุ่มคำศัพท์จากฐานข้อมูล JSON
- 🏆 ระบบบันทึกคะแนนเมื่อตอบถูก

## 🛠 เทคโนโลยีที่ใช้

- [Flutter](https://flutter.dev/) - Cross-platform UI framework
- [Dart](https://dart.dev/) - ภาษาที่ใช้ในการพัฒนา
- [flutter_tts](https://pub.dev/packages/flutter_tts) - สำหรับการแปลงข้อความเป็นเสียงพูด
- [speech_to_text](https://pub.dev/packages/speech_to_text) - สำหรับการแปลงเสียงพูดเป็นข้อความ
- [shared_preferences](https://pub.dev/packages/shared_preferences) - สำหรับการจัดเก็บข้อมูลคะแนน

## 🚀 การติดตั้ง

1. ติดตั้ง Flutter และ Dart SDK: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

2. โคลนโปรเจคนี้:

```bash
git clone https://github.com/yourusername/engky.git
cd engky
```

3. ติดตั้ง dependencies:

```bash
flutter pub get
```

4. สร้างโฟลเดอร์ assets และเพิ่มไฟล์ vocabulary.json:

```bash
mkdir -p assets
cp vocabulary.json assets/
```

5. แก้ไขไฟล์ pubspec.yaml เพื่อเพิ่ม assets:

```yaml
flutter:
  assets:
    - assets/vocabulary.json
```

6. รันแอปพลิเคชัน:

```bash
flutter run
```

## 📋 การใช้งานแอปพลิเคชัน

1. **หน้าหลัก** - แอปพลิเคชันจะแสดงคำศัพท์ภาษาอังกฤษพร้อมคำแปลภาษาไทย
   
2. **ฟังการออกเสียง** - กดปุ่ม `Listen` (สีฟ้า) เพื่อฟังการออกเสียงของคำศัพท์นั้นๆ
   
3. **ฝึกพูด** - กดปุ่ม `Speak` (สีส้ม) เพื่อเริ่มการบันทึกเสียง โดยมีเวลา 5 วินาที
   
4. **ระบบตรวจสอบ** - เมื่อครบ 5 วินาที ระบบจะตรวจสอบว่าคุณพูดถูกต้องหรือไม่
   - หากพูดถูกต้อง จะแสดงข้อความ "Correct!" พร้อมเพิ่มคะแนน
   - หากพูดผิด จะแสดงข้อความ "Try Again" พร้อมแสดงคำที่คุณพูด
   
5. **ข้ามคำศัพท์** - กดปุ่ม `Skip` (สีม่วง) เพื่อไปยังคำศัพท์ถัดไป

6. **เปลี่ยนคำศัพท์** - เลื่อนซ้ายหรือขวาเพื่อดูคำศัพท์อื่นๆ

## 📂 โครงสร้างโปรเจค

```
engky/
├── lib/
│   └── main.dart         # ไฟล์หลักที่รวมทุกฟังก์ชันไว้ด้วยกัน
├── assets/
│   └── vocabulary.json   # ไฟล์ JSON เก็บคำศัพท์และคำแปล
└── pubspec.yaml          # กำหนดค่า dependencies
```

## 🔄 การปรับแต่งคำศัพท์ใน JSON

คุณสามารถปรับแต่งคำศัพท์ได้โดยการแก้ไขไฟล์ `assets/vocabulary.json`

### โครงสร้าง JSON:

```json
{
  "words": [
    {
      "word": "apple",
      "meaning": "แอปเปิ้ล"
    },
    {
      "word": "book",
      "meaning": "หนังสือ"
    },
    ...
  ]
}
```

### วิธีการเพิ่มคำศัพท์ใหม่:

1. เปิดไฟล์ `assets/vocabulary.json`
2. เพิ่มรายการใหม่ในอาเรย์ `words`
3. แต่ละรายการต้องมี `word` (ภาษาอังกฤษ) และ `meaning` (ภาษาไทย)
4. บันทึกไฟล์และรันแอปพลิเคชันอีกครั้ง

## 🎯 ตัวอย่างโค้ดสำคัญ

### การใช้งาน Text-to-Speech

```dart
Future<void> _speakWord() async {
  await flutterTts.setLanguage('en-US');
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.speak(widget.vocab.word);
}
```

### การใช้งาน Speech-to-Text พร้อมตั้งเวลา

```dart
Future<void> _listen() async {
  setState(() {
    recognizedText = '';
    isListening = true;
    hasChecked = false;
    isCorrect = false;
    _timerValue = 0.0;
  });

  try {
    _speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords.toLowerCase();
        });
      },
      listenFor: const Duration(seconds: 5),
      localeId: 'en_US',
    );
    
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timerValue += 0.02;
      });
      
      if (_timerValue >= 1.0) {
        _countdownTimer?.cancel();
        _forceCheckAnswer();
      }
    });
  } catch (e) {
    print('Error starting speech recognition: $e');
    setState(() {
      isListening = false;
    });
  }
}
```


## 👨‍💻 ผู้พัฒนา

พัฒนาโดย Triwit Pawante

---

<div align="center">
Made with ❤️ for learning English
</div>
