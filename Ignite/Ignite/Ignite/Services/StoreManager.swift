import Foundation
import StoreKit
import FirebaseAuth
import Combine

class StoreManager: ObservableObject {
    static let shared = StoreManager()

    static let sparkMonthly = "com.nnajjar.ignite.spark.monthly"
    static let igniteMonthly = "com.nnajjar.ignite.ignite.monthly"

    static let founderEmails: Set<String> = [
        "nadi.najjar11@gmail.com"
    ]

    @Published var products: [Product] = []
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var isPurchasing: Bool = false
    @Published var errorMessage: String = ""

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updateCurrentPlan() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        await MainActor.run { errorMessage = "" }
        do {
            let loaded = try await Product.products(for: [
                StoreManager.sparkMonthly,
                StoreManager.igniteMonthly
            ])
            print("StoreKit loaded \(loaded.count) products: \(loaded.map(\.id))")
            if loaded.isEmpty {
                await MainActor.run {
                    errorMessage = "No products found. Make sure the StoreKit config is set in the scheme (Run → Options → StoreKit Configuration)."
                }
            } else {
                await MainActor.run {
                    products = loaded.sorted { $0.price < $1.price }
                }
            }
        } catch {
            print("StoreKit loadProducts error: \(error)")
            await MainActor.run { errorMessage = "Could not load plans: \(error.localizedDescription)" }
        }
    }

    func purchase(_ product: Product) async {
        await MainActor.run { isPurchasing = true }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateCurrentPlan()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isPurchasing = false }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateCurrentPlan()
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }

    func updateCurrentPlan() async {
        // Founder accounts always get Ignite for free
        if let email = Auth.auth().currentUser?.email,
           StoreManager.founderEmails.contains(email.lowercased()) {
            await MainActor.run { currentPlan = .ignite }
            return
        }

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                switch transaction.productID {
                case StoreManager.igniteMonthly:
                    await MainActor.run { currentPlan = .ignite }
                    return
                case StoreManager.sparkMonthly:
                    await MainActor.run { currentPlan = .spark }
                    return
                default:
                    break
                }
            }
        }
        await MainActor.run { currentPlan = .free }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await self.updateCurrentPlan()
                    await transaction.finish()
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}

enum SubscriptionPlan: String {
    case free = "Free"
    case spark = "Spark"
    case ignite = "Ignite"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .spark: return "Spark ⚡"
        case .ignite: return "Ignite 🔥"
        }
    }

    var color: String {
        switch self {
        case .free: return "#9CA3AF"
        case .spark: return "#FF8C42"
        case .ignite: return "#FF4D4D"
        }
    }

    var unlimitedLikes: Bool { self != .free }
    var seeWhoLikedYou: Bool { self != .free }
    var aiFeatures: Bool { self != .free }
    var voiceIntro: Bool { self != .free }
    var undoSwipe: Bool { self != .free }
    var familyMode: Bool { self == .ignite }
    var readReceipts: Bool { self == .ignite }
    var priorityQueue: Bool { self == .ignite }
    var weeklyBoosts: Int { self == .ignite ? 3 : self == .spark ? 1 : 0 }
    var dailyLikes: Int { self == .free ? 10 : 999 }
}
