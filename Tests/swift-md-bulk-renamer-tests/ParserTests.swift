import Testing

@testable import swift_md_bulk_renamer

@Test func `parses valid 2-column table`() throws {
	let markdown = """
		| From | To |
		|------|-----|
		| a.txt | b.txt |
		| c.md | d.md |
		"""
	let instructions = try parse(markdown)
	#expect(
		instructions == [
			Instruction(from: "a.txt", to: "b.txt")!,
			Instruction(from: "c.md", to: "d.md")!,
		]
	)
}

@Test func `skips rows with empty To column`() throws {
	let markdown = """
		| From | To |
		|------|-----|
		| a.txt | b.txt |
		| c.md | |
		"""
	let instructions = try parse(markdown)
	#expect(
		instructions == [
			Instruction(from: "a.txt", to: "b.txt")!
		]
	)
}

@Test func `throws when no table found`() {
	let markdown = "Just some text"
	#expect(throws: ParseError.noTableFound) {
		_ = try parse(markdown)
	}
}

@Test func `generates table from instructions`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt")!,
		Instruction(from: "c.md", to: "d.md")!,
	]
	let output = generateTable(from: instructions)
	#expect(output.contains("From"))
	#expect(output.contains("To"))
	#expect(output.contains("a.txt"))
	#expect(output.contains("b.txt"))
}

@Test func `generates table from filenames with empty To`() throws {
	let filenames = ["a.txt", "b.txt"]
	let output = generateTable(fromFilenames: filenames)
	#expect(output.contains("From"))
	#expect(output.contains("To"))
	#expect(output.contains("a.txt"))
	#expect(output.contains("b.txt"))
}

@Test func `round-trip preserves instructions`() throws {
	let instructions = [
		Instruction(from: "foo.txt", to: "bar.txt")!,
		Instruction(from: "baz.md", to: "qux.md")!,
	]
	let markdown = generateTable(from: instructions)
	let parsed = try parse(markdown)
	#expect(parsed == instructions)
}
