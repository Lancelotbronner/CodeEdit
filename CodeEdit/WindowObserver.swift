//
//  WindowObserver.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

struct WindowObserver<Content: View>: View {
	@ViewBuilder var content: Content

	/// The fullscreen state of the NSWindow.
	/// This will be passed into all child views as an environment variable.
	@State private var isFullscreen = false
	@State private var window: WindowBox?
	@State var modifierFlags: NSEvent.ModifierFlags = []

	var body: some View {
		if let window {
			content
				.environment(\.modifierKeys, modifierFlags.intersection(.deviceIndependentFlagsMask))
				.onReceive(NSEvent.publisher(scope: .local, matching: .flagsChanged)) { output in
					modifierFlags = output.modifierFlags
				}
				.environment(\.window, window)
				.environment(\.isFullscreen, isFullscreen)
				.onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { _ in
					self.isFullscreen = true
				}
				.onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
					self.isFullscreen = false
				}
		} else {
			WindowReader(window: $window)
		}
	}
}

private struct WindowReader: NSViewRepresentable {
	@Binding var window: WindowBox?

	func makeNSView(context: Context) -> NSWindowReaderView {
		let nsview = NSWindowReaderView()
		nsview._window = $window
		return nsview
	}

	func updateNSView(_ nsView: NSWindowReaderView, context: Context) {}
}

private final class NSWindowReaderView: NSView {
	var _window: Binding<WindowBox?>?

	init() {
		super.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillMove(toWindow newWindow: NSWindow?) {
		_window?.wrappedValue = WindowBox(value: newWindow)
	}
}
