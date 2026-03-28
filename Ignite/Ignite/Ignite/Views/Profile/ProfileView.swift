import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var store = StoreManager.shared
    @ObservedObject private var l = L10n.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    if let user = authViewModel.currentUser, !user.profileImageURL.isEmpty {
                        AsyncImage(url: URL(string: user.profileImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding(.top)
                    } else {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                            )
                            .padding(.top)
                    }

                    if let user = authViewModel.currentUser {
                        VStack(spacing: 4) {
                            Text("\(user.name), \(user.age)")
                                .font(.title.bold())
                            Text(user.city)
                                .foregroundColor(.secondary)

                            // Subscription badge
                            Text(store.currentPlan.displayName)
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: store.currentPlan.color))
                                .cornerRadius(12)
                        }

                        if let religion = user.religion, !religion.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(IgniteTheme.primary)
                                Text(religion)
                                    .font(.subheadline)
                                    .foregroundColor(IgniteTheme.textSecondary)
                            }
                        }

                        Text(user.bio)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Interests
                        if !user.interests.isEmpty {
                            FlowLayout(items: user.interests)
                        }
                    }

                    // Upgrade button for free users
                    if store.currentPlan == .free {
                        Button { showPaywall = true } label: {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text(L("profile_upgrade")).font(.headline)
                            }
                            .primaryButton()
                        }
                        .padding(.horizontal)
                    }

                    NavigationLink(destination: EditProfileView()) {
                        Text(L("profile_edit"))
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

                    // Language toggle
                    HStack {
                        Text(L("profile_language"))
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textSecondary)
                        Spacer()
                        Button("English") { l.language = "en" }
                            .font(.subheadline.bold())
                            .foregroundColor(l.language == "en" ? IgniteTheme.primary : IgniteTheme.textSecondary)
                        Text("/")
                            .foregroundColor(IgniteTheme.textSecondary)
                        Button("العربية") { l.language = "ar" }
                            .font(.subheadline.bold())
                            .foregroundColor(l.language == "ar" ? IgniteTheme.primary : IgniteTheme.textSecondary)
                    }
                    .padding(.horizontal)

                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        Text(L("profile_signout"))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(L("tab_profile"))
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
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
