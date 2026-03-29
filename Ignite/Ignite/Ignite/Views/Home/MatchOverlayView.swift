import SwiftUI

struct MatchOverlayView: View {
    let currentUser: User
    let matchedUser: User
    let onMessage: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var particles: [ConfettiItem] = (0..<50).map { _ in ConfettiItem() }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            Color.black.opacity(0.4).ignoresSafeArea()

            // Confetti layer
            GeometryReader { geo in
                ForEach(particles) { particle in
                    Capsule()
                        .fill(particle.color)
                        .frame(width: particle.width, height: particle.height)
                        .position(x: particle.startX * geo.size.width, y: appeared ? geo.size.height + 40 : -40)
                        .rotationEffect(.degrees(particle.rotation))
                        .animation(
                            .linear(duration: particle.duration)
                            .delay(particle.delay)
                            .repeatForever(autoreverses: false),
                            value: appeared
                        )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text(L("match_title"))
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(.white)
                        .scaleEffect(appeared ? 1 : 0.4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)

                    Text("You and \(matchedUser.name) liked each other")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.2), value: appeared)
                }

                HStack(spacing: 24) {
                    profileCircle(url: currentUser.profileImageURL)
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15), value: appeared)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.25), value: appeared)

                    profileCircle(url: matchedUser.profileImageURL)
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15), value: appeared)
                }

                VStack(spacing: 14) {
                    Button(action: onMessage) {
                        Text(L("match_send_message"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(IgniteTheme.mainGradient)
                            .cornerRadius(IgniteTheme.buttonRadius)
                    }
                    .padding(.horizontal, 32)

                    Button(action: onDismiss) {
                        Text(L("match_keep_swiping"))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.35), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private func profileCircle(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.orange.opacity(0.3)
        }
        .frame(width: 130, height: 130)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 3))
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}

struct ConfettiItem: Identifiable {
    let id = UUID()
    let color: Color
    let startX: CGFloat
    let width: CGFloat
    let height: CGFloat
    let rotation: Double
    let duration: Double
    let delay: Double

    init() {
        let colors: [Color] = [.red, .orange, .yellow, .pink, .purple, .green, .cyan, .white]
        color = colors.randomElement()!
        startX = CGFloat.random(in: 0...1)
        width = CGFloat.random(in: 6...12)
        height = CGFloat.random(in: 10...20)
        rotation = Double.random(in: 0...360)
        duration = Double.random(in: 1.8...3.0)
        delay = Double.random(in: 0...1.0)
    }
}
