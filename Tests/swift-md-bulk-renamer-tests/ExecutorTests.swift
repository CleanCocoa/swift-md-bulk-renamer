import Testing

@testable import swift_md_bulk_renamer

#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif

@Test func `successfully renames a single file`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourcePath = tempDir.appendingPathComponent("original.txt")
	try "test content".write(to: sourcePath, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [Instruction(from: "original.txt", to: "renamed.txt")!]

	try executor.execute(instructions)

	let destinationPath = tempDir.appendingPathComponent("renamed.txt")
	#expect(FileManager.default.fileExists(atPath: destinationPath.path))
	#expect(!FileManager.default.fileExists(atPath: sourcePath.path))

	let content = try String(contentsOf: destinationPath, encoding: .utf8)
	#expect(content == "test content")
}

@Test func `successfully renames multiple files`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let file1 = tempDir.appendingPathComponent("file1.txt")
	let file2 = tempDir.appendingPathComponent("file2.md")
	let file3 = tempDir.appendingPathComponent("file3.doc")

	try "content1".write(to: file1, atomically: true, encoding: .utf8)
	try "content2".write(to: file2, atomically: true, encoding: .utf8)
	try "content3".write(to: file3, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [
		Instruction(from: "file1.txt", to: "new1.txt")!,
		Instruction(from: "file2.md", to: "new2.md")!,
		Instruction(from: "file3.doc", to: "new3.doc")!,
	]

	try executor.execute(instructions)

	#expect(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("new1.txt").path))
	#expect(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("new2.md").path))
	#expect(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("new3.doc").path))

	#expect(!FileManager.default.fileExists(atPath: file1.path))
	#expect(!FileManager.default.fileExists(atPath: file2.path))
	#expect(!FileManager.default.fileExists(atPath: file3.path))

	let content1 = try String(contentsOf: tempDir.appendingPathComponent("new1.txt"), encoding: .utf8)
	let content2 = try String(contentsOf: tempDir.appendingPathComponent("new2.md"), encoding: .utf8)
	let content3 = try String(contentsOf: tempDir.appendingPathComponent("new3.doc"), encoding: .utf8)

	#expect(content1 == "content1")
	#expect(content2 == "content2")
	#expect(content3 == "content3")
}

@Test func `creates intermediate directories for destination`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourcePath = tempDir.appendingPathComponent("source.txt")
	try "test content".write(to: sourcePath, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [Instruction(from: "source.txt", to: "subdir/nested/target.txt")!]

	try executor.execute(instructions)

	let destinationPath = tempDir.appendingPathComponent("subdir/nested/target.txt")
	#expect(FileManager.default.fileExists(atPath: destinationPath.path))
	#expect(!FileManager.default.fileExists(atPath: sourcePath.path))

	let content = try String(contentsOf: destinationPath, encoding: .utf8)
	#expect(content == "test content")

	let subdirExists = FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("subdir").path)
	let nestedExists = FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("subdir/nested").path)
	#expect(subdirExists)
	#expect(nestedExists)
}

@Test func `throws sourceNotFound when source does not exist`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [Instruction(from: "nonexistent.txt", to: "target.txt")!]

	#expect(throws: ExecutorError.sourceNotFound(path: "nonexistent.txt")) {
		try executor.execute(instructions)
	}
}

@Test func `empty instructions list does nothing`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let testFile = tempDir.appendingPathComponent("unchanged.txt")
	try "content".write(to: testFile, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions: [Instruction] = []

	try executor.execute(instructions)

	#expect(FileManager.default.fileExists(atPath: testFile.path))
	let content = try String(contentsOf: testFile, encoding: .utf8)
	#expect(content == "content")
}

@Test func `renames files with spaces in names`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourcePath = tempDir.appendingPathComponent("my document.txt")
	try "content".write(to: sourcePath, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [Instruction(from: "my document.txt", to: "renamed file.txt")!]

	try executor.execute(instructions)

	let destinationPath = tempDir.appendingPathComponent("renamed file.txt")
	#expect(FileManager.default.fileExists(atPath: destinationPath.path))
	#expect(!FileManager.default.fileExists(atPath: sourcePath.path))
}

@Test func `renames into directory with spaces`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourcePath = tempDir.appendingPathComponent("source.txt")
	try "content".write(to: sourcePath, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [Instruction(from: "source.txt", to: "My Documents/Project Files/target.txt")!]

	try executor.execute(instructions)

	let destinationPath = tempDir.appendingPathComponent("My Documents/Project Files/target.txt")
	#expect(FileManager.default.fileExists(atPath: destinationPath.path))
	#expect(!FileManager.default.fileExists(atPath: sourcePath.path))

	let content = try String(contentsOf: destinationPath, encoding: .utf8)
	#expect(content == "content")
}

@Test func `renames file with special characters`() throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourcePath = tempDir.appendingPathComponent("notes (draft) [v1].txt")
	try "content".write(to: sourcePath, atomically: true, encoding: .utf8)

	let executor = Executor(baseDirectory: tempDir)
	let instructions = [Instruction(from: "notes (draft) [v1].txt", to: "notes (final) [v2].txt")!]

	try executor.execute(instructions)

	let destinationPath = tempDir.appendingPathComponent("notes (final) [v2].txt")
	#expect(FileManager.default.fileExists(atPath: destinationPath.path))
	#expect(!FileManager.default.fileExists(atPath: sourcePath.path))
}
