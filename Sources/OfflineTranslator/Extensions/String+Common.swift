//
// String+Common.swift
//

import Foundation

public extension String {
    
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
    
    func translate(
        fromLanguage: Language,
        toLanguage: Language,
        _ block: @escaping TranslateBlock
    ) {
        let offlineTranslator = OfflineTranslator.shared
//        offlineTranslator = 
    }
}

