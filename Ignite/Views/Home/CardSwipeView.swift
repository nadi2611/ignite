import SwiftUI

struct CardSwipeView: View {
    let user: User
    var onLike: () -> Void
    var onDislike: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray5))
                .frame(width: 340, height: 520)

            // Profile image placeholder
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: 340, height: 520, alignment: .center)

            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(user.name)
                        .font(.title.bold())
                    Text("\(user.age)")
                        .font(.title2)
                }
                Text(user.city)
                    .font(.subheadline)
                    .opacity(0.8)
                Text(user.bio)
                    .font(.caption)
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding()
            .frame(width: 340, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(20)
            )

            // Like / Nope overlays
            if offset.width > 40 {
                Text("LIKE")
                    .font(.title.bold())
                    .foregroundColor(.green)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 3))
                    .rotationEffect(.degrees(-15))
                    .padding()
                    .frame(width: 340, alignment: .leading)
            }
            if offset.width < -40 {
                Text("NOPE")
                    .font(.title.bold())
                    .foregroundColor(.red)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 3))
                    .rotationEffect(.degrees(15))
                    .padding()
                    .frame(width: 340, alignment: .trailing)
            }
        }
        .cornerRadius(20)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                    rotation = Double(value.translation.width / 20)
                }
                .onEnded { value in
                    if value.translation.width > 120 {
                        onLike()
                    } else if value.translation.width < -120 {
                        onDislike()
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
        )
        .animation(.interactiveSpring(), value: offset)
    }
}
