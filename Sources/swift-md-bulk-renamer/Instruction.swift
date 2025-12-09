public struct Instruction: Equatable, Sendable {
	public let from: String
	public let to: String

	public init(from: String, to: String) {
		self.from = from
		self.to = to
	}
}
