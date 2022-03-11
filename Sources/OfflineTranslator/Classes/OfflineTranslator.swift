//
// OfflineTranslator.swift
//

import Foundation

public class OfflineTranslator {
    
    // MARK: - Public typealias
    
    public typealias TranslateBlock = (Result<String, Error>) -> Void
    
    // MARK: - Public static let
    
    public static let shared = OfflineTranslator()
    
    // MARK: - Private var
    
    private var fromLanguage: Language?
    private var toLanguage: Language?
    
    private var translatorA: Translator?
    private var translatorB: Translator?
    
    // MARK: - Public func
    
    public func setup(
        _ fromLanguage: Language,
        _ toLanguage: Language
    ) {
        DispatchQueue.offlineTranslator.async { [weak self] in
            guard let self = self else {
                return
            }
            let available = Language.available
            guard
                available.contains(fromLanguage),
                available.contains(toLanguage)
            else {
                self.translatorA = nil
                self.translatorB = nil
                return
            }
            switch (fromLanguage.isEnglish, toLanguage.isEnglish) {
            case (true, true):
                self.translatorA = nil
                self.translatorB = nil
                return
            case (true, false):
                guard self.toLanguage != toLanguage else {
                    break
                }
                self.translatorA = Translator(
                    fromCode: String.englishCode,
                    toCode: toLanguage.code,
                    path: toLanguage.englishToLanguagePath
                )
                self.translatorB = nil
            case (false, true):
                guard self.fromLanguage != fromLanguage else {
                    break
                }
                self.translatorA = Translator(
                    fromCode: fromLanguage.code,
                    toCode: String.englishCode,
                    path: fromLanguage.languageToEnglishPath
                )
                self.translatorB = nil
            case (false, false):
                guard
                    self.fromLanguage != fromLanguage,
                    self.toLanguage != toLanguage
                else {
                    break
                }
                self.translatorA = Translator(
                    fromCode: fromLanguage.code,
                    toCode: String.englishCode,
                    path: fromLanguage.languageToEnglishPath
                )
                self.translatorB = Translator(
                    fromCode: String.englishCode,
                    toCode: toLanguage.code,
                    path: toLanguage.englishToLanguagePath
                )
            }
            self.fromLanguage = fromLanguage
            self.toLanguage = toLanguage
        }
    }
    
    public func translate(
        _ string: String,
        _ block: @escaping TranslateBlock
    ) {
        DispatchQueue.offlineTranslator.async { [weak self] in
            guard let self = self else {
                return
            }
            do {
                if string.isEmpty {
                    throw OfflineTranslatorError.emptyString
                }
                let resultA = self.translatorA?.translate(with: string) ?? string
                let resultB = self.translatorB?.translate(with: resultA) ?? resultA
                block(.success(resultB))
            } catch let error {
                block(.failure(error))
            }
        }
    }
}
