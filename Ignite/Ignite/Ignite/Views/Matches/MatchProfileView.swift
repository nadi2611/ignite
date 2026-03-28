import SwiftUI

struct MatchProfileView: View {
    let match: MatchWithId
    @Environment(\.dismiss) private var dismiss

    var user: User { match.user }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // Hero photo
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: user.profileImageURL)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            IgniteTheme.mainGradient
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.white.opacity(0.4))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 420)
                        .clipped()

                        // Gradient overlay for text
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 420)

                        // Name + age
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(user.name), \(user.age)")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.subheadline)
                                Text(user.city)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(20)
                    }

                    // Info section
                    VStack(alignment: .leading, spacing: 24) {

                        // Religion
                        if let religion = user.religion, !religion.isEmpty {
                            HStack(spacing: 10) {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(IgniteTheme.primary)
                                    .font(.title3)
                                Text(religion)
                                    .font(.body)
                                    .foregroundColor(IgniteTheme.textPrimary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }

                        // Bio
                        if !user.bio.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(IgniteTheme.textPrimary)
                                Text(user.bio)
                                    .font(.body)
                                    .foregroundColor(IgniteTheme.textSecondary)
                                    .lineSpacing(4)
                            }
                        }

                        // Interests
                        if !user.interests.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Interests")
                                    .font(.headline)
                                    .foregroundColor(IgniteTheme.textPrimary)

                                FlowTagsView(tags: user.interests)
                            }
                        }

                        // Message button
                        NavigationLink(destination: ChatView(user: user, matchId: match.id)) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Send Message")
                                    .font(.headline)
                            }
                            .primaryButton()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
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
