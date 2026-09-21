import SwiftUI
import BandwagonCore

public struct SidebarView: View {
    public let accountStore: AccountStore
    @Binding public var activeManager: VPSManager?
    @State private var showAddSheet = false
    @State private var accountToDelete: VPSAccount?
    @State private var showDeleteConfirmation = false

    public init(accountStore: AccountStore, activeManager: Binding<VPSManager?>) {
        self.accountStore = accountStore
        self._activeManager = activeManager
    }

    public var body: some View {
        List(selection: Binding(
            get: { accountStore.selectedAccountID },
            set: { newID in
                accountStore.selectedAccountID = newID
                updateActiveManager()
            }
        )) {
            Section("Servers") {
                if accountStore.accounts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No Servers Added")
                            .font(.headline)
                        Text("Click the + button to add your BandwagonHost VPS using VEID and API Key.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } else {
                    ForEach(accountStore.accounts) { account in
                        NavigationLink(value: account.id) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(activeManager?.id == account.id && activeManager?.isRunning == true ? Color.green : Color.secondary)
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(account.name)
                                        .font(.body)
                                        .fontWeight(.medium)

                                    Text("VEID: \(account.veid)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                accountToDelete = account
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete Server", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Label("Add VPS", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            updateActiveManager()
        }) {
            AddVPSView(accountStore: accountStore)
        }
        .confirmationDialog(
            "Delete Server",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let acc = accountToDelete {
                    accountStore.deleteAccount(id: acc.id)
                    updateActiveManager()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove this server? Credentials will be removed from Keychain.")
        }
        .onAppear {
            updateActiveManager()
        }
    }

    private func updateActiveManager() {
        guard let current = accountStore.selectedAccount else {
            activeManager = nil
            return
        }

        if activeManager?.id != current.id {
            if let apiKey = accountStore.getApiKey(for: current.veid) {
                activeManager = VPSManager(account: current, apiKey: apiKey)
            }
        }
    }
}
