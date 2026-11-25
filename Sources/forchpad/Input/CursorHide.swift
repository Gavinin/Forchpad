import Cocoa

/// Full-lock cursor hiding. A background agent can't hide the pointer directly:
/// NSCursor.hide() only lasts while the app is frontmost (the pad window never takes focus),
/// and macOS 27 ignores CGDisplayHideCursor from a non-active process. What the WindowServer
/// always honors — even for a background app — is the cursor rect of the topmost window under
/// the pointer. So while locked, a transparent overlay per screen covers every display and
/// offers a blank cursor. The event tap (installed before these appear) already drops every
/// click, so the overlays don't need to ignore events; the tap dies with the process, and so
/// do these windows — a crash can never strand a hidden cursor.
var cursorOverlays: [NSWindow] = []

/// Covers every screen with a blank-cursor overlay.
func hideCursor() {
    showCursor()   // balance any previous call
    for screen in NSScreen.screens {
        let window = NSWindow(contentRect: screen.frame, styleMask: .borderless,
                              backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isExcludedFromWindowsMenu = true
        window.sharingType = .none   // don't even show up in screen recordings
        let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
        window.contentView = view
        window.orderFrontRegardless()
        // The blank cursor rect is the whole point: it goes in with the final frame.
        view.addCursorRect(view.bounds, cursor: blankCursor())
        window.invalidateCursorRects(for: view)
        cursorOverlays.append(window)
    }
    cursorHidden = true
}

/// Takes the overlays down; the normal cursor returns everywhere.
func showCursor() {
    for window in cursorOverlays { window.orderOut(nil) }
    cursorOverlays = []
    cursorHidden = false
}

/// A fully transparent cursor: the pointer is there, just not drawn.
func blankCursor() -> NSCursor {
    NSCursor(image: NSImage(size: NSSize(width: 16, height: 16)), hotSpot: .zero)
}
