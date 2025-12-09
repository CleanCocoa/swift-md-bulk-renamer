import Testing

@testable import swift_md_bulk_renamer

@Test func `accepts valid relative paths`() throws {
	try validatePath("file.txt")
	try validatePath("dir/file.md")
	try validatePath("a/b/c/file.txt")
	try validatePath("./file.txt")
	try validatePath("dir/./file.txt")
}

@Test func `accepts paths with dots in names`() throws {
	try validatePath("my.file.txt")
	try validatePath("dir.name/file.txt")
	try validatePath("...file")
}

@Test func `rejects absolute paths`() {
	#expect(throws: PathValidationError.absolutePath("/etc/hosts")) {
		try validatePath("/etc/hosts")
	}
	#expect(throws: PathValidationError.absolutePath("/file.txt")) {
		try validatePath("/file.txt")
	}
	#expect(throws: PathValidationError.absolutePath("/")) {
		try validatePath("/")
	}
}

@Test func `rejects parent directory escapes`() {
	#expect(throws: PathValidationError.parentDirectoryEscape("..")) {
		try validatePath("..")
	}
	#expect(throws: PathValidationError.parentDirectoryEscape("../file.txt")) {
		try validatePath("../file.txt")
	}
	#expect(throws: PathValidationError.parentDirectoryEscape("dir/../file.txt")) {
		try validatePath("dir/../file.txt")
	}
	#expect(throws: PathValidationError.parentDirectoryEscape("dir/subdir/../../file.txt")) {
		try validatePath("dir/subdir/../../file.txt")
	}
	#expect(throws: PathValidationError.parentDirectoryEscape("dir/../..")) {
		try validatePath("dir/../..")
	}
}

#if !os(Windows)
	@Test func `rejects Windows drive prefixes`() {
		#expect(throws: PathValidationError.windowsDrivePrefix("C:file.txt")) {
			try validatePath("C:file.txt")
		}
		#expect(throws: PathValidationError.windowsDrivePrefix("C:\\file.txt")) {
			try validatePath("C:\\file.txt")
		}
		#expect(throws: PathValidationError.windowsDrivePrefix("D:\\dir\\file.txt")) {
			try validatePath("D:\\dir\\file.txt")
		}
		#expect(throws: PathValidationError.windowsDrivePrefix("Z:file.txt")) {
			try validatePath("Z:file.txt")
		}
		#expect(throws: PathValidationError.windowsDrivePrefix("c:file.txt")) {
			try validatePath("c:file.txt")
		}
		#expect(throws: PathValidationError.windowsDrivePrefix("d:\\file.txt")) {
			try validatePath("d:\\file.txt")
		}
	}

	@Test func `rejects Windows UNC paths`() {
		#expect(throws: PathValidationError.windowsUNCPath("\\\\server\\share")) {
			try validatePath("\\\\server\\share")
		}
		#expect(throws: PathValidationError.windowsUNCPath("\\\\server\\share\\file.txt")) {
			try validatePath("\\\\server\\share\\file.txt")
		}
		#expect(throws: PathValidationError.windowsUNCPath("\\\\")) {
			try validatePath("\\\\")
		}
	}
#endif

#if os(Windows)
	@Test func `accepts Windows drive prefixes on Windows`() throws {
		try validatePath("C:file.txt")
		try validatePath("C:\\file.txt")
		try validatePath("D:\\dir\\file.txt")
		try validatePath("c:file.txt")
	}

	@Test func `accepts Windows UNC paths on Windows`() throws {
		try validatePath("\\\\server\\share")
		try validatePath("\\\\server\\share\\file.txt")
	}

	@Test func `rejects parent directory escapes with backslashes on Windows`() {
		#expect(throws: PathValidationError.parentDirectoryEscape("..\\file.txt")) {
			try validatePath("..\\file.txt")
		}
		#expect(throws: PathValidationError.parentDirectoryEscape("dir\\..\\file.txt")) {
			try validatePath("dir\\..\\file.txt")
		}
	}
#endif

@Test func `accepts paths with colons not at drive position`() throws {
	try validatePath("file:name.txt")
	try validatePath("dir/file:name.txt")
	try validatePath("::file.txt")
}

@Test func `validateInstruction checks both from and to paths`() throws {
	try validateInstruction(Instruction(from: "a.txt", to: "b.txt")!)
	try validateInstruction(Instruction(from: "dir/a.txt", to: "dir/b.txt")!)
}

@Test func `validateInstruction rejects absolute path in from`() {
	let instruction = Instruction(from: "/etc/hosts", to: "local.txt")!
	#expect(throws: PathValidationError.absolutePath("/etc/hosts")) {
		try validateInstruction(instruction)
	}
}

@Test func `validateInstruction rejects absolute path in to`() {
	let instruction = Instruction(from: "local.txt", to: "/etc/hosts")!
	#expect(throws: PathValidationError.absolutePath("/etc/hosts")) {
		try validateInstruction(instruction)
	}
}

@Test func `validateInstruction rejects parent escape in from`() {
	let instruction = Instruction(from: "../file.txt", to: "local.txt")!
	#expect(throws: PathValidationError.parentDirectoryEscape("../file.txt")) {
		try validateInstruction(instruction)
	}
}

@Test func `validateInstruction rejects parent escape in to`() {
	let instruction = Instruction(from: "local.txt", to: "../file.txt")!
	#expect(throws: PathValidationError.parentDirectoryEscape("../file.txt")) {
		try validateInstruction(instruction)
	}
}

#if !os(Windows)
	@Test func `validateInstruction rejects Windows drive in from`() {
		let instruction = Instruction(from: "C:\\file.txt", to: "local.txt")!
		#expect(throws: PathValidationError.windowsDrivePrefix("C:\\file.txt")) {
			try validateInstruction(instruction)
		}
	}

	@Test func `validateInstruction rejects Windows drive in to`() {
		let instruction = Instruction(from: "local.txt", to: "D:\\file.txt")!
		#expect(throws: PathValidationError.windowsDrivePrefix("D:\\file.txt")) {
			try validateInstruction(instruction)
		}
	}

	@Test func `validateInstruction rejects Windows UNC in from`() {
		let instruction = Instruction(from: "\\\\server\\share\\file.txt", to: "local.txt")!
		#expect(throws: PathValidationError.windowsUNCPath("\\\\server\\share\\file.txt")) {
			try validateInstruction(instruction)
		}
	}

	@Test func `validateInstruction rejects Windows UNC in to`() {
		let instruction = Instruction(from: "local.txt", to: "\\\\server\\share\\file.txt")!
		#expect(throws: PathValidationError.windowsUNCPath("\\\\server\\share\\file.txt")) {
			try validateInstruction(instruction)
		}
	}
#endif

#if os(Windows)
	@Test func `validateInstruction accepts Windows paths on Windows`() throws {
		try validateInstruction(Instruction(from: "C:\\file.txt", to: "local.txt")!)
		try validateInstruction(Instruction(from: "local.txt", to: "D:\\dir\\file.txt")!)
		try validateInstruction(Instruction(from: "\\\\server\\share\\file.txt", to: "local.txt")!)
	}

	@Test func `validateInstruction rejects parent escape with backslashes on Windows`() {
		let instruction = Instruction(from: "..\\file.txt", to: "local.txt")!
		#expect(throws: PathValidationError.parentDirectoryEscape("..\\file.txt")) {
			try validateInstruction(instruction)
		}
	}
#endif
