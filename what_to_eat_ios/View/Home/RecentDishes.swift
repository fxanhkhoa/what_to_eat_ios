//
//  RecentDishes.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 7/8/25.
//

import SwiftUI

struct RecentDishes: View {
    let dishes: [Dish]
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            LocalizedText("popular_dishes")
                .font(.headline)
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 64) {
                if dishes.isEmpty {
                    LocalizedText("no_results")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(dishes) { dish in
                        DishCardFancy(dish: dish)
                    }
                }
            }
        }
    }
}

#Preview {
    RecentDishes(dishes: [SampleData.sampleDish, SampleData.sampleDish])
}
