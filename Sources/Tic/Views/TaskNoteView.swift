import AppKit
import SwiftUI

/// A task's note, shown in a popover from the row (right-click → Add Note…, or the row's note icon).
///
/// The note is rich text — typed text, pasted images, and links — stored as **RTFD**, the same format
/// Stickies uses, so `NSTextView` does all the editing natively. It loads on open and saves itself as
/// you type (debounced) and when the popover closes; emptying it removes the note (and the icon).
struct TaskNoteView: View {
    let taskText: String
    let load: () async -> Data?
    let save: (Data?) -> Void

    @State private var initial: NSAttributedString?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
                Text(taskText.isEmpty ? "Note" : taskText)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)

            Divider()

            if let initial {
                RichNoteEditor(initial: initial, save: save)
            } else {
                ProgressView().controlSize(.small).frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text("Paste images or links · Esc to close")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .frame(width: 380, height: 320)
        .task {
            let data = await load()
            initial = data.flatMap(RichNote.decode) ?? NSAttributedString()
        }
    }
}

/// RTFD encode/decode, and what counts as an empty note.
enum RichNote {
    static func decode(_ data: Data) -> NSAttributedString? {
        try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd],
                                documentAttributes: nil)
    }

    /// RTFD bytes for `text`, or nil when there's nothing worth keeping (only whitespace, no images).
    static func encode(_ text: NSAttributedString) -> Data? {
        guard !isEmpty(text) else { return nil }
        return try? text.data(from: NSRange(location: 0, length: text.length),
                              documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
    }

    static func isEmpty(_ text: NSAttributedString) -> Bool {
        var hasAttachment = false
        text.enumerateAttribute(.attachment, in: NSRange(location: 0, length: text.length)) { value, _, stop in
            if value != nil { hasAttachment = true; stop.pointee = true }
        }
        return !hasAttachment && text.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

/// The editable rich-text view: an `NSTextView` that takes pasted images (shrunk to fit the width on
/// screen; the original is what's saved) and turns URLs into clickable links.
private struct RichNoteEditor: NSViewRepresentable {
    let initial: NSAttributedString
    let save: (Data?) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        guard let text = scroll.documentView as? NSTextView else { return scroll }
        _ = text.layoutManager   // TextKit 1: attachment cells size predictably there
        text.isRichText = true
        text.importsGraphics = true
        text.allowsUndo = true
        text.drawsBackground = false
        text.font = .systemFont(ofSize: 13)
        text.textColor = .labelColor
        text.typingAttributes = [.font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.labelColor]
        text.textContainerInset = NSSize(width: 8, height: 8)
        text.isAutomaticLinkDetectionEnabled = true
        text.isAutomaticQuoteSubstitutionEnabled = false
        text.isAutomaticDashSubstitutionEnabled = false
        text.isAutomaticTextReplacementEnabled = false
        text.textStorage?.setAttributedString(initial)
        text.delegate = context.coordinator
        context.coordinator.textView = text
        context.coordinator.fitAttachments()
        // Take the keyboard once the popover's window exists.
        Task { @MainActor in
            text.window?.makeFirstResponder(text)
            text.setSelectedRange(NSRange(location: text.string.utf16.count, length: 0))
        }
        return scroll
    }

    func updateNSView(_ view: NSScrollView, context: Context) {
        context.coordinator.save = save
    }

    static func dismantleNSView(_ view: NSScrollView, coordinator: Coordinator) {
        coordinator.flush()   // the popover closed: save whatever is pending, now
    }

    func makeCoordinator() -> Coordinator { Coordinator(save: save) }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var save: (Data?) -> Void
        weak var textView: NSTextView?
        private var pending: Task<Void, Never>?
        private var dirty = false

        init(save: @escaping (Data?) -> Void) { self.save = save }

        func textDidChange(_ notification: Notification) {
            dirty = true
            fitAttachments()
            pending?.cancel()
            pending = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                self?.flush()
            }
        }

        /// Writes the note if it changed since the last save.
        func flush() {
            pending?.cancel()
            guard dirty, let textView, let storage = textView.textStorage else { return }
            dirty = false
            // Link any URL that was pasted rather than typed (typing links them as you go).
            textView.checkText(in: NSRange(location: 0, length: storage.length),
                               types: NSTextCheckingResult.CheckingType.link.rawValue, options: [:])
            save(RichNote.encode(storage))
        }

        /// Shrinks images wider than the text column to fit it. Only the on-screen cell is resized —
        /// the attachment's file wrapper (what RTFD saves) keeps the original image.
        func fitAttachments() {
            guard let textView, let storage = textView.textStorage,
                  let container = textView.textContainer else { return }
            let maxWidth = max(40, container.size.width - container.lineFragmentPadding * 2 - 4)
            let full = NSRange(location: 0, length: storage.length)
            storage.enumerateAttribute(.attachment, in: full) { value, range, _ in
                guard let attachment = value as? NSTextAttachment,
                      let image = Self.image(of: attachment), image.size.width > maxWidth else { return }
                let scaled = image.copy() as? NSImage ?? image
                scaled.size = NSSize(width: maxWidth, height: image.size.height * maxWidth / image.size.width)
                attachment.attachmentCell = NSTextAttachmentCell(imageCell: scaled)
                textView.layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
            }
        }

        private static func image(of attachment: NSTextAttachment) -> NSImage? {
            if let cell = attachment.attachmentCell as? NSTextAttachmentCell, let image = cell.image { return image }
            if let image = attachment.image { return image }
            return attachment.fileWrapper?.regularFileContents.flatMap(NSImage.init(data:))
        }
    }
}
