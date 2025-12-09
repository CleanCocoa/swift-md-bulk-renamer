import Foundation

public enum PathValidationError: Error, Equatable {
	case absolutePath(String)
	case parentDirectoryEscape(String)
	case windowsDrivePrefix(String)
	case windowsUNCPath(String)
}

public func validatePath(_ path: String) throws {
	if path.hasPrefix("/") {
		throw PathValidationError.absolutePath(path)
	}

	if path.hasPrefix(#"\\"#) {
		throw PathValidationError.windowsUNCPath(path)
	}

	if path.count >= 2 {
		let secondChar = path.index(path.startIndex, offsetBy: 1)
		if path[secondChar] == ":" {
			let firstChar = path[path.startIndex]
			if firstChar.isLetter {
				throw PathValidationError.windowsDrivePrefix(path)
			}
		}
	}

	let components = path.split(separator: "/", omittingEmptySubsequences: false)
	for component in components {
		if component == ".." {
			throw PathValidationError.parentDirectoryEscape(path)
		}
	}
}

public func validateInstruction(_ instruction: Instruction) throws {
	try validatePath(instruction.from)
	try validatePath(instruction.to)
}
