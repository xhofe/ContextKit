import ContextKitCore
import Foundation

@main
enum ContextKitHelperMain {
    static func main() {
        let delegate = ContextKitHelperListenerDelegate()
        let listener = NSXPCListener(machServiceName: ContextKitHelperConstants.machServiceName)
        listener.delegate = delegate
        listener.resume()
        RunLoop.main.run()
    }
}
