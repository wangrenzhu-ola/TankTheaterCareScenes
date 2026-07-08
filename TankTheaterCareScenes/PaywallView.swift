import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var premium: PremiumStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Premium Tank Theater").font(.largeTitle.bold())
                Text("Unlock multiple tanks, longer local history, export, and extra stage themes. Your first core Care Scene remains free.")
                PremiumFeatureGrid()
                Text(premium.storeKitMessage).font(.callout).foregroundStyle(.secondary)
                if let restoreFailure = premium.restoreFailureNote { ErrorBanner(message: restoreFailure) { Task { await premium.restorePurchases() } } }
                Button("Unlock Premium") { Task { await premium.purchasePremium() } }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Unlock Premium with StoreKit")
                Button("Restore Purchases") { Task { await premium.restorePurchases() } }
                    .accessibilityLabel("Restore Purchases")
            }
            .padding()
        }
        .task { await premium.loadProducts() }
        .navigationTitle("Paywall")
    }
}

private struct PremiumFeatureGrid: View {
    let features = ["Multiple tank stages", "Longer cue history", "Local export", "Extra stage themes"]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.seal.fill")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "EAF7F3"), in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }
}
