import UIKit

class LocalizationManager {
    
    static func localizedString(key: LocKey) -> String {
        return NSLocalizedString(key.rawValue, comment: "")
    }
}

func Localized(_ key: LocKey) -> String {
    return LocalizationManager.localizedString(key: key)
}
