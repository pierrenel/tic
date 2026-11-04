import SwiftUI

/// The colour theme of a sticky note. Stored as its raw string in SQLite, mapped to concrete
/// SwiftUI colours here so the rest of the app stays theme-agnostic.
///
/// The first six are Tic's own pastel papers. The rest are popular editor/terminal schemes, using
/// each scheme's published palette (base → paper, text → ink, its signature colour → accent). Several
/// are dark (`isDark`), so a solid note in one draws its controls, caret and popovers dark too.
enum NoteColor: String, Codable, CaseIterable, Identifiable, Sendable {
    case yellow
    case pink
    case blue
    case green
    case purple
    case graphite

    case catppuccinLatte
    case catppuccinFrappe
    case catppuccinMacchiato
    case catppuccinMocha

    case rosePine
    case rosePineMoon
    case rosePineDawn

    case tokyoNight
    case tokyoNightStorm
    case tokyoNightMoon
    case tokyoNightDay

    case dracula
    case nord
    case gruvboxDark
    case gruvboxLight
    case solarizedDark
    case solarizedLight

    var id: String { rawValue }

    /// The colour picker's rows: Tic's pastels, then one row per scheme family.
    enum Family: String, CaseIterable, Identifiable {
        case classic = "Classic"
        case catppuccin = "Catppuccin"
        case rosePine = "Rosé Pine"
        case tokyoNight = "Tokyo Night"
        case more = "More"

        var id: String { rawValue }
        var members: [NoteColor] { NoteColor.allCases.filter { $0.family == self } }
    }

    var family: Family {
        switch self {
        case .yellow, .pink, .blue, .green, .purple, .graphite: return .classic
        case .catppuccinLatte, .catppuccinFrappe, .catppuccinMacchiato, .catppuccinMocha: return .catppuccin
        case .rosePine, .rosePineMoon, .rosePineDawn: return .rosePine
        case .tokyoNight, .tokyoNightStorm, .tokyoNightMoon, .tokyoNightDay: return .tokyoNight
        case .dracula, .nord, .gruvboxDark, .gruvboxLight, .solarizedDark, .solarizedLight: return .more
        }
    }

    /// A new note gets one of the pastels — never a surprise dark scheme.
    static var classic: [NoteColor] { Family.classic.members }

    var displayName: String {
        switch self {
        case .catppuccinLatte:     return "Catppuccin Latte"
        case .catppuccinFrappe:    return "Catppuccin Frappé"
        case .catppuccinMacchiato: return "Catppuccin Macchiato"
        case .catppuccinMocha:     return "Catppuccin Mocha"
        case .rosePine:            return "Rosé Pine"
        case .rosePineMoon:        return "Rosé Pine Moon"
        case .rosePineDawn:        return "Rosé Pine Dawn"
        case .tokyoNight:          return "Tokyo Night"
        case .tokyoNightStorm:     return "Tokyo Night Storm"
        case .tokyoNightMoon:      return "Tokyo Night Moon"
        case .tokyoNightDay:       return "Tokyo Night Day"
        case .dracula:             return "Dracula"
        case .nord:                return "Nord"
        case .gruvboxDark:         return "Gruvbox Dark"
        case .gruvboxLight:        return "Gruvbox Light"
        case .solarizedDark:       return "Solarized Dark"
        case .solarizedLight:      return "Solarized Light"
        default:                   return rawValue.capitalized
        }
    }

    /// A dark paper with light ink. Solid notes in these render with a dark colour scheme.
    var isDark: Bool {
        switch self {
        case .catppuccinFrappe, .catppuccinMacchiato, .catppuccinMocha,
             .rosePine, .rosePineMoon,
             .tokyoNight, .tokyoNightStorm, .tokyoNightMoon,
             .dracula, .nord, .gruvboxDark, .solarizedDark:
            return true
        default:
            return false
        }
    }

    // MARK: - Palettes

    /// Every colour a theme needs. Inks are for solid notes; glass uses adaptive system colours.
    fileprivate struct Palette {
        let fill: Color        // the paper (solid notes; a faint tint behind glass)
        let accent: Color      // soft accents: title underline, quick-add tint, star
        let title: Color
        let task: Color
        let secondary: Color   // placeholder / empty-state text; muting is baked in, add no opacity
        let completed: Color
        let checkbox: Color
    }

    private var palette: Palette {
        switch self {
        // Tic's pastels. Each ink is a deep, slightly-desaturated tone of the hue rather than one flat
        // near-black: it reads crisper on its pastel than pure black while clearing WCAG AA.
        case .yellow:
            return Palette(fill: .rgb(1.00, 0.90, 0.46), accent: .rgb(0.78, 0.62, 0.10),
                           title: .rgb(0.20, 0.16, 0.02), task: .rgb(0.24, 0.19, 0.04),
                           secondary: .rgb(0.42, 0.35, 0.12), completed: .rgb(0.46, 0.40, 0.20),
                           checkbox: .rgb(0.78, 0.62, 0.10))
        case .pink:
            return Palette(fill: .rgb(1.00, 0.78, 0.84), accent: .rgb(0.82, 0.36, 0.50),
                           title: .rgb(0.30, 0.10, 0.16), task: .rgb(0.27, 0.12, 0.17),
                           secondary: .rgb(0.50, 0.28, 0.34), completed: .rgb(0.55, 0.34, 0.40),
                           checkbox: .rgb(0.78, 0.30, 0.45))
        case .blue:
            return Palette(fill: .rgb(0.70, 0.86, 1.00), accent: .rgb(0.18, 0.48, 0.78),
                           title: .rgb(0.06, 0.16, 0.30), task: .rgb(0.08, 0.18, 0.32),
                           secondary: .rgb(0.24, 0.36, 0.50), completed: .rgb(0.34, 0.45, 0.58),
                           checkbox: .rgb(0.13, 0.42, 0.72))
        case .green:
            return Palette(fill: .rgb(0.76, 0.93, 0.74), accent: .rgb(0.26, 0.58, 0.30),
                           title: .rgb(0.08, 0.22, 0.10), task: .rgb(0.10, 0.24, 0.12),
                           secondary: .rgb(0.26, 0.40, 0.26), completed: .rgb(0.36, 0.48, 0.36),
                           checkbox: .rgb(0.18, 0.50, 0.24))
        case .purple:
            return Palette(fill: .rgb(0.84, 0.79, 0.97), accent: .rgb(0.46, 0.36, 0.74),
                           title: .rgb(0.20, 0.12, 0.36), task: .rgb(0.22, 0.14, 0.38),
                           secondary: .rgb(0.40, 0.32, 0.55), completed: .rgb(0.48, 0.42, 0.62),
                           checkbox: .rgb(0.42, 0.30, 0.72))
        case .graphite:
            return Palette(fill: .rgb(0.86, 0.87, 0.90), accent: .rgb(0.40, 0.42, 0.46),
                           title: .rgb(0.10, 0.11, 0.14), task: .rgb(0.14, 0.15, 0.18),
                           secondary: .rgb(0.40, 0.42, 0.47), completed: .rgb(0.48, 0.50, 0.55),
                           checkbox: .rgb(0.30, 0.40, 0.78))

        // Catppuccin: base / text / subtext0 / overlay1, accent mauve.
        case .catppuccinLatte:
            return .scheme(fill: 0xEFF1F5, text: 0x4C4F69, secondary: 0x6C6F85, completed: 0x8C8FA1, accent: 0x8839EF)
        case .catppuccinFrappe:
            return .scheme(fill: 0x303446, text: 0xC6D0F5, secondary: 0xA5ADCE, completed: 0x838BA7, accent: 0xCA9EE6)
        case .catppuccinMacchiato:
            return .scheme(fill: 0x24273A, text: 0xCAD3F5, secondary: 0xA5ADCB, completed: 0x8087A2, accent: 0xC6A0F6)
        case .catppuccinMocha:
            return .scheme(fill: 0x1E1E2E, text: 0xCDD6F4, secondary: 0xA6ADC8, completed: 0x7F849C, accent: 0xCBA6F7)

        // Rosé Pine: base / text / subtle / muted, accent rose.
        case .rosePine:
            return .scheme(fill: 0x191724, text: 0xE0DEF4, secondary: 0x908CAA, completed: 0x6E6A86, accent: 0xEBBCBA)
        case .rosePineMoon:
            return .scheme(fill: 0x232136, text: 0xE0DEF4, secondary: 0x908CAA, completed: 0x6E6A86, accent: 0xEA9A97)
        case .rosePineDawn:
            return .scheme(fill: 0xFAF4ED, text: 0x575279, secondary: 0x797593, completed: 0x9893A5, accent: 0xD7827E)

        // Tokyo Night: bg / fg / fg_dark / comment-ish, accent blue.
        case .tokyoNight:
            return .scheme(fill: 0x1A1B26, text: 0xC0CAF5, secondary: 0xA9B1D6, completed: 0x737AA2, accent: 0x7AA2F7)
        case .tokyoNightStorm:
            return .scheme(fill: 0x24283B, text: 0xC0CAF5, secondary: 0xA9B1D6, completed: 0x737AA2, accent: 0x7AA2F7)
        case .tokyoNightMoon:
            return .scheme(fill: 0x222436, text: 0xC8D3F5, secondary: 0x828BB8, completed: 0x636DA6, accent: 0x82AAFF)
        case .tokyoNightDay:
            return .scheme(fill: 0xE1E2E7, text: 0x3760BF, secondary: 0x6172B0, completed: 0x8990B3, accent: 0x2E7DE9)

        case .dracula:
            return .scheme(fill: 0x282A36, text: 0xF8F8F2, secondary: 0xA4A9C6, completed: 0x6272A4, accent: 0xBD93F9)
        case .nord:
            return .scheme(fill: 0x2E3440, text: 0xECEFF4, secondary: 0xAAB3C3, completed: 0x7B88A1, accent: 0x88C0D0)
        case .gruvboxDark:
            return .scheme(fill: 0x282828, text: 0xEBDBB2, secondary: 0xBDAE93, completed: 0x928374, accent: 0xFABD2F)
        case .gruvboxLight:
            return .scheme(fill: 0xFBF1C7, text: 0x3C3836, secondary: 0x665C54, completed: 0x928374, accent: 0xB57614)
        case .solarizedDark:
            return .scheme(fill: 0x002B36, text: 0x93A1A1, secondary: 0x839496, completed: 0x586E75, accent: 0x268BD2)
        case .solarizedLight:
            return .scheme(fill: 0xFDF6E3, text: 0x073642, secondary: 0x657B83, completed: 0x93A1A1, accent: 0x268BD2)
        }
    }

    /// The note's paper fill (used for solid notes and as a faint tint behind glass).
    var fill: Color { palette.fill }

    /// A deeper shade of the theme for soft accents (title underline, quick-add bar tint).
    var accent: Color { palette.accent }

    // MARK: - Role resolution (solid vs glass)
    //
    // Glass uses semantic, appearance-adaptive system colours (they invert over light/dark
    // backdrops and ride the material's vibrancy); solid uses the palette's inks.

    enum Surface { case solid, glass }
    enum InkRole { case title, task, secondary, completed, checkbox }

    func color(_ role: InkRole, on surface: Surface) -> Color {
        switch surface {
        case .solid:
            switch role {
            case .title:     return palette.title
            case .task:      return palette.task
            case .secondary: return palette.secondary
            case .completed: return palette.completed
            case .checkbox:  return palette.checkbox
            }
        case .glass:
            switch role {
            case .title:     return .primary
            case .task:      return .primary
            case .secondary: return .secondary
            case .completed: return .secondary
            case .checkbox:  return accent   // stays chromatic so the theme is still identifiable
            }
        }
    }
}

fileprivate extension NoteColor.Palette {
    /// A scheme from its published palette: one text colour for title and tasks, the accent for the
    /// checkbox too.
    static func scheme(fill: UInt32, text: UInt32, secondary: UInt32, completed: UInt32, accent: UInt32) -> Self {
        Self(fill: .hex(fill), accent: .hex(accent), title: .hex(text), task: .hex(text),
             secondary: .hex(secondary), completed: .hex(completed), checkbox: .hex(accent))
    }
}

private extension Color {
    static func rgb(_ red: Double, _ green: Double, _ blue: Double) -> Color {
        Color(red: red, green: green, blue: blue)
    }

    static func hex(_ value: UInt32) -> Color {
        Color(red: Double((value >> 16) & 0xFF) / 255,
              green: Double((value >> 8) & 0xFF) / 255,
              blue: Double(value & 0xFF) / 255)
    }
}

/// A resolved palette for a note, so views ask for a role (`theme.task`) without branching on
/// whether the note is solid or glass.
struct NoteTheme: Equatable {
    let color: NoteColor
    let surface: NoteColor.Surface

    var isGlass: Bool { surface == .glass }

    /// A solid note on a dark scheme: its controls, caret and popovers should draw dark.
    var isDark: Bool { surface == .solid && color.isDark }

    var fill: Color { color.fill }
    var accent: Color { color.accent }
    var title: Color { color.color(.title, on: surface) }
    var task: Color { color.color(.task, on: surface) }
    var secondary: Color { color.color(.secondary, on: surface) }
    var completed: Color { color.color(.completed, on: surface) }
    var checkbox: Color { color.color(.checkbox, on: surface) }
}
