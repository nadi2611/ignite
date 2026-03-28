import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                        )
                        .padding(.top)

                    if let user = authViewModel.currentUser {
                        VStack(spacing: 4) {
                            Text("\(user.name), \(user.age)")
                                .font(.title.bold())
                            Text(user.city)
                                .foregroundColor(.secondary)
                        }

                        Text(user.bio)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Interests
                        if !user.interests.isEmpty {
                            FlowLayout(items: user.interests)
                        }
                    }

                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal)

                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct FlowLayout: View {
    let items: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
