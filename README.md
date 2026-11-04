<div align="center">
  <img src="Assets/AppIcon/Tic-256.png" width="128" alt="Tic icon">
  <h1>Tic</h1>
  <p><strong>Floating, Stickies-style task lists for macOS.</strong></p>

[![CI](https://github.com/pierrenel/tic/actions/workflows/ci.yml/badge.svg)](https://github.com/pierrenel/tic/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/pierrenel/tic)](https://github.com/pierrenel/tic/releases)
[![GitHub Downloads](https://img.shields.io/github/downloads/pierrenel/tic/total)](https://github.com/pierrenel/tic/releases)

<a href="https://www.producthunt.com/products/tic?utm_source=badge-follow&utm_medium=badge&utm_source=badge-tic" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/follow.svg?product_id=1317575&theme=light" alt="Tic - To&#0045;do&#0032;lists&#0032;that&#0032;live&#0032;on&#0032;your&#0032;desktop&#0044;&#0032;not&#0032;in&#0032;a&#0032;menu&#0032;bar | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>

<a href="https://tic.kasvith.me"><img src="site/public/og.png" alt="Tic sticky-note to-do lists floating on a Mac desktop"></a>

</div>

Tic keeps your lists **on the desktop** as floating sticky notes instead of buried behind a menu
bar click — glance at them, check things off, drag them around. Each note is its own checklist.

## What's different in this fork

This is a fork of [kasvith/tic](https://github.com/kasvith/tic) with a few changes on top. The install
script, release downloads, and the in-app updater all point at this fork, so updating never swaps
these changes back out for upstream's build.

- **Mark a task to do today** — double-click a task's text to star it (⭐). It moves, with its
  subtasks, to the top of its group (the top of the list, or the top of its parent's subtasks),
  just below anything already starred. Double-click again to unstar; ticking it done clears the
  star. The star is a real flag (new `isToday` column), so AI agents can see and set it too through
  the MCP `update_task` tool (`today: true/false`).
- **Notes on tasks** — right-click a task → **Add Note…** to attach a note: rich text, pasted
  images, and clickable links (stored as RTFD, like Stickies). It saves as you type; a task with a
  note shows a note icon at the end of its row; click it to open the note. Emptying a note (or
  **Remove Note**) removes it. The right-click menu also has **Do Today** and **Delete Task**.
  Note text follows light/dark mode, including text pasted from documents.
- **Editor colour schemes** — alongside the six pastels, the colour picker has Catppuccin (Latte,
  Frappé, Macchiato, Mocha), Rosé Pine (Main, Moon, Dawn), Tokyo Night (Night, Storm, Moon, Day),
  Dracula, Nord, Gruvbox and Solarized (dark and light). A solid note on a dark scheme goes fully
  dark: caret, scrollbars and popovers too. AI agents can set them through MCP (`catppuccinMocha`, …).
- **⌘N adds a task, ⇧⌘N makes a new list** — ⌘N puts the cursor in the focused note's
  "Add a task…" field (unrolling the note if it's rolled up). With no note focused it still makes a
  new list. New List moved to ⇧⌘N.
- **Drag to reorder works with "Move completed to bottom" on** — upstream pauses dragging while
  that option is on. Here, a drop lands where you saw it and that order is saved; the sort still
  applies, so an unfinished task dropped among finished ones settles just above them.

> Single-clicking a task's text now waits a moment before editing starts, while macOS checks for a
> double-click.

## Features

- **Floating sticky notes** — borderless, draggable, resizable panels; optional float-on-top and
  show-on-all-Spaces per note. Positions and state are remembered across launches.
- **Multiple lists** — create from the menu bar, **⇧⌘N**, the in-note **+**, or the Dock menu.
  New lists are auto-named *List 1, List 2, …*
- **Rich tasks** — **subtasks** up to 3 levels (completing a parent completes its children),
  **multiline** notes (Shift-Return), and inline Markdown (`**bold**`, `*italic*`, `` `code` ``,
  `~~strike~~`, links). Tap to edit; double-click to star it for today; drag to reorder, or drag
  right to nest.
- **Solid or Liquid-Glass** notes — per-note color themes (pastels plus editor schemes like Catppuccin and Tokyo Night), or a translucent material that shows
  the desktop through it.
- **Roll-up** — double-click a note's title bar to collapse it to just the header.
- **Raycast-style search palette** — a floating, centered command palette to search/open/delete
  any list, with keyboard navigation.
- **Launch at Login**, a custom menu-bar icon, and a native Dock identity.

## Requirements

macOS **14 (Sonoma)** or later, on Apple silicon.

## Install

Paste this in Terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/pierrenel/tic/main/site/public/install.sh | sh
```

It installs Tic to `/Applications` (or `~/Applications` on a non-admin account) and opens it. Run it
again any time to update. Tic isn't notarized, and macOS adds a quarantine flag to apps downloaded in
a browser, which makes Gatekeeper block the first launch; `curl` doesn't add that flag, so this
just works. The script is short and readable: [`site/public/install.sh`](site/public/install.sh).

**Or download it by hand:** get the `.dmg` from the
[latest release](https://github.com/pierrenel/tic/releases/latest), move **`Tic.app`** to
`/Applications`, then clear the quarantine flag once:

```sh
xattr -c /Applications/Tic.app
```

(Alternatively: right-click `Tic.app` → **Open** → **Open**.) To have Tic open automatically, enable
**Launch at Login** from its menu-bar menu.

## Build from source

Tic is a Swift Package — no `.xcodeproj` needed.

```sh
swift run                 # build + launch (dev)
swift build -c release    # release build
swift test                # run the test suite (Swift Testing)
./scripts/package.sh      # assemble dist/Tic.app (add --open to launch it)
open Package.swift        # edit in Xcode
```

## Usage

- The menu-bar icon lists your **recent lists** (with a **More Lists** submenu for the rest) and
  opens **Search Lists…**, **New List** (⇧⌘N), and **Launch at Login**.
- Hover a note to reveal its controls: color, solid/glass, float-on-top, roll-up, **+** new list,
  and close. Click the title to rename; the bottom field adds tasks (Return keeps focus).
- Hover a task to reveal a **✕** (delete) and, below it, a **＋** line — click it to add a subtask
  nested under that row. An empty task you don't fill in disappears when you click away.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| **Return** | Finish editing a task / add the typed task |
| **Shift-Return** (or **⌥ Return**) | New line within the same task |
| **Shift-Tab** | Make the task a subtask (nest one level deeper) |
| **⌃ Shift-Tab** | Un-nest a subtask (move it back out) |
| **⌘N** | Add a task to the focused list (jumps to the add-a-task field) |
| **⇧⌘N** | New list |
| **Double-click** a task | Mark it to do today (⭐, moves to the top of its group); again to unmark |
| **Double-click** the title bar | Roll the note up / down |

You can also **drag a task** to reorder it, or **drag it right** to nest it — the drop indicator
shows where (and at what level) it will land. The relevant chord (`⇧⏎ line`, `⇧⇥ nest`) shows as a
tiny keycap hint right in the field while you're editing, so you don't have to memorise this table.

## Architecture

SwiftUI views hosted inside AppKit `NSPanel`s (the only way to get true desktop-sticky behavior),
backed by **SQLite via GRDB**. An `AppModel` coordinator bridges the menu bar to the window layer.
See [`CLAUDE.md`](CLAUDE.md) for the full breakdown.

**Stack:** Swift 6 · SwiftUI + AppKit · GRDB (SQLite) · `SMAppService` (login item).

## Development & releases

- **CI** (`.github/workflows/ci.yml`) builds, tests, and lints on every push/PR.
- **Changelog** is generated from [Conventional Commits](https://www.conventionalcommits.org)
  with [git-cliff](https://git-cliff.org) (`cliff.toml`) and kept in `CHANGELOG.md`.
- **Releases are tag-based:** push a `v*` tag and the release workflow builds `Tic.app`, generates
  release notes, and publishes a GitHub Release with the zipped app.

  ```sh
  git tag v0.1.0 && git push origin v0.1.0
  ```

Icon source art lives in [`Assets/`](Assets) (AppIcon / Flat / MenuBar).

## License

Released under the [MIT License](LICENSE). © 2026 Kasun Vithanage.
