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
    var profileImageURL: String
    var interests: [String]
    var religion: String?
    var createdAt: Date?
    var fcmToken: String?

    init(id: String? = nil, name: String, age: Int, bio: String = "", city: String = "",
         gender: String = "", interestedIn: String = "", profileImageURL: String = "",
         interests: [String] = [], religion: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.city = city
        self.gender = gender
        self.interestedIn = interestedIn
        self.profileImageURL = profileImageURL
        self.interests = interests
        self.religion = religion
        self.createdAt = createdAt
    }

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
