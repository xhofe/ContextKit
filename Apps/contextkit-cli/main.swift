import Darwin
import ContextKitCore
import Foundation

let environment = CLIEnvironment()
let printer = ConsolePrinter()
let arguments = Array(CommandLine.arguments.dropFirst())

func run() throws {
    guard let command = arguments.first else {
        throw CLIError.usage("""
        contextkit run <action-id> <path...>
        contextkit workflow run <workflow-id> <path...>
        contextkit plugin install <local-path|git-url>
        contextkit plugin list
        contextkit logs tail
        """)
    }

    switch command {
    case "run":
        let result = try RunActionCommand(environment: environment).execute(arguments: arguments.dropFirst())
        printer.printResult(result)
    case "workflow":
        guard arguments.dropFirst().first == "run" else {
            throw CLIError.usage("contextkit workflow run <workflow-id> <path...>")
        }
        let result = try RunWorkflowCommand(environment: environment).execute(arguments: arguments.dropFirst(2))
        printer.printResult(result)
    case "plugin":
        guard let subcommand = arguments.dropFirst().first else {
            throw CLIError.usage("contextkit plugin <install|list>")
        }
        switch subcommand {
        case "install":
            let plugin = try InstallPluginCommand(environment: environment).execute(arguments: arguments.dropFirst(2))
            Swift.print(L10n.string("cli.install.success", fallback: "Installed %@.", plugin.package.manifest.name))
        case "list":
            let plugins = try ListPluginsCommand(environment: environment).execute()
            printer.printPlugins(plugins)
        default:
            throw CLIError.usage("contextkit plugin <install|list>")
        }
    case "logs":
        guard arguments.dropFirst().first == "tail" else {
            throw CLIError.usage("contextkit logs tail")
        }
        let logs = try TailLogsCommand(environment: environment).execute()
        printer.printLogs(logs)
    default:
        throw CLIError.usage(L10n.string("cli.unknownCommand", fallback: "Unknown command %@", command))
    }
}

do {
    try run()
} catch {
    printer.printError(error)
    exit(1)
}
