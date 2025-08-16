import SwiftUI
import Combine
import Foundation

enum GameState {
    case notStarted
    case playing
    case completed
}

struct GameCard: Identifiable, Equatable {
    let id = UUID()
    let dish: Dish
    var isFlipped: Bool = false
    
    static func == (lhs: GameCard, rhs: GameCard) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class FlippingCardViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var selectedDishes: [Dish] = [] // New: User-selected dishes
    @Published var cards: [GameCard] = []
    @Published var gameState: GameState = .notStarted
    @Published var isLoading = false
    @Published var selectedDish: Dish?
    @Published var errorMessage: String?
    
    private let dishService = DishService()
    private var cancellables = Set<AnyCancellable>()
    
    // Game configuration
    private let numberOfCards = 12 // 3x4 grid of cards
    
    // MARK: - Public Methods
    
    func loadDishes() {
        guard !isLoading else { return }
        
        if selectedDishes.isEmpty {
            // Load random dishes if no dishes are selected
            isLoading = true
            
            dishService.findRandom(limit: numberOfCards)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            self?.handleError(error)
                        }
                    },
                    receiveValue: { [weak self] dishes in
                        self?.dishes = dishes
                        self?.selectedDishes = dishes // Sync with selected dishes
                        self?.setupGame()
                    }
                )
                .store(in: &cancellables)
        } else {
            // Use selected dishes
            dishes = selectedDishes
            setupGame()
        }
    }
    
    func updateSelectedDishes(_ newDishes: [Dish]) {
        selectedDishes = newDishes
        dishes = newDishes
        resetGame()
        if !newDishes.isEmpty {
            setupGame()
        }
    }
    
    func removeDishFromGame(_ dish: Dish) {
        selectedDishes.removeAll { $0.id == dish.id }
        updateSelectedDishes(selectedDishes)
    }
    
    func cardTapped(_ card: GameCard) {
        guard gameState == .playing, !card.isFlipped else {
            return
        }
        
        // Flip the selected card
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFlipped = true
            selectedDish = card.dish
            gameState = .completed
        }
    }
    
    func startNewGame() {
        resetGame()
        loadDishes()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func setupGame() {
        guard dishes.count >= numberOfCards else {
            if dishes.isEmpty {
                errorMessage = nil // Don't show error for empty selection
            } else {
                errorMessage = "Not enough dishes to start the game"
            }
            return
        }
        
        // Create cards for each dish
        cards = dishes.prefix(numberOfCards).map { dish in
            GameCard(dish: dish, isFlipped: false)
        }
        
        // Shuffle the cards
        cards.shuffle()
        
        gameState = .playing
    }
    
    private func resetGame() {
        selectedDish = nil
        gameState = .notStarted
        cards.removeAll()
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? URLError {
            switch networkError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection"
            case .timedOut:
                errorMessage = "Request timed out"
            default:
                errorMessage = "Network error: \(networkError.localizedDescription)"
            }
        } else {
            errorMessage = "Failed to load dishes: \(error.localizedDescription)"
        }
        print("FlippingCardViewModel Error: \(error)")
    }
}
