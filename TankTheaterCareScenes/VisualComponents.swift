import SwiftUI

struct HeroTankStage: View {
    let cue: CareCue
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(title).font(.largeTitle.bold())
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                CueBadge(cue: cue)
            }
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 28).fill(LinearGradient(colors: [cue.color.opacity(0.22), Color(hex: "F7FBFA")], startPoint: .top, endPoint: .bottom))
                MiniTankStage(stage: .plantedBowl, cue: cue).padding(.horizontal, 18).padding(.bottom, 14)
            }
            .frame(height: 220)
        }
        .padding()
        .background(Color(hex: "FAF7EF"), in: RoundedRectangle(cornerRadius: 32))
    }
}

struct MiniTankStage: View {
    let stage: TankStage
    let cue: CareCue

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 22).stroke(Color(hex: stage.accentHex), lineWidth: 5).background(RoundedRectangle(cornerRadius: 22).fill(cue.color.opacity(0.14)))
            HStack(alignment: .bottom, spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule().fill(Color(hex: "2F7D68").opacity(0.5 + Double(index) * 0.08)).frame(width: 10, height: CGFloat(34 + index * 10))
                }
                Circle().fill(Color(hex: "E69F35")).frame(width: 34, height: 22).overlay(Circle().fill(.white).frame(width: 6, height: 6).offset(x: 8, y: -2))
                VStack(spacing: 4) { ForEach(0..<3, id: \.self) { _ in Circle().fill(cue.color.opacity(0.45)).frame(width: 12, height: 12) } }
            }
            .padding(.bottom, 22)
            Text(stage.rawValue).font(.caption.bold()).padding(8).background(.ultraThinMaterial, in: Capsule()).padding(10).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct CareSceneCard: View {
    let record: CareSceneRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text(record.title).font(.headline); Spacer(); CueBadge(cue: record.cue) }
            Text(record.cueReason).font(.subheadline).foregroundStyle(.secondary)
            HStack {
                Label(record.tankStage.rawValue, systemImage: "water.waves")
                Label(record.observation.rawValue, systemImage: "eye")
            }.font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(hex: record.waterCueHex).opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct CueBadge: View {
    let cue: CareCue
    var body: some View { Text(cue.rawValue).font(.caption.bold()).padding(.horizontal, 10).padding(.vertical, 6).background(cue.color.opacity(0.18), in: Capsule()).foregroundStyle(cue.color) }
}

struct CuePill: View {
    let cue: CareCue
    let reason: String
    var body: some View { VStack(alignment: .leading, spacing: 6) { CueBadge(cue: cue); Text(reason) }.accessibilityElement(children: .combine) }
}

struct MiniCueComparison: View {
    let newText: String
    let previousText: String
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) { Text("Current cue").font(.caption); Text(newText).bold() }
            Image(systemName: "arrow.left.arrow.right")
            VStack(alignment: .leading) { Text("Comparison").font(.caption); Text(previousText).bold() }
        }
        .padding()
        .background(Color(hex: "EAF7F3"), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct PremiumPreviewCard: View {
    let isUnlocked: Bool
    let openPaywall: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text("Premium stage themes").font(.headline); Spacer(); Text(isUnlocked ? "Unlocked" : "Additive") }
            Text("Multiple tanks, longer history, export, and extra stage themes unlock after the free first loop.")
            Button(isUnlocked ? "Review Premium" : "View Premium", action: openPaywall)
        }
        .padding()
        .background(Color(hex: "F4EFE3"), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct ErrorBanner: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(message, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red)
            Button("Try again", action: retry)
        }
        .accessibilityElement(children: .combine)
    }
}


struct SuccessToast: View {
    let message: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
            Text(message).font(.headline)
            Spacer()
            Button("Dismiss", action: dismiss).font(.caption.bold())
        }
        .padding()
        .background(Color(hex: "EAF7F3"), in: Capsule())
        .shadow(radius: 10, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Care Scene saved.")
    }
}
