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

func calcWindowPosition(windowSize: CGSize, screenSize: CGSize) -> CGPoint {
    // top-right only for now
    return CGPointMake(
        screenSize.width - windowSize.width,
        screenSize.height - windowSize.height
    )
}

class Clock: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func updateWindowPosition() {
        if let screen = window.screen {
            let pos = calcWindowPosition(windowSize: self.window.frame.size,
                                         screenSize: screen.frame.size)
            window.setFrameOrigin(pos)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.initTimeDisplay()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main
        ) {
            notification -> Void in
            self.updateWindowPosition()
        }
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
        label.textColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1 - 1 / 8)

        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        shadow.shadowOffset = NSMakeSize(0, 0)
        shadow.shadowBlurRadius = 1
        label.shadow = shadow

        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            label.stringValue = formatter.string(from: Date())
        }
        timer.tolerance = interval / 10
        timer.fire()

        return label
    }

    func initWindow(size: CGSize, label: NSTextField) -> NSWindow {
        let pos = calcWindowPosition(windowSize: size,
                                     screenSize: NSScreen.main!.frame.size)
        let rect = NSMakeRect(pos.x, pos.y, size.width, size.height)
        let window = NSWindow(
            contentRect: rect,
            styleMask: .borderless,
            backing: .buffered,
            defer: true

        )

        window.contentView = label
        window.ignoresMouseEvents = true
        window.level = NSWindow.Level.floating
        window.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
        window.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        window.orderFrontRegardless()

        return window
    }

    func initTimeDisplay() {
        let font = NSFont.monospacedDigitSystemFont(ofSize: 22, weight: .regular)
        let label = self.initLabel(
            font: font,
            format: "hh:mm",
            interval: 1
        )

        let width: CGFloat = 120
        let height: CGFloat = 30

        self.window = self.initWindow(
            size: CGSizeMake(width, height),
            label: label
        )
    }
}

let clock = Clock()

let app = NSApplication.shared
app.delegate = clock
app.setActivationPolicy(.accessory)
app.run()
