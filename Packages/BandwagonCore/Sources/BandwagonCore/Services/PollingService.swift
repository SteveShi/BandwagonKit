import Foundation
import Observation

/// 定时自动轮询服务
@Observable
public final class PollingService: @unchecked Sendable {
    public var intervalSeconds: TimeInterval = 30
    public var isEnabled: Bool = true
    public private(set) var isPolling: Bool = false

    private var pollingTask: Task<Void, Never>?

    public init(intervalSeconds: TimeInterval = 30, isEnabled: Bool = true) {
        self.intervalSeconds = intervalSeconds
        self.isEnabled = isEnabled
    }

    public func startPolling(with manager: VPSManager) {
        stopPolling()
        guard isEnabled && intervalSeconds > 0 else { return }

        isPolling = true
        pollingTask = Task { [weak manager, intervalSeconds] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
                } catch {
                    break
                }
                guard !Task.isCancelled, let manager else { break }
                await manager.refreshLiveInfo()
            }
        }
    }

    public func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        isPolling = false
    }

    deinit {
        stopPolling()
    }
}
