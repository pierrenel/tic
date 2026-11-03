import AppKit
import Foundation
import Testing
@testable import Tic

@Suite("Task notes")
struct TaskNoteTests {
    private func noteWithTask() async throws -> (AppDatabase, Note, TaskItem) {
        let db = try AppDatabase.makeInMemory()
        let note = Note()
        try await db.insert(note)
        let task = TaskItem(noteId: note.id, text: "A")
        try await db.insertTask(task)
        return (db, note, task)
    }

    @Test("a note saves, reads back, shows in the id set, and nil removes it")
    func roundTrip() async throws {
        let (db, note, task) = try await noteWithTask()
        #expect(try await db.taskNoteData(taskId: task.id) == nil)

        try await db.setTaskNote(taskId: task.id, data: Data([1, 2, 3]))
        #expect(try await db.taskNoteData(taskId: task.id) == Data([1, 2, 3]))
        #expect(try await db.taskNoteIds(noteId: note.id) == [task.id])

        try await db.setTaskNote(taskId: task.id, data: nil)
        #expect(try await db.taskNoteData(taskId: task.id) == nil)
        #expect(try await db.taskNoteIds(noteId: note.id).isEmpty)
    }

    @Test("deleting the task deletes its note")
    func cascades() async throws {
        let (db, note, task) = try await noteWithTask()
        try await db.setTaskNote(taskId: task.id, data: Data([1]))
        try await db.applyStructuralUpdate(deleteIds: [task.id])
        #expect(try await db.taskNoteIds(noteId: note.id).isEmpty)
    }

    @Test("RTFD round-trips text and a link; whitespace-only counts as empty")
    func richNoteEncoding() throws {
        let url = try #require(URL(string: "https://example.com"))
        let text = NSMutableAttributedString(string: "Call Sam ")
        text.append(NSAttributedString(string: "site", attributes: [.link: url]))
        let data = try #require(RichNote.encode(text))
        let decoded = try #require(RichNote.decode(data))
        #expect(decoded.string == "Call Sam site")
        let link = decoded.attribute(.link, at: decoded.length - 1, effectiveRange: nil)
        #expect((link as? URL) == url || (link as? String) == url.absoluteString)

        #expect(RichNote.encode(NSAttributedString(string: "  \n ")) == nil)
        #expect(RichNote.isEmpty(NSAttributedString(string: "")))
    }

    @Test("an image-only note is not empty")
    func imageOnlyNote() {
        let attachment = NSTextAttachment()
        attachment.image = NSImage(size: NSSize(width: 4, height: 4))
        #expect(!RichNote.isEmpty(NSAttributedString(attachment: attachment)))
    }

    @MainActor
    @Test("saveTaskNote updates the icon set at once and persists")
    func controllerSave() async throws {
        let (db, note, task) = try await noteWithTask()
        let c = NoteController(note: note, database: db)
        c.saveTaskNote(Data([9]), for: task.id)
        #expect(c.taskNoteIDs == [task.id])
        var stored: Data?
        for _ in 0..<100 {
            stored = await c.loadTaskNote(task.id)
            if stored != nil { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(stored == Data([9]))
        c.saveTaskNote(nil, for: task.id)
        #expect(c.taskNoteIDs.isEmpty)
    }
}
