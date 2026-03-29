import SwiftUI

struct AdminDashboardView: View {
    @State private var pendingUsers: [User] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                } else if pendingUsers.isEmpty {
                    Text("No pending verifications")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(pendingUsers) { user in
                        AdminUserRow(user: user) { success in
                            if success {
                                withAnimation {
                                    pendingUsers.removeAll { $0.id == user.id }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await loadPending()
            }
        }
    }
    
    private func loadPending() async {
        do {
            pendingUsers = try await AdminService.shared.fetchPendingVerifications()
            isLoading = false
        } catch {
            print("Admin error: \(error)")
            isLoading = false
        }
    }
}

struct AdminUserRow: View {
    let user: User
    var onAction: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text("\(user.age) years • \(user.city)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Photo Comparison
            HStack(spacing: 12) {
                VStack {
                    Text("Profile Photo")
                        .font(.system(size: 10, weight: .bold))
                    photoView(url: user.profileImageURL)
                }
                
                VStack {
                    Text("Selfie")
                        .font(.system(size: 10, weight: .bold))
                    photoView(url: user.verificationSelfieURL ?? user.profileImageURL)
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    actionApprove()
                } label: {
                    Text("Verify")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                Button {
                    actionReject()
                } label: {
                    Text("Reject")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func photoView(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.gray.opacity(0.2)
        }
        .frame(width: 140, height: 180)
        .cornerRadius(12)
        .clipped()
    }
    
    private func actionApprove() {
        Task {
            do {
                try await AdminService.shared.approveUser(uid: user.id ?? "")
                onAction(true)
            } catch {
                print("Approve error: \(error)")
            }
        }
    }
    
    private func actionReject() {
        Task {
            do {
                try await AdminService.shared.rejectUser(uid: user.id ?? "")
                onAction(true)
            } catch {
                print("Reject error: \(error)")
            }
        }
    }
}
