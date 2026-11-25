import Foundation
import Darwin

/// Raw trackpad contacts come from MultitouchSupport, a private framework. It is never linked:
/// every symbol is resolved at launch and checked, so a macOS update means a clear message, not a crash.
let mt = dlopen("/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport", RTLD_NOW)
func sym<T>(_ name: String, _: T.Type) -> T? {
    guard let mt, let p = dlsym(mt, name) else { return nil }
    return unsafeBitCast(p, to: T.self)
}

typealias CreateList = @convention(c) () -> Unmanaged<CFArray>?
typealias GetID = @convention(c) (UnsafeMutableRawPointer, UnsafeMutablePointer<UInt64>) -> Int32
typealias IsBuiltIn = @convention(c) (UnsafeMutableRawPointer) -> Bool
typealias FrameCallback = @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, Int32, Double, Int32) -> Int32
typealias RegisterCallback = @convention(c) (UnsafeMutableRawPointer, FrameCallback) -> Void
typealias DeviceStart = @convention(c) (UnsafeMutableRawPointer, Int32) -> Void
typealias DeviceStop = @convention(c) (UnsafeMutableRawPointer) -> Void

let mtCreateList = sym("MTDeviceCreateList", CreateList.self)
let mtGetID = sym("MTDeviceGetDeviceID", GetID.self)
let mtIsBuiltIn = sym("MTDeviceIsBuiltIn", IsBuiltIn.self)
let mtRegister = sym("MTRegisterContactFrameCallback", RegisterCallback.self)
let mtUnregister = sym("MTUnregisterContactFrameCallback", RegisterCallback.self)
let mtStart = sym("MTDeviceStart", DeviceStart.self)
let mtStop = sym("MTDeviceStop", DeviceStop.self)

func mtSymbolsPresent() -> Bool {
    mtCreateList != nil && mtGetID != nil && mtRegister != nil && mtUnregister != nil && mtStart != nil && mtStop != nil
}

/// One trackpad macOS told us about.
struct TrackpadDevice {
    let id: UInt64
    let builtIn: Bool
    let ref: UnsafeMutableRawPointer
}

/// The CFArray keeps the device pointers alive; never let go of it while a device is started.
var deviceList: CFArray?
var trackpads: [TrackpadDevice] = []

/// Lists the trackpads, built-in first, then by id so the order is stable between launches.
func refreshTrackpads() {
    var found: [TrackpadDevice] = []
    if let mtCreateList, let list = mtCreateList()?.takeRetainedValue() {
        deviceList = list
        for i in 0..<CFArrayGetCount(list) {
            guard let raw = CFArrayGetValueAtIndex(list, i), let mtGetID else { continue }
            let dev = UnsafeMutableRawPointer(mutating: raw)
            var id: UInt64 = 0
            guard mtGetID(dev, &id) == 0 else { continue }
            found.append(TrackpadDevice(id: id, builtIn: mtIsBuiltIn?(dev) ?? false, ref: dev))
        }
    } else {
        deviceList = nil
    }
    trackpads = found.sorted { ($0.builtIn ? 0 : 1, $0.id) < ($1.builtIn ? 0 : 1, $1.id) }
}

/// The trackpad the player chose, or the first one (built-in wins the sort) when they never chose.
func selectedTrackpad() -> TrackpadDevice? {
    if settings.selectedDeviceID != 0, let t = trackpads.first(where: { $0.id == settings.selectedDeviceID }) {
        return t
    }
    return trackpads.first
}

/// Checks with a throwaway device list, so a playing trackpad is never re-enumerated mid-stream.
func deviceStillPresent(_ id: UInt64) -> Bool {
    guard let mtCreateList, let mtGetID, let list = mtCreateList()?.takeRetainedValue() else { return false }
    for i in 0..<CFArrayGetCount(list) {
        guard let raw = CFArrayGetValueAtIndex(list, i) else { continue }
        var other: UInt64 = 0
        if mtGetID(UnsafeMutableRawPointer(mutating: raw), &other) == 0 && other == id { return true }
    }
    return false
}
