public struct NonemptyString: Equatable, Hashable, Sendable {
	public let value: String

	public init?(_ string: String) {
		let trimmed = string.trimmingCharacters(in: .whitespaces)
		guard !trimmed.isEmpty else { return nil }
		self.value = trimmed
	}
}

extension NonemptyString: CustomStringConvertible {
	public var description: String { value }
}

extension NonemptyString: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) {
		guard let instance = NonemptyString(value) else {
			fatalError("NonemptyString cannot be initialized with empty string literal")
		}
		self = instance
	}
}
