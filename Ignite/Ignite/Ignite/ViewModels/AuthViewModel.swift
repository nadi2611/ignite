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
    @Published var verificationID: String? = nil

    private let db = Firestore.firestore()
    private var handle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
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

    func sendOTP(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        print("DEBUG: Sending OTP to \(phoneNumber)")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self?.verificationID = verificationID
            completion(true)
        }
    }

    func verifyOTP(code: String, name: String? = nil) {
        guard let verificationID = verificationID else {
            self.errorMessage = "Missing verification ID"
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        
        isRegistering = name != nil
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // If registering, create the user doc
            if let name = name {
                let newUser = User(id: uid, name: name, age: 0, phoneNumber: result?.user.phoneNumber)
                DispatchQueue.main.async {
                    self.currentUser = newUser
                    self.isLoggedIn = true
                    self.onboardingComplete = false
                    self.isRegistering = false
                    self.isInitializing = false
                }
            } else {
                // If logging in, fetchUser will be called by state listener
                self.isRegistering = false
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
        userListener?.remove()
        NotificationManager.clearFCMToken()
        try? Auth.auth().signOut()
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser, let uid = currentUser?.id else { return }
        
        // 1. Delete Firestore data
        db.collection("users").document(uid).delete()
        
        // 2. Delete Auth user
        user.delete { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.logout()
            }
        }
    }

    private func fetchUser(uid: String) {
        userListener?.remove()
        userListener = db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Firestore error: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                if self.isLoggedIn && !self.isRegistering {
                    try? Auth.auth().signOut()
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
