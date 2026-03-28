import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var senderId: String
    var text: String
    var timestamp: Date

    static let mock = Message(
        id: "1",
        senderId: "1",
        text: "Hey! 👋",
        timestamp: Date()
    )
}
