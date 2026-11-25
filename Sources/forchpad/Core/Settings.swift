import Foundation
import Carbon.HIToolbox   // for cmdKey/shiftKey, the default shortcut's modifier bits

/// What the player picked in the settings window, kept in UserDefaults between runs.
final class Settings {
    static let shared = Settings()
    private let d = UserDefaults.standard

    var rows = 3
    var cols = 3
    var midiChannel = 10          // shown to the player as 1...16, sent as 0...15
    var baseNote = 36             // bottom-left pad; pads count up from there
    var velocity = 100
    var selectedDeviceID: UInt64 = 0   // 0 means "the built-in trackpad"
    var hotkeyKeyCode: UInt32 = 14     // kVK_ANSI_E
    var hotkeyModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    var hotkeyDisplay = "⇧⌘E"
    var pauseHotkeyKeyCode: UInt32 = 35   // kVK_ANSI_P — temporary pause, window stays up
    var pauseHotkeyModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    var pauseHotkeyDisplay = "⇧⌘P"
    var confirmed = false              // the player must say yes once before the shortcut works
    var languageOverride: String?      // nil = follow the system language
    var pinPadsOnTop = true            // the pad window floats above other windows
    var pausePointer = true            // pause the pointer while playing; off = no permission needed
    var lockPointer = true             // freeze it for the whole performance; off = only while fingers touch
    /// Per-pad customization, "row,col" (touch coordinates, row 0 = bottom) → style. See PadStyle.swift.
    var padStyles: [String: PadStyle] = [:]
    var padWindowX: Double?              // where the player parked the pads; nil = never placed yet
    var padWindowY: Double?

    func load() {
        if d.object(forKey: "rows") != nil { rows = d.integer(forKey: "rows") }
        if d.object(forKey: "cols") != nil { cols = d.integer(forKey: "cols") }
        if d.object(forKey: "midiChannel") != nil { midiChannel = d.integer(forKey: "midiChannel") }
        if d.object(forKey: "baseNote") != nil { baseNote = d.integer(forKey: "baseNote") }
        if d.object(forKey: "velocity") != nil { velocity = d.integer(forKey: "velocity") }
        if d.object(forKey: "selectedDeviceID") != nil { selectedDeviceID = UInt64(bitPattern: Int64(d.integer(forKey: "selectedDeviceID"))) }
        if d.object(forKey: "hotkeyKeyCode") != nil { hotkeyKeyCode = UInt32(d.integer(forKey: "hotkeyKeyCode")) }
        if d.object(forKey: "hotkeyModifiers") != nil { hotkeyModifiers = UInt32(d.integer(forKey: "hotkeyModifiers")) }
        if let s = d.string(forKey: "hotkeyDisplay") { hotkeyDisplay = s }
        if d.object(forKey: "pauseHotkeyKeyCode") != nil { pauseHotkeyKeyCode = UInt32(d.integer(forKey: "pauseHotkeyKeyCode")) }
        if d.object(forKey: "pauseHotkeyModifiers") != nil { pauseHotkeyModifiers = UInt32(d.integer(forKey: "pauseHotkeyModifiers")) }
        if let s = d.string(forKey: "pauseHotkeyDisplay") { pauseHotkeyDisplay = s }
        languageOverride = d.string(forKey: "languageOverride")
        if d.object(forKey: "pinPadsOnTop") != nil { pinPadsOnTop = d.bool(forKey: "pinPadsOnTop") }
        if d.object(forKey: "pausePointer") != nil { pausePointer = d.bool(forKey: "pausePointer") }
        if d.object(forKey: "lockPointer") != nil { lockPointer = d.bool(forKey: "lockPointer") }
        if let data = d.data(forKey: "padStyles"),
           let decoded = try? JSONDecoder().decode([String: PadStyle].self, from: data) {
            padStyles = decoded
        }
        if d.object(forKey: "padWindowX") != nil { padWindowX = d.double(forKey: "padWindowX") }
        if d.object(forKey: "padWindowY") != nil { padWindowY = d.double(forKey: "padWindowY") }
        confirmed = d.bool(forKey: "confirmed")
        clamp()
    }

    /// Keeps anything that was edited by hand (or by an older version) inside the sane ranges.
    func clamp() {
        rows = min(10, max(1, rows))
        cols = min(10, max(1, cols))
        midiChannel = min(16, max(1, midiChannel))
        velocity = min(127, max(1, velocity))
        baseNote = min(127, max(0, baseNote))
        if baseNote + rows * cols - 1 > 127 { baseNote = 36 }
    }

    func save() {
        clamp()
        d.set(rows, forKey: "rows")
        d.set(cols, forKey: "cols")
        d.set(midiChannel, forKey: "midiChannel")
        d.set(baseNote, forKey: "baseNote")
        d.set(velocity, forKey: "velocity")
        d.set(Int(Int64(bitPattern: selectedDeviceID)), forKey: "selectedDeviceID")
        d.set(Int(hotkeyKeyCode), forKey: "hotkeyKeyCode")
        d.set(Int(hotkeyModifiers), forKey: "hotkeyModifiers")
        d.set(hotkeyDisplay, forKey: "hotkeyDisplay")
        d.set(Int(pauseHotkeyKeyCode), forKey: "pauseHotkeyKeyCode")
        d.set(Int(pauseHotkeyModifiers), forKey: "pauseHotkeyModifiers")
        d.set(pauseHotkeyDisplay, forKey: "pauseHotkeyDisplay")
        d.set(languageOverride, forKey: "languageOverride")
        d.set(pinPadsOnTop, forKey: "pinPadsOnTop")
        d.set(pausePointer, forKey: "pausePointer")
        d.set(lockPointer, forKey: "lockPointer")
        if let data = try? JSONEncoder().encode(padStyles) {
            d.set(data, forKey: "padStyles")
        } else {
            d.removeObject(forKey: "padStyles")
        }
        if let padWindowX { d.set(padWindowX, forKey: "padWindowX") } else { d.removeObject(forKey: "padWindowX") }
        if let padWindowY { d.set(padWindowY, forKey: "padWindowY") } else { d.removeObject(forKey: "padWindowY") }
        d.set(confirmed, forKey: "confirmed")
    }
}

let settings = Settings.shared
