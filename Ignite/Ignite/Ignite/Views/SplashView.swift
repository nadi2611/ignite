import SwiftUI

struct SplashView: View {
    @State private var flameScale: CGFloat = 0.4
    @State private var flameOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            IgniteTheme.mainGradient
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    // Glow behind flame
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: glowRadius)

                    Text("🔥")
                        .font(.system(size: 90))
                        .scaleEffect(flameScale)
                }

                VStack(spacing: 6) {
                    Text(L("app_name"))
                        .font(.system(size: 42, weight: .black))
                        .foregroundColor(.white)

                    Text(L("app_tagline"))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                flameScale = 1.0
                flameOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                glowRadius = 30
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.4)) {
                textOpacity = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
