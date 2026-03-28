import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil

    func login(email: String, password: String) {
        // TODO: connect to backend
        self.currentUser = User.mock
        self.isLoggedIn = true
    }

    func register(name: String, email: String, password: String) {
        // TODO: connect to backend
        self.currentUser = User.mock
        self.isLoggedIn = true
    }

    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}
