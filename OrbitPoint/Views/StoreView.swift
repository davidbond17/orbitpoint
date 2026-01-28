import SwiftUI

struct StoreView: View {

    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            header

            Picker("Category", selection: $selectedTab) {
                Text("Satellite").tag(0)
                Text("Sun").tag(1)
                Text("Debris").tag(2)
                Text("Themes").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            ScrollView {
                switch selectedTab {
                case 0:
                    itemGrid(items: StoreItems.satellites, equippedId: storeManager.equippedSatelliteId)
                case 1:
                    itemGrid(items: StoreItems.suns, equippedId: storeManager.equippedSunId)
                case 2:
                    itemGrid(items: StoreItems.debris, equippedId: storeManager.equippedDebrisId)
                case 3:
                    themeGrid
                default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Text("Store")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            CoinDisplay(amount: viewModel.totalCurrency)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.glassBackground)
                    .clipShape(Circle())
            }
            .padding(.leading, 12)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    private func itemGrid(items: [StoreItem], equippedId: String) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(items) { item in
                StoreItemCard(
                    item: item,
                    isUnlocked: storeManager.isUnlocked(item.id),
                    isEquipped: item.id == equippedId,
                    onPurchase: {
                        _ = storeManager.purchase(item)
                    },
                    onEquip: {
                        storeManager.equip(item)
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private var themeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
            ForEach(StoreItems.themes) { theme in
                ThemePackCard(
                    theme: theme,
                    isUnlocked: storeManager.isUnlocked(theme.id),
                    onPurchase: {
                        _ = storeManager.purchaseTheme(theme)
                    },
                    onEquip: {
                        storeManager.equipTheme(theme)
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct StoreItemCard: View {

    let item: StoreItem
    let isUnlocked: Bool
    let isEquipped: Bool
    let onPurchase: () -> Void
    let onEquip: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(item.previewColor)
                .frame(width: 50, height: 50)
                .shadow(color: item.previewColor.opacity(0.5), radius: 10)

            Text(item.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)

            if isEquipped {
                Text("Equipped")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.accent.opacity(0.2))
                    .cornerRadius(12)
            } else if isUnlocked {
                Button(action: onEquip) {
                    Text("Equip")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.glassBackground)
                        .cornerRadius(12)
                }
            } else {
                Button(action: onPurchase) {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("\(item.price)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.glassBackground)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glassBackground()
    }
}

struct ThemePackCard: View {

    let theme: ThemePack
    let isUnlocked: Bool
    let onPurchase: () -> Void
    let onEquip: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(theme.name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(theme.satelliteColor)
                        .frame(width: 30, height: 30)
                    Text("Satellite")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                VStack(spacing: 4) {
                    Circle()
                        .fill(theme.sunCoreColor)
                        .frame(width: 30, height: 30)
                        .shadow(color: theme.sunGlowColor.opacity(0.6), radius: 8)
                    Text("Sun")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                VStack(spacing: 4) {
                    Circle()
                        .fill(theme.debrisColor)
                        .frame(width: 30, height: 30)
                    Text("Debris")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            if isUnlocked {
                Button(action: onEquip) {
                    Text("Apply Theme")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.glassBackground)
                        .cornerRadius(16)
                }
            } else {
                Button(action: onPurchase) {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("\(theme.price)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.Colors.glassBackground)
                    .cornerRadius(16)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassBackground()
    }
}
