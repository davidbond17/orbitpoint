import SwiftUI

struct MissionBriefingView: View {

    let zone: Int
    let onDismiss: () -> Void

    @State private var textOpacity: Double = 0
    @State private var headerOpacity: Double = 0

    private var voiceLineId: String { "zone\(zone)_briefing" }

    private var theme: ZoneTheme {
        ZoneThemes.theme(for: zone)
    }

    private var briefingText: String {
        switch zone {
        case 1:
            return "Probe Unit OP-1 online. Primary directive: maintain orbital stability around Star SOL-7. Debris field density: minimal. Begin calibration sequence."
        case 2:
            return "SOL-7's emissions are destabilizing the Crimson Nebula. Debris patterns are... organized. Almost as if something is directing them. Maintain orbit. Do not investigate."
        case 3:
            return "Thermal readings dropping. SOL-7 is losing energy faster than projected. The ice is not natural — it's crystallized starlight. Something drained this sector long before we arrived."
        case 4:
            return "Gravitational anomalies detected. Spacetime is fractured here. The debris... it's moving against physics. OP-1, your readings are being logged but we cannot guarantee retrieval. You are on your own."
        case 5:
            return "Final transmission. SOL-7 is going critical. All remaining probe units have been lost. You are the last. Every second you hold orbit delays the inevitable. Make it count."
        default:
            return ""
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: theme.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(theme.accentColor)
                    .opacity(headerOpacity)

                VStack(spacing: 8) {
                    Text("ZONE \(zone)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(theme.accentColor)
                        .tracking(3)
                        .opacity(headerOpacity)

                    Text(theme.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .opacity(headerOpacity)
                }

                Text(briefingText)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .opacity(textOpacity)

                Spacer()

                Button {
                    VoiceLineManager.shared.stop()
                    onDismiss()
                } label: {
                    Text("BEGIN")
                }
                .buttonStyle(.glass)
                .padding(.horizontal, 40)
                .opacity(textOpacity)

                Button {
                    VoiceLineManager.shared.stop()
                    onDismiss()
                } label: {
                    Text("Skip")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                }
                .opacity(textOpacity)

                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                headerOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.4)) {
                textOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                VoiceLineManager.shared.play(voiceLineId)
            }
        }
    }
}
