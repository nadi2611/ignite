import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var age: Int
    var bio: String
    var city: String
    var profileImages: [String]
    var interests: [String]

    static let mock = User(
        id: "1",
        name: "Layla",
        age: 26,
        bio: "Coffee lover. Sunset chaser. Looking for my person.",
        city: "Haifa",
        profileImages: ["person.fill"],
        interests: ["Travel", "Food", "Music"]
    )
}
