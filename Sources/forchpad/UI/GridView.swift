import Cocoa

/// The margin and spacing every pad layout shares (drawing, hit test, selection ring).
private let padInset: CGFloat = 12
private let padGap: CGFloat = 8

/// Draws the pads (note number in the corner, lit while down) and a dot per live finger.
/// Each pad is a Launchpad-style light in its own assigned color: brightest at the center,
/// easing to a dark rim. Unassigned pads stay neutral glass.
/// Everything is drawn with CGPath: NSBezierPath.cgPath needs macOS 14, we target 12.
class GridView: NSView {
    override var isFlipped: Bool { true }   // so the first row drawn is the top row

    // MARK: Layout

    /// One pad's rect in view coordinates. visualRow 0 is the top row on screen.
    func padRect(visualRow: Int, col: Int) -> CGRect {
        let rows = settings.rows, cols = settings.cols
        let area = bounds.insetBy(dx: padInset, dy: padInset)
        let cw = (area.width - padGap * CGFloat(cols - 1)) / CGFloat(cols)
        let ch = (area.height - padGap * CGFloat(rows - 1)) / CGFloat(rows)
        return CGRect(x: area.origin.x + CGFloat(col) * (cw + padGap),
                      y: area.origin.y + CGFloat(visualRow) * (ch + padGap),
                      width: cw, height: ch)
    }

    /// The pad under a view point, or nil in a gap or the margin. Row is the touch row
    /// (0 = bottom) — the same numbering the engine uses for notes.
    func padAt(viewPoint: NSPoint) -> (row: Int, col: Int)? {
        guard settings.rows > 0, settings.cols > 0 else { return nil }
        for visualRow in 0..<settings.rows {
            for col in 0..<settings.cols
            where padRect(visualRow: visualRow, col: col).contains(viewPoint) {
                return (settings.rows - 1 - visualRow, col)
            }
        }
        return nil
    }

    // MARK: Drawing

    override func draw(_ dirty: NSRect) {
        let rows = settings.rows, cols = settings.cols
        guard rows > 0, cols > 0, let ctx = NSGraphicsContext.current?.cgContext else { return }

        os_unfair_lock_lock(&displayLock)
        let pads = displayState.pads
        let contacts = displayState.contacts
        let isLive = displayState.performing
        os_unfair_lock_unlock(&displayLock)

        let area = bounds.insetBy(dx: padInset, dy: padInset)
        let cw = (area.width - padGap * CGFloat(cols - 1)) / CGFloat(cols)
        let ch = (area.height - padGap * CGFloat(rows - 1)) / CGFloat(rows)
        guard cw > 0, ch > 0 else { return }

        let accent = NSColor.controlAccentColor
        let cs = CGColorSpaceCreateDeviceRGB()

        func roundPath(_ rect: CGRect, corner: CGFloat = 12) -> CGPath {
            CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
        }
        /// A white specular streak across the top of a pad — the glass catching light.
        /// (isFlipped: the pad's top edge is rect.minY in view coordinates.)
        func specular(_ rect: CGRect, path: CGPath, alpha: CGFloat) {
            let g = CGGradient(colorsSpace: cs, colors: [
                NSColor.white.withAlphaComponent(alpha).cgColor,
                NSColor.white.withAlphaComponent(0).cgColor,
            ] as CFArray, locations: [0, 1])!
            ctx.saveGState()
            ctx.addPath(path)
            ctx.clip()
            ctx.drawLinearGradient(g, start: CGPoint(x: rect.midX, y: rect.minY),
                                   end: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.45), options: [])
            ctx.restoreGState()
        }

        for visualRow in 0..<rows {
            for col in 0..<cols {
                // Top of the window is the far side of the glass (y near 1).
                let touchRow = rows - 1 - visualRow
                let cell = touchRow * cols + col
                let rect = padRect(visualRow: visualRow, col: col)
                let down = pads[cell]
                let path = roundPath(rect)
                let center = CGPoint(x: rect.midX, y: rect.midY)
                // This pad's assigned color; unassigned pads play with the system accent.
                let custom = settings.padColor(row: touchRow, col: col)
                let base = custom ?? accent

                if let size = down {
                    let intensity = CGFloat(min(1, 0.35 + size * 6))
                    // Luminous glass: a halo behind the pad, then the lit face.
                    let halo = CGGradient(colorsSpace: cs, colors: [
                        base.withAlphaComponent(0.40 * intensity).cgColor,
                        base.withAlphaComponent(0).cgColor,
                    ] as CFArray, locations: [0, 1])!
                    ctx.drawRadialGradient(halo, startCenter: center, startRadius: 0,
                                           endCenter: center, endRadius: max(cw, ch) * 0.95, options: [])
                    // The Launchpad LED: a white-hot center, the pad's color, a dark rim.
                    let face = CGGradient(colorsSpace: cs, colors: [
                        base.blended(withFraction: 0.55 * intensity, of: .white)!.cgColor,
                        base.cgColor,
                        base.blended(withFraction: 0.45, of: .black)!.cgColor,
                    ] as CFArray, locations: [0, 0.45, 1])!
                    ctx.saveGState()
                    ctx.addPath(path)
                    ctx.clip()
                    ctx.drawRadialGradient(face, startCenter: center, startRadius: 0,
                                           endCenter: center, endRadius: hypot(cw, ch) / 2, options: [])
                    ctx.restoreGState()
                    specular(rect, path: path, alpha: 0.35)
                    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.5).cgColor)
                    ctx.setLineWidth(1)
                    ctx.addPath(path)
                    ctx.strokePath()
                } else if custom != nil {
                    // Assigned but at rest: a dim glow of its own color, like hardware pads.
                    let dim = CGGradient(colorsSpace: cs, colors: [
                        base.withAlphaComponent(0.30).cgColor,
                        base.withAlphaComponent(0.08).cgColor,
                    ] as CFArray, locations: [0, 1])!
                    ctx.saveGState()
                    ctx.addPath(path)
                    ctx.clip()
                    ctx.drawRadialGradient(dim, startCenter: center, startRadius: 0,
                                           endCenter: center, endRadius: hypot(cw, ch) / 2, options: [])
                    ctx.restoreGState()
                    ctx.setStrokeColor(base.withAlphaComponent(0.40).cgColor)
                    ctx.setLineWidth(1)
                    ctx.addPath(path)
                    ctx.strokePath()
                } else {
                    // Idle glass tile: faint white, brighter at the top.
                    ctx.setFillColor(NSColor.white.withAlphaComponent(0.09).cgColor)
                    ctx.addPath(path)
                    ctx.fillPath()
                    specular(rect, path: path, alpha: 0.13)
                    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.14).cgColor)
                    ctx.setLineWidth(1)
                    ctx.addPath(path)
                    ctx.strokePath()
                }

                let label = String(settings.baseNote + cell)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium),
                    .foregroundColor: down != nil ? NSColor.white.withAlphaComponent(0.92)
                                                  : NSColor.white.withAlphaComponent(0.38),
                ]
                let labelSize = label.size(withAttributes: attrs)
                label.draw(at: NSPoint(x: rect.maxX - labelSize.width - 8, y: rect.maxY - labelSize.height - 6),
                           withAttributes: attrs)
            }
        }

        // Live fingers: a white ring with a red core, legible on any pad.
        for c in contacts {
            let px = area.origin.x + CGFloat(c.x) * area.width
            let py = area.origin.y + CGFloat(1 - c.y) * area.height
            let d: CGFloat = 10
            ctx.setFillColor(NSColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: px - d / 2 - 1.5, y: py - d / 2 - 1.5, width: d + 3, height: d + 3))
            ctx.setFillColor(NSColor.systemRed.cgColor)
            ctx.fillEllipse(in: CGRect(x: px - d / 2, y: py - d / 2, width: d, height: d))
        }

        // A thin accent ring while playing, so the window reads "live" at a glance.
        if isLive {
            ctx.setStrokeColor(accent.withAlphaComponent(0.35).cgColor)
            ctx.setLineWidth(2)
            ctx.addPath(roundPath(area))
            ctx.strokePath()
        }
    }
}
