import Foundation

public enum PluginEnvironment {
    public static let requestID = "CONTEXTKIT_REQUEST_ID"
    public static let selectedURLsJSON = "CONTEXTKIT_SELECTED_URLS_JSON"
    public static let monitoredRootPath = "CONTEXTKIT_MONITORED_ROOT_PATH"
    public static let invocationSource = "CONTEXTKIT_INVOCATION_SOURCE"
    public static let previousClipboardText = "CONTEXTKIT_PREVIOUS_TEXT"
    public static let previousStructuredPayloadJSON = "CONTEXTKIT_PREVIOUS_STRUCTURED_PAYLOAD_JSON"
}
