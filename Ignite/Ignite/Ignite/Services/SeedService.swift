import Foundation
import FirebaseFirestore

struct SeedService {
    static var db: Firestore { Firestore.firestore() }

    static let testUsers: [User] = [
        User(id: "test_1", name: "Sara", age: 24,
             bio: "Artist from Nazareth who loves coffee and sunsets ☕",
             city: "Nazareth", gender: "Woman", interestedIn: "Men",
             imageURLs: ["https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"],
             interests: ["Art", "Coffee", "Nature"], religion: "Christian"),
        
        User(id: "test_2", name: "Ahmed", age: 28,
             bio: "Tech lover and foodie. Looking for something serious.",
             city: "Haifa", gender: "Man", interestedIn: "Women",
             imageURLs: ["https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"],
             interests: ["Tech", "Food", "Travel"], religion: "Muslim"),
        
        User(id: "test_3", name: "Yasmine", age: 22,
             bio: "Student. Loves music and dancing 💃",
             city: "Acre", gender: "Woman", interestedIn: "Men",
             imageURLs: ["https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"],
             interests: ["Music", "Dancing", "Reading"], religion: "Muslim"),
        
        User(id: "test_4", name: "Omar", age: 31,
             bio: "Civil engineer. Ambitious and kind.",
             city: "Jerusalem", gender: "Man", interestedIn: "Women",
             imageURLs: ["https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"],
             interests: ["Sports", "Tech", "Cooking"], religion: "Muslim"),
        
        User(id: "test_5", name: "Noor", age: 25,
             bio: "Loves travel and adventure! 🌍",
             city: "Jaffa", gender: "Woman", interestedIn: "Men",
             imageURLs: ["https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"],
             interests: ["Travel", "Photography", "Fitness"], religion: "Muslim")
    ]

    static func seedIfNeeded() {
        db.collection("users").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking for seeded users: \(error)")
                return
            }

            if snapshot?.isEmpty == true {
                for user in testUsers {
                    guard let id = user.id else { continue }
                    try? db.collection("users").document(id).setData(from: user)
                }
                print("✅ Test users seeded")
            }
        }
    }
}
