//
// Language.swift
//

import Foundation

public class Language: Equatable {
    
    // MARK: - Public static var
    
    public static var available: [Language] {
        var result = Package.packages.compactMap { package -> Language? in
            if package.isInstalled, let code = package.code {
                return Language(code: code)
            }
            return nil
        }
        result.append(Language(code: String.englishCode))
        return result
    }
    
    // MARK: - Public let
    
    public let code: String
    
    // MARK: - Internal var
    
    var isEnglish: Bool {
        return code == String.englishCode
    }
    
    var languageToEnglishPath: String {
        return path(with: "\(code)_\(String.englishCode)")
    }
    
    var englishToLanguagePath: String {
        return path(with: "\(String.englishCode)_\(code)")
    }
    
    // MARK: - Public init
    
    public init(code: String) {
        self.code = code
    }
    
    // MARK: - Private func
    
    private func path(with folder: String) -> String {
        guard let directory = String.directory else {
            return ""
        }
        return directory + "/" + String.packages + "/" + folder + "/1"
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.code == rhs.code
    }
}
