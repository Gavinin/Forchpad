import Cocoa

/// The settings window: trackpad, language, grid size, shortcut, MIDI. No pad grid here —
/// the grid lives in the pad window, which only appears while playing. Closing this window
/// never quits the app.
final class SettingsWindowController: NSObject, NSWindowDelegate {
    let window: NSWindow

    // Value controls.
    let statusLabel = NSTextField(wrappingLabelWithString: "")
    let devicePopup = NSPopUpButton()
    let languagePopup = NSPopUpButton()
    let rowsField = NSTextField()
    let colsField = NSTextField()
    let rowsStepper = NSStepper()
    let colsStepper = NSStepper()
    let startHotkeyLabel = NSTextField(labelWithString: "")
    let recordButton = NSButton()
    let pauseHotkeyLabel = NSTextField(labelWithString: "")
    let pauseRecordButton = NSButton()
    let pausePointerCheckbox = NSButton()
    let lockPointerCheckbox = NSButton()
    let channelField = NSTextField()
    let baseNoteField = NSTextField()
    let velocityField = NSTextField()
    let confirmButton = NSButton()
    let openSettingsButton = NSButton()
    let editPadsButton = NSButton()

    // Captions, kept so a language change can re-render them.
    private let deviceCaption = NSTextField(labelWithString: "")
    private let languageCaption = NSTextField(labelWithString: "")
    private let rowsCaption = NSTextField(labelWithString: "")
    private let colsCaption = NSTextField(labelWithString: "")
    private let startHotkeyCaption = NSTextField(labelWithString: "")
    private let pauseHotkeyCaption = NSTextField(labelWithString: "")
    private let pausePointerHint = NSTextField(wrappingLabelWithString: "")
    private let lockPointerHint = NSTextField(wrappingLabelWithString: "")
    private let generalTitleCaption = NSTextField(labelWithString: "")
    private let shortcutTitleCaption = NSTextField(labelWithString: "")
    private let playingTitleCaption = NSTextField(labelWithString: "")
    private let midiTitleCaption = NSTextField(labelWithString: "")
    private let channelCaption = NSTextField(labelWithString: "")
    private let baseCaption = NSTextField(labelWithString: "")
    private let velocityCaption = NSTextField(labelWithString: "")

    /// Which hot key is being recorded right now, if any.
    var recordingHotKey: AppHotKey?
    var recordMonitor: Any?

    override init() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 380, height: 340),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered, defer: false)
        super.init()
        build()
    }

    required init?(coder: NSCoder) { nil }

    /// A labeled text field narrow enough for three MIDI numbers.
    private func numberField(_ field: NSTextField, min: Int, max: Int, width: CGFloat) {
        let f = NumberFormatter()
        f.allowsFloats = false
        f.minimum = NSNumber(value: min)
        f.maximum = NSNumber(value: max)
        field.formatter = f
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    private func caption(_ label: NSTextField) -> NSTextField {
        label.font = NSFont.systemFont(ofSize: 12)
        return label
    }

    private func separator() -> NSBox {
        let box = NSBox()
        box.boxType = .separator
        return box
    }

    private func build() {
        window.title = "Forchpad"
        window.delegate = self
        window.isReleasedWhenClosed = false
        // macOS 27 chrome: no title-bar seam, the whole window is one sheet of glass.
        applyGlassChrome(window)

        numberField(rowsField, min: 1, max: 10, width: 44)
        numberField(colsField, min: 1, max: 10, width: 44)
        numberField(channelField, min: 1, max: 16, width: 52)
        numberField(baseNoteField, min: 0, max: 127, width: 52)
        numberField(velocityField, min: 1, max: 127, width: 52)

        rowsStepper.minValue = 1; rowsStepper.maxValue = 10; rowsStepper.increment = 1
        colsStepper.minValue = 1; colsStepper.maxValue = 10; colsStepper.increment = 1
        rowsStepper.target = self; rowsStepper.action = #selector(stepperChanged(_:))
        colsStepper.target = self; colsStepper.action = #selector(stepperChanged(_:))

        recordButton.bezelStyle = .rounded
        recordButton.target = self
        recordButton.action = #selector(recordClicked(_:))
        pauseRecordButton.bezelStyle = .rounded
        pauseRecordButton.target = self
        pauseRecordButton.action = #selector(recordClicked(_:))

        pausePointerCheckbox.setButtonType(.switch)
        pausePointerCheckbox.target = self
        pausePointerCheckbox.action = #selector(pausePointerChanged(_:))
        lockPointerCheckbox.setButtonType(.switch)
        lockPointerCheckbox.target = self
        lockPointerCheckbox.action = #selector(lockPointerChanged(_:))

        confirmButton.bezelStyle = .rounded
        confirmButton.target = self
        confirmButton.action = #selector(confirmClicked(_:))
        confirmButton.keyEquivalent = "\r"

        openSettingsButton.bezelStyle = .rounded
        openSettingsButton.target = self
        openSettingsButton.action = #selector(openSettingsClicked(_:))
        openSettingsButton.isHidden = true

        editPadsButton.bezelStyle = .rounded
        editPadsButton.target = self
        editPadsButton.action = #selector(editPadsClicked(_:))

        devicePopup.target = self
        devicePopup.action = #selector(deviceChanged(_:))
        languagePopup.target = self
        languagePopup.action = #selector(languageChanged(_:))

        // One fixed content width; every section lines up inside it. The form is two
        // columns: captions on the trailing edge of a fixed first column, controls next.
        let contentWidth: CGFloat = 420
        let inset: CGFloat = 20
        let captionWidth: CGFloat = 100
        let controlWidth = contentWidth - inset * 2 - captionWidth - 8

        statusLabel.font = NSFont.systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.preferredMaxLayoutWidth = contentWidth - inset * 2
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.maximumNumberOfLines = 0

        startHotkeyLabel.font = NSFont.boldSystemFont(ofSize: 13)
        pauseHotkeyLabel.font = NSFont.boldSystemFont(ofSize: 13)

        devicePopup.translatesAutoresizingMaskIntoConstraints = false
        devicePopup.widthAnchor.constraint(equalToConstant: controlWidth).isActive = true
        languagePopup.translatesAutoresizingMaskIntoConstraints = false
        languagePopup.widthAnchor.constraint(equalToConstant: controlWidth).isActive = true

        pausePointerHint.font = NSFont.systemFont(ofSize: 11)
        pausePointerHint.textColor = .secondaryLabelColor
        pausePointerHint.preferredMaxLayoutWidth = controlWidth
        pausePointerHint.lineBreakMode = .byWordWrapping
        pausePointerHint.maximumNumberOfLines = 0
        lockPointerHint.font = NSFont.systemFont(ofSize: 11)
        lockPointerHint.textColor = .secondaryLabelColor
        lockPointerHint.preferredMaxLayoutWidth = controlWidth
        lockPointerHint.lineBreakMode = .byWordWrapping
        lockPointerHint.maximumNumberOfLines = 0

        for title in [generalTitleCaption, shortcutTitleCaption, playingTitleCaption, midiTitleCaption] {
            title.font = NSFont.boldSystemFont(ofSize: 13)
        }

        /// A two-column form grid: captions in a fixed column, controls next, all aligned.
        func formGrid(_ rows: [[NSView]]) -> NSGridView {
            let grid = NSGridView(views: rows)
            grid.column(at: 0).width = captionWidth
            grid.column(at: 0).xPlacement = .trailing
            grid.rowSpacing = 8
            grid.columnSpacing = 8
            return grid
        }

        /// A bold title over its form, with room to breathe between sections.
        func section(_ title: NSView, _ form: NSView) -> NSStackView {
            let stack = NSStackView(views: [title, form])
            stack.orientation = .vertical
            stack.alignment = .leading
            stack.spacing = 6
            return stack
        }

        let rowsCluster = NSStackView(views: [rowsField, rowsStepper])
        rowsCluster.spacing = 4
        let colsCluster = NSStackView(views: [colsField, colsStepper])
        colsCluster.spacing = 4
        let hotkeyCluster = NSStackView(views: [startHotkeyLabel, recordButton])
        hotkeyCluster.spacing = 8
        let pauseHotkeyCluster = NSStackView(views: [pauseHotkeyLabel, pauseRecordButton])
        pauseHotkeyCluster.spacing = 8

        let generalSection = section(generalTitleCaption, formGrid([
            [caption(languageCaption), languagePopup],
        ]))
        let shortcutSection = section(shortcutTitleCaption, formGrid([
            [caption(startHotkeyCaption), hotkeyCluster],
            [caption(pauseHotkeyCaption), pauseHotkeyCluster],
        ]))
        let playingSection = section(playingTitleCaption, formGrid([
            [caption(deviceCaption), devicePopup],
            [caption(rowsCaption), rowsCluster],
            [caption(colsCaption), colsCluster],
            [NSGridCell.emptyContentView, editPadsButton],
            [NSGridCell.emptyContentView, pausePointerCheckbox],
            [NSGridCell.emptyContentView, pausePointerHint],
            [NSGridCell.emptyContentView, lockPointerCheckbox],
            [NSGridCell.emptyContentView, lockPointerHint],
        ]))
        let midiSection = section(midiTitleCaption, formGrid([
            [caption(channelCaption), channelField],
            [caption(baseCaption), baseNoteField],
            [caption(velocityCaption), velocityField],
        ]))

        // Buttons sit at the trailing edge, like a system dialog.
        let spring = NSView()
        spring.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
        let buttonRow = NSStackView(views: [spring, openSettingsButton, confirmButton])
        buttonRow.spacing = 12
        buttonRow.translatesAutoresizingMaskIntoConstraints = false
        buttonRow.widthAnchor.constraint(equalToConstant: contentWidth - inset * 2).isActive = true
        let buttonSeparator = separator()
        buttonSeparator.translatesAutoresizingMaskIntoConstraints = false
        buttonSeparator.widthAnchor.constraint(equalToConstant: contentWidth - inset * 2).isActive = true

        // Status line lives at the bottom, just above the buttons, with air around it —
        // like the message in a system dialog.
        let content = NSStackView(views: [
            generalSection, shortcutSection, playingSection, midiSection, buttonSeparator, statusLabel, buttonRow,
        ])
        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 10
        // No title bar anymore: extra headroom so the traffic lights don't sit on the first section.
        content.edgeInsets = NSEdgeInsets(top: 34, left: inset, bottom: inset, right: inset)
        content.setCustomSpacing(16, after: generalSection)
        content.setCustomSpacing(16, after: shortcutSection)
        content.setCustomSpacing(16, after: playingSection)
        content.setCustomSpacing(16, after: midiSection)
        content.setCustomSpacing(14, after: buttonSeparator)
        content.setCustomSpacing(14, after: statusLabel)

        embedInGlass(window, content: content)
        window.setContentSize(NSSize(width: contentWidth, height: content.fittingSize.height))
        window.center()

        relocalize()
        refreshFields()
        performStateChanged()
    }

    // MARK: Actions

    @objc func stepperChanged(_ sender: NSStepper) {
        if sender == rowsStepper { rowsField.stringValue = String(sender.integerValue) }
        if sender == colsStepper { colsField.stringValue = String(sender.integerValue) }
    }

    @objc func deviceChanged(_ sender: NSPopUpButton) {
        if let num = sender.selectedItem?.representedObject as? NSNumber {
            settings.selectedDeviceID = num.uint64Value
            settings.save()
        }
        performStateChanged()
    }

    @objc func languageChanged(_ sender: NSPopUpButton) {
        let code = sender.selectedItem?.representedObject as? String ?? ""
        settings.languageOverride = code.isEmpty ? nil : code
        settings.save()
        appDelegate.relocalizeUI()
    }

    @objc func pausePointerChanged(_ sender: NSButton) {
        settings.pausePointer = sender.state == .on
        settings.save()
        // Turning it on needs macOS to say yes; register and ask now, not at shortcut time.
        if settings.pausePointer {
            ensureAccessibilityInterest()
        }
        performStateChanged()
    }

    @objc func lockPointerChanged(_ sender: NSButton) {
        settings.lockPointer = sender.state == .on
        settings.save()
        performStateChanged()
    }

    @objc func recordClicked(_ sender: NSButton) {
        let which: AppHotKey = sender == pauseRecordButton ? .pause : .toggle
        if recordingHotKey != nil { stopRecording(); return }
        recordingHotKey = which
        (which == .pause ? pauseRecordButton : recordButton).title = L("Press a shortcut…")
        recordMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self, let which = self.recordingHotKey else { return event }
            if event.type == .flagsChanged { return nil }
            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if event.keyCode == 53 && mods.isEmpty {   // plain Esc cancels
                self.stopRecording()
                return nil
            }
            // A shortcut with no modifier would steal that letter from every app, so it's not allowed.
            guard mods.contains(.command) || mods.contains(.control) || mods.contains(.option) || mods.contains(.shift) else {
                return nil
            }
            let carbon = carbonModifiers(mods)
            let status = reregisterHotKey(which, keyCode: UInt32(event.keyCode), modifiers: carbon)
            if status == noErr {
                which.save(keyCode: UInt32(event.keyCode), modifiers: carbon,
                           display: hotkeyDisplayString(keyCode: event.keyCode, flags: mods,
                                                        characters: event.charactersIgnoringModifiers))
                self.stopRecording()
                self.performStateChanged()
            } else {
                self.stopRecording()
                self.setStatus(L("That shortcut is already taken. Choose another."))
            }
            return nil
        }
    }

    private func stopRecording() {
        recordingHotKey = nil
        if let monitor = recordMonitor { NSEvent.removeMonitor(monitor) }
        recordMonitor = nil
        recordButton.title = L("Record")
        pauseRecordButton.title = L("Record")
    }

    @objc func confirmClicked(_ sender: NSButton) {
        guard let (rows, cols, channel, base, vel) = validatedFields() else { return }
        if !settings.confirmed {
            // First time only: make sure the pointer pause is understood before it can happen.
            let alert = NSAlert()
            alert.messageText = L("Before you play")
            alert.informativeText = fmt(L("While your fingers are on the trackpad, the pointer is paused; lift them and it works again. Press %@ at any time to stop. Mission Control and other trackpad gestures may still fire; turn them off in System Settings if they get in the way."), settings.hotkeyDisplay)
            alert.addButton(withTitle: L("I understand"))
            alert.addButton(withTitle: L("Cancel"))
            alert.beginSheetModal(for: window) { [weak self] response in
                guard let self, response == .alertFirstButtonReturn else { return }
                self.applyFields(rows: rows, cols: cols, channel: channel, base: base, vel: vel)
            }
            return
        }
        applyFields(rows: rows, cols: cols, channel: channel, base: base, vel: vel)
    }

    @objc func openSettingsClicked(_ sender: NSButton) {
        openAccessibilitySettings()
    }

    @objc func editPadsClicked(_ sender: NSButton) {
        padEditorWindow.show()
    }

    /// Reads the fields; on a bad value, says why and returns nil.
    private func validatedFields() -> (rows: Int, cols: Int, channel: Int, base: Int, vel: Int)? {
        guard let rows = Int(rowsField.stringValue), let cols = Int(colsField.stringValue),
              (1...10).contains(rows), (1...10).contains(cols) else {
            setStatus(L("Rows and columns must be whole numbers between 1 and 10."))
            return nil
        }
        guard let channel = Int(channelField.stringValue), (1...16).contains(channel) else {
            setStatus(L("MIDI channel must be 1–16."))
            return nil
        }
        guard let vel = Int(velocityField.stringValue), (1...127).contains(vel) else {
            setStatus(L("Velocity must be 1–127."))
            return nil
        }
        guard let base = Int(baseNoteField.stringValue), (0...127).contains(base),
              base + rows * cols - 1 <= 127 else {
            setStatus(L("Base note plus the grid size must stay at or below note 127."))
            return nil
        }
        return (rows, cols, channel, base, vel)
    }

    private func applyFields(rows: Int, cols: Int, channel: Int, base: Int, vel: Int) {
        settings.rows = rows
        settings.cols = cols
        settings.midiChannel = channel
        settings.baseNote = base
        settings.velocity = vel
        settings.confirmed = true
        settings.save()
        // The shortcut is about to start working; register and ask for the permission it needs.
        if settings.pausePointer {
            ensureAccessibilityInterest()
        }
        padWindow.gridView.needsDisplay = true
        refreshPadEditorIfExists()
        performStateChanged()
        // Saved and done: the window's job is over until the menu bar brings it back.
        window.close()
    }

    // MARK: State display

    /// Puts the settings back into the fields (called when the window opens).
    func refreshFields() {
        rowsField.stringValue = String(settings.rows)
        colsField.stringValue = String(settings.cols)
        rowsStepper.integerValue = settings.rows
        colsStepper.integerValue = settings.cols
        channelField.stringValue = String(settings.midiChannel)
        baseNoteField.stringValue = String(settings.baseNote)
        velocityField.stringValue = String(settings.velocity)
        startHotkeyLabel.stringValue = settings.hotkeyDisplay
        pauseHotkeyLabel.stringValue = settings.pauseHotkeyDisplay
        pausePointerCheckbox.state = settings.pausePointer ? .on : .off
        lockPointerCheckbox.state = settings.lockPointer ? .on : .off
        updateDevicePopup()
        updateLanguagePopup()
        updateConfirmButton()
    }

    func updateDevicePopup() {
        let selected = settings.selectedDeviceID
        devicePopup.removeAllItems()
        let builtInCount = trackpads.filter(\.builtIn).count
        let externalCount = trackpads.count - builtInCount
        for t in trackpads {
            var title = t.builtIn ? L("Built-in trackpad") : L("Magic Trackpad")
            // Two of the same kind need a way to tell them apart.
            if (t.builtIn && builtInCount > 1) || (!t.builtIn && externalCount > 1) {
                title += String(format: " (%04llX)", t.id & 0xFFFF)
            }
            devicePopup.addItem(withTitle: title)
            devicePopup.lastItem?.representedObject = NSNumber(value: t.id)
            if t.id == selected { devicePopup.select(devicePopup.lastItem) }
        }
        if devicePopup.selectedItem == nil, devicePopup.numberOfItems > 0 {
            devicePopup.selectItem(at: 0)
        }
        devicePopup.isEnabled = !trackpads.isEmpty
    }

    func updateLanguagePopup() {
        languagePopup.removeAllItems()
        for choice in languageChoices {
            let title = choice.code == nil ? L("System language") : choice.name
            languagePopup.addItem(withTitle: title)
            languagePopup.lastItem?.representedObject = choice.code ?? ""
            if choice.code == settings.languageOverride {
                languagePopup.select(languagePopup.lastItem)
            }
        }
        if languagePopup.selectedItem == nil { languagePopup.selectItem(at: 0) }
    }

    private func updateConfirmButton() {
        confirmButton.title = settings.confirmed ? L("Save") : L("Confirm settings")
    }

    /// Re-renders every localized string the window is showing.
    func relocalize() {
        if recordingHotKey != nil { stopRecording() }
        deviceCaption.stringValue = L("Trackpad")
        languageCaption.stringValue = L("Language")
        rowsCaption.stringValue = L("Rows")
        colsCaption.stringValue = L("Columns")
        startHotkeyCaption.stringValue = L("Start/Stop")
        pauseHotkeyCaption.stringValue = L("Temporary pause")
        pausePointerCheckbox.title = L("Pause the pointer while playing")
        pausePointerHint.stringValue = L("When off, touches also move and click the pointer.")
        lockPointerCheckbox.title = L("Lock the pointer completely while playing")
        lockPointerHint.stringValue = L("When off, the pointer is only paused while your fingers are on the glass.")
        generalTitleCaption.stringValue = L("General")
        shortcutTitleCaption.stringValue = L("Shortcut settings")
        playingTitleCaption.stringValue = L("Playing")
        midiTitleCaption.stringValue = L("MIDI settings")
        channelCaption.stringValue = L("MIDI channel")
        baseCaption.stringValue = L("Base note")
        velocityCaption.stringValue = L("Velocity")
        recordButton.title = L("Record")
        pauseRecordButton.title = L("Record")
        openSettingsButton.title = L("Open System Settings")
        editPadsButton.title = L("Edit pads…")
        updateDevicePopup()
        updateLanguagePopup()
        updateConfirmButton()
        performStateChanged()
    }

    /// Shows a one-off message until the next state change recomputes the status line.
    func setStatus(_ text: String) {
        statusLabel.stringValue = text
    }

    /// Recomputes everything that depends on the play state: status line, enabled controls, menu-bar icon.
    func performStateChanged() {
        statusLabel.stringValue = defaultStatus()
        startHotkeyLabel.stringValue = settings.hotkeyDisplay
        pauseHotkeyLabel.stringValue = settings.pauseHotkeyDisplay
        updateConfirmButton()
        openSettingsButton.isHidden = !permissionProblem

        let editable = !performing && !pendingStart
        for control in [devicePopup as NSControl, languagePopup, rowsField, colsField, rowsStepper, colsStepper,
                        recordButton, pauseRecordButton, pausePointerCheckbox, channelField, baseNoteField, velocityField, confirmButton] {
            control.isEnabled = editable
        }
        // Full lock only makes sense when the pointer pauses at all.
        lockPointerCheckbox.isEnabled = editable && settings.pausePointer
        updateDevicePopup()
    }

    /// The status line for the current state, in plain words.
    private func defaultStatus() -> String {
        let key = settings.hotkeyDisplay
        if performing { return fmt(L("Performing — press %@ to stop."), key) }
        if paused { return fmt(L("Paused — press %@ to resume, %@ to stop."), settings.pauseHotkeyDisplay, key) }
        if pendingStart { return L("Release the mouse button to start…") }
        if permissionProblem {
            return fmt(L("Forchpad needs permission to pause the pointer. Open System Settings, allow accessibility, then press %@ again."), key)
        }
        if !mtSymbolsPresent() {
            return L("This macOS version doesn't have the trackpad functions Forchpad needs.")
        }
        if trackpads.isEmpty {
            return L("No trackpad found. Connect a Force Touch trackpad.")
        }
        if !settings.confirmed {
            return fmt(L("Confirm your settings below, then press %@ to start playing."), key)
        }
        return fmt(L("Ready — press %@ to play."), key)
    }

    /// Brings the window forward; the app has no Dock icon, so it must be activated by hand.
    func show() {
        refreshFields()
        if !window.isVisible { window.center() }
        window.makeKeyAndOrderFront(nil)
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func windowWillClose(_ notification: Notification) {
        if recordingHotKey != nil { stopRecording() }
    }
}

/// The settings window, built on first use and always on main. Computed on purpose: a plain
/// global can be initialized before the command line is parsed, so --help would build a window.
private var settingsWindowStorage: SettingsWindowController?
var settingsWindow: SettingsWindowController {
    if let existing = settingsWindowStorage { return existing }
    let created = SettingsWindowController()
    settingsWindowStorage = created
    return created
}
