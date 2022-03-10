//
// Package.swift
//

import Foundation
import Zip

public class Package: Codable, Equatable {
    
    // MARK: - Public typealia
    
    public typealias InstallBlock = (Error?) -> Void
    public typealias UninstallBlock = (Error?) -> Void
    
    // MARK: - Private enum
    
    private enum Key: CodingKey {
        
        case zip, version, folders
    }
    
    // MARK: - Public static var
    
    public static var installed: [Package] {
        return (try? UserDefaults.standard.get([Package].self, key)) ?? []
    }
    
    // MARK: - Private static var
    
    private static var key: String {
        return "installed"
    }
    
    // MARK: - Public let
    
    public let zip: String
    
    public let version: Int
    
    // MARK: - Private var
    
    private var folders: [String]?
        
    // MARK: - Public init
    
    public init(zip: String, version: Int) {
        self.zip = zip
        self.version = version
    }
    
    // MARK: - Public func
    
    public func install(_ block: InstallBlock? = nil) throws {
        guard Package.installed.filter({ $0 == self }).isEmpty else {
            throw PackageError.versionAlreadyInstalled
        }
        guard let path = Bundle.main.path(forResource: zip, ofType: "zip") else {
            throw PackageError.canNotFindZip
        }
        guard let file = URL(string: path) else {
            throw PackageError.wrongUrlString(path)
        }
        guard let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            throw PackageError.canNotFindCachesDirectory
        }
        let uuid = UUID().uuidString
        let packages = directory + "/Packages"
        let temporary = packages + "/" + uuid
        guard let destination = URL(string: temporary) else {
            throw PackageError.wrongUrlString(temporary)
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }
            do {
                try Zip.unzipFile(
                    file,
                    destination: destination,
                    overwrite: true,
                    password: nil,
                    progress: nil,
                    fileOutputHandler: nil
                )
                let fileManager = FileManager()
                let folders = try fileManager.contentsOfDirectory(atPath: temporary)
                for folder in folders {
                    try fileManager.moveItem(
                        atPath: temporary + "/" + folder,
                        toPath: packages + "/" + folder
                    )
                }
                try fileManager.removeItem(atPath: temporary)
                self.folders = folders
                var installed = Package.installed
                installed.append(self)
                try UserDefaults.standard.set(installed, Package.key)
                block?(nil)
            } catch let error {
                block?(error)
            }
        }
    }
    
    public func uninstall(_ block: UninstallBlock? = nil) throws {
        guard let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            throw PackageError.canNotFindCachesDirectory
        }
        guard let folders = folders else {
            throw PackageError.foldersDoNotExist
        }
        let fileManager = FileManager.default
        for folder in folders {
            try fileManager.removeItem(atPath: directory + "/Packages/" + folder)
        }
        var installed = Package.installed
        if let index = installed.firstIndex(of: self) {
            installed.remove(at: index)
            try UserDefaults.standard.set(installed, Package.key)
        }
    }
    
    // MARK: - Codable
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.zip = try container.decode(String.self, forKey: .zip)
        self.version = try container.decode(Int.self, forKey: .version)
        self.folders = try container.decode([String]?.self, forKey: .folders)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(zip, forKey: .zip)
        try container.encode(version, forKey: .version)
        try container.encode(folders, forKey: .folders)
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Package, rhs: Package) -> Bool {
        let result = lhs.version == rhs.version
        guard
            let lhsFolders = lhs.folders,
            let rhsFolders = rhs.folders
        else {
            return result
        }
        return result && lhsFolders.elementsEqual(rhsFolders) { $0 == $1 }
    }
}
