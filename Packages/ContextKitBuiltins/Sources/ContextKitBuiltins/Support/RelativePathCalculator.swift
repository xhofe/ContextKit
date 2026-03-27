import Foundation

struct RelativePathCalculator {
    func relativePaths(for urls: [URL], within rootURL: URL) throws -> [String] {
        let standardizedRoot = rootURL.standardizedFileURL
        return try urls.map { url in
            let standardizedURL = url.standardizedFileURL
            guard standardizedURL.path.hasPrefix(standardizedRoot.path) else {
                throw RelativePathError.outsideRoot(url)
            }

            let path = standardizedURL.path.replacingOccurrences(of: standardizedRoot.path + "/", with: "")
            return path.isEmpty ? standardizedURL.lastPathComponent : path
        }
    }
}

enum RelativePathError: LocalizedError {
    case outsideRoot(URL)

    var errorDescription: String? {
        switch self {
        case let .outsideRoot(url):
            return "\(url.lastPathComponent) is outside the monitored root."
        }
    }
}
