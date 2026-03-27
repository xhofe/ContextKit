import CryptoKit
import Foundation

struct FileHasher {
    func md5(for url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }

    func sha256(for url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        return SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
}
