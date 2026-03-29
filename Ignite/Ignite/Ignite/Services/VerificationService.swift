import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class VerificationService {
    static let shared = VerificationService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func submitVerification(selfie: UIImage) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let url = try await CloudinaryService.uploadImage(selfie)
        
        try await db.collection("users").document(uid).updateData([
            "isPendingVerification": true,
            "verificationSelfieURL": url
        ])
    }
}
