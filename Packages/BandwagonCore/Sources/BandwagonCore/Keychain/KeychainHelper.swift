import Foundation
import Security

/// Keychain 敏感凭证存储助手（保存 API Key）
public final class KeychainHelper: Sendable {
    public static let shared = KeychainHelper()
    private let service = "com.steveshi.bandwagonkit.credentials"

    private init() {}

    public func saveApiKey(_ apiKey: String, forVeid veid: String) throws {
        let account = "veid_\(veid)"
        guard let data = apiKey.data(using: .utf8) else { return }

        // 先尝试删除已有
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // 添加新记录
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: "KeychainHelper", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to save to Keychain, status: \(status)"])
        }
    }

    public func getApiKey(forVeid veid: String) -> String? {
        let account = "veid_\(veid)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    public func deleteApiKey(forVeid veid: String) {
        let account = "veid_\(veid)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
