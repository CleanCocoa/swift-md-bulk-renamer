#if canImport(FoundationEssentials)
	import FoundationEssentials
#else
	import Foundation
#endif

public enum ExecutorError: Error, Equatable {
	case sourceNotFound(path: String)
	case renameFailed(from: String, to: String, underlying: Error)

	public static func == (lhs: ExecutorError, rhs: ExecutorError) -> Bool {
		switch (lhs, rhs) {
		case (.sourceNotFound(let l), .sourceNotFound(let r)):
			return l == r
		case (.renameFailed(let lf, let lt, _), .renameFailed(let rf, let rt, _)):
			return lf == rf && lt == rt
		default:
			return false
		}
	}
}

public struct Executor {
	public let baseDirectory: URL
	public let fileManager: FileManager

	public init(baseDirectory: URL, fileManager: FileManager = .default) {
		self.baseDirectory = baseDirectory
		self.fileManager = fileManager
	}

	public func execute(_ instructions: [Instruction]) throws {
		for instruction in instructions {
			let sourceURL = baseDirectory.appendingPathComponent(instruction.from.value)
			let destinationURL = baseDirectory.appendingPathComponent(instruction.to.value)

			guard fileManager.fileExists(atPath: sourceURL.path) else {
				throw ExecutorError.sourceNotFound(path: instruction.from.value)
			}

			let destinationParent = destinationURL.deletingLastPathComponent()
			if !fileManager.fileExists(atPath: destinationParent.path) {
				try fileManager.createDirectory(
					at: destinationParent,
					withIntermediateDirectories: true
				)
			}

			do {
				try fileManager.moveItem(at: sourceURL, to: destinationURL)
			} catch {
				throw ExecutorError.renameFailed(
					from: instruction.from.value,
					to: instruction.to.value,
					underlying: error
				)
			}
		}
	}
}
