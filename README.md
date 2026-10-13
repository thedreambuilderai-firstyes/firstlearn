# FirstLearn: Kannada with a friend

An iPhone app that teaches Kannada from zero. The learner picks a teacher, and that character guides them through short, picture-based lessons.

| Teacher | Role | Personality |
|---|---|---|
| 👵 Ajji | Grandma | Patient, warm, always asks if you've eaten |
| 💃 Chikkamma | Fun aunt | Dramatic, chatty, knows the market tricks |
| 🧑‍💻 Macha | Friend | Bengaluru buddy: traffic jokes and filter coffee |
| 🐘 Aane | Elephant | Gentle giant who never forgets a word |
| 🐼 Pandu | Panda | Sleepy, snacky, very silly |

There are two learner modes:

- **Grown-up:** 4 answer choices, Kannada script shown by default.
- **Kids:** 3 choices, bigger pictures, script hidden, and answers are checked as soon as you tap.

## Running it

You need a Mac with **Xcode 16 or later**.

1. Open `FirstLearn.xcodeproj`.
2. Pick an iPhone simulator, such as iPhone 16, and press **Run** (⌘R).
3. To run on your own iPhone, select the **FirstLearn** target, go to *Signing & Capabilities*, and choose your Apple ID under *Team*.

The project targets iOS 17+. New files added under `FirstLearn/` are picked up automatically, with no need to drag them into Xcode.

## What works today

- Onboarding: welcome, your name, Grown-up or Kids, and choosing a teacher.
- A home screen with a teacher greeting, 🔥 streak, ⭐️ XP and 📚 words learned.
- A winding lesson path. Lessons 1–3 are playable and each one unlocks the next. Lessons 4–10 show as *Coming soon*.
- The lesson player:
  - **Learn cards:** picture, word, meaning, culture tip, plus *Listen* and *Slow* buttons.
  - **Picture match:** see the Kannada word, pick the picture.
  - **Meaning match:** see the picture, pick the Kannada word.
  - **Listen and tap:** hear the word, pick it.
  - Wrong answers come back again at the end of the lesson.
  - The teacher reacts to every answer in their own voice, with haptics.
- A celebration screen, with progress saved on the phone.
- Settings: change your name, mode, teacher or script display, or start over.

## Project layout

```
FirstLearn/
  FirstLearnApp.swift        App entry and root screen switch
  Models/
    Course.swift             Phrase / Lesson / Course + JSON loading
    Tutor.swift              Teacher personalities and Grown-up/Kids mode
    Progress.swift           Learner profile, XP and streak rules
    LessonPlanner.swift      Turns a lesson into learn and quiz steps
    AppState.swift           Shared state, unlocking, saving
  Services/
    Speaker.swift            Text-to-speech (placeholder for real recordings)
  Views/                     SwiftUI screens
  Resources/Course.json      All lesson content
```

### Adding lessons

Lesson content lives in `FirstLearn/Resources/Course.json`, so no code changes are needed. To finish a "coming soon" lesson, fill its `phrases` array. Each phrase needs `id`, `kannada`, `romanized`, `english`, `emoji` and an optional `note`. Use at least 4 phrases per lesson so Grown-up mode has enough answer choices.

### Adding a teacher

Add a new `Tutor` in `Models/Tutor.swift` and include it in `Tutor.all`.

## Before real users see it

- **Native speaker review:** every Kannada phrase, spelling and tip in `Course.json` is a draft (`"reviewStatus": "draft"`). A native Kannada speaker must check it.
- **Real audio:** iPhones may not include a Kannada voice. The app then reads the English spelling with an Indian-English voice, which is only good enough for testing. Record a native speaker for each phrase.
- **Art:** the emoji are stand-ins. Next comes illustrated characters, ideally animated with Rive.
- **Kids privacy:** before shipping kids mode publicly, review Apple's Kids Category rules and child-privacy law (COPPA, and India's DPDP Act). Don't add accounts, analytics or AI chat to kids mode without that review.

## Roadmap

1. Write lessons 4–10 and get them reviewed.
2. Native-speaker audio recordings.
3. Illustrated, animated characters.
4. A "Speak it" exercise using speech recognition.
5. Spaced-repetition review of older words.
6. AI chat with your teacher (grown-ups only, via a small backend server).
7. An optional Kannada script track ("a letter a day with Ajji").
