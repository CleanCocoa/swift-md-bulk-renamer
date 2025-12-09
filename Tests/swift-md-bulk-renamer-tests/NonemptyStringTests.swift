import Testing

@testable import swift_md_bulk_renamer

@Test func `init returns nil for empty string`() {
	let emptyString = ""
	let result = NonemptyString(emptyString)
	#expect(result == nil)
}

@Test func `init returns nil for whitespace-only string`() {
	let spacesString = "   "
	let tabsString = "\t"
	#expect(NonemptyString(spacesString) == nil)
	#expect(NonemptyString(tabsString) == nil)
}

@Test func `init succeeds for non-empty string`() {
	let helloString = "hello"
	let result = NonemptyString(helloString)
	#expect(result != nil)
	#expect(result?.value == "hello")
}

@Test func `value returns trimmed string`() {
	let spacesString = "  hello  "
	let withSpaces = NonemptyString(spacesString)
	#expect(withSpaces?.value == "hello")

	let tabsString = "\t\tworld\t\t"
	let withTabs = NonemptyString(tabsString)
	#expect(withTabs?.value == "world")

	let mixedString = "  \t  foo  \t  "
	let mixed = NonemptyString(mixedString)
	#expect(mixed?.value == "foo")
}

@Test func `string literal initialization works`() {
	let literal: NonemptyString = "test"
	#expect(literal.value == "test")

	let withSpaces: NonemptyString = "  content  "
	#expect(withSpaces.value == "content")
}
