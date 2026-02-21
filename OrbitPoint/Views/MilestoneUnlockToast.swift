import SwiftUI

struct MilestoneUnlockToast: View {

    let item: StoreItem
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -120

    var body: some View {
        VStack {
            HStack(spacing: 14) {
                Circle()
                    .fill(item.previewColor)
                    .frame(width: 36, height: 36)
                    .shadow(color: item.previewColor.opacity(0.6), radius: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Skin Unlocked!")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.accent)
                    Text("\(item.name) \(item.type.rawValue.capitalized)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(item.previewColor.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
            .padding(.horizontal, 20)
            .offset(y: offset)

            Spacer()
        }
        .padding(.top, 60)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeIn(duration: 0.3)) {
                    offset = -120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}
