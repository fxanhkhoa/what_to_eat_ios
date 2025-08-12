//
//  Color.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 12/8/25.
//

import SwiftUI

struct ColorPalette {
    static let palette: [Color] = [
        Color(hex: "#311300"),
        Color(hex: "#502400"),
        Color(hex: "#5f2e04"),
        Color(hex: "#6d390f"),
        Color(hex: "#7b441a"),
        Color(hex: "#8a5025"),
        Color(hex: "#a7683a"),
        Color(hex: "#c58151"),
        Color(hex: "#e39b69"),
        Color(hex: "#ffb786"),
        Color(hex: "#ffdcc6"),
        Color(hex: "#ffede4"),
        Color(hex: "#fff8f5"),
        Color(hex: "#fffbff")
    ]
    
    static let textColors: [Color] = [
        Color(hex: "#ffffff"),
        Color(hex: "#ffffff"),
        Color(hex: "#ffffff"),
        Color(hex: "#ffffff"),
        Color(hex: "#ffffff"),
        Color(hex: "#ffffff"),
        Color(hex: "#ffffff"),
        Color(hex: "#F3A446"),
        Color(hex: "#F3A446"),
        Color(hex: "#F3A446"),
        Color(hex: "#F3A446"),
        Color(hex: "#F3A446"),
        Color(hex: "#F3A446"),
        Color(hex: "#F3A446"),
    ]
    
    static func textColorByIndex(for index: Int, with reverse: Bool = false) -> Color {
        if reverse {
            return textColors[(textColors.count - 1) - (index % textColors.count)]
        }
        return textColors[index % textColors.count]
    }
    
    static func colorByIndex (for index: Int, with reverse: Bool = false) -> Color {
        if reverse {
            return palette[(palette.count - 1) - (index % palette.count)]
        }
        return palette[index % palette.count]
    }
    
}
