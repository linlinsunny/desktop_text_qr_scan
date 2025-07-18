
import SwiftUI

@main
struct TextScannerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "Text Scanner")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "识别文本", action: #selector(recognizeText), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "识别二维码", action: #selector(recognizeQRCode), keyEquivalent: "q"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "关于", action: #selector(openAbout), keyEquivalent: "a"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "e"))
        statusBarItem.menu = menu
    }

    @objc func recognizeText() {
        let screenCapture = ScreenCapture()
        screenCapture.capture(type: .text)
    }

    @objc func recognizeQRCode() {
        let screenCapture = ScreenCapture()
        screenCapture.capture(type: .qrCode)
    }

    @objc func openAbout() {
        if let url = URL(string: "https://sunnydodo.top/about.html") {
            NSWorkspace.shared.open(url)
        }
    }
}
