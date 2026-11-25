import Cocoa

/// The grid editor: the pads from the current grid settings, drawn like the pad window,
/// each one clickable to color it. Opened from the settings window; changes save at once.
final class PadEditorWindowController: NSObject, NSWindowDelegate {
    let window: NSWindow
    let editorGrid = EditorGridView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let hintLabel = NSTextField(labelWithString: "")
    private var popover: NSPopover?

    override init() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 420, height: 380),
                          styleMask: [.titled, .closable, .resizable],
                          backing: .buffered, defer: false)
        super.init()
        build()
    }

    required init?(coder: NSCoder) { nil }

    private func build() {
        window.title = "Forchpad"
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 300, height: 260)
        // Same dark glass as the pad window, so the colors read the way they'll play.
        applyGlassChrome(window)
        window.appearance = NSAppearance(named: .darkAqua)

        titleLabel.font = NSFont.boldSystemFont(ofSize: 13)
        hintLabel.font = NSFont.systemFont(ofSize: 11)
        hintLabel.textColor = .secondaryLabelColor

        editorGrid.onPadClicked = { [weak self] row, col, rect in
            self?.editPad(row: row, col: col, rect: rect)
        }

        let header = NSStackView(views: [titleLabel, hintLabel])
        header.orientation = .vertical
        header.alignment = .leading
        header.spacing = 2

        // Manual layout, not a stack: the grid must stretch with the window.
        let content = NSView()
        for v in [header, editorGrid] as [NSView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(v)
        }
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            header.topAnchor.constraint(equalTo: content.topAnchor),
            editorGrid.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            editorGrid.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            editorGrid.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            editorGrid.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16),
        ])
        // 28pt of headroom: the traffic lights float above the content.
        embedInGlass(window, content: content, material: .hudWindow, topInset: 28)

        relocalize()
    }

    /// Opens the style popover for one pad, anchored to the pad itself.
    private func editPad(row: Int, col: Int, rect: NSRect) {
        popover?.close()
        let vc = PadStyleEditorViewController(row: row, col: col) { [weak self] in
            self?.editorGrid.needsDisplay = true
            padWindow.gridView.needsDisplay = true
        }
        _ = vc.view   // load now, so the popover gets a real preferredContentSize
        let p = NSPopover()
        p.behavior = .transient
        p.contentViewController = vc
        p.show(relativeTo: rect, of: editorGrid, preferredEdge: .maxY)
        popover = p
    }

    /// Brings the window forward; the app has no Dock icon, so it must be activated by hand.
    func show() {
        if !window.isVisible { window.center() }
        window.makeKeyAndOrderFront(nil)
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    /// Re-renders the strings after a language change.
    func relocalize() {
        titleLabel.stringValue = L("Edit pads")
        hintLabel.stringValue = L("Click a pad to color it.")
    }

    func windowWillClose(_ notification: Notification) {
        popover?.close()
        editorGrid.selected = nil
    }
}

/// The pad grid, made clickable: a click selects the pad and asks for its style popover.
final class EditorGridView: GridView {
    /// The pad under edit (touch coordinates), so its ring stays lit while the popover is up.
    var selected: (row: Int, col: Int)?
    /// Fired on click: the pad's touch row/col and its rect in view coordinates.
    var onPadClicked: ((_ row: Int, _ col: Int, _ rect: NSRect) -> Void)?

    override func draw(_ dirty: NSRect) {
        super.draw(dirty)
        guard let selected,
              (0..<settings.rows).contains(selected.row), (0..<settings.cols).contains(selected.col),
              let ctx = NSGraphicsContext.current?.cgContext else { return }
        let rect = padRect(visualRow: settings.rows - 1 - selected.row, col: selected.col).insetBy(dx: -2.5, dy: -2.5)
        ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.85).cgColor)
        ctx.setLineWidth(2)
        ctx.addPath(CGPath(roundedRect: rect, cornerWidth: 14, cornerHeight: 14, transform: nil))
        ctx.strokePath()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        guard let hit = padAt(viewPoint: point) else { return }
        selected = hit
        needsDisplay = true
        onPadClicked?(hit.row, hit.col, padRect(visualRow: settings.rows - 1 - hit.row, col: hit.col))
    }
}

/// The editor window, built on first use and always on main. Computed on purpose: a plain
/// global can be initialized before the command line is parsed, so --help would build a window.
private var padEditorWindowStorage: PadEditorWindowController?
var padEditorWindow: PadEditorWindowController {
    if let existing = padEditorWindowStorage { return existing }
    let created = PadEditorWindowController()
    padEditorWindowStorage = created
    return created
}

/// Language change without building the window just for that.
func relocalizePadEditorIfExists() { padEditorWindowStorage?.relocalize() }

/// Repaint without building the window just for that (grid size changed in settings).
func refreshPadEditorIfExists() { padEditorWindowStorage?.editorGrid.needsDisplay = true }
