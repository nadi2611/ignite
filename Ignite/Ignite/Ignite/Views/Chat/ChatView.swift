import SwiftUI
import FirebaseAuth

struct ChatView: View {
    let user: User
    let matchId: String
    @StateObject private var chatVM: ChatViewModel
    @State private var newMessage = ""
    @FocusState private var inputFocused: Bool

    init(user: User, matchId: String) {
        self.user = user
        self.matchId = matchId
        _chatVM = StateObject(wrappedValue: ChatViewModel(matchId: matchId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(chatVM.messages) { message in
                            let isMe = message.senderId == Auth.auth().currentUser?.uid
                            MessageBubble(message: message, isMe: isMe)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .onChange(of: chatVM.messages.count) { _, _ in
                    if let last = chatVM.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onAppear {
                    if let last = chatVM.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            // Input bar
            HStack(spacing: 10) {
                TextField(L("chat_placeholder"), text: $newMessage, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(22)
                    .focused($inputFocused)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(11)
                        .background(Color.gray.opacity(0.4))
                        .background(
                            Group {
                                if !newMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                                    IgniteTheme.mainGradient
                                }
                            }
                        )
                        .clipShape(Circle())
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .overlay(Divider(), alignment: .top)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: user.profileImageURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.orange.opacity(0.2)
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            if user.isVerified == true {
                                VerifiedBadge(size: 14)
                            }
                        }
                        Text(user.city)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        Task {
                            try? await SafetyService.shared.unmatch(otherUID: user.id ?? "")
                            dismiss()
                        }
                    } label: {
                        Label(L("unmatch_user"), systemImage: "person.fill.xmark")
                    }

                    Button(role: .destructive) {
                        Task {
                            try? await SafetyService.shared.block(userUID: user.id ?? "")
                            dismiss()
                        }
                    } label: {
                        Label(L("block_user"), systemImage: "hand.raised.fill")
                    }
                    
                    Menu(L("report_title")) {
                        Button(L("report_photos")) { reportUser(reason: L("report_photos")) }
                        Button(L("report_fake")) { reportUser(reason: L("report_fake")) }
                        Button(L("report_harassment")) { reportUser(reason: L("report_harassment")) }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.bold())
                        .foregroundColor(IgniteTheme.textPrimary)
                }
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss

    private func reportUser(reason: String) {
        Task {
            try? await SafetyService.shared.report(userUID: user.id ?? "", reason: reason)
            dismiss()
        }
    }

    private func sendMessage() {
        let text = newMessage.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        chatVM.sendMessage(text: text)
        newMessage = ""
    }
}

struct MessageBubble: View {
    let message: Message
    let isMe: Bool

    var body: some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
            HStack {
                if isMe { Spacer(minLength: 60) }
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(isMe ? .clear : .systemGray5))
                    .background(Group { if isMe { IgniteTheme.mainGradient } })
                    .foregroundColor(isMe ? .white : .primary)
                    .cornerRadius(18)
                if !isMe { Spacer(minLength: 60) }
            }

            Text(message.timestamp.messageTime)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
        .padding(.vertical, 2)
    }
}

private extension Date {
    var messageTime: String {
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDateInToday(self) ? "HH:mm" : "dd/MM HH:mm"
        return f.string(from: self)
    }
}

#Preview {
    NavigationStack {
        ChatView(user: User.mock, matchId: "preview")
    }
}
