import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    Text("🔥")
                        .font(.system(size: 80))

                    VStack(spacing: 8) {
                        Text("Ignite")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Text("Find your spark")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        NavigationLink(destination: RegisterView()) {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                        }

                        NavigationLink(destination: LoginView()) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(30)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
