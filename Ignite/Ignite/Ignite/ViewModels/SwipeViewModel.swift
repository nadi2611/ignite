import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class SwipeViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = true
    @Published var matchedUser: User? = nil
    @Published var hasReachedLimit: Bool = false
    
    private let db = Firestore.firestore()

    init() {}
    
    func checkSwipeLimit(currentUser: User?) {
        guard let user = currentUser else { return }
        let lastDate = user.lastSwipeDate ?? .distantPast
        let swipes = user.swipesToday ?? 0
        let dailyLimit = StoreManager.shared.currentPlan.dailyLikes
        if Calendar.current.isDateInToday(lastDate) {
            hasReachedLimit = swipes >= dailyLimit
        } else {
            hasReachedLimit = false
        }
    }

    func fetchUsers(currentUser: User? = nil) {
        guard let currentUser = currentUser, let currentUID = currentUser.id else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.users = []
            }
            return
        }
        
        checkSwipeLimit(currentUser: currentUser)

        // Automatic Gender Filter (Bilingual)
        let gender = currentUser.gender
        let targetGender: String?
        if gender == "Man" || gender == "رجل" {
            targetGender = "Woman"
        } else if gender == "Woman" || gender == "امرأة" {
            targetGender = "Man"
        } else {
            targetGender = nil
        }

        let group = DispatchGroup()
        var seenUIDs: Set<String> = [currentUID]

        group.enter()
        db.collection("likes").document(currentUID).collection("liked").getDocuments { snap, _ in
            snap?.documents.forEach { seenUIDs.insert($0.documentID) }
            group.leave()
        }

        group.enter()
        db.collection("dislikes").document(currentUID).collection("disliked").getDocuments { snap, _ in
            snap?.documents.forEach { seenUIDs.insert($0.documentID) }
            group.leave()
        }

        group.enter()
        db.collection("blocks").document(currentUID).collection("blocked").getDocuments { snap, _ in
            snap?.documents.forEach { seenUIDs.insert($0.documentID) }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            if let targetGender {
                let targetGenders = (targetGender == "Woman") ? ["Woman", "امرأة"] : ["Man", "رجل"]
                
                self.db.collection("users")
                    .whereField("gender", in: targetGenders)
                    .limit(to: 100)
                    .getDocuments { snapshot, error in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            
                            self.users = (snapshot?.documents ?? [])
                                .compactMap { try? $0.data(as: User.self) }
                                .filter { !seenUIDs.contains($0.id ?? "") }
                        }
                    }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.users = []
                }
            }
        }
    }

    func like(user: User) {
        if hasReachedLimit { return }
        guard let currentUID = Auth.auth().currentUser?.uid,
              let likedUID = user.id else { return }

        db.collection("likes").document(currentUID).collection("liked").document(likedUID).setData(["likedAt": Date()]) { [weak self] _ in
            self?.checkForMatch(currentUID: currentUID, likedUID: likedUID)
        }
        trackSwipe(uid: currentUID)
        removeUser(user)
    }

    func dislike(user: User) {
        if hasReachedLimit { return }
        guard let currentUID = Auth.auth().currentUser?.uid,
              let dislikedUID = user.id else { return }

        db.collection("dislikes").document(currentUID).collection("disliked").document(dislikedUID).setData(["dislikedAt": Date()])
        trackSwipe(uid: currentUID)
        removeUser(user)
    }
    
    private func trackSwipe(uid: String) {
        let userRef = db.collection("users").document(uid)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userSnapshot: DocumentSnapshot
            do { userSnapshot = try transaction.getDocument(userRef) } catch { return nil }
            var swipes = userSnapshot.data()?["swipesToday"] as? Int ?? 0
            let lastDate = (userSnapshot.data()?["lastSwipeDate"] as? Timestamp)?.dateValue() ?? .distantPast
            if Calendar.current.isDateInToday(lastDate) { swipes += 1 } else { swipes = 1 }
            transaction.updateData(["swipesToday": swipes, "lastSwipeDate": FieldValue.serverTimestamp()], forDocument: userRef)
            return nil
        }) { _, _ in }
    }

    private func checkForMatch(currentUID: String, likedUID: String) {
        db.collection("likes").document(likedUID).collection("liked").document(currentUID).getDocument { [weak self] snapshot, _ in
            if let snapshot = snapshot, snapshot.exists {
                self?.createMatch(uid1: currentUID, likedUID: likedUID)
            }
        }
    }

    private func createMatch(uid1: String, likedUID: String) {
        let matchData: [String: Any] = [
            "users": [uid1, likedUID],
            "createdAt": Date(),
            "expiresAt": Calendar.current.date(byAdding: .hour, value: 48, to: Date()) ?? Date()
        ]
        db.collection("matches").addDocument(data: matchData)
        db.collection("users").document(likedUID).getDocument { [weak self] snapshot, _ in
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async { self?.matchedUser = user }
            }
        }
    }

    func clearMatch() { matchedUser = nil }

    func report(user: User, reason: String) {
        guard let reportedUID = user.id else { return }
        Task {
            do {
                try await SafetyService.shared.report(userUID: reportedUID, reason: reason)
                DispatchQueue.main.async { self.removeUser(user) }
            } catch { print("Error reporting user: \(error)") }
        }
    }

    func block(user: User) {
        guard let blockedUID = user.id else { return }
        Task {
            do {
                try await SafetyService.shared.block(userUID: blockedUID)
                DispatchQueue.main.async { self.removeUser(user) }
            } catch { print("Error blocking user: \(error)") }
        }
    }

    private func removeUser(_ user: User) {
        users.removeAll { $0.id == user.id }
    }
}
