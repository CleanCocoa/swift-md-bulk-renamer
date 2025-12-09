import Markdown

public func generateTable(from instructions: [Instruction]) -> String {
	let header = Table.Head(Table.Cell(Text("From")), Table.Cell(Text("To")))
	let rows = instructions.map { instruction in
		Table.Row(Table.Cell(Text(instruction.from)), Table.Cell(Text(instruction.to)))
	}
	let body = Table.Body(rows)
	let table = Table(header: header, body: body)
	return table.format()
}

public func generateTable(fromFilenames filenames: [String]) -> String {
	let header = Table.Head(Table.Cell(Text("From")), Table.Cell(Text("To")))
	let rows = filenames.map { filename in
		Table.Row(Table.Cell(Text(filename)), Table.Cell())
	}
	let body = Table.Body(rows)
	let table = Table(header: header, body: body)
	return table.format()
}
