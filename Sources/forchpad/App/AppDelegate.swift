import Cocoa

/// The menu-bar letter and the app lifecycle. No Dock icon: the status item is the home base.
final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // One copy at a time: a second launch brings the first forward and leaves.
        if let bundleID = Bundle.main.bundleIdentifier {
            let others = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
                .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
            if !others.isEmpty {
                others.first?.activate(options: [])
                NSApp.terminate(nil)
                return
            }
        }

        _ = setupMIDI()
        refreshTrackpads()
        if cliOptions.preferExternal {
            if let ext = trackpads.first(where: { !$0.builtIn }) {
                settings.selectedDeviceID = ext.id
            } else {
                fail("--external was given, but no external trackpad was found.\nTurn on your Magic Trackpad (2 or newer), connect it, and run it again.")
            }
        }

        _ = registerHotKey(.toggle, keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers)
        _ = registerHotKey(.pause, keyCode: settings.pauseHotkeyKeyCode, modifiers: settings.pauseHotkeyModifiers)

        // Returning players already know about the pointer pause: make sure macOS has asked
        // its Accessibility question before the first shortcut press of the day.
        if settings.confirmed && settings.pausePointer {
            ensureAccessibilityInterest()
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        rebuildMenu()
        updateStatusItemAppearance()

        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in tickUI() }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in self.refreshDevices() }

        let wc = NSWorkspace.shared.notificationCenter
        wc.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { _ in
            stopPerformance(reason: .sleep)
        }
        wc.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            self.refreshDevices()
        }

        // First run, or a system too old for the touch functions: show the window so the player sees why.
        if !settings.confirmed || !mtSymbolsPresent() { settingsWindow.show() }

        // Diagnostic for permission reports: which taps may this exact process create?
        if cliOptions.probeTap {
            let result = String(format: "preflight=%d axTrusted=%d filteringTap=%d listenOnlyTap=%d",
                                CGPreflightListenEventAccess() ? 1 : 0,
                                AXIsProcessTrusted() ? 1 : 0,
                                installEventTap() ? 1 : 0,
                                listenProbeWorks() ? 1 : 0)
            NSLog("forchpad probe: %@", result)
            try? result.write(toFile: "/tmp/forchpad_probe.txt", atomically: true, encoding: .utf8)
            NSApp.terminate(nil)
        }

        // Diagnostic for "pads don't see my fingers": do MultitouchSupport frames reach this
        // process at all? Capture for ten seconds, count frames and contacts, report, quit.
        if cliOptions.probeTouch {
            guard let dev = selectedTrackpad(), let mtRegister, let mtStart else {
                try? "no trackpad or no MultitouchSupport symbols".write(toFile: "/tmp/forchpad_touch_probe.txt", atomically: true, encoding: .utf8)
                NSApp.terminate(nil)
                return
            }
            mtRegister(dev.ref, touchCallback)
            mtStart(dev.ref, 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                mtStop?(dev.ref)
                let contacts = readContacts()
                var sample = ""
                for c in contacts.prefix(4) {
                    sample += String(format: " (%.3f,%.3f,size=%.3f)", c.x, c.y, c.size)
                }
                let result = String(format: "device=%04llX builtin=%d frames=%llu framesWithContacts=%llu liveContacts=%d%@",
                                    dev.id & 0xFFFF, dev.builtIn ? 1 : 0,
                                    framesReceived, framesWithContacts, contacts.count, sample)
                NSLog("forchpad touch probe: %@", result)
                try? result.write(toFile: "/tmp/forchpad_touch_probe.txt", atomically: true, encoding: .utf8)
                NSApp.terminate(nil)
            }
        }
    }

    /// The status-item menu, rebuilt whenever the language changes.
    func rebuildMenu() {
        let menu = NSMenu()
        let settingsItem = NSMenuItem(title: L("Settings…"), action: #selector(showSettings(_:)), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: L("Quit"), action: #selector(quitApp(_:)), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem?.menu = menu
        statusItem?.button?.toolTip = L("Forchpad — MIDI pads")
    }

    /// Re-applies the current language everywhere it has already been rendered.
    func relocalizeUI() {
        rebuildMenu()
        settingsWindow.relocalize()
        padWindow.relocalize()
        relocalizePadEditorIfExists()
    }

    /// Keeps the device list fresh when idle; while playing, only watches for the device going away.
    func refreshDevices() {
        if performing {
            if let dev = startedDevice, !deviceStillPresent(dev.id) {
                stopPerformance(reason: .deviceLost)
            }
            return
        }
        let had = trackpads.count
        refreshTrackpads()
        if trackpads.count != had { settingsWindow.performStateChanged() }
    }

    /// The menu-bar glyph: a 3×3 mini grid, bottom-left pad pressed — the icon in miniature.
    /// Template-rendered so macOS tints it; we tint it red while playing.
    let statusIcon: NSImage = {
        let img = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            let pad: CGFloat = 4.4, gap: CGFloat = 1.7
            let span = 3 * pad + 2 * gap
            let ox = (18 - span) / 2, oy = (18 - span) / 2
            for r in 0..<3 {
                for c in 0..<3 {
                    let rect = NSRect(x: ox + CGFloat(c) * (pad + gap), y: oy + CGFloat(r) * (pad + gap),
                                      width: pad, height: pad)
                    let pressed = (c == 0 && r == 0)
                    NSColor.black.withAlphaComponent(pressed ? 1.0 : 0.35).setFill()
                    NSBezierPath(roundedRect: rect, xRadius: 1.3, yRadius: 1.3).fill()
                }
            }
            return true
        }
        img.isTemplate = true
        return img
    }()

    /// The status item: plain grid at rest, red while playing.
    func updateStatusItemAppearance() {
        guard let button = statusItem?.button else { return }
        button.image = statusIcon
        button.imagePosition = .imageOnly
        button.contentTintColor = performing ? .systemRed : nil
    }

    @objc func showSettings(_ sender: Any?) { settingsWindow.show() }

    @objc func quitApp(_ sender: Any?) { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        stopPerformance(reason: .quit)
        unregisterAllHotKeys()
        teardownMIDI()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

let appDelegate = AppDelegate()
