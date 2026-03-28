import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var swipeVM = SwipeViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Swipe Tab
            swipeTab
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Discover")
                }
                .tag(0)

            // Matches Tab
            MatchesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Matches")
                }
                .tag(1)

            // Chat Tab
            ChatListView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }

    var swipeTab: some View {
        VStack {
            // Header
            HStack {
                Text("🔥 Ignite")
                    .font(.title.bold())
                Spacer()
            }
            .padding(.horizontal)

            Spacer()

            if swipeVM.users.isEmpty {
                VStack(spacing: 16) {
                    Text("🔥")
                        .font(.system(size: 60))
                    Text("No more profiles")
                        .font(.title2.bold())
                    Text("Check back later!")
                        .foregroundColor(.secondary)
                }
            } else {
                ZStack {
                    ForEach(swipeVM.users.reversed()) { user in
                        CardSwipeView(
                            user: user,
                            onLike: { swipeVM.like(user: user) },
                            onDislike: { swipeVM.dislike(user: user) }
                        )
                    }
                }

                // Action buttons
                HStack(spacing: 40) {
                    Button {
                        if let user = swipeVM.users.last {
                            swipeVM.dislike(user: user)
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title.bold())
                            .foregroundColor(.red)
                            .frame(width: 64, height: 64)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button {
                        if let user = swipeVM.users.last {
                            swipeVM.like(user: user)
                        }
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.title.bold())
                            .foregroundColor(.orange)
                            .frame(width: 64, height: 64)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding(.top, 24)
            }

            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
