import Foundation

/// Which pads are down right now, with the strongest contact size in each. Lives on engineQueue.
var activePads: [Int: Float] = [:]
let engineQueue = DispatchQueue(label: "forchpad.engine")
var engineTimer: DispatchSourceTimer?

/// What the pad window draws: pads, live contacts, and whether we're playing.
struct DisplayState {
    var pads: [Int: Float] = [:]
    var contacts: [Contact] = []
    var performing = false
}
var displayLock = os_unfair_lock()
var displayState = DisplayState()

/// Maps a contact to a pad index: bottom row first, left to right, so note numbers read like a keyboard.
func cellFor(_ c: Contact) -> Int {
    let col = min(settings.cols - 1, max(0, Int(c.x * Float(settings.cols))))
    let row = min(settings.rows - 1, max(0, Int(c.y * Float(settings.rows))))
    return row * settings.cols + col
}

/// Turns contacts into note on/off edges. A pad stays down until its last finger lifts,
/// so two fingers in one pad still mean one note.
func engineTick() {
    let contacts = readContacts()
    var down: [Int: Float] = [:]
    for c in contacts {
        let cell = cellFor(c)
        down[cell] = max(down[cell] ?? 0, c.size)
    }
    let base = settings.baseNote
    for (cell, _) in down where activePads[cell] == nil {
        sendNote(UInt8(clamping: base + cell), on: true)
    }
    for cell in activePads.keys where down[cell] == nil {
        sendNote(UInt8(clamping: base + cell), on: false)
    }
    activePads = down
    os_unfair_lock_lock(&displayLock)
    displayState.pads = down
    displayState.contacts = contacts
    os_unfair_lock_unlock(&displayLock)
}

/// Turns every sounding note off; called before the device stops, whenever the mode ends.
func allNotesOff() {
    engineQueue.sync {
        let base = settings.baseNote
        for cell in activePads.keys {
            sendNote(UInt8(clamping: base + cell), on: false)
        }
        activePads = [:]
        os_unfair_lock_lock(&displayLock)
        displayState.pads = [:]
        displayState.contacts = []
        os_unfair_lock_unlock(&displayLock)
    }
}

/// The 125 Hz heartbeat that reads touches and plays notes; MIDI timing never waits for drawing.
func startEngine() {
    engineTimer?.cancel()
    let timer = DispatchSource.makeTimerSource(queue: engineQueue)
    timer.schedule(deadline: .now(), repeating: .milliseconds(8))
    timer.setEventHandler { engineTick() }
    engineTimer = timer
    timer.resume()
}
