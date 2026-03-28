import ContextKitCore
import Darwin
import Foundation

enum ContextKitHelperRegistrationStatus {
    case ready
    case unavailable(String)

    var message: String {
        switch self {
        case .ready:
            return "Finder helper is ready."
        case let .unavailable(message):
            return message
        }
    }
}

@MainActor
final class ContextKitHelperRegistrationController {
    private let fileManager: FileManager
    private let processRunner: ProcessRunner
    private let helperClient: ContextKitHelperClient

    init(
        fileManager: FileManager = .default,
        processRunner: ProcessRunner = ProcessRunner(),
        helperClient: ContextKitHelperClient = ContextKitHelperClient(timeout: 1.0)
    ) {
        self.fileManager = fileManager
        self.processRunner = processRunner
        self.helperClient = helperClient
    }

    func ensureRegistered(bundle: Bundle = .main) throws {
        let helperURL = try helperExecutableURL(bundle: bundle)
        let launchAgentURL = try launchAgentPlistURL()
        let desiredContents = launchAgentContents(helperURL: helperURL)
        let existingContents = try? String(contentsOf: launchAgentURL, encoding: .utf8)

        if existingContents != desiredContents {
            try fileManager.createDirectory(
                at: launchAgentURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try desiredContents.write(to: launchAgentURL, atomically: true, encoding: .utf8)
            unloadLaunchAgent(at: launchAgentURL)
        }

        if helperClient.ping() {
            return
        }

        let output = try processRunner.run(
            executableURL: URL(fileURLWithPath: "/bin/launchctl"),
            arguments: ["bootstrap", "gui/\(getuid())", launchAgentURL.path]
        )

        if output.terminationStatus != 0 &&
            !output.standardError.localizedCaseInsensitiveContains("already bootstrapped") &&
            !output.standardError.localizedCaseInsensitiveContains("service already loaded") {
            throw NSError(
                domain: "ContextKitHelperRegistration",
                code: Int(output.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: output.standardError.isEmpty ? output.standardOutput : output.standardError]
            )
        }
    }

    func status(bundle: Bundle = .main) -> ContextKitHelperRegistrationStatus {
        do {
            try ensureRegistered(bundle: bundle)
            return helperClient.ping() ? .ready : .unavailable("Finder helper is registered but not reachable.")
        } catch {
            return .unavailable(error.localizedDescription)
        }
    }

    private func helperExecutableURL(bundle: Bundle) throws -> URL {
        let candidates = [
            bundle.bundleURL.appending(path: "Contents/Helpers/\(ContextKitHelperConstants.helperExecutableName)"),
            bundle.bundleURL.deletingLastPathComponent().appending(path: ContextKitHelperConstants.helperExecutableName),
        ]

        if let url = candidates.first(where: { fileManager.fileExists(atPath: $0.path) }) {
            return url
        }

        throw NSError(
            domain: "ContextKitHelperRegistration",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "ContextKit helper executable is missing."]
        )
    }

    private func launchAgentPlistURL() throws -> URL {
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let directory = homeDirectory.appending(path: "Library/LaunchAgents", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appending(path: ContextKitHelperConstants.launchAgentPlistName)
    }

    private func unloadLaunchAgent(at launchAgentURL: URL) {
        _ = try? processRunner.run(
            executableURL: URL(fileURLWithPath: "/bin/launchctl"),
            arguments: ["bootout", "gui/\(getuid())", launchAgentURL.path]
        )
    }

    private func launchAgentContents(helperURL: URL) -> String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(ContextKitHelperConstants.launchAgentLabel)</string>
            <key>MachServices</key>
            <dict>
                <key>\(ContextKitHelperConstants.machServiceName)</key>
                <true/>
            </dict>
            <key>ProgramArguments</key>
            <array>
                <string>\(helperURL.path)</string>
            </array>
            <key>ProcessType</key>
            <string>Background</string>
        </dict>
        </plist>
        """
    }
}
