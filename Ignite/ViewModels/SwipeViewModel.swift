import Foundation
import SwiftUI

class SwipeViewModel: ObservableObject {
    @Published var users: [User] = [
        User(id: "2", name: "Sara", age: 24, bio: "Artist & dreamer from Nazareth.", city: "Nazareth", profileImages: ["person.fill"], interests: ["Art", "Coffee"]),
        User(id: "3", name: "Nour", age: 28, bio: "Doctor by day, foodie by night.", city: "Tel Aviv", profileImages: ["person.fill"], interests: ["Food", "Travel"]),
        User(id: "4", name: "Rana", age: 25, bio: "Music is my language.", city: "Haifa", profileImages: ["person.fill"], interests: ["Music", "Dance"])
    ]

    func like(user: User) {
        removeUser(user)
        // TODO: send like to backend
    }

    func dislike(user: User) {
        removeUser(user)
        // TODO: send dislike to backend
    }

    private func removeUser(_ user: User) {
        users.removeAll { $0.id == user.id }
    }
}
