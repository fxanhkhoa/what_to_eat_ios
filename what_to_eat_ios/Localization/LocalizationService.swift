import Foundation
import Combine

class LocalizationService {
    static let shared = LocalizationService()
    
    @Published var currentLanguage: Language = {
        if let languageCode = UserDefaults.standard.string(forKey: "AppLanguage") {
            return Language(rawValue: languageCode) ?? .english
        } else {
            // Get system language if possible
            let preferredLanguage = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
            return Language(rawValue: String(preferredLanguage)) ?? .english
        }
    }()
    
    private init() {}

    func setLanguage(_ language: Language) {
        self.currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
        // Force refresh notification
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    func localizedString(for key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? Bundle.main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
    }
}

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case vietnamese = "vi"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .vietnamese: return "Tiếng Việt"
        }
    }
}

// Extension for String to make it easy to localize any string
extension String {
    var localized: String {
        return LocalizationService.shared.localizedString(for: self)
    }
}
