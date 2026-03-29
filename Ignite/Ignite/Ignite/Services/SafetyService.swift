import Foundation
import FirebaseFirestore
import FirebaseAuth

class SafetyService {
    static let shared = SafetyService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func report(userUID: String, reason: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let reportData: [String: Any] = [
            "reportedBy": currentUID,
            "reportedUser": userUID,
            "reason": reason,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("reports").addDocument(data: reportData)
        
        // Auto-block after reporting
        try await block(userUID: userUID)
    }
    
    func block(userUID: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        try await db.collection("blocks")
            .document(currentUID)
            .collection("blocked")
            .document(userUID)
            .setData(["blockedAt": FieldValue.serverTimestamp()])
        
        // Also remove any existing match
        try await unmatch(otherUID: userUID)
    }
    
    func unmatch(otherUID: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await db.collection("matches")
            .whereField("users", arrayContains: currentUID)
            .getDocuments()
        
        for doc in snapshot.documents {
            let users = doc.data()["users"] as? [String] ?? []
            if users.contains(otherUID) {
                try await db.collection("matches").document(doc.documentID).delete()
            }
        }
    }

    func getBlockedUIDs() async throws -> Set<String> {
        guard let currentUID = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("blocks")
            .document(currentUID)
            .collection("blocked")
            .getDocuments()
        
        let uids = snapshot.documents.map { $0.documentID }
        return Set(uids)
    }
}
