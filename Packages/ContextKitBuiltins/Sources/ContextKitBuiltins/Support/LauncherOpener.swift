import Foundation
import ContextKitCore

struct LauncherOpener {
    private let processRunner = ProcessRunner()

    func open(_ urls: [URL], with launcher: AppLauncher) throws {
        var arguments: [String] = []
        if let bundleIdentifier = launcher.bundleIdentifier {
            arguments += ["-b", bundleIdentifier]
        } else {
            arguments += ["-a", launcher.name]
        }
        arguments += urls.map(\.path)

        let output = try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/open"),
            arguments: arguments
        )

        guard output.terminationStatus == 0 else {
            throw OpenApplicationError.failed(output.standardError)
        }
    }
}

enum OpenApplicationError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case let .failed(message):
            return message.isEmpty ? "Failed to open application." : message
        }
    }
}
