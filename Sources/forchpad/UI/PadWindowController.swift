import Cocoa

/// The pad grid, in its own small window. It only exists while playing, appears on top by
/// default, can be resized, and has no close button — the shortcut is the only way out.
/// The pin button in the title bar chooses whether it floats above other windows.
final class PadWindowController: NSObject, NSWindowDelegate {
    let window: NSWindow
    let gridView = GridView()
    private var pinButton: NSButton?

    override init() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 360, height: 300),
                          styleMask: [.titled, .resizable],
                          backing: .buffered, defer: false)
        super.init()
        build()
    }

    required init?(coder: NSCoder) { nil }

    private func build() {
        window.title = "Forchpad"
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 240, height: 200)
        // macOS 27 chrome: no title-bar seam; the pads float on dark glass so the glowing
        // ones read like the icon. Dark appearance keeps labels legible over any backdrop.
        applyGlassChrome(window)
        window.appearance = NSAppearance(named: .darkAqua)
        // 28pt of headroom: the traffic lights and the pin button float above the grid.
        embedInGlass(window, content: gridView, material: .hudWindow, topInset: 28)

        // The pin toggle, top right of the title bar.
        let button = NSButton(image: pinImage(), target: self, action: #selector(pinToggled(_:)))
        button.isBordered = false
        button.imageScaling = .scaleProportionallyDown
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 22).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        pinButton = button

        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = button
        accessory.layoutAttribute = .right
        window.addTitlebarAccessoryViewController(accessory)

        applyPinState()
    }

    private func pinImage() -> NSImage {
        let name = settings.pinPadsOnTop ? "pin.fill" : "pin"
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        return NSImage(systemSymbolName: name, accessibilityDescription: L("Keep this window on top"))?
            .withSymbolConfiguration(config) ?? NSImage()
    }

    @objc func pinToggled(_ sender: NSButton) {
        settings.pinPadsOnTop.toggle()
        settings.save()
        applyPinState()
    }

    /// Applies the pin preference: floating over every space, or an ordinary window.
    func applyPinState() {
        if settings.pinPadsOnTop {
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        } else {
            window.level = .normal
            window.collectionBehavior = []
        }
        pinButton?.image = pinImage()
        pinButton?.toolTip = settings.pinPadsOnTop ? L("Let other windows cover it") : L("Keep this window on top")
    }

    /// Shows the pads when playing starts. orderFront on purpose: the DAW keeps key focus.
    /// Every start is topmost — the Esc flow relies on the window staying clickable, and a
    /// buried window can't be. The pin toggle can still drop it mid-performance.
    func show() {
        if !settings.pinPadsOnTop {
            settings.pinPadsOnTop = true
            settings.save()
        }
        applyPinState()
        if !window.isVisible { restorePosition() }
        window.orderFront(nil)
    }

    /// Where the window appears: the spot the player left it (persisted on every move), or
    /// the main screen's top-right corner on first run.
    private func restorePosition() {
        if let x = settings.padWindowX, let y = settings.padWindowY {
            let frame = NSRect(x: x, y: y, width: window.frame.width, height: window.frame.height)
            // A monitor could have left since: only trust positions still on a screen.
            if NSScreen.screens.contains(where: { $0.visibleFrame.intersects(frame) }) {
                window.setFrameOrigin(NSPoint(x: x, y: y))
                return
            }
        }
        if let visible = NSScreen.main?.visibleFrame {
            window.setFrameTopLeftPoint(NSPoint(x: visible.maxX - window.frame.width - 16,
                                                y: visible.maxY - 16))
        }
    }

    /// Remembers where the player parks the pads.
    func windowDidMove(_ notification: Notification) {
        settings.padWindowX = Double(window.frame.origin.x)
        settings.padWindowY = Double(window.frame.origin.y)
        settings.save()
    }

    func hide() {
        window.orderOut(nil)
    }

    func refreshDisplay() {
        if window.isVisible { gridView.needsDisplay = true }
    }

    /// Refreshes the strings that survive a language change (tooltips).
    func relocalize() {
        applyPinState()
    }
}

/// The pad window, built on first use and always on main. Computed on purpose: a plain global
/// can be initialized before the command line is parsed, so --help would build a window.
private var padWindowStorage: PadWindowController?
var padWindow: PadWindowController {
    if let existing = padWindowStorage { return existing }
    let created = PadWindowController()
    padWindowStorage = created
    return created
}

/// True when the pad window exists and is on screen, without building it to find out.
func padWindowIsShowing() -> Bool {
    padWindowStorage?.window.isVisible ?? false
}
