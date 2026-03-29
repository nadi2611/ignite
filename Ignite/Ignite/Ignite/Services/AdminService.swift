import Foundation
import FirebaseFirestore

class AdminService {
    static let shared = AdminService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchPendingVerifications() async throws -> [User] {
        let snapshot = try await db.collection("users")
            .whereField("isPendingVerification", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    func approveUser(uid: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "isVerified": true,
            "isPendingVerification": false
        ])
    }
    
    func rejectUser(uid: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "isVerified": false,
            "isPendingVerification": false
        ])
    }
}
