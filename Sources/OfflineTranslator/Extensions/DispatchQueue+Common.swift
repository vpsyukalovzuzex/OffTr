//
// DispatchQueue+Common.swift
//

import Foundation

extension DispatchQueue {
    
    static let package = DispatchQueue(label: "package", qos: .background)
}
