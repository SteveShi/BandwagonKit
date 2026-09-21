import Foundation
import Observation
import BandwagonAPI

/// 管理所有 VPS 账户凭证与持久化
@Observable
public final class AccountStore: @unchecked Sendable {
    public private(set) var accounts: [VPSAccount] = []
    public var selectedAccountID: UUID?

    private let storageURL: URL
    private let keychain: KeychainHelper

    public init(
        storageURL: URL? = nil,
        keychain: KeychainHelper = .shared
    ) {
        self.keychain = keychain
        if let storageURL {
            self.storageURL = storageURL
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let appDir = appSupport.appendingPathComponent("BandwagonKit", isDirectory: true)
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
            self.storageURL = appDir.appendingPathComponent("accounts.json")
        }
        loadAccounts()
    }

    public var selectedAccount: VPSAccount? {
        guard let id = selectedAccountID else { return accounts.first }
        return accounts.first(where: { $0.id == id }) ?? accounts.first
    }

    public func loadAccounts() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let loaded = try JSONDecoder().decode([VPSAccount].self, from: data)
            self.accounts = loaded
            if selectedAccountID == nil {
                selectedAccountID = loaded.first?.id
            }
        } catch {
            print("Failed to load accounts: \(error)")
        }
    }

    public func saveAccounts() {
        do {
            let data = try JSONEncoder().encode(accounts)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("Failed to save accounts: \(error)")
        }
    }

    @discardableResult
    public func addAccount(name: String, veid: String, apiKey: String, colorHex: String? = nil, customSSHPort: Int? = nil) throws -> VPSAccount {
        let trimmedVeid = veid.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        try keychain.saveApiKey(trimmedKey, forVeid: trimmedVeid)

        let newAccount = VPSAccount(
            name: trimmedName.isEmpty ? "VPS \(trimmedVeid)" : trimmedName,
            veid: trimmedVeid,
            colorHex: colorHex,
            customSSHPort: customSSHPort
        )

        accounts.append(newAccount)
        saveAccounts()

        if selectedAccountID == nil {
            selectedAccountID = newAccount.id
        }
        return newAccount
    }

    public func updateAccount(_ account: VPSAccount, newApiKey: String? = nil) throws {
        if let newApiKey, !newApiKey.isEmpty {
            try keychain.saveApiKey(newApiKey, forVeid: account.veid)
        }

        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveAccounts()
        }
    }

    public func deleteAccount(id: UUID) {
        guard let account = accounts.first(where: { $0.id == id }) else { return }
        keychain.deleteApiKey(forVeid: account.veid)
        accounts.removeAll(where: { $0.id == id })
        saveAccounts()

        if selectedAccountID == id {
            selectedAccountID = accounts.first?.id
        }
    }

    public func getApiKey(for veid: String) -> String? {
        keychain.getApiKey(forVeid: veid)
    }
}
