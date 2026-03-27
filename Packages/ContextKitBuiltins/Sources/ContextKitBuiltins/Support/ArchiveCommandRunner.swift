import Foundation
import ContextKitCore

struct ArchiveCommandRunner {
    private let processRunner = ProcessRunner()

    func zip(inputURLs: [URL], outputURL: URL) throws {
        let output = try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/zip"),
            arguments: ["-r", outputURL.path] + inputURLs.map(\.lastPathComponent),
            currentDirectoryURL: inputURLs.first?.deletingLastPathComponent()
        )

        guard output.terminationStatus == 0 else {
            throw ArchiveError.failed(output.standardError)
        }
    }

    func unzip(inputURL: URL, outputDirectoryURL: URL) throws {
        let output = try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/unzip"),
            arguments: [inputURL.path, "-d", outputDirectoryURL.path]
        )

        guard output.terminationStatus == 0 else {
            throw ArchiveError.failed(output.standardError)
        }
    }
}

enum ArchiveError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case let .failed(message):
            return message.isEmpty ? "Archive command failed." : message
        }
    }
}
