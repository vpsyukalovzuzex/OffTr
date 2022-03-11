//
// Language.swift
//

import Foundation

public class Language {
    
    public static var available: [Language] {
        return Package.packages.compactMap {
            if let code = $0.code {
                return Language(code: code)
            }
            return nil
        }
    }
    
    public let code: String
    
    public var languageToEnglishPath: String? {
        return path(with: "\(code)_en")
    }
    
    public var englishToLanguagePath: String? {
        return path(with: "en_\(code)")
    }
    
    public init(code: String) {
        self.code = code
    }
    
    private func path(with folder: String) -> String? {
        guard let directory = String.directory else {
            return nil
        }
        return directory + "/" + String.packages + "/" + folder + "/1"
    }
}
