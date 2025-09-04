//
//  Carousel.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 4/8/25.
//

import SwiftUI

struct Carousel<Content: View>: View {
    let items: [Content]
    let spacing: CGFloat
    let itemWidth: CGFloat
    let height: CGFloat
    let autoScrollInterval: TimeInterval?
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    
    init(_ items: [Content], spacing: CGFloat = 16, itemWidth: CGFloat = 300, height: CGFloat = 200, autoScrollInterval: TimeInterval? = nil) {
        self.items = items
        self.spacing = spacing
        self.itemWidth = itemWidth
        self.height = height
        self.autoScrollInterval = autoScrollInterval
    }
    
    var body: some View {
        VStack {
            if items.isEmpty {
                Text("No items to display")
                    .frame(height: height)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(0..<items.count, id: \.self) { index in
                        items[index]
                            .frame(width: itemWidth)
                            .padding(.horizontal, spacing)
                            .tag(index)
                    }
                }
                .frame(height: height)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentIndex)
                .onAppear {
                    startAutoScroll()
                }
                .onDisappear {
                    stopAutoScroll()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    startAutoScroll()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    stopAutoScroll()
                }
                                
                // Custom indicators
                HStack(spacing: 8) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.primary : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentIndex)
                            .onTapGesture {
                                withAnimation {
                                    currentIndex = index
                                }
                                // Restart auto-scroll timer when user manually changes slide
                                restartAutoScroll()
                            }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Auto Scroll Functions
    private func startAutoScroll() {
        guard let interval = autoScrollInterval, items.count > 1 else { return }
        
        stopAutoScroll() // Stop any existing timer
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = wrappedIndex(currentIndex + 1)
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func restartAutoScroll() {
        stopAutoScroll()
        startAutoScroll()
    }
    
    // Function to handle wrapping indices for looping behavior
    private func wrappedIndex(_ index: Int) -> Int {
        if items.isEmpty {
            return 0
        }
        
        // Handle wrapping at both ends
        if index < 0 {
            return items.count - 1
        } else if index >= items.count {
            return 0
        } else {
            return index
        }
    }
}

struct Carousel_Previews: PreviewProvider {
    static var previews: some View {
        Carousel([
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .overlay(Text("Item 1").foregroundColor(.white)),
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green)
                .overlay(Text("Item 2").foregroundColor(.white)),
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red)
                .overlay(Text("Item 3").foregroundColor(.white))
        ])
    }
}
