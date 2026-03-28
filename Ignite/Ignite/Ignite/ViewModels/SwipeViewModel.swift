import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class SwipeViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = true
    @Published var matchedUser: User? = nil

    private let db = Firestore.firestore()

    init() {
        fetchUsers()
    }

    func fetchUsers(currentUser: User? = nil) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        let targetGender: String?
        switch currentUser?.gender {
        case "Man": targetGender = "Woman"
        case "Woman": targetGender = "Man"
        default: targetGender = nil
        }

        // Fetch already-seen + blocked UIDs first, then load deck
        let group = DispatchGroup()
        var seenUIDs: Set<String> = [currentUID]

        group.enter()
        db.collection("likes").document(currentUID).collection("liked")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { seenUIDs.insert($0.documentID) }
                group.leave()
            }

        group.enter()
        db.collection("dislikes").document(currentUID).collection("disliked")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { seenUIDs.insert($0.documentID) }
                group.leave()
            }

        group.enter()
        db.collection("blocks").document(currentUID).collection("blocked")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { seenUIDs.insert($0.documentID) }
                group.leave()
            }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }

            let completion: (QuerySnapshot?, Error?) -> Void = { snapshot, _ in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.users = (snapshot?.documents ?? [])
                        .compactMap { try? $0.data(as: User.self) }
                        .filter { !seenUIDs.contains($0.id ?? "") }
                }
            }

            if let targetGender {
                self.db.collection("users")
                    .whereField("gender", isEqualTo: targetGender)
                    .limit(to: 50)
                    .getDocuments(completion: completion)
            } else {
                self.db.collection("users")
                    .limit(to: 50)
                    .getDocuments(completion: completion)
            }
        }
    }

    func like(user: User) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let likedUID = user.id else { return }

        // Save like to Firestore
        db.collection("likes")
            .document(currentUID)
            .collection("liked")
            .document(likedUID)
            .setData(["likedAt": Date()]) { [weak self] _ in
                self?.checkForMatch(currentUID: currentUID, likedUID: likedUID)
            }

        removeUser(user)
    }

    func dislike(user: User) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let dislikedUID = user.id else { return }

        db.collection("dislikes")
            .document(currentUID)
            .collection("disliked")
            .document(dislikedUID)
            .setData(["dislikedAt": Date()])

        removeUser(user)
    }

    private func checkForMatch(currentUID: String, likedUID: String) {
        db.collection("likes")
            .document(likedUID)
            .collection("liked")
            .document(currentUID)
            .getDocument { [weak self] snapshot, _ in
                if snapshot?.exists == true {
                    self?.createMatch(uid1: currentUID, uid2: likedUID)
                }
            }
    }

    private func createMatch(uid1: String, uid2: String) {
        let matchData: [String: Any] = [
            "users": [uid1, uid2],
            "createdAt": Date()
        ]
        db.collection("matches").addDocument(data: matchData)

        db.collection("users").document(uid2).getDocument { [weak self] snapshot, _ in
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async { self?.matchedUser = user }
            }
        }
    }

    func clearMatch() {
        matchedUser = nil
    }

    func report(user: User, reason: String) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let reportedUID = user.id else { return }
        db.collection("reports").addDocument(data: [
            "reportedBy": currentUID,
            "reportedUser": reportedUID,
            "reason": reason,
            "createdAt": Date()
        ])
        removeUser(user)
    }

    func block(user: User) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let blockedUID = user.id else { return }
        db.collection("blocks")
            .document(currentUID)
            .collection("blocked")
            .document(blockedUID)
            .setData(["blockedAt": Date()])
        removeUser(user)
    }

    private func removeUser(_ user: User) {
        users.removeAll { $0.id == user.id }
    }
}
