import Foundation

/// HTTP 请求方法
public enum BWGHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

/// KiwiVM API 端点定义
public enum BWGEndpoint: Sendable {
    // MARK: - Information
    case getServiceInfo
    case getLiveServiceInfo
    case getAvailableOS
    case getRateLimitStatus
    case getSuspensionDetail
    case getAuditLog
    case getDiskIO
    case getSshKeys

    // MARK: - Power
    case start
    case stop
    case restart
    case kill

    // MARK: - Snapshots
    case snapshotList
    case snapshotCreate(description: String? = nil)
    case snapshotDelete(snapshotKey: String)
    case snapshotRestore(snapshotKey: String)

    // MARK: - Migration
    case migrateGetLocations
    case migrateStart(location: String)

    // MARK: - System
    case reinstallOS(os: String)
    case resetRootPassword
    case setHostname(newHostname: String)
    case setPTR(ip: String, ptr: String)

    // MARK: - IPv6
    case ipv6Add
    case ipv6Delete(ip: String)

    // MARK: - Security & Keys
    case setApiKey

    /// API 请求路径
    public var path: String {
        switch self {
        case .getServiceInfo:
            return "getServiceInfo"
        case .getLiveServiceInfo:
            return "getLiveServiceInfo"
        case .getAvailableOS:
            return "getAvailableOS"
        case .getRateLimitStatus:
            return "getRateLimitStatus"
        case .getSuspensionDetail:
            return "getSuspensionDetail"
        case .getAuditLog:
            return "getAuditLog"
        case .getDiskIO:
            return "getDiskIO"
        case .getSshKeys:
            return "getSshKeys"

        case .start:
            return "start"
        case .stop:
            return "stop"
        case .restart:
            return "restart"
        case .kill:
            return "kill"

        case .snapshotList:
            return "snapshot/list"
        case .snapshotCreate:
            return "snapshot/create"
        case .snapshotDelete:
            return "snapshot/delete"
        case .snapshotRestore:
            return "snapshot/restore"

        case .migrateGetLocations:
            return "migrate/getLocations"
        case .migrateStart:
            return "migrate/start"

        case .reinstallOS:
            return "reinstallOS"
        case .resetRootPassword:
            return "resetRootPassword"
        case .setHostname:
            return "setHostname"
        case .setPTR:
            return "setPTR"

        case .ipv6Add:
            return "ipv6/add"
        case .ipv6Delete:
            return "ipv6/delete"

        case .setApiKey:
            return "setApiKey"
        }
    }

    /// 额外的请求参数
    public var parameters: [String: String] {
        switch self {
        case .snapshotCreate(let desc):
            if let desc, !desc.isEmpty {
                return ["description": desc]
            }
            return [:]
        case .snapshotDelete(let key):
            return ["snapshotKey": key]
        case .snapshotRestore(let key):
            return ["snapshotKey": key]
        case .migrateStart(let location):
            return ["location": location]
        case .reinstallOS(let os):
            return ["os": os]
        case .setHostname(let newHostname):
            return ["newHostname": newHostname]
        case .setPTR(let ip, let ptr):
            return ["ip": ip, "ptr": ptr]
        case .ipv6Delete(let ip):
            return ["ip": ip]
        default:
            return [:]
        }
    }

    /// 推荐的 HTTP 方法（KiwiVM 支持 GET/POST，推荐变动状态的操作使用 POST）
    public var method: BWGHTTPMethod {
        switch self {
        case .start, .stop, .restart, .kill,
             .snapshotCreate, .snapshotDelete, .snapshotRestore,
             .migrateStart, .reinstallOS, .resetRootPassword,
             .setHostname, .setPTR, .ipv6Add, .ipv6Delete, .setApiKey:
            return .post
        default:
            return .get
        }
    }
}
