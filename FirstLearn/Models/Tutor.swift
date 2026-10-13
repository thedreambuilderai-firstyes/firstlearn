import Foundation

/// Who the app is for. Kids mode keeps things simpler and bigger.
enum LearnerMode: String, Codable, CaseIterable, Identifiable {
    case adult
    case kids

    var id: String { rawValue }

    var title: String {
        switch self {
        case .adult: "Grown-up"
        case .kids: "Kids"
        }
    }

    var subtitle: String {
        switch self {
        case .adult: "Everyday Kannada for life in Karnataka"
        case .kids: "Big pictures, fewer choices, lots of cheering"
        }
    }

    var emoji: String {
        switch self {
        case .adult: "🧑"
        case .kids: "🧒"
        }
    }

    /// Number of answer options shown in a question.
    var answerChoices: Int {
        switch self {
        case .adult: 4
        case .kids: 3
        }
    }
}

/// A teacher personality. The lesson content is shared; the tutor changes how it is said.
struct Tutor: Identifiable, Hashable {
    let id: String
    let name: String
    let role: String
    let emoji: String
    let colorHex: UInt32
    let tagline: String
    /// `{name}` is replaced with the learner's name.
    let greetingTemplate: String
    let learnLines: [String]
    let praiseLines: [String]
    let correctionLines: [String]
    let completionLines: [String]

    func greeting(for learnerName: String) -> String {
        greetingTemplate.replacingOccurrences(of: "{name}", with: learnerName)
    }

    func learnLine() -> String { learnLines.randomElement() ?? "" }
    func praise() -> String { praiseLines.randomElement() ?? "" }
    func correction() -> String { correctionLines.randomElement() ?? "" }
    func completion() -> String { completionLines.randomElement() ?? "" }
}

extension Tutor {
    static func find(_ id: String?) -> Tutor {
        all.first { $0.id == id } ?? all[0]
    }

    static let all: [Tutor] = [ajji, chikkamma, macha, aane, pandu]

    static let ajji = Tutor(
        id: "ajji",
        name: "Ajji",
        role: "Grandma",
        emoji: "👵",
        colorHex: 0xE8875B,
        tagline: "Patient, warm, always asks if you've eaten",
        greetingTemplate: "Banni, kulithkolli! Come, sit, {name}. Ajji will teach you slowly.",
        learnLines: ["Listen to Ajji, kanda…", "Say it with me, nice and slow.", "This one is very useful, dear."],
        praiseLines: ["Shabhash! Just like your Ajji.", "Very good, kanda!", "Chennagide! That was lovely."],
        correctionLines: ["Paravagilla, no problem. We'll try once more.", "Ayyo, almost! Ajji will help you."],
        completionLines: ["Oota aaytha? You've earned a treat!", "Ajji is so proud of you today."]
    )

    static let chikkamma = Tutor(
        id: "chikkamma",
        name: "Chikkamma",
        role: "Fun Aunt",
        emoji: "💃",
        colorHex: 0xD64F8A,
        tagline: "Dramatic, chatty, knows all the market tricks",
        greetingTemplate: "Arre {name}! Chikkamma has so much to tell you. Let's go!",
        learnLines: ["Okay, listen, this one is important!", "Psst… everyone uses this one.", "Say it with style!"],
        praiseLines: ["Sooper! You're a natural!", "See? Chikkamma knew you could do it!"],
        correctionLines: ["Ayyo, so close! Don't tell anyone, just try again.", "Tch, no worries. Even I mixed that up once."],
        completionLines: ["Wait till I tell the whole family about you!", "Lesson done! Now we celebrate."]
    )

    static let macha = Tutor(
        id: "macha",
        name: "Macha",
        role: "Friend",
        emoji: "🧑‍💻",
        colorHex: 0x3C8DDB,
        tagline: "Your Bengaluru buddy: traffic jokes and filter coffee",
        greetingTemplate: "Macha {name}! Swalpa time, let's learn some Kannada.",
        learnLines: ["Okay macha, new word.", "Trust me, you'll use this daily.", "Easy one, boss."],
        praiseLines: ["Sakkath, macha!", "Full marks, boss!", "Super, you're basically local now."],
        correctionLines: ["Swalpa adjust maadi, try again!", "No tension, macha. One more go."],
        completionLines: ["Lesson done. Filter coffee on me ☕", "Sakkath work today, macha!"]
    )

    static let aane = Tutor(
        id: "aane",
        name: "Aane",
        role: "Elephant",
        emoji: "🐘",
        colorHex: 0x7A6FD0,
        tagline: "A gentle giant who never forgets a word",
        greetingTemplate: "Hello {name}! I'm Aane the elephant. Let's stomp through some words!",
        learnLines: ["Big ears ready? Listen!", "Stomp, stomp, new word!", "Elephants never forget. Neither will you!"],
        praiseLines: ["Trumpet toot! 🎺 You got it!", "Big elephant hug for you!"],
        correctionLines: ["Oopsie! Let's try that again together.", "Almost! Flap your ears and try again."],
        completionLines: ["You did it! Banana party! 🍌", "Stomp stomp hooray!"]
    )

    static let pandu = Tutor(
        id: "pandu",
        name: "Pandu",
        role: "Panda",
        emoji: "🐼",
        colorHex: 0x4BA67A,
        tagline: "Sleepy, snacky, and very silly",
        greetingTemplate: "Yawn… oh hi {name}! Pandu is awake now. Let's learn!",
        learnLines: ["Munch munch… new word!", "Pandu learned this one between naps.", "Listen closely!"],
        praiseLines: ["Bamboo-tiful! 🎋", "Yay! Pandu does a happy roll!"],
        correctionLines: ["Hmm, Pandu was napping. Let's try again!", "Nearly! Have a snack and try again."],
        completionLines: ["All done! Time for a bamboo snack 🎋", "You're the best, Pandu is so happy!"]
    )
}
