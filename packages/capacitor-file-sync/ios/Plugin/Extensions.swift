//
//  Extensions.swift
//  Ideamesh
//
//  Created by Mono Wang on 4/8/R4.
//

import Foundation
import CryptoKit

// via https://github.com/krzyzanowskim/CryptoSwift
extension Array where Element == UInt8 {
    public init(hex: String) {
        self = Array.init()
        self.reserveCapacity(hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
}

extension Data {
    public init?(hexEncoded: String) {
        self.init([UInt8](hex: hexEncoded))
    }

    var hexDescription: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var MD5: String {
        let computed = Insecure.MD5.hash(data: self)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }

    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

    func fnameEncrypt(rawKey: Data) -> String? {
        guard !self.isEmpty else {
            return nil
        }
        guard let raw = self.precomposedStringWithCanonicalMapping.data(using: .utf8) else {
            return nil
        }

        let key = SymmetricKey(data: rawKey)
        let nonce = try! ChaChaPoly.Nonce(data: Data(repeating: 0, count: 12))
        guard let sealed = try? ChaChaPoly.seal(raw, using: key, nonce: nonce) else { return nil }

        // strip nonce here, since it's all zero
        return "e." + (sealed.ciphertext + sealed.tag).hexDescription

    }

    func fnameDecrypt(rawKey: Data) -> String? {
        // well-formated, non-empty encrypted string
        guard self.hasPrefix("e.") && self.count > 36 else {
            return nil
        }

        let encryptedHex = self.suffix(from: self.index(self.startIndex, offsetBy: 2))
        guard let encryptedRaw = Data(hexEncoded: String(encryptedHex)) else {
            // invalid hex
            return nil
        }

        let key = SymmetricKey(data: rawKey)
        let nonce = Data(repeating: 0, count: 12)

        guard let sealed = try? ChaChaPoly.SealedBox(combined: nonce + encryptedRaw) else {
            return nil
        }
        guard let outputRaw = try? ChaChaPoly.open(sealed, using: key) else {
            return nil
        }
        return String(data: outputRaw, encoding: .utf8)?.precomposedStringWithCanonicalMapping
    }
}

extension URL {
    func relativePath(from base: URL) -> String? {
        // Ensure that both URLs represent files:
        guard self.isFileURL && base.isFileURL else {
            return nil
        }

        // Remove/replace "." and "..", make paths absolute:
        let destComponents = self.standardizedFileURL.pathComponents
        let baseComponents = base.standardizedFileURL.pathComponents

        // Find number of common path components:
        var i = 0
        while i < destComponents.count && i < baseComponents.count
                && destComponents[i] == baseComponents[i] {
            i += 1
        }

        // Build relative path:
        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        return relComponents.joined(separator: "/")
    }

    func ensureParentDir() {
        let dirURL = self.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
    }

    func writeData(data: Data) throws {
        self.ensureParentDir()
        if FileManager.default.fileExists(atPath: self.path) {
            try FileManager.default.removeItem(at: self)
        }
        try data.write(to: self, options: .atomic)
    }

    func isICloudPlaceholder() -> Bool {
        if self.lastPathComponent.starts(with: ".") && self.pathExtension.lowercased() == "icloud" {
            return true
        }
        return false
    }

    func isSkipSync() -> Bool {
        // skip hidden file
        if self.lastPathComponent.starts(with: ".") {
            return true
        }
        if self.absoluteString.contains("/ideamesh/bak/") || self.absoluteString.contains("/ideamesh/version-files/") {
            return true
        }
        if self.lastPathComponent == "graphs-txid.edn" || self.lastPathComponent == "broken-config.edn" {
            return true
        }
        return false
    }
}
