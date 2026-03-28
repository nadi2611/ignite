import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let matchId: String

    init(matchId: String) {
        self.matchId = matchId
        listenForMessages()
    }

    func listenForMessages() {
        listener = db.collection("matches")
            .document(matchId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.messages = docs.compactMap { try? $0.data(as: Message.self) }
                }
            }
    }

    func sendMessage(text: String) {
        guard let senderId = Auth.auth().currentUser?.uid else { return }
        let messageId = UUID().uuidString
        let message = Message(id: messageId, senderId: senderId, text: text, timestamp: Date())
        do {
            try db.collection("matches")
                .document(matchId)
                .collection("messages")
                .document(messageId)
                .setData(from: message)

            db.collection("matches").document(matchId).updateData([
                "lastMessage": text,
                "lastMessageAt": Date()
            ])
        } catch {
            print("Error sending message: \(error)")
        }
    }

    deinit {
        listener?.remove()
    }
}
