import Foundation
@preconcurrency import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var age: Int
    var bio: String
    var city: String
    var gender: String
    var interestedIn: String
    var imageURLs: [String]
    var verificationSelfieURL: String?
    var interests: [String]
    var religion: String?
    var religiosityLevel: String?
    var marriageTimeline: String?
    var education: String?
    var profession: String?
    var phoneNumber: String?
    var originCity: String?
    var height: Int?
    var smokes: String?
    var prays: String?
    var fasts: String?
    var isVerified: Bool?
    var isPendingVerification: Bool?
    var isAdmin: Bool?
    var agreedToTerms: Bool?
    var agreedAt: Date?
    var swipesToday: Int?
    var lastSwipeDate: Date?
    var createdAt: Date?
    var fcmToken: String?

    var profileImageURL: String {
        imageURLs.first ?? ""
    }

    init(id: String? = nil, name: String, age: Int, bio: String = "", city: String = "",
         gender: String = "", interestedIn: String = "", imageURLs: [String] = [],
         verificationSelfieURL: String? = nil,
         interests: [String] = [], religion: String? = nil,
         religiosityLevel: String? = nil, marriageTimeline: String? = nil,
         education: String? = nil, profession: String? = nil, phoneNumber: String? = nil,
         originCity: String? = nil, height: Int? = nil, smokes: String? = nil,
         prays: String? = nil, fasts: String? = nil,
         isVerified: Bool = false, isPendingVerification: Bool = false, isAdmin: Bool = false,
         agreedToTerms: Bool = false, agreedAt: Date? = nil,
         swipesToday: Int = 0, lastSwipeDate: Date? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.city = city
        self.gender = gender
        self.interestedIn = interestedIn
        self.imageURLs = imageURLs
        self.verificationSelfieURL = verificationSelfieURL
        self.interests = interests
        self.religion = religion
        self.religiosityLevel = religiosityLevel
        self.marriageTimeline = marriageTimeline
        self.education = education
        self.profession = profession
        self.phoneNumber = phoneNumber
        self.originCity = originCity
        self.height = height
        self.smokes = smokes
        self.prays = prays
        self.fasts = fasts
        self.isVerified = isVerified
        self.isPendingVerification = isPendingVerification
        self.isAdmin = isAdmin
        self.agreedToTerms = agreedToTerms
        self.agreedAt = agreedAt
        self.swipesToday = swipesToday
        self.lastSwipeDate = lastSwipeDate
        self.createdAt = createdAt
    }

    var completionScore: Int {
        var score = 0
        if !imageURLs.isEmpty { score += 20 }
        if !bio.isEmpty { score += 15 }
        if religion != nil { score += 15 }
        if !city.isEmpty && (originCity != nil && !originCity!.isEmpty) { score += 10 }
        if smokes != nil { score += 5 }
        if prays != nil { score += 5 }
        if fasts != nil { score += 5 }
        if height != nil { score += 5 }
        if isVerified == true { score += 20 }
        return score
    }

    struct ChecklistItem: Identifiable {
        let id = UUID()
        let title: String
        let points: Int
        let isComplete: Bool
    }

    var scoreChecklist: [ChecklistItem] {[
        ChecklistItem(title: L("score_photo"), points: 20, isComplete: !imageURLs.isEmpty),
        ChecklistItem(title: L("score_bio"), points: 15, isComplete: !bio.isEmpty),
        ChecklistItem(title: L("score_religion"), points: 15, isComplete: religion != nil),
        ChecklistItem(title: L("score_cities"), points: 10, isComplete: !city.isEmpty && (originCity != nil && !originCity!.isEmpty)),
        ChecklistItem(title: L("score_lifestyle"), points: 15, isComplete: smokes != nil && prays != nil && fasts != nil),
        ChecklistItem(title: L("score_height"), points: 5, isComplete: height != nil),
        ChecklistItem(title: L("score_verified"), points: 20, isComplete: isVerified == true)
    ]}

    static let mock = User(
        id: "mock1",
        name: "Layla",
        age: 26,
        bio: "Coffee lover. Sunset chaser.",
        city: "Haifa",
        gender: "Woman",
        interestedIn: "Men",
        interests: ["Travel", "Food", "Music"],
        religion: "Sunni Muslim"
    )
}
