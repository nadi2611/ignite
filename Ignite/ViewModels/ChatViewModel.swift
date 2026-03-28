import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(id: "1", senderId: "2", text: "Hey! 👋", timestamp: Date()),
        Message(id: "2", senderId: "1", text: "Hi! How are you?", timestamp: Date())
    ]

    func sendMessage(text: String, senderId: String) {
        let message = Message(id: UUID().uuidString, senderId: senderId, text: text, timestamp: Date())
        messages.append(message)
        // TODO: send to backend
    }
}
