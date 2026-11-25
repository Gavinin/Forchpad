import Cocoa

/// The popover that edits one pad's style, opened from the grid editor. One section per
/// property — today that's only Color; a future property (note override, name…) adds its
/// own build…Section() below and joins the stack in loadView.
final class PadStyleEditorViewController: NSViewController {
    private let row: Int   // touch coordinates, row 0 = bottom (the engine's numbering)
    private let col: Int
    /// Called after every change so the editor grid and the pad window can repaint.
    private let onChange: () -> Void

    private let colorWell = NSColorWell()

    init(row: Int, col: Int, onChange: @escaping () -> Void) {
        self.row = row
        self.col = col
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        let content = NSStackView()
        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 12
        content.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        content.addArrangedSubview(buildColorSection())
        // Future pad properties get their section here.

        view = content
        preferredContentSize = content.fittingSize
    }

    // MARK: Color section

    /// Big title, one-tap presets, the system color well, and a way back to the default.
    private func buildColorSection() -> NSView {
        let section = NSStackView()
        section.orientation = .vertical
        section.alignment = .leading
        section.spacing = 10

        let title = NSTextField(labelWithString: L("Color"))
        title.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        section.addArrangedSubview(title)

        // One-tap presets, like picking a pad color on a hardware controller.
        var swatchRows: [[NSView]] = []
        var rowViews: [NSView] = []
        for color in padColorPresets {
            rowViews.append(makeSwatch(color))
            if rowViews.count == 6 { swatchRows.append(rowViews); rowViews = [] }
        }
        if !rowViews.isEmpty { swatchRows.append(rowViews) }
        let swatches = NSGridView(views: swatchRows)
        swatches.rowSpacing = 8
        swatches.columnSpacing = 8
        section.addArrangedSubview(swatches)

        // Anything the presets don't cover, through the system color picker.
        let customCaption = NSTextField(labelWithString: L("Custom"))
        customCaption.font = NSFont.systemFont(ofSize: 12)
        colorWell.color = settings.padColor(row: row, col: col) ?? NSColor.controlAccentColor
        colorWell.target = self
        colorWell.action = #selector(colorWellChanged(_:))
        let customRow = NSStackView(views: [customCaption, colorWell])
        customRow.orientation = .horizontal
        customRow.alignment = .centerY
        customRow.spacing = 8
        section.addArrangedSubview(customRow)

        let resetButton = NSButton(title: L("Use default color"), target: self, action: #selector(resetClicked(_:)))
        resetButton.bezelStyle = .rounded
        section.addArrangedSubview(resetButton)

        return section
    }

    /// A small button showing a filled color circle; one tap assigns the color.
    private func makeSwatch(_ color: NSColor) -> NSButton {
        let image = NSImage(size: NSSize(width: 20, height: 20), flipped: false) { rect in
            let circle = rect.insetBy(dx: 1, dy: 1)
            color.setFill()
            NSBezierPath(ovalIn: circle).fill()
            NSColor.white.withAlphaComponent(0.25).setStroke()
            let outline = NSBezierPath(ovalIn: circle)
            outline.lineWidth = 1
            outline.stroke()
            return true
        }
        let button = NSButton(image: image, target: self, action: #selector(swatchClicked(_:)))
        button.isBordered = false
        button.imageScaling = .scaleProportionallyDown
        // The color travels with the button; no tags to keep in sync.
        button.identifier = NSUserInterfaceItemIdentifier(color.forchpadHex ?? "")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 22).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        return button
    }

    // MARK: Actions

    @objc private func swatchClicked(_ sender: NSButton) {
        guard let hex = sender.identifier?.rawValue, let color = NSColor(forchpadHex: hex) else { return }
        apply(color)
    }

    @objc private func colorWellChanged(_ sender: NSColorWell) {
        apply(sender.color)
    }

    @objc private func resetClicked(_ sender: NSButton) {
        apply(nil)
    }

    /// Writes the choice, keeps the color well in sync, and repaints everything showing pads.
    private func apply(_ color: NSColor?) {
        settings.setPadColor(color, row: row, col: col)
        settings.save()
        colorWell.color = color ?? NSColor.controlAccentColor
        onChange()
    }
}
