import Foundation
import CoreGraphics
import ImageIO

// Forchpad icon generator — renders the Liquid Glass logo at every iconset size and
// writes build/AppIcon.iconset, then iconutil turns it into Resources/AppIcon.icns.
// Run from the repo root:  swiftc -O tools/genicon.swift -o build/genicon && ./build/genicon

// The design: a frosted-glass squircle (the Force Touch surface) with 3×3 glass pads.
// The amber pad is being pressed (touch ripple), blue sustains, red is armed.

func makeContext(_ S: Int) -> CGContext {
    CGContext(data: nil, width: S, height: S, bitsPerComponent: 8,
              bytesPerRow: S * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}

func drawIcon(size S: Int) -> CGImage {
    let ctx = makeContext(S)
    // Draw in a 1024-unit design space; the context scales everything down.
    let k = CGFloat(S) / 1024
    ctx.scaleBy(x: k, y: k)
    let cs = CGColorSpaceCreateDeviceRGB()

    func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> CGColor {
        CGColor(colorSpace: cs, components: [r, g, b, a])!
    }
    func squircle(center: CGPoint, radius r: CGFloat, n: CGFloat = 5) -> CGPath {
        let path = CGMutablePath()
        let steps = 400
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
            let c = cos(t), s = sin(t)
            let x = center.x + r * pow(abs(c), 2 / n) * (c < 0 ? -1 : 1)
            let y = center.y + r * pow(abs(s), 2 / n) * (s < 0 ? -1 : 1)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
    func glow(at p: CGPoint, radius: CGFloat, color: CGColor) {
        let g = CGGradient(colorsSpace: cs, colors: [color, rgba(1, 1, 1, 0)] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(g, startCenter: p, startRadius: 0, endCenter: p, endRadius: radius, options: [])
    }

    let iconPath = squircle(center: CGPoint(x: 512, y: 512), radius: 412)

    // Frosted glass body
    ctx.saveGState()
    ctx.addPath(iconPath)
    ctx.clip()
    let body = CGGradient(colorsSpace: cs, colors: [
        rgba(0.97, 0.98, 1.00, 1), rgba(0.80, 0.83, 0.90, 1),
    ] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(body, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])
    glow(at: CGPoint(x: 800, y: 860), radius: 620, color: rgba(0.55, 0.68, 1.00, 0.28))
    glow(at: CGPoint(x: 220, y: 180), radius: 560, color: rgba(1.00, 0.78, 0.45, 0.16))
    let bottomShade = CGGradient(colorsSpace: cs, colors: [
        rgba(0.10, 0.14, 0.28, 0.16), rgba(0.10, 0.14, 0.28, 0),
    ] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(bottomShade, start: CGPoint(x: 512, y: 100), end: CGPoint(x: 512, y: 360), options: [])

    // Pad grid — 3×3 glass tiles
    let pad: CGFloat = 176
    let gap: CGFloat = 34
    let gridSpan = 3 * pad + 2 * gap
    let origin = CGPoint(x: 512 - gridSpan / 2, y: 512 - gridSpan / 2)

    struct Pad: Hashable { let col: Int; let row: Int }   // row 0 = bottom
    struct GlassStyle { let top: CGColor; let bottom: CGColor; let halo: CGColor }
    let lit: [Pad: GlassStyle] = [
        Pad(col: 0, row: 0): GlassStyle(top: rgba(1.00, 0.86, 0.58, 1), bottom: rgba(1.00, 0.63, 0.13, 1),
                                        halo: rgba(1.00, 0.68, 0.18, 0.55)),   // pressed, amber
        Pad(col: 1, row: 1): GlassStyle(top: rgba(0.66, 0.82, 1.00, 1), bottom: rgba(0.30, 0.55, 1.00, 1),
                                        halo: rgba(0.38, 0.60, 1.00, 0.45)),   // sustained, blue
        Pad(col: 2, row: 2): GlassStyle(top: rgba(1.00, 0.72, 0.68, 1), bottom: rgba(1.00, 0.38, 0.34, 1),
                                        halo: rgba(1.00, 0.44, 0.38, 0.38)),   // armed, red
    ]

    func padRect(col: Int, row: Int) -> CGRect {
        CGRect(x: origin.x + CGFloat(col) * (pad + gap),
               y: origin.y + CGFloat(row) * (pad + gap),
               width: pad, height: pad)
    }
    func padPath(_ rect: CGRect, inset: CGFloat = 0, corner: CGFloat = 30) -> CGPath {
        CGPath(roundedRect: rect.insetBy(dx: inset, dy: inset), cornerWidth: corner, cornerHeight: corner, transform: nil)
    }

    for (p, style) in lit {
        let r = padRect(col: p.col, row: p.row)
        glow(at: CGPoint(x: r.midX, y: r.midY), radius: pad * 1.5, color: style.halo)
    }

    for row in 0..<3 {
        for col in 0..<3 {
            let rect = padRect(col: col, row: row)
            let path = padPath(rect)
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: rgba(0.10, 0.14, 0.30, 0.22))
            ctx.addPath(path)
            ctx.setFillColor(rgba(1, 1, 1, 1))
            ctx.fillPath()
            ctx.restoreGState()

            let colors: [CGColor]
            if let style = lit[Pad(col: col, row: row)] {
                colors = [style.top, style.bottom]
            } else {
                colors = [rgba(1, 1, 1, 0.72), rgba(1, 1, 1, 0.38)]
            }
            let face = CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: nil)!
            ctx.saveGState()
            ctx.addPath(path)
            ctx.clip()
            ctx.drawLinearGradient(face, start: CGPoint(x: rect.midX, y: rect.maxY),
                                   end: CGPoint(x: rect.midX, y: rect.minY), options: [])
            let streak = CGGradient(colorsSpace: cs, colors: [rgba(1, 1, 1, 0.55), rgba(1, 1, 1, 0)] as CFArray,
                                    locations: [0, 1])!
            ctx.drawLinearGradient(streak, start: CGPoint(x: rect.midX, y: rect.maxY),
                                   end: CGPoint(x: rect.midX, y: rect.maxY - pad * 0.38), options: [])
            ctx.restoreGState()

            ctx.setStrokeColor(rgba(1, 1, 1, 0.65))
            ctx.setLineWidth(2)
            ctx.addPath(padPath(rect, inset: 1, corner: 29))
            ctx.strokePath()
        }
    }

    // Touch ripple on the amber pad — dropped at small sizes where it would only mush.
    if S >= 128 {
        let pressed = padRect(col: 0, row: 0)
        let pc = CGPoint(x: pressed.midX, y: pressed.midY)
        for (r, a) in [(CGFloat(60), 0.50), (94, 0.26), (130, 0.12)] as [(CGFloat, CGFloat)] {
            ctx.setStrokeColor(rgba(1, 1, 1, a))
            ctx.setLineWidth(4.5)
            ctx.strokeEllipse(in: CGRect(x: pc.x - r, y: pc.y - r, width: r * 2, height: r * 2))
        }
        glow(at: pc, radius: 140, color: rgba(1, 1, 1, 0.45))
        ctx.setFillColor(rgba(1, 1, 1, 0.95))
        ctx.fillEllipse(in: CGRect(x: pc.x - 28, y: pc.y - 28, width: 56, height: 56))
    }

    // Rim light, brightest at the top
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(iconPath)
    ctx.clip()
    let rim = CGGradient(colorsSpace: cs, colors: [rgba(1, 1, 1, 0.85), rgba(1, 1, 1, 0.08)] as CFArray,
                         locations: [0, 1])!
    ctx.addPath(squircle(center: CGPoint(x: 512, y: 512), radius: 408))
    ctx.setLineWidth(7)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(rim, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 380), options: [])
    ctx.restoreGState()

    return ctx.makeImage()!
}

func writePNG(_ image: CGImage, to path: String) {
    let url = URL(fileURLWithPath: path)
    let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

// The iconset: (file name, pixel size)
let set = "build/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: "build/AppIcon.iconset")
try! FileManager.default.createDirectory(atPath: set, withIntermediateDirectories: true)
for (name, px) in [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
] as [(String, Int)] {
    writePNG(drawIcon(size: px), to: "\(set)/\(name)")
}
// A standalone 1024 for the README and the web.
writePNG(drawIcon(size: 1024), to: "build/Forchpad-logo-1024.png")
print("iconset written to \(set) (run iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns)")
