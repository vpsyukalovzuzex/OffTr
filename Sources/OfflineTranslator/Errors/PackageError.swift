//
// PackageError.swift
//

import Foundation

public enum PackageError: Error {
    
    case versionAlreadyInstalled
    case canNotFindZip
    case canNotFindCachesDirectory
    case wrongUrlString(_ urlString: String)
    case foldersDoNotExist
}
