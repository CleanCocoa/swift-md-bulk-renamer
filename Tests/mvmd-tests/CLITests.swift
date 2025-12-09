import Subprocess
import Testing

#if canImport(System)
	import System
#else
	import SystemPackage
#endif

#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif

@Test func `dry-run outputs from -> to format`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let file1 = tempDir.appendingPathComponent("original1.txt")
	let file2 = tempDir.appendingPathComponent("original2.md")
	try "content1".write(to: file1, atomically: true, encoding: .utf8)
	try "content2".write(to: file2, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| original1.txt | renamed1.txt |
		| original2.md | renamed2.md |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	let output = try await runMVMD(
		arguments: [markdownFile.path],
		workingDirectory: tempDir
	)

	#expect(output.contains("original1.txt -> renamed1.txt"))
	#expect(output.contains("original2.md -> renamed2.md"))

	#expect(FileManager.default.fileExists(atPath: file1.path))
	#expect(FileManager.default.fileExists(atPath: file2.path))
	#expect(
		!FileManager.default.fileExists(
			atPath: tempDir.appendingPathComponent("renamed1.txt").path
		)
	)
	#expect(
		!FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("renamed2.md").path)
	)
}

@Test func `--apply executes renames`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let file1 = tempDir.appendingPathComponent("source1.txt")
	let file2 = tempDir.appendingPathComponent("source2.md")
	try "content1".write(to: file1, atomically: true, encoding: .utf8)
	try "content2".write(to: file2, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| source1.txt | dest1.txt |
		| source2.md | dest2.md |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	let output = try await runMVMD(
		arguments: [markdownFile.path, "--apply"],
		workingDirectory: tempDir
	)

	#expect(output.contains("Successfully renamed 2 file(s)"))

	#expect(!FileManager.default.fileExists(atPath: file1.path))
	#expect(!FileManager.default.fileExists(atPath: file2.path))

	let dest1 = tempDir.appendingPathComponent("dest1.txt")
	let dest2 = tempDir.appendingPathComponent("dest2.md")
	#expect(FileManager.default.fileExists(atPath: dest1.path))
	#expect(FileManager.default.fileExists(atPath: dest2.path))

	let content1 = try String(contentsOf: dest1, encoding: .utf8)
	let content2 = try String(contentsOf: dest2, encoding: .utf8)
	#expect(content1 == "content1")
	#expect(content2 == "content2")
}

@Test func `--force bypasses destination exists check in dry-run`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourceFile = tempDir.appendingPathComponent("source.txt")
	let destFile = tempDir.appendingPathComponent("dest.txt")
	try "source content".write(to: sourceFile, atomically: true, encoding: .utf8)
	try "existing content".write(to: destFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| source.txt | dest.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	let output = try await runMVMD(
		arguments: [markdownFile.path, "--force"],
		workingDirectory: tempDir
	)

	#expect(output.contains("source.txt -> dest.txt"))

	#expect(FileManager.default.fileExists(atPath: sourceFile.path))
	#expect(FileManager.default.fileExists(atPath: destFile.path))
	let sourceContent = try String(contentsOf: sourceFile, encoding: .utf8)
	let destContent = try String(contentsOf: destFile, encoding: .utf8)
	#expect(sourceContent == "source content")
	#expect(destContent == "existing content")
}

@Test func `error when destination exists without --force`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourceFile = tempDir.appendingPathComponent("source.txt")
	let destFile = tempDir.appendingPathComponent("dest.txt")
	try "source content".write(to: sourceFile, atomically: true, encoding: .utf8)
	try "existing content".write(to: destFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| source.txt | dest.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	await #expect(throws: (any Error).self) {
		_ = try await runMVMD(
			arguments: [markdownFile.path, "--apply"],
			workingDirectory: tempDir
		)
	}

	let sourceContent = try String(contentsOf: sourceFile, encoding: .utf8)
	let destContent = try String(contentsOf: destFile, encoding: .utf8)
	#expect(sourceContent == "source content")
	#expect(destContent == "existing content")
}

@Test func `error when source file does not exist`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let markdown = """
		| From | To |
		|------|-----|
		| nonexistent.txt | dest.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	await #expect(throws: (any Error).self) {
		_ = try await runMVMD(
			arguments: [markdownFile.path],
			workingDirectory: tempDir
		)
	}
}

@Test func `error when path is absolute`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let markdown = """
		| From | To |
		|------|-----|
		| file.txt | /absolute/path.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	await #expect(throws: (any Error).self) {
		_ = try await runMVMD(
			arguments: [markdownFile.path],
			workingDirectory: tempDir
		)
	}
}

@Test func `error when path contains parent directory escape`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let markdown = """
		| From | To |
		|------|-----|
		| file.txt | ../escape.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	await #expect(throws: (any Error).self) {
		_ = try await runMVMD(
			arguments: [markdownFile.path],
			workingDirectory: tempDir
		)
	}
}

@Test func `stdin input with dash argument`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourceFile = tempDir.appendingPathComponent("input.txt")
	try "test content".write(to: sourceFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| input.txt | output.txt |
		"""

	let output = try await runMVMD(
		arguments: ["-"],
		workingDirectory: tempDir,
		stdin: markdown
	)

	#expect(output.contains("input.txt -> output.txt"))
	#expect(FileManager.default.fileExists(atPath: sourceFile.path))
}

@Test func `applies renames from stdin`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourceFile = tempDir.appendingPathComponent("before.txt")
	try "content".write(to: sourceFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| before.txt | after.txt |
		"""

	let output = try await runMVMD(
		arguments: ["-", "--apply"],
		workingDirectory: tempDir,
		stdin: markdown
	)

	#expect(output.contains("Successfully renamed 1 file(s)"))
	#expect(!FileManager.default.fileExists(atPath: sourceFile.path))

	let destFile = tempDir.appendingPathComponent("after.txt")
	#expect(FileManager.default.fileExists(atPath: destFile.path))

	let content = try String(contentsOf: destFile, encoding: .utf8)
	#expect(content == "content")
}

@Test func `handles subdirectory renames`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let subdir = tempDir.appendingPathComponent("subdir")
	try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)

	let sourceFile = subdir.appendingPathComponent("file.txt")
	try "content".write(to: sourceFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| subdir/file.txt | subdir/renamed.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	let output = try await runMVMD(
		arguments: [markdownFile.path, "--apply"],
		workingDirectory: tempDir
	)

	#expect(output.contains("Successfully renamed 1 file(s)"))
	#expect(!FileManager.default.fileExists(atPath: sourceFile.path))

	let destFile = subdir.appendingPathComponent("renamed.txt")
	#expect(FileManager.default.fileExists(atPath: destFile.path))

	let content = try String(contentsOf: destFile, encoding: .utf8)
	#expect(content == "content")
}

@Test func `CLI creates intermediate directories for destination`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

	let sourceFile = tempDir.appendingPathComponent("source.txt")
	try "content".write(to: sourceFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| source.txt | newdir/nested/target.txt |
		"""
	let markdownFile = tempDir.appendingPathComponent("instructions.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	let output = try await runMVMD(
		arguments: [markdownFile.path, "--apply"],
		workingDirectory: tempDir
	)

	#expect(output.contains("Successfully renamed 1 file(s)"))
	#expect(!FileManager.default.fileExists(atPath: sourceFile.path))

	let destFile = tempDir.appendingPathComponent("newdir/nested/target.txt")
	#expect(FileManager.default.fileExists(atPath: destFile.path))

	let content = try String(contentsOf: destFile, encoding: .utf8)
	#expect(content == "content")
}

@Test func `uses file parent directory as base for relative paths`() async throws {
	let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
		UUID().uuidString
	)
	defer { try? FileManager.default.removeItem(at: tempDir) }

	let subdir = tempDir.appendingPathComponent("subdir")
	try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)

	let sourceFile = subdir.appendingPathComponent("source.txt")
	try "content".write(to: sourceFile, atomically: true, encoding: .utf8)

	let markdown = """
		| From | To |
		|------|-----|
		| source.txt | renamed.txt |
		"""
	let markdownFile = subdir.appendingPathComponent("renames.md")
	try markdown.write(to: markdownFile, atomically: true, encoding: .utf8)

	let output = try await runMVMD(
		arguments: ["subdir/renames.md", "--apply"],
		workingDirectory: tempDir
	)

	#expect(output.contains("Successfully renamed 1 file(s)"))
	#expect(!FileManager.default.fileExists(atPath: sourceFile.path))

	let destFile = subdir.appendingPathComponent("renamed.txt")
	#expect(FileManager.default.fileExists(atPath: destFile.path))
}

private func runMVMD(
	arguments: [String],
	workingDirectory: URL,
	stdin stdinInput: String? = nil
) async throws -> String {
	let projectRoot = URL(fileURLWithPath: #filePath)
		.deletingLastPathComponent()
		.deletingLastPathComponent()
		.deletingLastPathComponent()
	let executablePath =
		projectRoot
		.appendingPathComponent(".build")
		.appendingPathComponent("debug")
		.appendingPathComponent("mvmd")
		.path

	let result: CollectedResult<StringOutput<UTF8>, StringOutput<UTF8>>
	if let stdinInput {
		result = try await run(
			.path(FilePath(executablePath)),
			arguments: Arguments(arguments),
			environment: .inherit,
			workingDirectory: FilePath(workingDirectory.path),
			input: .string(stdinInput),
			output: .string(limit: .max),
			error: .string(limit: .max)
		)
	} else {
		result = try await run(
			.path(FilePath(executablePath)),
			arguments: Arguments(arguments),
			environment: .inherit,
			workingDirectory: FilePath(workingDirectory.path),
			input: .none,
			output: .string(limit: .max),
			error: .string(limit: .max)
		)
	}

	guard result.terminationStatus.isSuccess else {
		throw CLITestError.nonZeroExit(
			status: result.terminationStatus,
			output: result.standardError ?? ""
		)
	}

	return result.standardOutput ?? ""
}

private enum CLITestError: Error {
	case nonZeroExit(status: TerminationStatus, output: String)
}
