import Testing
import Foundation
@testable import BandwagonCore

@Suite("BandwagonCore Tests")
struct BandwagonCoreTests {

    @Test("AccountStore add, update and delete flow")
    func testAccountStoreCRUD() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let storageURL = tempDir.appendingPathComponent("test_accounts.json")

        let store = AccountStore(storageURL: storageURL)
        #expect(store.accounts.isEmpty)

        // Add account
        let account = try store.addAccount(
            name: "HK Node",
            veid: "123456",
            apiKey: "private_key_abc",
            colorHex: "#00FF00",
            customSSHPort: 2222
        )
        #expect(store.accounts.count == 1)
        #expect(store.selectedAccount?.name == "HK Node")
        #expect(store.selectedAccount?.veid == "123456")
        #expect(store.selectedAccount?.customSSHPort == 2222)

        // Delete account
        store.deleteAccount(id: account.id)
        #expect(store.accounts.isEmpty)

        // Clean up
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("VPSManager initialization and computed properties")
    func testVPSManagerInit() {
        let account = VPSAccount(name: "US West", veid: "9999", customSSHPort: 29812)
        let manager = VPSManager(account: account, apiKey: "dummy_key")

        #expect(manager.account.name == "US West")
        #expect(manager.sshPort == 29812)
        #expect(manager.isRunning == false)
        #expect(manager.ipAddress == "—")
    }
}
