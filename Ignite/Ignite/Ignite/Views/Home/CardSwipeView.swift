import SwiftUI

enum SwipeDirection { case like, dislike, none }

struct CardSwipeView: View {
    let user: User
    var onLike: () -> Void
    var onDislike: () -> Void
    var onReport: () -> Void = {}

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    private var swipeDirection: SwipeDirection {
        if offset.width > 40 { return .like }
        if offset.width < -40 { return .dislike }
        return .none
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Card photo
            ZStack {
                RoundedRectangle(cornerRadius: IgniteTheme.cardRadius)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFB347"), Color(hex: "#FF6B6B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                if !user.profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: user.profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                            .tint(.white)
                    }
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(width: 340, height: 520)
            .clipShape(RoundedRectangle(cornerRadius: IgniteTheme.cardRadius))

            // Bottom info
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(user.name)
                        .font(.system(size: 26, weight: .bold))
                    Text("\(user.age)")
                        .font(.system(size: 22, weight: .semibold))
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(user.city)
                            .font(.subheadline)
                    }
                    if let religion = user.religion, !religion.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "moon.stars.fill")
                                .font(.caption)
                            Text(religion)
                                .font(.subheadline)
                        }
                    }
                }
                .opacity(0.9)

                Text(user.bio)
                    .font(.caption)
                    .opacity(0.8)
                    .lineLimit(2)

                if !user.interests.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(user.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding(20)
            .frame(width: 340, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: IgniteTheme.cardRadius))
            )

            // Report button
            VStack {
                HStack {
                    Spacer()
                    Button(action: onReport) {
                        Image(systemName: "ellipsis")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .padding(14)
                }
                Spacer()
            }
            .frame(width: 340, height: 520)

            // Stamp overlays
            if swipeDirection == .like {
                Text("LIKE")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.green, lineWidth: 3))
                    .rotationEffect(.degrees(-15))
                    .padding(20)
                    .frame(width: 340, alignment: .leading)
            }

            if swipeDirection == .dislike {
                Text("NOPE")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red, lineWidth: 3))
                    .rotationEffect(.degrees(15))
                    .padding(20)
                    .frame(width: 340, alignment: .trailing)
            }
        }
        .frame(width: 340, height: 520)
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                    rotation = Double(value.translation.width / 22)
                }
                .onEnded { value in
                    if value.translation.width > 120 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: 600, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onLike() }
                    } else if value.translation.width < -120 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: -600, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDislike() }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
        )
    }
}
