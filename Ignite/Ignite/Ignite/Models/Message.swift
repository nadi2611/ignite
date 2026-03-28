import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Date

    init(id: String? = nil, senderId: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
}
