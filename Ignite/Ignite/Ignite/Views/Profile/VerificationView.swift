import SwiftUI
import PhotosUI

struct VerificationView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selfie: UIImage? = nil
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if !showSuccess {
                    VStack(spacing: 8) {
                        Text(L("verification_title"))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(IgniteTheme.textPrimary)
                        
                        Text(L("verification_step_1_desc"))
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemGray6))
                                .frame(height: 380)
                            
                            if let selfie = selfie {
                                Image(uiImage: selfie)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 380)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(IgniteTheme.primary)
                                    Text(L("verification_step_1"))
                                        .font(.headline)
                                        .foregroundColor(IgniteTheme.primary)
                                }
                            }
                        }
                    }
                    .onChange(of: selectedItem) { _, _ in
                        loadSelfie()
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    Button {
                        submit()
                    } label: {
                        if isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text(L("verification_submit"))
                                .primaryButton()
                        }
                    }
                    .disabled(selfie == nil || isSubmitting)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                } else {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(L("verification_success"))
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text(L("onboarding_continue"))
                                .primaryButton()
                        }
                        .padding(.horizontal, 60)
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !showSuccess {
                        Button(L("edit_cancel")) {
                            dismiss()
                        }
                        .foregroundColor(IgniteTheme.textPrimary)
                    }
                }
            }
        }
    }
    
    private func loadSelfie() {
        Task {
            if let item = selectedItem,
               let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.selfie = image
                }
            }
        }
    }
    
    private func submit() {
        guard let image = selfie else { return }
        isSubmitting = true
        
        Task {
            do {
                try await VerificationService.shared.submitVerification(selfie: image)
                await MainActor.run {
                    isSubmitting = false
                    withAnimation { showSuccess = true }
                    // Update local user state
                    if var user = authVM.currentUser {
                        user.isPendingVerification = true
                        authVM.currentUser = user
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    authVM.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
