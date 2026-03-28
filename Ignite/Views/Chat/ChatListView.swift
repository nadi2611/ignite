import SwiftUI

struct ChatListView: View {
    let conversations: [User] = [
        User(id: "2", name: "Sara", age: 24, bio: "Hey! 👋", city: "Nazareth", profileImages: [], interests: []),
        User(id: "3", name: "Nour", age: 28, bio: "How are you?", city: "Tel Aviv", profileImages: [], interests: [])
    ]

    var body: some View {
        NavigationStack {
            List(conversations) { user in
                NavigationLink(destination: ChatView(user: user)) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.bio)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Messages")
        }
    }
}

#Preview {
    ChatListView()
}
