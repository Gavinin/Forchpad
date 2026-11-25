import Cocoa
import Carbon.HIToolbox

/// The two global shortcuts: start/stop and temporary pause. Carbon hot keys are system
/// registrations, not keyboard monitoring, so they need no accessibility permission.
enum AppHotKey {
    case toggle   // start/stop playing
    case pause    // temporary pause: stop the notes, leave the window up

    var id: UInt32 { self == .toggle ? 1 : 2 }
    var keyCode: UInt32 { self == .toggle ? settings.hotkeyKeyCode : settings.pauseHotkeyKeyCode }
    var modifiers: UInt32 { self == .toggle ? settings.hotkeyModifiers : settings.pauseHotkeyModifiers }

    /// Persists a freshly recorded shortcut for this hot key.
    func save(keyCode: UInt32, modifiers: UInt32, display: String) {
        switch self {
        case .toggle:
            settings.hotkeyKeyCode = keyCode
            settings.hotkeyModifiers = modifiers
            settings.hotkeyDisplay = display
        case .pause:
            settings.pauseHotkeyKeyCode = keyCode
            settings.pauseHotkeyModifiers = modifiers
            settings.pauseHotkeyDisplay = display
        }
        settings.save()
    }
}

var toggleHotKeyRef: EventHotKeyRef?
var pauseHotKeyRef: EventHotKeyRef?
var hotKeyHandlerInstalled = false
let hotKeySignature = fourCharCode("Fcpd")

func hotKeyRef(_ which: AppHotKey) -> EventHotKeyRef? { which == .toggle ? toggleHotKeyRef : pauseHotKeyRef }
func setHotKeyRef(_ which: AppHotKey, _ ref: EventHotKeyRef?) {
    if which == .toggle { toggleHotKeyRef = ref } else { pauseHotKeyRef = ref }
}

/// Fires on the Carbon event loop; hand off to main so all mode changes happen in one place.
let hotKeyHandler: EventHandlerUPP = { _, event, _ in
    guard let event else { return noErr }
    var id = EventHotKeyID()
    let err = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                nil, MemoryLayout<EventHotKeyID>.size, nil, &id)
    if err == noErr, id.signature == hotKeySignature {
        switch id.id {
        case AppHotKey.toggle.id: DispatchQueue.main.async { togglePerformance() }
        case AppHotKey.pause.id: DispatchQueue.main.async { togglePause() }
        default: break
        }
    }
    return noErr
}

func installHotKeyHandlerIfNeeded() {
    guard !hotKeyHandlerInstalled else { return }
    var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &spec, nil, nil)
    hotKeyHandlerInstalled = true
}

/// Registers one shortcut. Exclusive, so a clash with another app is a clear error, not two actions.
func registerHotKey(_ which: AppHotKey, keyCode: UInt32, modifiers: UInt32) -> OSStatus {
    installHotKeyHandlerIfNeeded()
    var ref: EventHotKeyRef?
    let id = EventHotKeyID(signature: hotKeySignature, id: which.id)
    let status = RegisterEventHotKey(keyCode, modifiers, id, GetApplicationEventTarget(),
                                     OptionBits(kEventHotKeyExclusive), &ref)
    if status == noErr { setHotKeyRef(which, ref) }
    return status
}

func unregisterHotKey(_ which: AppHotKey) {
    if let old = hotKeyRef(which) { UnregisterEventHotKey(old) }
    setHotKeyRef(which, nil)
}

func unregisterAllHotKeys() {
    unregisterHotKey(.toggle)
    unregisterHotKey(.pause)
}

/// Swaps a shortcut, putting the old one back if the new one is taken.
func reregisterHotKey(_ which: AppHotKey, keyCode: UInt32, modifiers: UInt32) -> OSStatus {
    let oldCode = which.keyCode, oldMods = which.modifiers
    unregisterHotKey(which)
    let status = registerHotKey(which, keyCode: keyCode, modifiers: modifiers)
    if status != noErr { _ = registerHotKey(which, keyCode: oldCode, modifiers: oldMods) }
    return status
}

/// AppKit modifier flags to Carbon modifier bits.
func carbonModifiers(_ flags: NSEvent.ModifierFlags) -> UInt32 {
    var m: UInt32 = 0
    if flags.contains(.command) { m |= UInt32(cmdKey) }
    if flags.contains(.shift) { m |= UInt32(shiftKey) }
    if flags.contains(.option) { m |= UInt32(optionKey) }
    if flags.contains(.control) { m |= UInt32(controlKey) }
    return m
}

/// A short name for a key, like "F5" or "Space", for the settings row.
func keyName(for keyCode: UInt16, characters: String?) -> String {
    let specials: [UInt16: String] = [
        36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋", 76: "⌤",
        96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9",
        103: "F11", 109: "F10", 111: "F12", 118: "F4", 120: "F2", 122: "F1",
        123: "←", 124: "→", 125: "↓", 126: "↑",
    ]
    if let name = specials[keyCode] { return name }
    return (characters ?? "?").uppercased()
}

/// How the shortcut reads in the window, like "⇧⌘E".
func hotkeyDisplayString(keyCode: UInt16, flags: NSEvent.ModifierFlags, characters: String?) -> String {
    var s = ""
    if flags.contains(.control) { s += "⌃" }
    if flags.contains(.option) { s += "⌥" }
    if flags.contains(.shift) { s += "⇧" }
    if flags.contains(.command) { s += "⌘" }
    return s + keyName(for: keyCode, characters: characters)
}
