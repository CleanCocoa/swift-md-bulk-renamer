import ArgumentParser
import Foundation
import swift_md_bulk_renamer

@main
struct MVMD: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "mvmd",
		abstract: "Batch file renamer driven by Markdown tables"
	)

	@Argument(
		help: "Markdown file with rename instructions (use '-' or omit for stdin)"
	)
	var file: String?

	@Flag(
		name: .long,
		help: "Execute renames (default is dry-run)"
	)
	var apply = false

	@Flag(
		name: .long,
		help: "Allow overwriting existing files"
	)
	var force = false

	mutating func run() throws {
		let markdown = try readInput()
		let instructions = try swift_md_bulk_renamer.parse(markdown)

		for instruction in instructions {
			try validateInstruction(instruction)
		}

		let baseDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
		let fileManager = FileManager.default

		let checkExists: (String) -> Bool = { path in
			let url = baseDirectory.appendingPathComponent(path)
			return fileManager.fileExists(atPath: url.path)
		}

		for instruction in instructions {
			try validateNotSymlink(instruction.from, in: baseDirectory, fileManager: fileManager)
		}

		let renameplan = try plan(
			instructions: instructions,
			checkSourceExists: checkExists,
			checkDestinationExists: checkExists,
			force: force
		)

		if apply {
			let executor = Executor(baseDirectory: baseDirectory, fileManager: fileManager)
			try executor.execute(renameplan.instructions)
			print("Successfully renamed \(renameplan.instructions.count) file(s)")
		} else {
			print(renameplan.dryRunOutput())
		}
	}

	func readInput() throws -> String {
		guard let file = file, file != "-" else {
			var input = ""
			while let line = readLine(strippingNewline: false) {
				input += line
			}
			return input
		}
		return try String(contentsOfFile: file, encoding: .utf8)
	}
}
