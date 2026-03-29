import SwiftUI

struct ProfileScoreView: View {
    let user: User
    @State private var showChecklist = false
    
    var milestoneText: String {
        let score = user.completionScore
        if score == 100 { return L("score_milestone_100") }
        if score >= 80 { return L("score_milestone_80") }
        if score >= 50 { return L("score_milestone_50") }
        return L("score_subtitle")
    }
    
    var body: some View {
        Button {
            showChecklist = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("score_title"))
                            .font(.headline)
                            .foregroundColor(IgniteTheme.textPrimary)
                        Text(milestoneText)
                            .font(.caption)
                            .foregroundColor(IgniteTheme.textSecondary)
                    }
                    Spacer()
                    Text("\(user.completionScore)%")
                        .font(.title2.bold())
                        .foregroundColor(IgniteTheme.primary)
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(IgniteTheme.mainGradient)
                            .frame(width: geo.size.width * CGFloat(user.completionScore) / 100, height: 8)
                    }
                }
                .frame(height: 8)
                
                // Milestones
                HStack {
                    milestoneIcon(score: 50, icon: "star.fill")
                    Spacer()
                    milestoneIcon(score: 80, icon: "bolt.fill")
                    Spacer()
                    milestoneIcon(score: 100, icon: "crown.fill")
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .sheet(isPresented: $showChecklist) {
            ScoreChecklistView(user: user)
        }
    }
    
    private func milestoneIcon(score: Int, icon: String) -> some View {
        let isReached = user.completionScore >= score
        return VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isReached ? IgniteTheme.primary : Color(.systemGray4))
            Text("\(score)%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isReached ? IgniteTheme.textPrimary : Color(.systemGray4))
        }
    }
}

struct ScoreChecklistView: View {
    let user: User
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(user.scoreChecklist) { item in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(item.isComplete ? Color.green.opacity(0.1) : Color(.systemGray6))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: item.isComplete ? "checkmark" : "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(item.isComplete ? .green : .secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline.bold())
                            .foregroundColor(item.isComplete ? IgniteTheme.textPrimary : .secondary)
                        Text("+\(item.points)%")
                            .font(.caption2)
                            .foregroundColor(item.isComplete ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    if item.isComplete {
                        Text("DONE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                .padding(.vertical, 4)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle(L("score_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("action_cancel")) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
