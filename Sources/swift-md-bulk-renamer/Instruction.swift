public struct Instruction: Equatable, Sendable {
	public let from: NonemptyString
	public let to: NonemptyString

	public init(from: NonemptyString, to: NonemptyString) {
		self.from = from
		self.to = to
	}

	public init?(from: String, to: String) {
		guard let fromNonEmpty = NonemptyString(from),
			let toNonEmpty = NonemptyString(to)
		else {
			return nil
		}
		self.from = fromNonEmpty
		self.to = toNonEmpty
	}
}
