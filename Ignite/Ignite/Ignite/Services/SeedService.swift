import Foundation
import FirebaseFirestore

struct SeedService {
    static let db = Firestore.firestore()

    static let testUsers: [User] = [
        User(id: "test_1", name: "Sara", age: 24,
             bio: "Artist from Nazareth who loves coffee and sunsets ☕",
             city: "Nazareth", gender: "Woman", interestedIn: "Men",
             profileImageURL: "https://randomuser.me/api/portraits/women/44.jpg",
             interests: ["Art", "Coffee", "Travel"]),

        User(id: "test_2", name: "Nour", age: 28,
             bio: "Doctor by day, foodie by night 🍕 Haifa is home.",
             city: "Haifa", gender: "Woman", interestedIn: "Men",
             profileImageURL: "https://randomuser.me/api/portraits/women/68.jpg",
             interests: ["Food", "Music", "Reading"]),

        User(id: "test_3", name: "Rana", age: 25,
             bio: "Music is my language 🎵 Looking for someone real.",
             city: "Tel Aviv", gender: "Woman", interestedIn: "Men",
             profileImageURL: "https://randomuser.me/api/portraits/women/90.jpg",
             interests: ["Music", "Dance", "Movies"]),

        User(id: "test_4", name: "Layla", age: 27,
             bio: "Teacher & traveler ✈️ Been to 12 countries and counting.",
             city: "Acre", gender: "Woman", interestedIn: "Men",
             profileImageURL: "https://randomuser.me/api/portraits/women/33.jpg",
             interests: ["Travel", "Reading", "Photography"]),

        User(id: "test_5", name: "Kareem", age: 29,
             bio: "Engineer who cooks better than most chefs 👨‍🍳",
             city: "Haifa", gender: "Man", interestedIn: "Women",
             profileImageURL: "https://randomuser.me/api/portraits/men/45.jpg",
             interests: ["Cooking", "Tech", "Fitness"]),

        User(id: "test_6", name: "Amir", age: 26,
             bio: "Architect, basketball player, terrible singer 🏀",
             city: "Nazareth", gender: "Man", interestedIn: "Women",
             profileImageURL: "https://randomuser.me/api/portraits/men/32.jpg",
             interests: ["Sports", "Art", "Coffee"])
    ]

    static func seedIfNeeded() {
        db.collection("users").document("test_1").getDocument { snapshot, _ in
            if snapshot?.exists == true { return } // Already seeded
            for user in testUsers {
                guard let id = user.id else { continue }
                try? db.collection("users").document(id).setData(from: user)
            }
            print("✅ Test users seeded")
        }
    }
}
