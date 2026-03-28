import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                IgniteTheme.mainGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 16) {
                        Text("🔥")
                            .font(.system(size: 90))
                            .shadow(color: .black.opacity(0.2), radius: 10)
                        Text("Ignite")
                            .font(.system(size: 52, weight: .black))
                            .foregroundColor(.white)
                        Text(L("app_tagline"))
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()

                    VStack(spacing: 14) {
                        NavigationLink(destination: RegisterView()) {
                            Text(L("welcome_create_account"))
                                .font(.headline)
                                .foregroundColor(IgniteTheme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(IgniteTheme.buttonRadius)
                        }

                        NavigationLink(destination: LoginView()) {
                            Text(L("welcome_sign_in"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(IgniteTheme.buttonRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: IgniteTheme.buttonRadius)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }

                        Text(L("welcome_terms"))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WelcomeView().environmentObject(AuthViewModel())
}
