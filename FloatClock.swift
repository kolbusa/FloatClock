// The MIT License

// Copyright (c) 2018 Daniel
// Copyright (c) 2023 Roman Dubtsov

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// How to build:
// $ swiftc -o clock -gnone -O -target x86_64-apple-macosx10.14 clock.swift
// How to run:
// $ ./clock

import Cocoa

class Clock: NSObject, NSApplicationDelegate {
    var timer : NSWindow?

    func updateWindowPosition() {
        let windowWidth: CGFloat = 120
        let windowHeight: CGFloat = 30

        let screenWidth = (NSScreen.main?.frame.width)!
        let screenHeight = (NSScreen.main?.frame.height)!

        timer?.setFrameOrigin(NSMakePoint(screenWidth - windowWidth, screenHeight - windowHeight))
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.initTimeDisplay()

        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
                                       object: NSApplication.shared,
                                       queue: OperationQueue.main) {
                                       notification -> Void in
                                       self.updateWindowPosition()}
    }

    func initLabel(font: NSFont, format: String, interval: TimeInterval) -> NSTextField {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        let label = NSTextField()
        label.font = font
        label.isBezeled = false
        label.isEditable = false
        label.drawsBackground = false
        label.alignment = .center
        /* label.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1-1/8) */
        label.textColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1-1/8)

        let shadow = NSShadow()
        /* shadow.shadowColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1-1/8) */
        shadow.shadowColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadow.shadowOffset = NSMakeSize(0, 0)
        shadow.shadowBlurRadius = 1;
        label.shadow = shadow

        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            label.stringValue = formatter.string(from: Date())
        }
        timer.tolerance = interval / 10
        timer.fire()

        return label
    }

    func initWindow(rect: NSRect, label: NSTextField) -> NSWindow {
        let window = NSWindow(
            contentRect : rect,
            styleMask   : .borderless,
            backing     : .buffered,
            defer       : true
        )

        window.contentView = label
        window.ignoresMouseEvents = true
        window.level = .floating
        window.collectionBehavior = .canJoinAllSpaces
        /* window.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1/16) */
        window.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        window.orderFrontRegardless()

        return window
    }

    func initTimeDisplay() {
        let font = NSFont.monospacedDigitSystemFont(ofSize: 22, weight: .regular)
        let label = self.initLabel(
            font     : font,
            format   : "hh:mm",
            interval : 1
        )

        let screenWidth = (NSScreen.main?.frame.width)!
        let screenHeight = (NSScreen.main?.frame.height)!

        let windowWidth: CGFloat = 120
        let windowHeight: CGFloat = 30

        let rect = NSMakeRect(screenWidth - windowWidth,
                screenHeight - windowHeight,
                windowWidth,
                windowHeight);

        self.timer = self.initWindow(
            rect     : rect,
            label    : label
        )
    }
}

let app = NSApplication.shared
let clock = Clock()
app.delegate = clock
app.setActivationPolicy(.accessory)
app.run()
