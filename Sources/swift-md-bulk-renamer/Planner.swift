public enum PlanError: Error, Equatable {
	case sourceNotFound(path: String)
	case duplicateSource(path: String)
	case conflictingDestination(path: String)
	case destinationExists(path: String)
}

public struct Plan: Equatable, Sendable {
	public let instructions: [Instruction]

	public init(instructions: [Instruction]) {
		self.instructions = instructions
	}

	public func dryRunOutput() -> String {
		instructions.map { "\($0.from.value) -> \($0.to.value)" }.joined(separator: "\n")
	}
}

public func plan(
	instructions: [Instruction],
	checkSourceExists: (String) -> Bool,
	checkDestinationExists: (String) -> Bool,
	force: Bool
) throws -> Plan {
	var seenSources: Set<String> = []
	var seenDestinations: Set<String> = []

	for instruction in instructions {
		let from = instruction.from.value
		let to = instruction.to.value

		if !checkSourceExists(from) {
			throw PlanError.sourceNotFound(path: from)
		}

		if seenSources.contains(from) {
			throw PlanError.duplicateSource(path: from)
		}
		seenSources.insert(from)

		if seenDestinations.contains(to) {
			throw PlanError.conflictingDestination(path: to)
		}
		seenDestinations.insert(to)

		if !force && checkDestinationExists(to) {
			throw PlanError.destinationExists(path: to)
		}
	}

	return Plan(instructions: instructions)
}
