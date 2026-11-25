//
// main.swift — entry point. Parses the command line, loads settings, starts the app.
// Top-level code lives only here; every other file is declarations.
//

import Cocoa

cliOptions = parseCommandLine()
settings.load()
if let rows = cliOptions.rows { settings.rows = rows }
if let cols = cliOptions.cols { settings.cols = cols }
settings.clamp()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)   // menu bar only, no Dock icon
app.delegate = appDelegate
app.run()
