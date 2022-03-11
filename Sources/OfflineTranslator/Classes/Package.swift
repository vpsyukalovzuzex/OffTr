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
        
        case id, zip, version, folders
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
    
    public let id: String
    
    public let zip: String
    
    public let version: Int
    
    // MARK: - Private var
    
    private var folders: [String]?
    
    // MARK: - Public init
    
    public init(id: String, zip: String, version: Int) {
        self.id = id
        self.zip = zip
        self.version = version
    }
    
    // MARK: - Public func
    
    public func install(_ block: InstallBlock? = nil) throws {
        guard Package.installed.firstIndex(of: self) == nil else {
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
                    let atPath = temporary + "/" + folder
                    let toPath = packages + "/" + folder
                    try? fileManager.removeItem(atPath: toPath)
                    try fileManager.moveItem(
                        atPath: atPath,
                        toPath: toPath
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
        self.id = try container.decode(String.self, forKey: .id)
        self.zip = try container.decode(String.self, forKey: .zip)
        self.version = try container.decode(Int.self, forKey: .version)
        self.folders = try container.decode([String]?.self, forKey: .folders)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(id, forKey: .id)
        try container.encode(zip, forKey: .zip)
        try container.encode(version, forKey: .version)
        try container.encode(folders, forKey: .folders)
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Package, rhs: Package) -> Bool {
        return lhs.id == rhs.id && lhs.version == rhs.version
    }
}
