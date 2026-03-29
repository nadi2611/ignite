import SwiftUI

enum SwipeDirection { case like, dislike, none }

struct CardSwipeView: View {
    let user: User
    var onLike: () -> Void
    var onDislike: () -> Void
    var onReport: () -> Void = {}

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var hasTriggeredHaptic = false
    @State private var currentImageIndex = 0

    private var swipeDirection: SwipeDirection {
        if offset.width > 40 { return .like }
        if offset.width < -40 { return .dislike }
        return .none
    }

    var body: some View {
        ZStack {
            // Card Content
            ZStack(alignment: .bottomLeading) {
                // 1. Image cycling layer
                ZStack(alignment: .top) {
                    if !user.imageURLs.isEmpty {
                        AsyncImage(url: URL(string: user.imageURLs[currentImageIndex])) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 340, height: 520)
                        
                        // Image Indicators (Story style)
                        if user.imageURLs.count > 1 {
                            HStack(spacing: 4) {
                                ForEach(0..<user.imageURLs.count, id: \.self) { index in
                                    Capsule()
                                        .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.4))
                                        .frame(height: 4)
                                }
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        }
                        
                        // Tap areas for left/right photo cycling
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
                        Color.gray.opacity(0.2)
                            .frame(width: 340, height: 520)
                    }
                }
                .frame(width: 340, height: 520)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Gradient Overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(width: 340, height: 520)
                .cornerRadius(24)

                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(user.name)
                            .font(.system(size: 26, weight: .bold))
                        if user.isVerified == true {
                            VerifiedBadge(size: 20)
                                .offset(y: -2)
                        }
                        Text("\(user.age)")
                            .font(.system(size: 22, weight: .semibold))
                    }

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                            Text(user.city)
                        }
                        
                        if let religion = user.religion, !religion.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "moon.stars.fill")
                                Text(religion)
                            }
                        }
                    }
                    .font(.caption.bold())
                    
                    HStack(spacing: 8) {
                        if let marriage = user.marriageTimeline, !marriage.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "ring.circle.fill")
                                Text(marriage)
                            }
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }

                        if let religiosity = user.religiosityLevel, !religiosity.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "hand.raised.fill")
                                Text(religiosity)
                            }
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)

                    Text(user.bio)
                        .font(.caption)
                        .opacity(0.8)
                        .lineLimit(2)

                    if !user.interests.isEmpty {
                        HStack {
                            ForEach(user.interests.prefix(3), id: \.self) { interest in
                                Text(interest)
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .foregroundColor(.white)
                .padding(20)
            }
            .frame(width: 340, height: 520)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 10)

            // Swipe Badges (LIKE / NOPE)
            if swipeDirection != .none {
                Text(swipeDirection == .like ? "LIKE" : "NOPE")
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(swipeDirection == .like ? .green : .red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(swipeDirection == .like ? .green : .red, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(swipeDirection == .like ? -15 : 15))
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                    rotation = Double(value.translation.width / 22)
                    
                    // Light haptic when crossing a small threshold
                    if abs(offset.width) > 40 && !hasTriggeredHaptic {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        hasTriggeredHaptic = true
                    } else if abs(offset.width) < 30 {
                        hasTriggeredHaptic = false
                    }
                }
                .onEnded { value in
                    if value.translation.width > 120 {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: 600, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onLike() }
                    } else if value.translation.width < -120 {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: -600, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDislike() }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                            hasTriggeredHaptic = false
                        }
                    }
                }
        )
    }
}
