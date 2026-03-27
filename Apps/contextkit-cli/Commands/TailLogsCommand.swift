import ContextKitCore
import Foundation

struct TailLogsCommand {
    let environment: CLIEnvironment

    func execute(limit: Int = 20) throws -> [ExecutionLogEntry] {
        Array(try environment.logStore.load().prefix(limit))
    }
}
