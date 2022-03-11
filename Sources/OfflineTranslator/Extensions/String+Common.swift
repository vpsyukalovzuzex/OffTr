//
// String+Common.swift
//

import Foundation

public extension String {
    
    // MARK: - Public func
    
    func translate(
        fromLanguage: Language,
        toLanguage: Language,
        _ block: @escaping OfflineTranslator.TranslateBlock
    ) {
        let offlineTranslator = OfflineTranslator.shared
        offlineTranslator.setup(fromLanguage, toLanguage)
        offlineTranslator.translate(self, block)
    }
    
    // MARK: - Internal static var
    
    internal static var directory: String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    internal static var packages: String {
        return "Packages"
    }
    
    internal static var englishCode: String {
        return "en"
    }
}
