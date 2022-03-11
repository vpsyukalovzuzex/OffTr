//
// String+Common.swift
//

import Foundation

extension String {
    
    static var directory: String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    static var packages: String {
        return "Packages"
    }
}
