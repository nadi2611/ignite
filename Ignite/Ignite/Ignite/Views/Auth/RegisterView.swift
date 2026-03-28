import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("register_title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(IgniteTheme.textPrimary)
                    Text(L("register_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.textSecondary)
                }
                .padding(.top, 16)

                VStack(spacing: 14) {
                    TextField(L("register_name"), text: $name)
                        .inputField()

                    TextField(L("login_email"), text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .inputField()

                    SecureField(L("register_password_hint"), text: $password)
                        .inputField()
                }

                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    authViewModel.register(name: name, email: email, password: password)
                } label: {
                    Text(L("register_button")).primaryButton()
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
            }
            .padding(.horizontal)
        }
        .background(IgniteTheme.background.ignoresSafeArea())
        .navigationTitle(L("register_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegisterView().environmentObject(AuthViewModel())
}
