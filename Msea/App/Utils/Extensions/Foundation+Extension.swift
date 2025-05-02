//
//  Foundation+Extension.swift
//  Msea
//
//  Created by Awro on 2022/1/30.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension FileManager {
    func getCacheSize() -> String {
        var totalSize = 0.00
        if let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
           let files = FileManager.default.subpaths(atPath: cachePath) {
            var size = 0
            for file in files {
                let path = cachePath + "/\(file)"
                print(path)
                do {
                    let floder = try FileManager.default.attributesOfItem(atPath: path)
                    for (key, fileSize) in floder where key == FileAttributeKey.size {
                        size += (fileSize as AnyObject).integerValue
                    }
                } catch {
                    print("文件异常！")
                }
            }
            totalSize = Double(size) / 1024.0 / 1024.0
        }

        let tempPath = NSTemporaryDirectory()
        if let files = FileManager.default.subpaths(atPath: tempPath) {
            var size = 0
            for file in files {
                let path = tempPath + "\(file)"
                print(path)
                do {
                    let floder = try FileManager.default.attributesOfItem(atPath: path)
                    for (key, fileSize) in floder where key == FileAttributeKey.size {
                        size += (fileSize as AnyObject).integerValue
                    }
                } catch {
                    print("文件异常！")
                }
            }
            totalSize += Double(size) / 1024.0 / 1024.0
        }

        return String(format: "%.2fM", totalSize)
    }

    func cleanCache() {
        if let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
           let files = FileManager.default.subpaths(atPath: cachePath) {
            for file in files {
                let path = cachePath + "/\(file)"
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch {
                        print("文件异常！")
                    }
                }
            }
        }

        let tempPath = NSTemporaryDirectory()
        if let files = FileManager.default.subpaths(atPath: tempPath) {
            for file in files {
                let path = tempPath + "\(file)"
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch {
                        print("文件异常！")
                    }
                }
            }
        }
    }
}
