import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var swipeVM = SwipeViewModel()
    @State private var selectedTab = 0
    @State private var reportTarget: User? = nil
    @State private var showReportSheet = false
    @State private var isPulsing = false

    var body: some View {
        TabView(selection: $selectedTab) {
            swipeTab
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text(L("tab_discover"))
                }
                .tag(0)

            MatchesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text(L("tab_matches"))
                }
                .tag(1)

            ChatListView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text(L("tab_messages"))
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text(L("tab_profile"))
                }
                .tag(3)
        }
        .accentColor(.orange)
        .onAppear {
            swipeVM.fetchUsers(currentUser: authViewModel.currentUser)
        }
        .fullScreenCover(item: $swipeVM.matchedUser) { matched in
            MatchOverlayView(
                currentUser: authViewModel.currentUser ?? User(name: "", age: 0),
                matchedUser: matched,
                onMessage: {
                    swipeVM.clearMatch()
                    selectedTab = 2
                },
                onDismiss: {
                    swipeVM.clearMatch()
                }
            )
        }
        .confirmationDialog(L("report_title"), isPresented: $showReportSheet, presenting: reportTarget) { user in
            Button(L("report_photos")) { swipeVM.report(user: user, reason: L("report_photos")) }
            Button(L("report_fake")) { swipeVM.report(user: user, reason: L("report_fake")) }
            Button(L("report_harassment")) { swipeVM.report(user: user, reason: L("report_harassment")) }
            Button("\(L("block_user")) \(user.name)", role: .destructive) { swipeVM.block(user: user) }
            Button(L("action_cancel"), role: .cancel) {}
        }
    }

    var swipeTab: some View {
        VStack {
            HStack {
                Text("🔥 \(L("app_name"))")
                    .font(.title.bold())
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isPulsing)
                Spacer()
            }
            .padding(.horizontal)
            .onAppear { isPulsing = true }

            Spacer()

            if swipeVM.isLoading {
                VStack(spacing: 20) {
                    Text("🔥")
                        .font(.system(size: 60))
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                    
                    Text(L("loading_discover"))
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                }
                .onAppear { isPulsing = true }
            } else if swipeVM.hasReachedLimit {
                VStack(spacing: 20) {
                    Image(systemName: "hourglass.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(IgniteTheme.mainGradient)
                    
                    Text(L("discover_limit_title"))
                        .font(.title2.bold())
                    
                    Text(L("discover_limit_subtitle"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        selectedTab = 1 // Go to matches
                    } label: {
                        Text(L("tab_matches"))
                            .primaryButton()
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 60)
                }
            } else if swipeVM.users.isEmpty {
                VStack(spacing: 16) {
                    Text("🔥").font(.system(size: 60))
                    Text(L("discover_empty_title")).font(.title2.bold())
                    Text(L("discover_empty_subtitle")).foregroundColor(.secondary)
                }
            } else {
                ZStack {
                    ForEach(swipeVM.users.reversed()) { user in
                        CardSwipeView(
                            user: user,
                            onLike: { swipeVM.like(user: user) },
                            onDislike: { swipeVM.dislike(user: user) },
                            onReport: {
                                reportTarget = user
                                showReportSheet = true
                            }
                        )
                    }
                }

                HStack(spacing: 40) {
                    Button {
                        if let user = swipeVM.users.last { swipeVM.dislike(user: user) }
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
                        if let user = swipeVM.users.last { swipeVM.like(user: user) }
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
    HomeView().environmentObject(AuthViewModel())
}
