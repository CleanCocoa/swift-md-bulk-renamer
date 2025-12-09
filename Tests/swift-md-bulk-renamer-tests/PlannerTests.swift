import Testing

@testable import swift_md_bulk_renamer

@Test func `valid instructions create plan successfully`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt"),
		Instruction(from: "c.md", to: "d.md"),
	]
	let result = try plan(
		instructions: instructions,
		checkDestinations: { _ in false },
		force: false
	)
	#expect(result.instructions == instructions)
}

@Test func `duplicate source paths throw duplicateSource`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt"),
		Instruction(from: "a.txt", to: "c.txt"),
	]
	#expect(throws: PlanError.duplicateSource(path: "a.txt")) {
		_ = try plan(
			instructions: instructions,
			checkDestinations: { _ in false },
			force: false
		)
	}
}

@Test func `conflicting destination paths throw conflictingDestination`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "target.txt"),
		Instruction(from: "b.txt", to: "target.txt"),
	]
	#expect(throws: PlanError.conflictingDestination(path: "target.txt")) {
		_ = try plan(
			instructions: instructions,
			checkDestinations: { _ in false },
			force: false
		)
	}
}

@Test func `existing destination throws destinationExists when force is false`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt")
	]
	#expect(throws: PlanError.destinationExists(path: "b.txt")) {
		_ = try plan(
			instructions: instructions,
			checkDestinations: { path in path == "b.txt" },
			force: false
		)
	}
}

@Test func `existing destination allowed when force is true`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt"),
		Instruction(from: "c.txt", to: "d.txt"),
	]
	let result = try plan(
		instructions: instructions,
		checkDestinations: { path in path == "b.txt" || path == "d.txt" },
		force: true
	)
	#expect(result.instructions == instructions)
}

@Test func `dryRunOutput returns correct format`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt"),
		Instruction(from: "c.md", to: "d.md"),
	]
	let result = try plan(
		instructions: instructions,
		checkDestinations: { _ in false },
		force: false
	)
	let output = result.dryRunOutput()
	#expect(output == "a.txt -> b.txt\nc.md -> d.md")
}

@Test func `empty instructions list creates empty plan`() throws {
	let instructions: [Instruction] = []
	let result = try plan(
		instructions: instructions,
		checkDestinations: { _ in false },
		force: false
	)
	#expect(result.instructions.isEmpty)
	#expect(result.dryRunOutput() == "")
}

@Test func `multiple existing destinations throw on first conflict`() throws {
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt"),
		Instruction(from: "c.txt", to: "d.txt"),
	]
	#expect(throws: PlanError.destinationExists(path: "b.txt")) {
		_ = try plan(
			instructions: instructions,
			checkDestinations: { _ in true },
			force: false
		)
	}
}

@Test func `checkDestinations not called when force is true`() throws {
	var callCount = 0
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt")
	]
	_ = try plan(
		instructions: instructions,
		checkDestinations: { _ in
			callCount += 1
			return true
		},
		force: true
	)
	#expect(callCount == 0)
}

@Test func `checkDestinations called for each instruction when force is false`() throws {
	var checkedPaths: [String] = []
	let instructions = [
		Instruction(from: "a.txt", to: "b.txt"),
		Instruction(from: "c.txt", to: "d.txt"),
	]
	_ = try plan(
		instructions: instructions,
		checkDestinations: { path in
			checkedPaths.append(path)
			return false
		},
		force: false
	)
	#expect(checkedPaths == ["b.txt", "d.txt"])
}
