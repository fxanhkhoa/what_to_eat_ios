import SwiftUI

struct FlippingCardDishChip: View {
    let dish: Dish
    let onRemove: () -> Void
    let localization = LocalizationService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                AsyncImage(url: URL(string: dish.thumbnail ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .foregroundColor(.gray)
                                .font(.title3)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Remove button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(4)
            }
            
            Text(getLocalizedTitle(for: dish))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .frame(width: 80, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
    
    private func getLocalizedTitle(for dish: Dish) -> String {
        return MultiLanguage.getLocalizedData(
            from: dish.title,
            for: localization.currentLanguage.rawValue
        ) ?? dish.slug
    }
}

#Preview {
    HStack {
        FlippingCardDishChip(
            dish: SampleData.sampleDishes[0],
            onRemove: {}
        )
        
        FlippingCardDishChip(
            dish: SampleData.sampleDishes[1],
            onRemove: {}
        )
    }
    .padding()
}