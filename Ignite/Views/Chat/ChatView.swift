import SwiftUI

struct ChatView: View {
    let user: User
    @StateObject private var chatVM = ChatViewModel()
    @State private var newMessage = ""
    let currentUserId = "1"

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatVM.messages) { message in
                            MessageBubble(
                                message: message,
                                isMe: message.senderId == currentUserId
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatVM.messages.count) { _ in
                    if let last = chatVM.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                TextField("Message...", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(24)

                Button {
                    guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    chatVM.sendMessage(text: newMessage, senderId: currentUserId)
                    newMessage = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageBubble: View {
    let message: Message
    let isMe: Bool

    var body: some View {
        HStack {
            if isMe { Spacer() }
            Text(message.text)
                .padding(12)
                .background(isMe ? Color.orange : Color(.systemGray5))
                .foregroundColor(isMe ? .white : .primary)
                .cornerRadius(18)
                .frame(maxWidth: 260, alignment: isMe ? .trailing : .leading)
            if !isMe { Spacer() }
        }
    }
}

#Preview {
    ChatView(user: User.mock)
}
