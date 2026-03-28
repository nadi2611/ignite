import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var canLogin: Bool { email.contains("@") && password.count >= 6 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("login_title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(IgniteTheme.textPrimary)
                    Text(L("login_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.textSecondary)
                }
                .padding(.top, 16)

                VStack(spacing: 14) {
                    TextField(L("login_email"), text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .inputField()

                    SecureField(L("login_password"), text: $password)
                        .inputField()
                }

                Button {
                    authViewModel.login(email: email, password: password)
                } label: {
                    Text(L("login_button")).primaryButton()
                }
                .disabled(!canLogin)
                .opacity(canLogin ? 1 : 0.5)
            }
            .padding(.horizontal)
        }
        .background(IgniteTheme.background.ignoresSafeArea())
        .navigationTitle(L("login_button"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LoginView().environmentObject(AuthViewModel())
}
