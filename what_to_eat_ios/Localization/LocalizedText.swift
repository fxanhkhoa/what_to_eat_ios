import SwiftUI
import Combine

struct LocalizedText: View {
    private var key: String
    private var arguments: [CVarArg]
    
    @ObservedObject private var localizationService = LocalizationObserver()
    
    init(_ key: String, _ arguments: CVarArg...) {
        self.key = key
        self.arguments = arguments
    }
    
    var body: some View {
        Text(String(format: key.localized, arguments: arguments))
    }
}

// Observer class to force view refresh when language changes
class LocalizationObserver: ObservableObject {
    @Published var currentLanguage: Language
    private var cancellable: AnyCancellable?
    
    init() {
        self.currentLanguage = LocalizationService.shared.currentLanguage
        self.cancellable = LocalizationService.shared.$currentLanguage.sink { [weak self] language in
            self?.currentLanguage = language
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

#Preview {
    VStack {
        LocalizedText("hello_world")
        LocalizedText("welcome_user", "John")
    }
}
