import Cocoa

/// The performance state machine. Playing means: the selected trackpad streams touches,
/// pads play MIDI notes, the pad window floats on screen, and the pointer pauses while
/// fingers are on the glass. Everything outside this file only changes state through here.
var performing = false
var paused = false          // notes and capture stopped, pad window left up, pause key resumes
var pendingStart = false
var pendingStartDeadline = Date.distantPast
var startedDevice: TrackpadDevice?
var permissionProblem = false
var cursorHidden = false

enum StopReason { case shortcut, pause, deviceLost, sleep, quit }

/// The master switch: starts when stopped, stops when started, ends a paused show.
func togglePerformance() {
    if performing {
        stopPerformance(reason: .shortcut)
        return
    }
    if paused {
        // Ending a pause for good: everything is already torn down, just drop the window.
        paused = false
        padWindow.hide()
        settingsWindow.performStateChanged()
        return
    }
    if pendingStart {
        pendingStart = false
        settingsWindow.performStateChanged()
        return
    }
    guard mtSymbolsPresent() else {
        settingsWindow.setStatus(L("This macOS version doesn't have the trackpad functions Forchpad needs."))
        settingsWindow.show()
        return
    }
    guard settings.confirmed else {
        settingsWindow.setStatus(fmt(L("Confirm your settings below, then press %@ to start playing."), settings.hotkeyDisplay))
        settingsWindow.show()
        return
    }
    refreshTrackpads()
    guard selectedTrackpad() != nil else {
        settingsWindow.setStatus(L("No trackpad found. Connect a Force Touch trackpad."))
        settingsWindow.show()
        return
    }
    guard setupMIDI() else {
        settingsWindow.setStatus(L("MIDI isn't available on this Mac."))
        settingsWindow.show()
        return
    }
    // Never swallow the release half of a click the player is still holding:
    // wait (briefly) until the mouse buttons and the glass are both clear.
    pendingStart = true
    pendingStartDeadline = Date().addingTimeInterval(3)
    settingsWindow.performStateChanged()
}

/// Called from the UI tick once the pointer is clear, or by nobody if the deadline passed.
func beginPerformance() {
    pendingStart = false
    guard let dev = selectedTrackpad() else {
        settingsWindow.setStatus(L("No trackpad found. Connect a Force Touch trackpad."))
        return
    }
    if settings.pausePointer {
        // The only honest gate is the tap itself: CGPreflightListenEventAccess lies on
        // macOS 27 (says no while filtering taps work), and Accessibility is the permission
        // that actually governs filtering. Try it; only a failure means something is missing.
        guard installEventTap() else {
            NSLog("forchpad: filtering tap failed; preflight=%d axTrusted=%d listenOnly=%d",
                  CGPreflightListenEventAccess() ? 1 : 0,
                  AXIsProcessTrusted() ? 1 : 0,
                  listenProbeWorks() ? 1 : 0)
            let trusted = AXIsProcessTrusted()
            permissionProblem = true
            if !trusted { ensureAccessibilityInterest() }
            settingsWindow.performStateChanged()
            alertAboutPermission(stale: trusted)
            return
        }
    }
    guard let mtRegister, let mtStart else {
        removeEventTap()
        settingsWindow.setStatus(L("This macOS version doesn't have the trackpad functions Forchpad needs."))
        return
    }
    permissionProblem = false
    clearTouchState()
    activePads = [:]
    mtRegister(dev.ref, touchCallback)
    mtStart(dev.ref, 0)
    startedDevice = dev
    startEngine()
    performing = true
    // Full lock hides the cursor outright: a frozen pointer on screen is just a distraction.
    if settings.pausePointer && settings.lockPointer {
        NSCursor.hide()
        cursorHidden = true
    }
    os_unfair_lock_lock(&displayLock)
    displayState.performing = true
    os_unfair_lock_unlock(&displayLock)
    padWindow.show()
    settingsWindow.performStateChanged()
    appDelegate.updateStatusItemAppearance()
}

/// Straight to the System Settings pane where the player flips the switch.
func openAccessibilitySettings() {
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
        NSWorkspace.shared.open(url)
    }
}

/// One focused alert, not a window hijack: say what's missing and offer the direct way out.
/// `stale` means the permission looks granted but the tap still failed — only a relaunch helps.
func alertAboutPermission(stale: Bool) {
    let alert = NSAlert()
    if stale {
        alert.messageText = fmt(L("macOS still won't let Forchpad pause the pointer. Quit and reopen the app, then press %@ again."), settings.hotkeyDisplay)
        alert.addButton(withTitle: L("Quit"))
    } else {
        alert.messageText = L("Before you play")
        alert.informativeText = fmt(L("Forchpad needs permission to pause the pointer. Open System Settings, allow accessibility, then press %@ again."), settings.hotkeyDisplay)
        alert.addButton(withTitle: L("Open System Settings"))
    }
    alert.addButton(withTitle: L("Cancel"))
    // The app has no Dock icon, so the alert must be pulled to the front by hand.
    if #available(macOS 14.0, *) {
        NSApp.activate()
    } else {
        NSApp.activate(ignoringOtherApps: true)
    }
    if alert.runModal() == .alertFirstButtonReturn {
        if stale {
            NSApp.terminate(nil)
        } else {
            openAccessibilitySettings()
        }
    }
}

/// The cleanup path every exit takes: notes off first, then the device, then the tap.
func stopPerformance(reason: StopReason) {
    pendingStart = false
    guard performing else { return }
    performing = false
    engineTimer?.cancel()
    engineTimer = nil
    allNotesOff()
    if let dev = startedDevice {
        mtUnregister?(dev.ref, touchCallback)
        mtStop?(dev.ref)
        startedDevice = nil
    }
    removeEventTap()
    if cursorHidden {
        NSCursor.unhide()
        cursorHidden = false
    }
    clearTouchState()
    os_unfair_lock_lock(&displayLock)
    displayState.performing = false
    displayState.pads = [:]
    displayState.contacts = []
    os_unfair_lock_unlock(&displayLock)
    // A pause leaves the window up: clicks can't land while playing, so pausing is the
    // player's only way to reach the pin button and the resize edges. Raise it again so
    // it's actually there to click, even if it was unpinned mid-performance.
    if reason == .pause {
        padWindow.show()
    } else {
        padWindow.hide()
    }
    settingsWindow.performStateChanged()
    appDelegate.updateStatusItemAppearance()
    if reason == .deviceLost {
        settingsWindow.setStatus(L("The trackpad disconnected."))
        settingsWindow.show()
    }
}

/// The second shortcut: while playing it pauses (notes off, capture stopped, window stays
/// up so the pin button and resize edges become clickable); pressed again it resumes the
/// performance. With no show on screen it does nothing — starting is the master switch's job.
func togglePause() {
    if performing {
        stopPerformance(reason: .pause)
        paused = true
        return
    }
    if paused {
        paused = false
        beginPerformance()
    }
}

/// Runs at display rate on main: starts a pending performance once the pointer is clear.
func tickUI() {
    if pendingStart {
        if NSEvent.pressedMouseButtons == 0 && !touchIsActive() {
            beginPerformance()
        } else if Date() > pendingStartDeadline {
            pendingStart = false
            settingsWindow.performStateChanged()
        }
    }
    padWindow.refreshDisplay()
}
