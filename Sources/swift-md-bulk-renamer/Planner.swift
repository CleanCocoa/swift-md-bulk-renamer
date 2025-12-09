public enum PlanError: Error, Equatable {
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
		instructions.map { "\($0.from) -> \($0.to)" }.joined(separator: "\n")
	}
}

public func plan(
	instructions: [Instruction],
	checkDestinations: (String) -> Bool,
	force: Bool
) throws -> Plan {
	var seenSources: Set<String> = []
	var seenDestinations: Set<String> = []

	for instruction in instructions {
		if seenSources.contains(instruction.from) {
			throw PlanError.duplicateSource(path: instruction.from)
		}
		seenSources.insert(instruction.from)

		if seenDestinations.contains(instruction.to) {
			throw PlanError.conflictingDestination(path: instruction.to)
		}
		seenDestinations.insert(instruction.to)

		if !force && checkDestinations(instruction.to) {
			throw PlanError.destinationExists(path: instruction.to)
		}
	}

	return Plan(instructions: instructions)
}
