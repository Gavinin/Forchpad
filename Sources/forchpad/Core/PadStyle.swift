import Cocoa

/// Per-pad customization, kept in Settings between runs. Optional Codable fields, so a
/// future property (note override, name…) joins without touching anyone's saved data.
struct PadStyle: Codable {
    var colorHex: String?   // "#RRGGBB"; nil = the pad plays with the default accent color
}

// MARK: - Settings

extension Settings {
    /// Dictionary key for a pad, in touch coordinates (row 0 = bottom row, as the engine
    /// counts). Keyed by row/col, not by cell index, so changing the column count never
    /// shuffles colors onto different pads.
    private func padKey(row: Int, col: Int) -> String { "\(row),\(col)" }

    /// The pad's custom color, or nil when it plays with the default accent.
    func padColor(row: Int, col: Int) -> NSColor? {
        guard let hex = padStyles[padKey(row: row, col: col)]?.colorHex else { return nil }
        return NSColor(forchpadHex: hex)
    }

    /// Sets (or clears, with nil) a pad's custom color. Callers save() afterwards.
    func setPadColor(_ color: NSColor?, row: Int, col: Int) {
        let key = padKey(row: row, col: col)
        if let color, let hex = color.forchpadHex {
            padStyles[key] = PadStyle(colorHex: hex)
        } else {
            padStyles.removeValue(forKey: key)
        }
    }
}

// MARK: - Hex colors

extension NSColor {
    /// Reads "#RRGGBB" — the only shape PadStyle writes. Alpha isn't stored: pads are opaque.
    convenience init?(forchpadHex hex: String) {
        var digits = hex
        if digits.hasPrefix("#") { digits.removeFirst() }
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        self.init(srgbRed: CGFloat((value >> 16) & 0xFF) / 255,
                  green: CGFloat((value >> 8) & 0xFF) / 255,
                  blue: CGFloat(value & 0xFF) / 255,
                  alpha: 1)
    }

    /// Writes "#RRGGBB" in sRGB; nil for the rare color that can't be represented there.
    var forchpadHex: String? {
        guard let c = usingColorSpace(.sRGB) else { return nil }
        return String(format: "#%02X%02X%02X",
                      Int((c.redComponent * 255).rounded()),
                      Int((c.greenComponent * 255).rounded()),
                      Int((c.blueComponent * 255).rounded()))
    }
}

// MARK: - Presets

/// The one-tap colors offered in the pad editor — vivid, Launchpad-flavored picks.
/// Fixed sRGB values, not the dynamic system colors, so what's picked is exactly what's saved.
let padColorPresets: [NSColor] = [
    "#FF453A", "#FF9F0A", "#FFD60A", "#32D74B", "#66D4CF", "#64D2FF",
    "#0A84FF", "#5E5CE6", "#BF5AF2", "#FF375F", "#AC8E68", "#FFFFFF",
].compactMap { NSColor(forchpadHex: $0) }
