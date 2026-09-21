import SwiftUI
import BandwagonAPI
import BandwagonCore

public struct AddVPSView: View {
    @Environment(\.dismiss) private var dismiss
    public let accountStore: AccountStore

    @State private var veid: String = ""
    @State private var apiKey: String = ""
    @State private var serverName: String = ""
    @State private var sshPort: String = ""

    @State private var isVerifying: Bool = false
    @State private var errorMessage: String?

    public init(accountStore: AccountStore) {
        self.accountStore = accountStore
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Add Server")
                .font(.system(.title2, design: .rounded, weight: .bold))

            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding(8)
                .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(spacing: 12) {
                TextField("VEID (VPS ID)", text: $veid)
                    .textFieldStyle(.roundedBorder)

                SecureField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)

                TextField("Server Name (Optional)", text: $serverName)
                    .textFieldStyle(.roundedBorder)

                TextField("SSH Port (Optional)", text: $sshPort)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button {
                    verifyAndAdd()
                } label: {
                    if isVerifying {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Verify & Add")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(veid.isEmpty || apiKey.isEmpty || isVerifying)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(width: 400)
    }

    private func verifyAndAdd() {
        isVerifying = true
        errorMessage = nil

        let trimmedVeid = veid.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let portInt = Int(sshPort.trimmingCharacters(in: .whitespacesAndNewlines))

        Task {
            let client = BWGClient(veid: trimmedVeid, apiKey: trimmedKey)
            do {
                let info = try await client.getServiceInfo()
                let finalName = serverName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? (info.hostname ?? "VPS \(trimmedVeid)")
                    : serverName

                try accountStore.addAccount(
                    name: finalName,
                    veid: trimmedVeid,
                    apiKey: trimmedKey,
                    customSSHPort: portInt ?? info.sshPort
                )

                await MainActor.run {
                    isVerifying = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
