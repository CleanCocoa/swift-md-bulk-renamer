import Foundation

public enum PathValidationError: Error, Equatable {
	case absolutePath(String)
	case parentDirectoryEscape(String)
	case windowsDrivePrefix(String)
	case windowsUNCPath(String)
	case sourceIsSymlink(String)
	case destinationIsSymlink(String)
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

public func validateNotSymlink(_ path: String, in baseDirectory: URL, fileManager: FileManager = .default) throws {
	let fullPath = baseDirectory.appendingPathComponent(path).path
	var isDirectory: ObjCBool = false
	if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
		let attributes = try fileManager.attributesOfItem(atPath: fullPath)
		if let fileType = attributes[.type] as? FileAttributeType, fileType == .typeSymbolicLink {
			throw PathValidationError.sourceIsSymlink(path)
		}
	}
}

public func validateInstruction(_ instruction: Instruction) throws {
	try validatePath(instruction.from.value)
	try validatePath(instruction.to.value)
}
