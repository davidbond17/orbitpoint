import SwiftUI

struct LoreCollectedToast: View {

    let fragment: LoreFragment
    let onDismiss: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "diamond.fill")
                    .foregroundColor(Color(red: 0.3, green: 0.9, blue: 1.0))
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    Text("DATA CRYSTAL RECOVERED")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.9, blue: 1.0))
                        .tracking(1)

                    Text(fragment.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                }

                Spacer()
            }
            .padding(16)
            .glassBackground()
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
        .allowsHitTesting(false)
    }
}
