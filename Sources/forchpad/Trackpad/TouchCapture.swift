import Foundation
import Darwin

/// A finger on the glass, in trackpad coordinates: x left→right, y bottom→top, both 0...1.
struct Contact { var x: Float; var y: Float; var size: Float }

var touchLock = os_unfair_lock()
var currentContacts: [Contact] = []

/// True while at least one finger touches the selected trackpad. The event tap reads this
/// to pause the pointer only during drumming, so the mouse works again the moment fingers lift.
var contactsActive = false

/// Diagnostic counters for --probe-touch: did frames arrive, and did any carry a contact?
var framesReceived: UInt64 = 0
var framesWithContacts: UInt64 = 0

/// The only place that knows the 96-byte record layout, verified on Apple Silicon.
/// state 3...5 means "finger down"; x/y are normalized; size is the contact area.
func parseContacts(_ data: UnsafeMutableRawPointer, _ count: Int32) -> [Contact] {
    var out: [Contact] = []
    let n = min(Int(count), 32)   // a wild count must never run past the buffer
    out.reserveCapacity(n)
    for i in 0..<n {
        let rec = data.advanced(by: i * 96)
        let state = rec.load(fromByteOffset: 20, as: Int32.self)
        guard (3...5).contains(state) else { continue }
        let x = rec.load(fromByteOffset: 32, as: Float.self)
        let y = rec.load(fromByteOffset: 36, as: Float.self)
        let size = rec.load(fromByteOffset: 48, as: Float.self)
        guard x.isFinite, y.isFinite, size.isFinite else { continue }
        out.append(Contact(x: min(1, max(0, x)), y: min(1, max(0, y)), size: max(0, size)))
    }
    return out
}

/// Runs on a private framework thread: copy the contacts out and leave. Never touch UI here.
let touchCallback: FrameCallback = { _, data, count, _, _ in
    let contacts = data.map { parseContacts($0, count) } ?? []
    os_unfair_lock_lock(&touchLock)
    currentContacts = contacts
    contactsActive = !contacts.isEmpty
    framesReceived += 1
    if !contacts.isEmpty { framesWithContacts += 1 }
    os_unfair_lock_unlock(&touchLock)
    return 0
}

func readContacts() -> [Contact] {
    os_unfair_lock_lock(&touchLock)
    defer { os_unfair_lock_unlock(&touchLock) }
    return currentContacts
}

/// Whether fingers are on the glass right now; drives the dynamic pointer pause.
func touchIsActive() -> Bool {
    os_unfair_lock_lock(&touchLock)
    defer { os_unfair_lock_unlock(&touchLock) }
    return contactsActive
}

/// Called when capture stops, so a stale "finger down" can't keep the pointer paused.
func clearTouchState() {
    os_unfair_lock_lock(&touchLock)
    currentContacts = []
    contactsActive = false
    os_unfair_lock_unlock(&touchLock)
}
