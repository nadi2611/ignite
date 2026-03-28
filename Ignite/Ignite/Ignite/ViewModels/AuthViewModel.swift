import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var onboardingComplete: Bool = false
    @Published var currentUser: User? = nil
    @Published var errorMessage: String = ""
    @Published var isInitializing: Bool = true

    private let db = Firestore.firestore()
    private var handle: AuthStateDidChangeListenerHandle?
    private var isRegistering: Bool = false

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            if let firebaseUser = firebaseUser {
                if self.isRegistering { return }
                self.isLoggedIn = true
                self.fetchUser(uid: firebaseUser.uid)
                Task { await StoreManager.shared.updateCurrentPlan() }
            } else {
                self.isLoggedIn = false
                self.onboardingComplete = false
                self.currentUser = nil
                self.isInitializing = false
                Task { await StoreManager.shared.updateCurrentPlan() }
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func register(name: String, email: String, password: String) {
        isRegistering = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.isRegistering = false
                self.errorMessage = error.localizedDescription
                return
            }
            guard let uid = result?.user.uid else { return }
            let newUser = User(id: uid, name: name, age: 0)
            DispatchQueue.main.async {
                self.currentUser = newUser
                self.isLoggedIn = true
                self.onboardingComplete = false
                self.isRegistering = false
                self.isInitializing = false
            }
        }
    }

    func completeOnboarding() {
        guard let user = currentUser, let uid = user.id else { return }
        do {
            try db.collection("users").document(uid).setData(from: user)
            DispatchQueue.main.async {
                self.onboardingComplete = true
                NotificationManager.requestPermission()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateUser(_ user: User) {
        guard let uid = user.id else { return }
        do {
            try db.collection("users").document(uid).setData(from: user, merge: true)
            self.currentUser = user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        NotificationManager.clearFCMToken()
        try? Auth.auth().signOut()
    }

    private func fetchUser(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                // Network/Firestore error — keep user logged in
                print("Firestore error: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                try? Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.onboardingComplete = false
                    self.currentUser = nil
                    self.isInitializing = false
                }
                return
            }

            if let user = try? snapshot.data(as: User.self) {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.onboardingComplete = true
                    self.isInitializing = false
                    NotificationManager.requestPermission()
                }
            } else {
                self.isInitializing = false
                print("Failed to decode user document")
            }
        }
    }
}
