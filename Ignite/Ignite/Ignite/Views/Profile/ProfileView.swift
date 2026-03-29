import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var store = StoreManager.shared
    @ObservedObject private var l = L10n.shared
    @State private var showPaywall = false
    @State private var showVerification = false
    @State private var showDeleteAlert = false
    @State private var showAdmin = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var currentImageIndex = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if let user = authViewModel.currentUser {
                        
                        // 1. Header with Avatar & Status
                        VStack(spacing: 20) {
                            ZStack(alignment: .bottomTrailing) {
                                if !user.imageURLs.isEmpty {
                                    ZStack(alignment: .top) {
                                        AsyncImage(url: URL(string: user.imageURLs[currentImageIndex])) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 140, height: 140)
                                        .clipShape(Circle())
                                        
                                        // Story Indicators
                                        if user.imageURLs.count > 1 {
                                            HStack(spacing: 3) {
                                                ForEach(0..<user.imageURLs.count, id: \.self) { index in
                                                    Capsule()
                                                        .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.4))
                                                        .frame(height: 3)
                                                }
                                            }
                                            .padding(.top, 12)
                                            .padding(.horizontal, 30)
                                        }
                                        
                                        // Tap areas
                                        HStack(spacing: 0) {
                                            Rectangle()
                                                .fill(Color.black.opacity(0.001))
                                                .onTapGesture {
                                                    if currentImageIndex > 0 {
                                                        currentImageIndex -= 1
                                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    }
                                                }
                                            Rectangle()
                                                .fill(Color.black.opacity(0.001))
                                                .onTapGesture {
                                                    if currentImageIndex < user.imageURLs.count - 1 {
                                                        currentImageIndex += 1
                                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    }
                                                }
                                        }
                                    }
                                    .frame(width: 140, height: 140)
                                } else {
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 140, height: 140)
                                        .overlay(Image(systemName: "person.fill").font(.system(size: 60)).foregroundColor(.orange))
                                }
                                
                                if user.isVerified == true {
                                    VerifiedBadge(size: 32)
                                        .background(Circle().fill(Color.white).padding(2))
                                }
                            }
                            
                            VStack(spacing: 6) {
                                HStack(spacing: 6) {
                                    Text("\(user.name), \(user.age)")
                                        .font(.title.bold())
                                        .foregroundColor(IgniteTheme.textPrimary)
                                    if user.isVerified == true {
                                        VerifiedBadge(size: 24)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                    Text(user.city)
                                }
                                .font(.subheadline)
                                .foregroundColor(IgniteTheme.textSecondary)
                                
                                // Subscription badge
                                Text(store.currentPlan.displayName)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: store.currentPlan.color))
                                    .cornerRadius(20)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 32)

                        VStack(alignment: .leading, spacing: 32) {
                            
                            // 0. Profile Strength Score
                            ProfileScoreView(user: user)
                            
                            // 2. Verification Action
                            if user.isVerified == false || user.isVerified == nil {
                                Button {
                                    showVerification = true
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.title)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(user.isPendingVerification == true ? L("verification_pending_title") : L("verification_get_verified"))
                                                .font(.headline)
                                                .foregroundColor(IgniteTheme.textPrimary)
                                            Text(user.isPendingVerification == true ? L("verification_pending_subtitle") : L("verification_subtitle"))
                                                .font(.subheadline)
                                                .foregroundColor(IgniteTheme.textSecondary)
                                        }
                                        Spacer()
                                        if user.isPendingVerification != true {
                                            Image(systemName: "chevron.right")
                                                .font(.caption.bold())
                                                .foregroundColor(IgniteTheme.textSecondary)
                                        }
                                    }
                                    .padding(20)
                                    .background(Color.blue.opacity(0.05))
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.1), lineWidth: 1))
                                }
                                .disabled(user.isPendingVerification == true)
                            }

                            // 3. Basics Grid
                            VStack(alignment: .leading, spacing: 16) {
                                Text(L("profile_basics_title"))
                                    .font(.headline)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    factCell(icon: "ruler", text: user.height != nil ? "\(user.height!) cm" : "--")
                                    factCell(icon: "ring.circle", text: user.marriageTimeline ?? "--")
                                    factCell(icon: "house", text: user.originCity ?? "--")
                                    factCell(icon: "briefcase", text: user.profession ?? "--")
                                }
                            }

                            // 4. About
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L("profile_about_title"))
                                    .font(.headline)
                                Text(user.bio.isEmpty ? L("edit_bio_placeholder") : user.bio)
                                    .font(.body)
                                    .foregroundColor(IgniteTheme.textSecondary)
                            }

                            // 5. Upgrade
                            if store.currentPlan == .free {
                                Button { showPaywall = true } label: {
                                    HStack {
                                        Image(systemName: "flame.fill")
                                        Text(L("profile_upgrade")).font(.headline)
                                    }
                                    .primaryButton()
                                }
                            }

                            // 6. Settings & Actions
                            VStack(spacing: 12) {
                                NavigationLink(destination: EditProfileView()) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(L("profile_edit"))
                                    }
                                    .font(.headline)
                                    .foregroundColor(IgniteTheme.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(IgniteTheme.primary.opacity(0.1))
                                    .cornerRadius(IgniteTheme.buttonRadius)
                                }

                                // Language
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(IgniteTheme.textSecondary)
                                    Text(L("profile_language"))
                                        .font(.subheadline)
                                    Spacer()
                                    Button("EN") { l.language = "en" }
                                        .foregroundColor(l.language == "en" ? IgniteTheme.primary : .secondary)
                                        .font(.caption.bold())
                                    Text("|")
                                        .foregroundColor(.gray.opacity(0.3))
                                    Button("AR") { l.language = "ar" }
                                        .foregroundColor(l.language == "ar" ? IgniteTheme.primary : .secondary)
                                        .font(.caption.bold())
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(16)

                                // Legal Section
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(L("profile_legal"))
                                        .font(.caption.bold())
                                        .foregroundColor(IgniteTheme.textSecondary)
                                        .padding(.leading, 12)
                                        .padding(.bottom, 8)
                                    
                                    VStack(spacing: 0) {
                                        Button { showPrivacy = true } label: {
                                            HStack {
                                                Text(L("profile_privacy_policy"))
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                            }
                                            .padding()
                                        }
                                        Divider().padding(.leading)
                                        Button { showTerms = true } label: {
                                            HStack {
                                                Text(L("profile_terms_of_service"))
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                            }
                                            .padding()
                                        }
                                    }
                                    .foregroundColor(IgniteTheme.textPrimary)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                }
                                .padding(.top, 8)

                                if user.isAdmin == true {
                                    Button {
                                        showAdmin = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "lock.shield.fill")
                                            Text("Admin Panel")
                                        }
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.black)
                                        .cornerRadius(IgniteTheme.buttonRadius)
                                    }
                                    .padding(.top, 12)
                                }

                                Button(role: .destructive) {
                                    authViewModel.logout()
                                } label: {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text(L("profile_signout"))
                                    }
                                    .font(.subheadline.bold())
                                    .padding()
                                }
                                
                                Button(role: .destructive) {
                                    showDeleteAlert = true
                                } label: {
                                    Text(L("profile_delete_account"))
                                        .font(.caption.bold())
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle(L("tab_profile"))
            .background(IgniteTheme.background.ignoresSafeArea())
            .alert(L("delete_account_title"), isPresented: $showDeleteAlert) {
                Button(L("action_cancel"), role: .cancel) { }
                Button(L("delete_account_confirm"), role: .destructive) {
                    authViewModel.deleteAccount()
                }
            } message: {
                Text(L("delete_account_message"))
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $showVerification) {
            VerificationView()
        }
        .fullScreenCover(isPresented: $showAdmin) {
            AdminDashboardView()
        }
        .sheet(isPresented: $showPrivacy) {
            LocalLegalView(filename: "privacy", title: L("profile_privacy_policy"))
        }
        .sheet(isPresented: $showTerms) {
            LocalLegalView(filename: "terms", title: L("profile_terms_of_service"))
        }
    }

    private func factCell(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(IgniteTheme.primary)
                .font(.system(size: 16))
                .frame(width: 20)
            Text(text)
                .font(.caption.bold())
                .foregroundColor(IgniteTheme.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView().environmentObject(AuthViewModel())
}
