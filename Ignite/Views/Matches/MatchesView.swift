import SwiftUI

struct MatchesView: View {
    let matches: [User] = [
        User(id: "2", name: "Sara", age: 24, bio: "Artist & dreamer.", city: "Nazareth", profileImages: [], interests: []),
        User(id: "3", name: "Nour", age: 28, bio: "Doctor by day.", city: "Tel Aviv", profileImages: [], interests: [])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(matches) { user in
                        VStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.orange)
                                        .font(.largeTitle)
                                )

                            Text(user.name)
                                .font(.headline)
                            Text(user.city)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Matches")
        }
    }
}

#Preview {
    MatchesView()
}
