import Foundation

/// Stops with a plain explanation: a headline, then what happened and what to do, indented.
func fail(_ message: String, headline: String = "Forchpad can't run on this Mac.", code: Int32 = 1) -> Never {
    let body = message.split(separator: "\n", omittingEmptySubsequences: false).map { "  " + $0 }.joined(separator: "\n")
    FileHandle.standardError.write(("\n  " + headline + "\n\n" + body + "\n\n").data(using: .utf8)!)
    exit(code)
}

/// A mistake in how it was run: says what's wrong and points at --help.
func usageError(_ message: String) -> Never {
    fail(message + "\nSee Forchpad --help for the options.", headline: "Forchpad didn't understand that.", code: 64)
}

/// Fills %@ placeholders in a localized string.
func fmt(_ format: String, _ args: CVarArg...) -> String {
    String(format: format, arguments: args)
}

/// Four printable characters packed for Carbon's OSType, like "Fcpd".
func fourCharCode(_ s: String) -> OSType {
    var code: OSType = 0
    for b in s.utf8.prefix(4) { code = (code << 8) | OSType(b) }
    return code
}
