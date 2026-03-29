import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

struct MatchWithId: Identifiable {
    let id: String   // matchId
    let user: User
    let expiresAt: Date?
}

class MatchesViewModel: ObservableObject {
    @Published var matches: [MatchWithId] = []
    @Published var isLoading = true

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() { fetchMatches() }
    deinit { listener?.remove() }

    private func fetchMatches() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Task {
            let blockedUIDs = (try? await SafetyService.shared.getBlockedUIDs()) ?? []
            
            DispatchQueue.main.async {
                self.listener = self.db.collection("matches")
                    .whereField("users", arrayContains: uid)
                    .addSnapshotListener { [weak self] snapshot, _ in
                        guard let self, let docs = snapshot?.documents else {
                            DispatchQueue.main.async { self?.isLoading = false }
                            return
                        }

                        let group = DispatchGroup()
                        var items: [MatchWithId] = []

                        for doc in docs {
                            let matchId = doc.documentID
                            let data = doc.data()
                            let users = data["users"] as? [String] ?? []
                            let otherUID = users.first { $0 != uid } ?? ""
                            let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue()
                            let lastMessage = data["lastMessage"] as? String ?? ""

                            // Hide if expired AND no message sent
                            if let expiry = expiresAt, expiry < Date(), lastMessage.isEmpty {
                                continue
                            }

                            if blockedUIDs.contains(otherUID) { continue }

                            group.enter()
                            self.db.collection("users").document(otherUID).getDocument { snap, _ in
                                if let user = try? snap?.data(as: User.self) {
                                    items.append(MatchWithId(id: matchId, user: user, expiresAt: expiresAt))
                                }
                                group.leave()
                            }
                        }

                        group.notify(queue: .main) {
                            self.matches = items
                            self.isLoading = false
                        }
                    }
            }
        }
    }
}

struct MatchesView: View {
    @StateObject private var vm = MatchesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.matches.isEmpty {
                    VStack(spacing: 16) {
                        Text("🔥").font(.system(size: 54))
                        Text(L("matches_empty_title")).font(.title3.bold())
                        Text(L("matches_empty_subtitle"))
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 16
                        ) {
                            ForEach(vm.matches) { match in
                                NavigationLink(destination: MatchProfileView(match: match)) {
                                    MatchCard(match: match)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(L("tab_matches"))
        }
    }
}

private extension Date {
    var timeRemaining: String {
        let diff = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: self)
        let hours = diff.hour ?? 0
        let minutes = diff.minute ?? 0
        
        if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "!"
        }
    }
}

struct MatchCard: View {
    let match: MatchWithId
    var user: User { match.user }
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: user.profileImageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.orange.opacity(0.15)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                        )
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(IgniteTheme.mainGradient, lineWidth: 2))
                
                if let expiry = match.expiresAt, expiry > Date() {
                    Text(expiry.timeRemaining)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }

            Text(user.name)
                .font(.headline)
                .foregroundColor(IgniteTheme.textPrimary)
            Text(user.city)
                .font(.caption)
                .foregroundColor(IgniteTheme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    MatchesView()
}
