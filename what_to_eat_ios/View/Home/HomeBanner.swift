//
//  HomeBanner.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 5/8/25.
//

import SwiftUI
import Kingfisher

struct HomeBanner: View {
    @Binding var selectedTab: Int
    
    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack (alignment: .topLeading) {
                Image("hero-bread")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: 400)
                
                Image("splash_3")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .padding(.leading, -20)
                    .padding(.top, -20)
                
                Image("what-to-eat-high-resolution-logo-black-transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 90)
                    .padding(.top, 100)
                    .padding(.leading, 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    LocalizedText("home_banner_title")
                        .font(.system(size: 36))
                        .fontWeight(.bold)
                    LocalizedText("home_banner_subtitle").foregroundStyle(.secondary)
                }
                .padding([.top], 240)
                .padding(.leading, 20)
                
            }.frame(height: 400)
            
            NeumorphicButton(text: LocalizationService.shared.localizedString(for: "find_your_meal"), action: {
                // Change selected tab to DishView (assuming it's tab index 1)
                withAnimation {
                    selectedTab = 1
                }
            })
        }
    }
}

#Preview {
    HomeBanner(selectedTab: .constant(0))
}
