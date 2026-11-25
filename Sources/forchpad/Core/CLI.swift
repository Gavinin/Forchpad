import Foundation

/// What the command line asked for. Written once by main.swift before the app starts.
struct CLIOptions {
    var preferExternal = false
    var rows: Int? = nil
    var cols: Int? = nil
    /// Hidden diagnostic: report which event taps this process may create, then quit.
    var probeTap = false
    /// Hidden diagnostic: capture trackpad frames for ten seconds, report counts, then quit.
    var probeTouch = false
}

var cliOptions = CLIOptions()

func printUsage() -> Never {
    print("""
    Forchpad — play a Force Touch trackpad as a grid of MIDI pads.

    Usage: Forchpad [options]

      --external     use an external Magic Trackpad instead of the built-in one
      --rows N       grid rows, 1-10 (default 3)
      --cols N       grid columns, 1-10 (default 3)
      --help         show this text

    The app lives in the menu bar. Press the shortcut (default ⇧⌘E) to start
    and stop playing. While your fingers are on the trackpad the pointer is
    paused; lift them and it works again. The shortcut always stops.
    """)
    exit(0)
}

/// Parses ProcessInfo's arguments; --help exits 0, a bad option exits 64 with a usage error.
func parseCommandLine() -> CLIOptions {
    var args = Array(ProcessInfo.processInfo.arguments.dropFirst())

    /// True when the flag is there; removes it so unknown flags can be caught at the end.
    func flag(_ name: String) -> Bool {
        if let i = args.firstIndex(of: name) {
            args.remove(at: i)
            return true
        }
        return false
    }

    /// The value after an option; missing or another flag is a usage error.
    func option(_ name: String) -> String {
        guard let i = args.firstIndex(of: name) else { return "" }
        args.remove(at: i)
        guard i < args.count, !args[i].hasPrefix("-") else {
            usageError("\(name) needs a value.")
        }
        let value = args[i]
        args.remove(at: i)
        return value
    }

    if flag("--help") || flag("-h") { printUsage() }

    var options = CLIOptions()
    options.preferExternal = flag("--external")
    options.probeTap = flag("--probe-tap")
    options.probeTouch = flag("--probe-touch")
    if args.contains("--rows") {
        let v = option("--rows")
        guard let n = Int(v), (1...10).contains(n) else {
            usageError("--rows needs a whole number between 1 and 10, not \"\(v)\".")
        }
        options.rows = n
    }
    if args.contains("--cols") {
        let v = option("--cols")
        guard let n = Int(v), (1...10).contains(n) else {
            usageError("--cols needs a whole number between 1 and 10, not \"\(v)\".")
        }
        options.cols = n
    }
    // The system adds these when testing languages; they are not ours.
    if let i = args.firstIndex(of: "-AppleLanguages") {
        args.remove(at: i)
        if i < args.count { args.remove(at: i) }
    }
    if let bad = args.first(where: { $0.hasPrefix("-") }) {
        usageError("no such option: \(bad)")
    }
    if !args.isEmpty {
        usageError("unexpected argument: \(args[0])")
    }
    return options
}
