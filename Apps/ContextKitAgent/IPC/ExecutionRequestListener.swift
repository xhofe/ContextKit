import ContextKitCore
import Foundation

final class ExecutionRequestListener: NSObject {
    private let processor = RequestProcessor()
    private var timer: Timer?

    func start() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleRequestQueued),
            name: IPCNotification.requestQueued,
            object: nil
        )

        timer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(handlePeriodicSweep),
            userInfo: nil,
            repeats: true
        )
        processor.processPendingRequests()
    }

    @objc private func handleRequestQueued() {
        processor.processPendingRequests()
    }

    @objc private func handlePeriodicSweep() {
        processor.processPendingRequests()
    }
}
