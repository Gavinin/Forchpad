import Cocoa

/// While playing, this tap is what stands between the trackpad and the pointer. Two modes:
/// full lock (default) drops every mouse/scroll event for the whole performance — the
/// cursor freezes and even double-clicks can't leak onto other windows, game-style. The
/// gentler mode drops events only while fingers touch the glass, so lifting them brings
/// the mouse straight back. macOS has no public way to silence one trackpad; the tap dies
/// with the process, so input always returns.
var eventTap: CFMachPort?
var tapRunLoopSource: CFRunLoopSource?

let tapCallback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
        return nil
    }
    if performing && (settings.lockPointer || touchIsActive()) { return nil }
    return Unmanaged.passUnretained(event)
}

func installEventTap() -> Bool {
    removeEventTap()
    func bit(_ t: CGEventType) -> CGEventMask { CGEventMask(1) << t.rawValue }
    let mask = bit(.mouseMoved) | bit(.leftMouseDown) | bit(.leftMouseUp)
        | bit(.rightMouseDown) | bit(.rightMouseUp) | bit(.leftMouseDragged) | bit(.rightMouseDragged)
        | bit(.otherMouseDown) | bit(.otherMouseUp) | bit(.otherMouseDragged) | bit(.scrollWheel)
    guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap,
                                      options: .defaultTap, eventsOfInterest: mask,
                                      callback: tapCallback, userInfo: nil) else { return false }
    eventTap = tap
    let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
    tapRunLoopSource = source
    CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)
    return true
}

/// Diagnostic: can this process open a listen-only tap right now? Compared with the
/// filtering tap's result, this tells Input-Monitoring problems from Accessibility ones.
func listenProbeWorks() -> Bool {
    let mask = CGEventMask(1) << CGEventType.mouseMoved.rawValue
    guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap,
                                      options: .listenOnly, eventsOfInterest: mask,
                                      callback: tapCallback, userInfo: nil) else { return false }
    CFMachPortInvalidate(tap)
    return true
}

/// macOS only lets a process filter events once it trusts it for Accessibility. Asking
/// with the prompt also lists the app in System Settings → Accessibility, so the player
/// can flip the switch there. Call this early — at launch, on first confirm, on toggle-on —
/// so the question doesn't first appear at shortcut time.
func ensureAccessibilityInterest() {
    if !AXIsProcessTrusted() {
        _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
    }
}

func removeEventTap() {
    if let source = tapRunLoopSource {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        tapRunLoopSource = nil
    }
    if let tap = eventTap {
        CGEvent.tapEnable(tap: tap, enable: false)
        CFMachPortInvalidate(tap)
        eventTap = nil
    }
}
