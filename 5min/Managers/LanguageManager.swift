import Foundation
import SwiftUI
import ObjectiveC.runtime

// MARK: - Bundle swizzle (redirects ALL NSLocalizedString calls to chosen language)
private var _bundleKey: UInt8 = 0

private final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let override = objc_getAssociatedObject(self, &_bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return override.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func overrideLanguage(_ code: String) {
        let override: Bundle?
        if code.isEmpty {
            override = nil
        } else if let path = Bundle.main.path(forResource: code, ofType: "lproj") {
            override = Bundle(path: path)
        } else {
            override = nil
        }
        objc_setAssociatedObject(Bundle.main, &_bundleKey, override, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        object_setClass(Bundle.main, LocalizedBundle.self)
    }
}

// MARK: - App Language

enum AppLanguage: String, CaseIterable, Identifiable {
    case system  = ""
    case english = "en"
    case french  = "fr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:  return "Système / System"
        case .english: return "English 🇬🇧"
        case .french:  return "Français 🇫🇷"
        }
    }
}

// MARK: - Manager

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    /// Changing this triggers a full ContentView refresh via .id()
    @Published private(set) var refreshID = UUID()

    private(set) var selectedLanguage: AppLanguage

    private init() {
        let saved = UserDefaults.standard.string(forKey: "First5Language") ?? ""
        selectedLanguage = AppLanguage(rawValue: saved) ?? .system
        apply(selectedLanguage)
    }

    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "First5Language")
        apply(language)
        refreshID = UUID()
    }

    private func apply(_ language: AppLanguage) {
        Bundle.overrideLanguage(language.rawValue)
    }
}
