import SwiftUI

struct MatchProfileView: View {
    let match: MatchWithId
    @Environment(\.dismiss) private var dismiss
    @State private var currentImageIndex = 0

    var user: User { match.user }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 1. Hero photo with Story-style indicators and Tap-to-Cycle
                    ZStack(alignment: .bottomLeading) {
                        ZStack(alignment: .top) {
                            if !user.imageURLs.isEmpty {
                                AsyncImage(url: URL(string: user.imageURLs[currentImageIndex])) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    IgniteTheme.mainGradient
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 460)
                                .clipped()
                                
                                // Story Indicators
                                if user.imageURLs.count > 1 {
                                    HStack(spacing: 4) {
                                        ForEach(0..<user.imageURLs.count, id: \.self) { index in
                                            Capsule()
                                                .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.4))
                                                .frame(height: 4)
                                        }
                                    }
                                    .padding(.top, 50)
                                    .padding(.horizontal, 20)
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
                            } else {
                                IgniteTheme.mainGradient
                                    .frame(height: 460)
                                    .overlay(Image(systemName: "person.fill").font(.system(size: 80)).foregroundColor(.white.opacity(0.4)))
                            }
                        }

                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 460)
                        .allowsHitTesting(false)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("\(user.name), \(user.age)")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.white)
                                
                                if user.isVerified == true {
                                    VerifiedBadge(size: 26)
                                }
                            }

                            HStack(spacing: 12) {
                                labelTag(icon: "mappin.circle.fill", text: user.city)
                                if let origin = user.originCity, !origin.isEmpty {
                                    labelTag(icon: "house.fill", text: "\(L("profile_origin")): \(origin)")
                                }
                            }
                        }
                        .padding(24)
                        .allowsHitTesting(false)
                    }

                    VStack(alignment: .leading, spacing: 32) {
                        
                        // 2. Quick Facts Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L("profile_basics_title"))
                                .font(.headline)
                                .foregroundColor(IgniteTheme.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                if let height = user.height {
                                    factCell(icon: "ruler", text: "\(height) cm")
                                }
                                if let marriage = user.marriageTimeline {
                                    factCell(icon: "ring.circle", text: marriage)
                                }
                                if let edu = user.education {
                                    factCell(icon: "graduationcap", text: edu)
                                }
                                if let job = user.profession {
                                    factCell(icon: "briefcase", text: job)
                                }
                            }
                        }
                        .padding(.top, 8)

                        // 3. About Section
                        if !user.bio.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L("profile_about_title"))
                                    .font(.headline)
                                    .foregroundColor(IgniteTheme.textPrimary)
                                Text(user.bio)
                                    .font(.body)
                                    .foregroundColor(IgniteTheme.textSecondary)
                                    .lineSpacing(4)
                            }
                        }

                        // 4. Faith & Values Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L("profile_values_title"))
                                .font(.headline)
                                .foregroundColor(IgniteTheme.textPrimary)
                            
                            VStack(spacing: 12) {
                                infoRow(icon: "moon.stars.fill", label: user.religion ?? "")
                                if let religiosity = user.religiosityLevel {
                                    infoRow(icon: "hand.raised.fill", label: religiosity)
                                }
                                if let prays = user.prays {
                                    infoRow(icon: "person.fill.checkmark", label: "\(L("profile_prays")): \(prays)")
                                }
                            }
                        }

                        // 5. Lifestyle Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L("profile_lifestyle_title"))
                                .font(.headline)
                                .foregroundColor(IgniteTheme.textPrimary)
                            
                            HStack(spacing: 12) {
                                if let smokes = user.smokes {
                                    lifestyleTag(icon: "smoke.fill", text: smokes)
                                }
                                if let fasts = user.fasts {
                                    lifestyleTag(icon: "sun.max.fill", text: "\(L("profile_fasts")): \(fasts)")
                                }
                            }
                        }

                        // 6. Interests
                        if !user.interests.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(L("onboarding_interests_title"))
                                    .font(.headline)
                                    .foregroundColor(IgniteTheme.textPrimary)

                                FlowTagsView(tags: user.interests)
                            }
                        }

                        // 7. Action Button
                        NavigationLink(destination: ChatView(user: user, matchId: match.id)) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text(L("match_send_message"))
                                    .font(.headline)
                            }
                            .primaryButton()
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                    .padding(24)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                try? await SafetyService.shared.unmatch(otherUID: user.id ?? "")
                                dismiss()
                            }
                        } label: {
                            Label(L("unmatch_user"), systemImage: "person.fill.xmark")
                        }

                        Button(role: .destructive) {
                            Task {
                                try? await SafetyService.shared.block(userUID: user.id ?? "")
                                dismiss()
                            }
                        } label: {
                            Label(L("block_user"), systemImage: "hand.raised.fill")
                        }
                        
                        Menu(L("report_title")) {
                            Button(L("report_photos")) { reportUser(reason: L("report_photos")) }
                            Button(L("report_fake")) { reportUser(reason: L("report_fake")) }
                            Button(L("report_harassment")) { reportUser(reason: L("report_harassment")) }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    private func labelTag(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.subheadline.bold())
        }
        .foregroundColor(.white.opacity(0.9))
    }

    private func factCell(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(IgniteTheme.primary)
                .font(.system(size: 18))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(IgniteTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func infoRow(icon: String, label: String, sub: String? = nil) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(IgniteTheme.primary)
                .font(.system(size: 20))
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.body.bold())
                    .foregroundColor(IgniteTheme.textPrimary)
                if let sub = sub {
                    Text(sub)
                        .font(.caption)
                        .foregroundColor(IgniteTheme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private func lifestyleTag(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(IgniteTheme.primary.opacity(0.1))
        .foregroundColor(IgniteTheme.primary)
        .cornerRadius(20)
    }
    
    private func reportUser(reason: String) {
        Task {
            try? await SafetyService.shared.report(userUID: user.id ?? "", reason: reason)
            dismiss()
        }
    }
}

// Simple wrapping tag grid
struct FlowTagsView: View {
    let tags: [String]
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(tags, id: \.self) { tag in
                TagChip(text: tag)
            }
        }
    }
}

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundColor(IgniteTheme.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(IgniteTheme.primary.opacity(0.1))
            .cornerRadius(20)
    }
}
