import Foundation
import CoreMIDI

/// Pads play through a virtual MIDI source named "Forchpad", so DAWs see this app
/// like any MIDI keyboard. Created once at launch and kept alive until quit.
var midiClient = MIDIClientRef()
var midiSource = MIDIEndpointRef()
var midiReady = false

func setupMIDI() -> Bool {
    guard !midiReady else { return true }
    var status = MIDIClientCreateWithBlock("Forchpad" as CFString, &midiClient, nil)
    guard status == noErr else { return false }
    status = MIDISourceCreateWithProtocol(midiClient, "Forchpad" as CFString, MIDIProtocolID._1_0, &midiSource)
    guard status == noErr else { return false }
    // A stable unique id lets DAWs keep their saved reference to this source between launches.
    let saved = Int32(UserDefaults.standard.integer(forKey: "midiUniqueID"))
    if saved != 0 { MIDIObjectSetIntegerProperty(midiSource, kMIDIPropertyUniqueID, saved) }
    var actual: Int32 = 0
    if MIDIObjectGetIntegerProperty(midiSource, kMIDIPropertyUniqueID, &actual) == noErr, actual != 0 {
        UserDefaults.standard.set(Int(actual), forKey: "midiUniqueID")
    }
    midiReady = true
    return true
}

func teardownMIDI() {
    guard midiReady else { return }
    MIDIEndpointDispose(midiSource)
    MIDIClientDispose(midiClient)
    midiReady = false
}

/// One channel-voice message as a MIDI 1.0 UMP word; the SDK's inline helpers don't reach Swift.
func midiWord(_ status: UInt8, _ channel: UInt8, _ data1: UInt8, _ data2: UInt8) -> UInt32 {
    (0x2 << 28) | (UInt32(status & 0x0F) << 20) | (UInt32(channel & 0x0F) << 16) | (UInt32(data1 & 0x7F) << 8) | UInt32(data2 & 0x7F)
}

/// Sends one note on/off from any thread. CoreMIDI is thread-safe; the buffer must be 8-byte aligned.
func sendNote(_ note: UInt8, on: Bool) {
    guard midiReady else { return }
    let channel = UInt8(clamping: settings.midiChannel - 1)
    let word = midiWord(on ? 0x9 : 0x8, channel, note, on ? UInt8(clamping: settings.velocity) : 64)
    let capacity = 64
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: capacity, alignment: 8)
    defer { buffer.deallocate() }
    let list = buffer.assumingMemoryBound(to: MIDIEventList.self)
    let first = MIDIEventListInit(list, ._1_0)
    var w = word
    // Timestamp 0 is not "now" for virtual sources; use the host clock.
    _ = withUnsafePointer(to: &w) { MIDIEventListAdd(list, capacity, first, mach_absolute_time(), 1, $0) }
    // The list only counts up when the event fit; a failed add leaves numPackets at 0.
    guard list.pointee.numPackets == 1 else { return }
    _ = MIDIReceivedEventList(midiSource, UnsafePointer(list))
}
