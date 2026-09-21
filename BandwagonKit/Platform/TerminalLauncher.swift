import Foundation
import AppKit

/// 支持的外部终端类型
public enum TerminalAppType: String, CaseIterable, Identifiable, Codable, Sendable {
    case terminal = "Terminal.app"
    case iterm2 = "iTerm2"
    case ghostty = "Ghostty"
    case macSSH = "MacSSH"
    case custom = "Custom"

    public var id: String { rawValue }

    public var bundleIdentifier: String? {
        switch self {
        case .terminal: return "com.apple.Terminal"
        case .iterm2: return "com.googlecode.iterm2"
        case .ghostty: return "com.mitchellh.ghostty"
        case .macSSH: return "com.steveshi.macssh"
        case .custom: return nil
        }
    }

    public var isInstalled: Bool {
        if self == .terminal { return true }
        guard let bundleId = bundleIdentifier else { return true }
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) != nil
    }
}

/// 外部终端启动器，负责以用户选定的终端打开 SSH 会话
@MainActor
public final class TerminalLauncher {
    public static let shared = TerminalLauncher()

    private init() {}

    /// 检测已安装的终端列表
    public func installedTerminals() -> [TerminalAppType] {
        TerminalAppType.allCases.filter { $0.isInstalled }
    }

    /// 打开终端并执行 SSH 命令
    /// - Parameters:
    ///   - host: IP 或域名
    ///   - port: SSH 端口（默认 22）
    ///   - user: 用户名（默认 root）
    ///   - terminal: 选用的终端类型
    public func launchSSH(
        host: String,
        port: Int = 22,
        user: String = "root",
        terminal: TerminalAppType = .terminal
    ) {
        let sshCommand = "ssh -p \(port) \(user)@\(host)"

        switch terminal {
        case .terminal:
            launchTerminalApp(command: sshCommand)
        case .iterm2:
            launchITerm2(command: sshCommand)
        case .ghostty:
            launchGhostty(command: sshCommand, host: host, port: port, user: user)
        case .macSSH:
            launchMacSSH(host: host, port: port, user: user)
        case .custom:
            launchTerminalApp(command: sshCommand)
        }
    }

    private func launchTerminalApp(command: String) {
        let escapedCommand = command.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "Terminal"
            activate
            do script "\(escapedCommand)"
        end tell
        """
        runAppleScript(script)
    }

    private func launchITerm2(command: String) {
        let escapedCommand = command.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "iTerm"
            activate
            set newWindow to (create window with default profile)
            tell current session of newWindow
                write text "\(escapedCommand)"
            end tell
        end tell
        """
        runAppleScript(script)
    }

    private func launchGhostty(command: String, host: String, port: Int, user: String) {
        // Ghostty 支持直接通过 open 启动或 AppleScript 发送按键
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.mitchellh.ghostty") {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration()) { app, _ in
                guard app != nil else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let escapedCommand = command.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
                    let script = """
                    tell application "System Events"
                        tell process "Ghostty"
                            keystroke "\(escapedCommand)"
                            keystroke return
                        end tell
                    end tell
                    """
                    self.runAppleScript(script)
                }
            }
        } else {
            // 回退到系统终端
            launchTerminalApp(command: command)
        }
    }

    private func launchMacSSH(host: String, port: Int, user: String) {
        // 尝试使用 ssh:// URL Scheme
        if let url = URL(string: "ssh://\(user)@\(host):\(port)") {
            if let macSSHURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.steveshi.macssh") {
                let config = NSWorkspace.OpenConfiguration()
                NSWorkspace.shared.open([url], withApplicationAt: macSSHURL, configuration: config, completionHandler: nil)
                return
            }
        }
        // 如果未注册 scheme，回退到终端
        launchTerminalApp(command: "ssh -p \(port) \(user)@\(host)")
    }

    private func runAppleScript(_ script: String) {
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if let error {
                print("AppleScript execution error: \(error)")
            }
        }
    }
}
