//
//  WheelOfFortune.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 12/8/25.
//

import SwiftUI
import Combine

struct WheelOfFortune: View {
    @State private var dishes: [Dish] = []
    @State private var rotationAngle: Double = 0
    @State private var isSpinning = false
    @State private var selectedDish: Dish?
    @State private var previewDish: Dish?
    @State private var showResult = false
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    private let dishService = DishService()
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground),
                        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerSection
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#F3A446")))
                                .scaleEffect(1.5)
                                .padding(.top, 50)
                        } else {
                            // Wheel Container
                            wheelContainer
                            
                            // Spin Button
                            spinButton
                            
                            // Result Section
                            if let selectedDish = selectedDish {
                                resultSection(dish: selectedDish)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .refreshable {
                    await refreshDishes()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                loadDishes()
            }
        }
        .sheet(isPresented: $showResult, onDismiss: {
            previewDish = nil
        }) {
            if let previewDish = previewDish {
                DishDetailView(dish: previewDish)
            } else if let selectedDish = selectedDish {
                DishDetailView(dish: selectedDish)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#F3A446"))
            
            LocalizedText("wheel_of_fortune")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LocalizedText("wheel_of_fortune_description")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var wheelContainer: some View {
        ZStack {
            // Wheel Background and Sections (these rotate)
            ZStack {
                // Wheel Background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemGray4),
                                Color(.systemGray5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .shadow(radius: 10)
                
                // Wheel Sections
                if !dishes.isEmpty {
                    ForEach(Array(dishes.enumerated()), id: \.element.id) { index, dish in
                        wheelSection(dish: dish, index: index, total: dishes.count)
                    }
                }
                
                // Center Circle
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 60, height: 60)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "crown.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#F3A446"))
                    )
            }
            .rotationEffect(.degrees(rotationAngle))
            .animation(
                isSpinning ?
                    .easeOut(duration: 3.0) :
                        .easeInOut(duration: 0.5),
                value: rotationAngle
            )
            
            // Stationary Pointer (doesn't rotate) - positioned at top
            VStack {
                Triangle()
                    .fill(Color(hex: "#F3A446"))
                    .frame(width: 20, height: 30)
                    .shadow(radius: 3)
                Spacer()
            }
            .offset(y: -20) // Fixed position at top of wheel
        }
    }
    
    private func wheelSection(dish: Dish, index: Int, total: Int) -> some View {
        let angle = 360.0 / Double(total)
        let startAngle = angle * Double(index)
        let sectionColor = ColorPalette.palette[index % ColorPalette.palette.count]
        let textColor = ColorPalette.textColors[index % ColorPalette.textColors.count]
        
        return ZStack {
            // Section Arc
            WheelSection(
                startAngle: .degrees(startAngle),
                endAngle: .degrees(startAngle + angle)
            )
            .fill(sectionColor)
            .stroke(Color.white, lineWidth: 2)
            .overlay(
                Text(slicedDishName(for: dish, totalSections: total))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .rotationEffect(.degrees(startAngle + angle/2))
                    .frame(width: max(50, min(90, 180 / Double(total))))
                    .offset(x: 100 * cos((startAngle + angle / 2) * .pi / 180),
                            y: 100 * sin((startAngle + angle / 2) * .pi / 180) - 10), // Offset to center text
            ).onTapGesture(perform: {
                previewDish = dish
                isSpinning = false
                showResult = true
            })
        }
        .frame(width: 300, height: 300)
    }
    
    private func slicedDishName(for dish: Dish, totalSections: Int) -> String {
        let fullName = getLocalizedTitle(for: dish)
        print("Full name: \(fullName)")
        
        // Calculate max characters based on number of sections
        let maxChars: Int
        switch totalSections {
        case 1...4:
            maxChars = 20
        case 5...6:
            maxChars = 15
        case 7...8:
            maxChars = 12
        case 9...10:
            maxChars = 10
        default:
            maxChars = 8
        }
        
        // If the name is too long, slice it and add ellipsis
        if fullName.count > maxChars {
            let endIndex = fullName.index(fullName.startIndex, offsetBy: maxChars - 1)
            print("Sliced name: \(String(fullName[..<endIndex]) + "…")")
            return String(fullName[..<endIndex]) + "…"
        }
        
        return fullName
    }
    
    private var spinButton: some View {
        Button(action: spinWheel) {
            HStack(spacing: 12) {
                Image(systemName: isSpinning ? "hourglass" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                LocalizedText(isSpinning ? "spinning" : "spin_the_wheel")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#F3A446"),
                        Color(hex: "#A06235")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(radius: 5)
            .scaleEffect(isSpinning ? 0.95 : 1.0)
        }
        .disabled(isSpinning || dishes.isEmpty)
        .animation(.easeInOut(duration: 0.1), value: isSpinning)
    }
    
    private func resultSection(dish: Dish) -> some View {
        VStack(spacing: 16) {
            LocalizedText("winner_celebration")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#F3A446"))
            
            Button(action: { showResult = true }) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: dish.thumbnail ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray4))
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getLocalizedTitle(for: dish))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        LocalizedText("tap_to_view_details")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                        .shadow(radius: 3)
                )
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Helper Methods
    
    private func loadDishes() {
        dishService.findRandom(limit: 7)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                
                if case .failure(let error) = completion {
                    print("Error loading dishes: \(error)")
                    // Fall back to sample data on error
                    dishes = Array(SampleData.sampleDishes.prefix(7))
                }
            } receiveValue: { receivedDishes in
                // If we got empty dishes, fall back to sample data
                dishes = receivedDishes.isEmpty ? Array(SampleData.sampleDishes.prefix(7)) : Array(receivedDishes)
            }
            .store(in: &cancellables)
    }
    
    private func refreshDishes() async {
        // Reset selected dish and spinning state when refreshing
        selectedDish = nil
        isSpinning = false
        
        await withCheckedContinuation { continuation in
            dishService.findRandom(limit: 7)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error refreshing dishes: \(error)")
                        // Fall back to sample data on error
                        dishes = Array(SampleData.sampleDishes.prefix(7))
                    }
                    continuation.resume()
                } receiveValue: { receivedDishes in
                    // If we got empty dishes, fall back to sample data
                    dishes = receivedDishes.isEmpty ? Array(SampleData.sampleDishes.prefix(7)) : Array(receivedDishes)
                }
                .store(in: &cancellables)
        }
    }
    
    private func spinWheel() {
        guard !dishes.isEmpty && !isSpinning else { return }
        
        isSpinning = true
        selectedDish = nil
        
        // Generate random spin (multiple full rotations + random angle)
        let randomSpins = Double.random(in: 3...6) * 360
        let randomAngle = Double.random(in: 0...360)
        rotationAngle += randomSpins + randomAngle
        
        // Calculate which dish was selected
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Normalize the final angle to 0-360 range
            let finalAngle = rotationAngle.truncatingRemainder(dividingBy: 360)
            
            // Calculate section angle
            let sectionAngle = 360.0 / Double(dishes.count)
            
            // Since the pointer is at the top (0 degrees) and sections start from 0 degrees,
            // we need to determine which section the pointer is pointing at
            // The wheel rotates clockwise, so we need to reverse the calculation
            let pointerAngle = (360 - finalAngle).truncatingRemainder(dividingBy: 360)
            
            // Add half section angle to ensure we're in the center of detection zone
            let adjustedAngle = (pointerAngle + (sectionAngle / 2)).truncatingRemainder(dividingBy: 360)
            
            // Calculate the selected index and adjust by +2
            var selectedIndex = (Int(adjustedAngle / sectionAngle) - 2) % dishes.count
            
            // Ensure the index is within bounds
            if selectedIndex < 0 {
                selectedIndex = dishes.count - 1
            } else if selectedIndex >= dishes.count {
                selectedIndex = selectedIndex % dishes.count
            }
            
            selectedDish = dishes[selectedIndex]
            isSpinning = false
            
            // Debug print to help verify the calculation
            print("Final angle: \(finalAngle)")
            print("Pointer angle: \(pointerAngle)")
            print("Adjusted angle: \(adjustedAngle)")
            print("Section angle: \(sectionAngle)")
            print("Selected index: \(selectedIndex)")
            print("Selected dish: \(getLocalizedTitle(for: dishes[selectedIndex]))")
        }
    }
    
    private func getLocalizedTitle(for dish: Dish) -> String {
        return MultiLanguage.getLocalizedData(
            from: dish.title,
            for: LocalizationService.shared.currentLanguage.rawValue
        ) ?? dish.slug
    }
}

// MARK: - Custom Shapes

struct WheelSection: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Rotated 180 degrees - triangle now points downward
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    WheelOfFortune()
        .environmentObject(ThemeManager())
}
