import Foundation

/// KiwiVM API 客户端
public actor BWGClient {
    public let veid: String
    public let apiKey: String
    public let baseURL: URL
    private let session: URLSession
    private let jsonDecoder: JSONDecoder

    /// 最小请求间隔保护（毫秒），防止并发密集请求导致搬瓦工暂停 API
    private var lastRequestTime: Date = .distantPast
    private let minRequestInterval: TimeInterval = 0.15 // 150ms

    public init(
        veid: String,
        apiKey: String,
        baseURL: URL = URL(string: "https://api.64clouds.com/v1/")!,
        session: URLSession? = nil
    ) {
        self.veid = veid.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.baseURL = baseURL
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.ephemeral
            config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            config.urlCache = nil
            self.session = URLSession(configuration: config)
        }
        self.jsonDecoder = JSONDecoder()
    }

    /// 发起 API 请求并解码响应
    public func request<T: Decodable>(_ endpoint: BWGEndpoint) async throws -> T {
        // 请求速率限制保护
        let elapsed = Date().timeIntervalSince(lastRequestTime)
        if elapsed < minRequestInterval {
            try await Task.sleep(nanoseconds: UInt64((minRequestInterval - elapsed) * 1_000_000_000))
        }
        lastRequestTime = Date()

        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw BWGError.invalidURL
        }

        // 构建通用参数
        var queryItems = [
            URLQueryItem(name: "veid", value: veid),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        for (k, v) in endpoint.parameters {
            queryItems.append(URLQueryItem(name: k, value: v))
        }

        var urlRequest: URLRequest
        if endpoint.method == .get {
            components.queryItems = queryItems
            guard let finalURL = components.url else {
                throw BWGError.invalidURL
            }
            urlRequest = URLRequest(url: finalURL)
            urlRequest.httpMethod = "GET"
        } else {
            // POST 请求也可以将 veid/api_key 带在 Query 中，同时将参数放 Body 或 Query
            // KiwiVM 支持通过 URL Query 传递参数，也支持 application/x-www-form-urlencoded
            components.queryItems = queryItems
            guard let finalURL = components.url else {
                throw BWGError.invalidURL
            }
            urlRequest = URLRequest(url: finalURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.timeoutInterval = 20
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw BWGError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BWGError.unknown
        }

        if httpResponse.statusCode == 429 {
            throw BWGError.rateLimited(resetTimestamp: nil)
        }

        // 先检查是否有 error 字段
        if let baseResponse = try? jsonDecoder.decode(BWGAPIResponse.self, from: data) {
            if !baseResponse.isSuccess {
                let msg = baseResponse.message ?? "Unknown API error"
                if baseResponse.error == 700001 || baseResponse.error == 700002 || msg.lowercased().contains("veid") || msg.lowercased().contains("key") {
                    throw BWGError.invalidCredentials
                }
                throw BWGError.apiError(code: baseResponse.error, message: msg)
            }
        }

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            let bodyString = String(data: data, encoding: .utf8) ?? "<binary>"
            throw BWGError.decodingError("Decoding \(T.self) failed: \(error.localizedDescription). Payload: \(bodyString)")
        }
    }

    // MARK: - Convenience Methods

    public func getServiceInfo() async throws -> BWGServiceInfo {
        try await request(.getServiceInfo)
    }

    public func getLiveServiceInfo() async throws -> BWGLiveServiceInfo {
        try await request(.getLiveServiceInfo)
    }

    public func getAvailableOS() async throws -> BWGAvailableOS {
        try await request(.getAvailableOS)
    }

    public func getRateLimitStatus() async throws -> BWGRateLimitStatus {
        try await request(.getRateLimitStatus)
    }

    public func getSuspensionDetail() async throws -> BWGSuspensionDetail {
        try await request(.getSuspensionDetail)
    }

    public func getAuditLog() async throws -> BWGAuditLogResponse {
        try await request(.getAuditLog)
    }

    public func getDiskIO() async throws -> BWGDiskIO {
        try await request(.getDiskIO)
    }

    public func getSshKeys() async throws -> BWGSshKeysResponse {
        try await request(.getSshKeys)
    }

    public func start() async throws -> BWGAPIResponse {
        try await request(.start)
    }

    public func stop() async throws -> BWGAPIResponse {
        try await request(.stop)
    }

    public func restart() async throws -> BWGAPIResponse {
        try await request(.restart)
    }

    public func kill() async throws -> BWGAPIResponse {
        try await request(.kill)
    }

    public func listSnapshots() async throws -> BWGSnapshotListResponse {
        try await request(.snapshotList)
    }

    public func createSnapshot(description: String? = nil) async throws -> BWGAPIResponse {
        try await request(.snapshotCreate(description: description))
    }

    public func deleteSnapshot(key: String) async throws -> BWGAPIResponse {
        try await request(.snapshotDelete(snapshotKey: key))
    }

    public func restoreSnapshot(key: String) async throws -> BWGAPIResponse {
        try await request(.snapshotRestore(snapshotKey: key))
    }

    public func getMigrationLocations() async throws -> BWGMigrationLocationsResponse {
        try await request(.migrateGetLocations)
    }

    public func startMigration(location: String) async throws -> BWGAPIResponse {
        try await request(.migrateStart(location: location))
    }

    public func reinstallOS(os: String) async throws -> BWGAPIResponse {
        try await request(.reinstallOS(os: os))
    }

    public func resetRootPassword() async throws -> BWGAPIResponse {
        try await request(.resetRootPassword)
    }

    public func setHostname(_ hostname: String) async throws -> BWGAPIResponse {
        try await request(.setHostname(newHostname: hostname))
    }

    public func setPTR(ip: String, ptr: String) async throws -> BWGAPIResponse {
        try await request(.setPTR(ip: ip, ptr: ptr))
    }

    public func addIPv6() async throws -> BWGAPIResponse {
        try await request(.ipv6Add)
    }

    public func deleteIPv6(ip: String) async throws -> BWGAPIResponse {
        try await request(.ipv6Delete(ip: ip))
    }

    public func resetApiKey() async throws -> BWGAPIResponse {
        try await request(.setApiKey)
    }
}
