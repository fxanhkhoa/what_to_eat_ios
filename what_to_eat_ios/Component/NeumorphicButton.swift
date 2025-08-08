//
//  NeumorphicButton.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 5/8/25.
//

import SwiftUI

struct NeumorphicButton: View {
    let icon: String?
    let text: String
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed: Bool = false
    
    init(icon: String? = nil, text: String, action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.action = action
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.9)
    }
    
    var shadowColor1: Color {
        colorScheme == .dark ? Color(white: 0.05) : Color.white
    }
    
    var shadowColor2: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.7)
    }
    
    var textColor: Color {
        colorScheme == .dark ? Color.white : Color(white: 0.2)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            // Add a small delay to show the press effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 10) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .medium))
                }
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(textColor)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                        .shadow(color: shadowColor1, radius: isPressed ? 1 : 8, x: isPressed ? -1 : -5, y: isPressed ? -1 : -5)
                        .shadow(color: shadowColor2, radius: isPressed ? 1 : 8, x: isPressed ? 1 : 5, y: isPressed ? 1 : 5)
                    
                    if isPressed {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(shadowColor2, lineWidth: 2)
                            .blur(radius: 2)
                            .offset(x: 0, y: 0)
                            .mask(RoundedRectangle(cornerRadius: 15).fill(LinearGradient(colors: [Color.black.opacity(0.5), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        NeumorphicButton(icon: "heart.fill", text: "With Icon", action: {
            print("Button with icon tapped")
        })
        .padding()
        
        NeumorphicButton(text: "No Icon", action: {
            print("Button without icon tapped")
        })
        .padding()
    }
    .padding()
    .preferredColorScheme(.light)
}
