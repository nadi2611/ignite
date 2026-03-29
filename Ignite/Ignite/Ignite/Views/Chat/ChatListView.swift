import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

struct MatchItem: Identifiable {
    let id: String
    let user: User
    let lastMessage: String
    let lastMessageAt: Date?
}

class ChatListViewModel: ObservableObject {
    @Published var matchItems: [MatchItem] = []
    @Published var isLoading = true

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() { fetchMatches() }

    deinit { listener?.remove() }

    func deleteMatch(_ item: MatchItem) {
        db.collection("matches").document(item.id).delete()
        matchItems.removeAll { $0.id == item.id }
    }

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
                        var items: [MatchItem] = []

                        for doc in docs {
                            let matchId = doc.documentID
                            let data = doc.data()
                            let users = data["users"] as? [String] ?? []
                            let otherUID = users.first { $0 != uid } ?? ""
                            let lastMessage = data["lastMessage"] as? String ?? ""
                            let lastMessageAt = (data["lastMessageAt"] as? Timestamp)?.dateValue()

                            if blockedUIDs.contains(otherUID) { continue }

                            group.enter()
                            self.db.collection("users").document(otherUID).getDocument { snap, _ in
                                if let user = try? snap?.data(as: User.self) {
                                    items.append(MatchItem(
                                        id: matchId,
                                        user: user,
                                        lastMessage: lastMessage,
                                        lastMessageAt: lastMessageAt
                                    ))
                                }
                                group.leave()
                            }
                        }

                        group.notify(queue: .main) {
                            self.matchItems = items.sorted {
                                ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast)
                            }
                            self.isLoading = false
                        }
                    }
            }
        }
    }
}

struct ChatListView: View {
    @StateObject private var vm = ChatListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.matchItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "message")
                            .font(.system(size: 54))
                            .foregroundColor(IgniteTheme.textSecondary.opacity(0.4))
                        Text(L("chat_empty_title")).font(.title3.bold())
                        Text(L("chat_empty_subtitle"))
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.matchItems) { item in
                        NavigationLink(destination: ChatView(user: item.user, matchId: item.id)) {
                            MatchRow(item: item)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                vm.deleteMatch(item)
                            } label: {
                                Label(L("action_delete"), systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(L("tab_messages"))
        }
    }
}

struct MatchRow: View {
    let item: MatchItem

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: item.user.profileImageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.orange.opacity(0.15)
                    .overlay(Image(systemName: "person.fill").foregroundColor(.orange).font(.title2))
            }
            .frame(width: 58, height: 58)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.user.name)
                        .font(.headline)
                    Spacer()
                    if let date = item.lastMessageAt {
                        Text(date.chatTimestamp)
                            .font(.caption)
                            .foregroundColor(IgniteTheme.textSecondary)
                    }
                }

                Text(item.lastMessage.isEmpty ? L("chat_say_hello") : item.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(item.lastMessage.isEmpty ? IgniteTheme.primary : IgniteTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

private extension Date {
    var chatTimestamp: String {
        if Calendar.current.isDateInToday(self) {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            return L("chat_yesterday")
        } else {
            let f = DateFormatter()
            f.dateFormat = "dd/MM"
            return f.string(from: self)
        }
    }
}

#Preview {
    ChatListView()
}
