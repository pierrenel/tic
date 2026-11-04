import SwiftUI
import AppKit

/// A note's background. `.solid` paints the paper fill; `.glass` shows the desktop through a
/// frosted, appearance-adaptive material (the "widget"/Stickies glass look), faintly tinted with
/// the theme colour. The material is `behindWindow`-blended so it samples whatever sits behind
/// the note's window, and it adopts the Liquid Glass appearance automatically on macOS 26.
struct NoteBackground: View {
    let color: NoteColor
    let material: NoteMaterial

    var body: some View {
        switch material {
        case .solid:
            color.fill
        case .glass:
            ZStack {
                VisualEffectBackground(material: .popover, blending: .behindWindow)
                color.fill.opacity(0.18)   // a hint of the theme over the glass
            }
        }
    }
}

/// Bridges `NSVisualEffectView` so a note window can show frosted, desktop-sampling translucency.
private struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blending: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blending
        view.state = .active   // keep the effect visible even when the window isn't key
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blending
        nsView.state = .active
    }
}

/// Forces its window dark while `dark` is set (a solid note on a dark scheme), else lets it follow the
/// system. Done on the window, not with a SwiftUI `colorScheme`, so the AppKit pieces — the text views'
/// caret and `labelColor`, scrollers, and the popovers anchored in the note — go dark with it.
struct WindowAppearance: NSViewRepresentable {
    let dark: Bool

    func makeNSView(context: Context) -> AppearanceView {
        let view = AppearanceView()
        view.dark = dark
        return view
    }

    func updateNSView(_ view: AppearanceView, context: Context) {
        view.dark = dark
        view.apply()
    }

    final class AppearanceView: NSView {
        var dark = false

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }

        func apply() {
            guard let window else { return }
            let wanted = dark ? NSAppearance(named: .darkAqua) : nil
            if window.appearance?.name != wanted?.name { window.appearance = wanted }
        }

        override func hitTest(_ point: NSPoint) -> NSView? { nil }
    }
}
