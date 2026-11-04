import SwiftUI
import Testing
@testable import Tic

@Suite("NoteColor")
struct NoteColorTests {
    @Test("six pastels, then the editor schemes in picker families")
    func cases() {
        #expect(NoteColor.classic == [.yellow, .pink, .blue, .green, .purple, .graphite])
        #expect(NoteColor.Family.catppuccin.members.count == 4)
        #expect(NoteColor.Family.rosePine.members.count == 3)
        #expect(NoteColor.Family.tokyoNight.members.count == 4)
        // Every colour lands in exactly one picker row.
        #expect(NoteColor.Family.allCases.flatMap(\.members).count == NoteColor.allCases.count)
    }

    @Test("dark schemes are marked dark, and only on a solid note does the theme go dark")
    func darkSchemes() {
        #expect(NoteColor.catppuccinMocha.isDark)
        #expect(!NoteColor.catppuccinLatte.isDark)
        #expect(!NoteColor.rosePineDawn.isDark)
        #expect(!NoteColor.yellow.isDark)
        #expect(NoteTheme(color: .tokyoNight, surface: .solid).isDark)
        #expect(!NoteTheme(color: .tokyoNight, surface: .glass).isDark)
        #expect(NoteColor.catppuccinFrappe.displayName == "Catppuccin Frappé")
    }

    @Test("solid surface resolves distinct, tuned inks per role")
    func solidRoles() {
        let color = NoteColor.yellow
        #expect(color.color(.title, on: .solid) != color.color(.secondary, on: .solid))
        #expect(color.color(.task, on: .solid) != color.color(.completed, on: .solid))
    }

    @Test("glass surface falls back to adaptive system colors")
    func glassRoles() {
        let color = NoteColor.blue
        #expect(color.color(.title, on: .glass) == .primary)
        #expect(color.color(.task, on: .glass) == .primary)
        #expect(color.color(.secondary, on: .glass) == .secondary)
    }
}
