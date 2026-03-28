import Foundation

@objc public protocol ContextKitFinderServiceProtocol {
    func ping(withReply reply: @escaping (Bool) -> Void)
    func observedRoots(withReply reply: @escaping (Data?, String?) -> Void)
    func menu(for requestData: Data, withReply reply: @escaping (Data?, String?) -> Void)
    func execute(_ requestData: Data, withReply reply: @escaping (Data?, String?) -> Void)
}
