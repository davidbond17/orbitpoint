import SwiftUI

struct PauseMenuView: View {

    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var storeManager = StoreManager.shared
    let onResume: () -> Void
    let onQuit: () -> Void

    @State private var showStore = false
    @State private var selectedCategory: CustomizeCategory = .satellite

    var body: some View {
        VStack(spacing: 24) {
            Text("Paused")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.top, 20)

            customizeSection

            Divider()
                .background(Theme.Colors.textSecondary.opacity(0.3))
                .padding(.horizontal, 20)

            actionButtons

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.opacity(0.95).ignoresSafeArea())
        .sheet(isPresented: $showStore) {
            StoreView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var customizeSection: some View {
        VStack(spacing: 16) {
            Text("Quick Customize")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.Colors.textSecondary)

            Picker("Category", selection: $selectedCategory) {
                ForEach(CustomizeCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(itemsForCategory) { item in
                        QuickSelectItem(
                            item: item,
                            isSelected: isItemEquipped(item),
                            isLocked: !storeManager.isUnlocked(item.id),
                            onTap: {
                                if storeManager.isUnlocked(item.id) {
                                    storeManager.equip(item)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .glassBackground()
    }

    private var itemsForCategory: [StoreItem] {
        switch selectedCategory {
        case .satellite:
            return StoreItems.satellites
        case .sun:
            return StoreItems.suns
        case .debris:
            return StoreItems.debris
        }
    }

    private func isItemEquipped(_ item: StoreItem) -> Bool {
        switch item.type {
        case .satellite:
            return item.id == storeManager.equippedSatelliteId
        case .sun:
            return item.id == storeManager.equippedSunId
        case .debris:
            return item.id == storeManager.equippedDebrisId
        case .theme:
            return false
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showStore = true
            }) {
                HStack {
                    Image(systemName: "bag.fill")
                    Text("Store")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .glassBackground()
            }

            Button(action: onResume) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Resume")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.Colors.accent)
                .cornerRadius(16)
            }

            Button(action: onQuit) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Quit to Menu")
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, 8)
        }
    }
}

enum CustomizeCategory: String, CaseIterable {
    case satellite = "Satellite"
    case sun = "Sun"
    case debris = "Debris"
}

struct QuickSelectItem: View {

    let item: StoreItem
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(item.previewColor)
                        .frame(width: 44, height: 44)
                        .shadow(color: item.previewColor.opacity(0.4), radius: 6)

                    if isLocked {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 44, height: 44)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }

                Text(item.name)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isLocked ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isLocked)
    }
}
