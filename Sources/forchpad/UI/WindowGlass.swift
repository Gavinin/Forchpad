import Cocoa

/// The macOS 27 window look: no title-bar seam — the glass runs edge to edge behind the
/// content, and the traffic lights float on it. The title text is hidden, but the window
/// title still exists for the Window menu and accessibility.
func applyGlassChrome(_ window: NSWindow) {
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.styleMask.insert(.fullSizeContentView)
    window.isOpaque = false
    window.backgroundColor = .clear
    window.isMovableByWindowBackground = true
}

/// Frosted glass that sits behind a window's content. System material, so it adapts to
/// light/dark and picks up whatever the current macOS does for window glass.
func glassBackdrop(material: NSVisualEffectView.Material = .underWindowBackground) -> NSVisualEffectView {
    let glass = NSVisualEffectView()
    glass.material = material
    glass.blendingMode = .behindWindow
    glass.state = .active
    return glass
}

/// Replaces a window's content view with glass and pins the given content flush into it.
/// topInset clears the floating traffic lights (and, on the pad window, the pin button).
func embedInGlass(_ window: NSWindow, content: NSView, material: NSVisualEffectView.Material = .underWindowBackground,
                  topInset: CGFloat = 0) {
    let glass = glassBackdrop(material: material)
    window.contentView = glass
    content.translatesAutoresizingMaskIntoConstraints = false
    glass.addSubview(content)
    NSLayoutConstraint.activate([
        content.leadingAnchor.constraint(equalTo: glass.leadingAnchor),
        content.trailingAnchor.constraint(equalTo: glass.trailingAnchor),
        content.topAnchor.constraint(equalTo: glass.topAnchor, constant: topInset),
        content.bottomAnchor.constraint(equalTo: glass.bottomAnchor),
    ])
}
