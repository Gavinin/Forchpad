import Cocoa

/// Draws the pads (note number in the corner, lit while down) and a dot per live finger.
/// The pads are glass tiles on the window's frosted backdrop — the same language as the icon.
/// Everything is drawn with CGPath: NSBezierPath.cgPath needs macOS 14, we target 12.
final class GridView: NSView {
    override var isFlipped: Bool { true }   // so the first row drawn is the top row

    override func draw(_ dirty: NSRect) {
        let rows = settings.rows, cols = settings.cols
        guard rows > 0, cols > 0, let ctx = NSGraphicsContext.current?.cgContext else { return }

        os_unfair_lock_lock(&displayLock)
        let pads = displayState.pads
        let contacts = displayState.contacts
        let isLive = displayState.performing
        os_unfair_lock_unlock(&displayLock)

        let inset: CGFloat = 12
        let gap: CGFloat = 8
        let area = bounds.insetBy(dx: inset, dy: inset)
        let cw = (area.width - gap * CGFloat(cols - 1)) / CGFloat(cols)
        let ch = (area.height - gap * CGFloat(rows - 1)) / CGFloat(rows)
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
                let rect = CGRect(x: area.origin.x + CGFloat(col) * (cw + gap),
                                  y: area.origin.y + CGFloat(visualRow) * (ch + gap),
                                  width: cw, height: ch)
                let down = pads[cell]
                let path = roundPath(rect)

                if let size = down {
                    let intensity = CGFloat(min(1, 0.35 + size * 6))
                    // Luminous glass: a halo behind the pad, then the lit face.
                    let halo = CGGradient(colorsSpace: cs, colors: [
                        accent.withAlphaComponent(0.40 * intensity).cgColor,
                        accent.withAlphaComponent(0).cgColor,
                    ] as CFArray, locations: [0, 1])!
                    ctx.drawRadialGradient(halo, startCenter: CGPoint(x: rect.midX, y: rect.midY),
                                           startRadius: 0, endCenter: CGPoint(x: rect.midX, y: rect.midY),
                                           endRadius: max(cw, ch) * 0.95, options: [])
                    let face = CGGradient(colorsSpace: cs, colors: [
                        accent.blended(withFraction: 0.35, of: .white)!.cgColor,
                        accent.cgColor,
                    ] as CFArray, locations: [0, 1])!
                    ctx.saveGState()
                    ctx.addPath(path)
                    ctx.clip()
                    ctx.drawLinearGradient(face, start: CGPoint(x: rect.midX, y: rect.minY),
                                           end: CGPoint(x: rect.midX, y: rect.maxY), options: [])
                    ctx.restoreGState()
                    specular(rect, path: path, alpha: 0.45)
                    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.5).cgColor)
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
