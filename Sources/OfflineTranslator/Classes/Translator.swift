//
// Translator.swift
//

import Foundation

#if os(macOS)
import LingvanexCTranslate2_macOS
#endif

class Translator {
    
    private let lingvanexCTranslate2 = LingvanexCTranslate2()
    
    // MARK: - Internal init
    
    init(fromCode: String, toCode: String, path: String) {
        lingvanexCTranslate2?.setup(
            withPath: path,
            fromCode: fromCode,
            toCode: toCode
        )
    }
    
    // MARK: - Internal func
    
    func translate(with string: String) -> String {
        return lingvanexCTranslate2?.translated(with: string) ?? string
    }
}
