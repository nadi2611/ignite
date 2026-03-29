import SwiftUI

struct PhoneLoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var phoneNumber = ""
    @State private var otpCode = ""
    @State private var name = ""
    @State private var isShowingOTP = false
    @State private var isRegistering = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(isRegistering ? L("register_title") : L("login_title"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(IgniteTheme.textPrimary)
                    
                    Text(isShowingOTP ? L("otp_subtitle") : L("phone_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.textSecondary)
                }
                .padding(.top, 40)
                
                if !isShowingOTP {
                    VStack(spacing: 16) {
                        if isRegistering {
                            TextField(L("register_name"), text: $name)
                                .inputField()
                        }
                        
                        HStack(spacing: 12) {
                            Text("+972") // Fixed for Israel
                                .font(.headline)
                                .padding(.leading, 12)
                            
                            TextField("5x-xxxxxxx", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .font(.body)
                        }
                        .frame(height: 56)
                        .background(Color(.systemGray6))
                        .cornerRadius(IgniteTheme.inputRadius)
                    }
                } else {
                    TextField("123456", text: $otpCode)
                        .keyboardType(.numberPad)
                        .inputField()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24, weight: .bold))
                }
                
                Button {
                    if isShowingOTP {
                        authVM.verifyOTP(code: otpCode, name: isRegistering ? name : nil)
                    } else {
                        let fullPhone = "+972\(phoneNumber)"
                        print("DEBUG: Clicking send code for \(fullPhone)")
                        authVM.sendOTP(phoneNumber: fullPhone) { success in
                            if success {
                                withAnimation { isShowingOTP = true }
                            }
                        }
                    }
                }
 label: {
                    if authVM.isInitializing {
                        ProgressView().tint(.white)
                    } else {
                        Text(isShowingOTP ? L("otp_button") : L("phone_button"))
                            .primaryButton()
                    }
                }
                .disabled(phoneNumber.isEmpty || (isShowingOTP && otpCode.count < 6))
                
                if !isShowingOTP {
                    Button {
                        isRegistering.toggle()
                    } label: {
                        Text(isRegistering ? L("phone_already_have_account") : L("phone_create_account"))
                            .font(.subheadline.bold())
                            .foregroundColor(IgniteTheme.primary)
                    }
                } else {
                    Button {
                        isShowingOTP = false
                    } label: {
                        Text(L("phone_change_number"))
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(IgniteTheme.textPrimary)
                    }
                }
            }
        }
    }
}

#Preview {
    PhoneLoginView().environmentObject(AuthViewModel())
}
