import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject private var store = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: String = StoreManager.igniteMonthly

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    IgniteTheme.mainGradient
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        Text("🔥")
                            .font(.system(size: 60))
                        Text("Upgrade Ignite")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                        Text("Unlock your perfect match")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.vertical, 40)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 24) {
                    // Plan cards
                    if store.products.isEmpty {
                        VStack(spacing: 12) {
                            if store.errorMessage.isEmpty {
                                ProgressView()
                                Text("Loading plans...")
                                    .font(.subheadline)
                                    .foregroundColor(IgniteTheme.textSecondary)
                            } else {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                Text(store.errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(IgniteTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                Button("Retry") {
                                    store.errorMessage = ""
                                    Task { await store.loadProducts() }
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(IgniteTheme.primary)
                            }
                        }
                        .padding()
                        .onAppear {
                            Task { await store.loadProducts() }
                        }
                    } else {
                        ForEach(store.products, id: \.id) { product in
                            PlanCard(
                                product: product,
                                isSelected: selectedPlan == product.id,
                                isRecommended: product.id == StoreManager.igniteMonthly
                            ) {
                                selectedPlan = product.id
                            }
                        }
                    }

                    // Feature comparison
                    FeatureComparisonView()

                    // Purchase button
                    Button {
                        Task {
                            if let product = store.products.first(where: { $0.id == selectedPlan }) {
                                await store.purchase(product)
                            } else if let first = store.products.first {
                                await store.purchase(first)
                            }
                        }
                    } label: {
                        if store.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(IgniteTheme.mainGradient)
                                .cornerRadius(IgniteTheme.buttonRadius)
                        } else {
                            Text("Continue")
                                .primaryButton()
                        }
                    }
                    .disabled(store.products.isEmpty)
                    .opacity(store.products.isEmpty ? 0.5 : 1)
                    .padding(.horizontal)

                    // Restore
                    Button {
                        Task { await store.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textSecondary)
                    }

                    // Legal
                    Text("Subscription auto-renews monthly. Cancel anytime in App Store settings.")
                        .font(.caption2)
                        .foregroundColor(IgniteTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
                .padding(.top, 24)
            }
        }
        .background(IgniteTheme.background.ignoresSafeArea())
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
                    .padding()
            }
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void

    var planName: String {
        product.id == StoreManager.igniteMonthly ? "Ignite 🔥" : "Spark ⚡"
    }

    var planSubtitle: String {
        product.id == StoreManager.igniteMonthly
            ? "All features + Family Mode"
            : "Unlimited likes + AI features"
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(planName)
                            .font(.headline.bold())
                        if isRecommended {
                            Text("BEST VALUE")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(IgniteTheme.primary)
                                .cornerRadius(8)
                        }
                    }
                    Text(planSubtitle)
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(IgniteTheme.textPrimary)
                    Text("per month")
                        .font(.caption)
                        .foregroundColor(IgniteTheme.textSecondary)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? IgniteTheme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
}

// MARK: - Feature Comparison

struct FeatureComparisonView: View {
    let features: [(String, String, String, String)] = [
        ("Daily Likes", "10", "Unlimited", "Unlimited"),
        ("See Who Liked You", "❌", "✅", "✅"),
        ("AI Compatibility", "❌", "✅", "✅"),
        ("AI Ice Breakers", "❌", "✅", "✅"),
        ("Voice Intro", "❌", "✅", "✅"),
        ("Undo Swipe", "❌", "✅", "✅"),
        ("Weekly Boosts", "0", "1", "3"),
        ("Read Receipts", "❌", "❌", "✅"),
        ("Family Mode", "❌", "❌", "✅"),
        ("Priority Queue", "❌", "❌", "✅"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Features")
                    .font(.caption.bold())
                    .foregroundColor(IgniteTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Free")
                    .font(.caption.bold())
                    .foregroundColor(IgniteTheme.textSecondary)
                    .frame(width: 60, alignment: .center)
                Text("Spark")
                    .font(.caption.bold())
                    .foregroundColor(IgniteTheme.secondary)
                    .frame(width: 60, alignment: .center)
                Text("Ignite")
                    .font(.caption.bold())
                    .foregroundColor(IgniteTheme.primary)
                    .frame(width: 60, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))

            ForEach(features, id: \.0) { feature in
                HStack {
                    Text(feature.0)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(feature.1)
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.textSecondary)
                        .frame(width: 60, alignment: .center)
                    Text(feature.2)
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.secondary)
                        .frame(width: 60, alignment: .center)
                    Text(feature.3)
                        .font(.subheadline)
                        .foregroundColor(IgniteTheme.primary)
                        .frame(width: 60, alignment: .center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white)

                Divider()
                    .padding(.leading, 20)
            }
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    PaywallView()
}
