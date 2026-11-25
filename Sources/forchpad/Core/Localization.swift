import Foundation

/// One row of the language popup: an lproj code, or nil for "follow the system".
struct LanguageChoice {
    let code: String?
    let name: String   // endonym, never translated
}

/// Languages this app ships, in the order they appear in the popup.
let languageChoices: [LanguageChoice] = [
    LanguageChoice(code: nil, name: ""),   // the system entry; its name comes from L("System language")
    LanguageChoice(code: "en", name: "English"),
    LanguageChoice(code: "zh-Hans", name: "简体中文"),
    LanguageChoice(code: "zh-Hant", name: "繁體中文"),
    LanguageChoice(code: "ja", name: "日本語"),
    LanguageChoice(code: "ko", name: "한국어"),
    LanguageChoice(code: "fr", name: "Français"),
    LanguageChoice(code: "es", name: "Español"),
    LanguageChoice(code: "ar", name: "العربية"),
]

/// Per-language bundles, loaded on demand so a manual choice works without relaunching.
private var bundleCache: [String: Bundle] = [:]

func bundleForLanguage(_ code: String) -> Bundle? {
    if let cached = bundleCache[code] { return cached }
    guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
          let bundle = Bundle(path: path) else { return nil }
    bundleCache[code] = bundle
    return bundle
}

/// Looks up a window/menu string. Keys are the English words, so a bare binary with no
/// bundle still reads fine. A manual language choice wins; anything unsupported falls back
/// to the bundle's own resolution (development region: English).
func L(_ key: String) -> String {
    if let code = settings.languageOverride {
        let bundle = bundleForLanguage(code) ?? bundleForLanguage("en")
        return bundle?.localizedString(forKey: key, value: key, table: nil) ?? key
    }
    return Bundle.main.localizedString(forKey: key, value: key, table: nil)
}
