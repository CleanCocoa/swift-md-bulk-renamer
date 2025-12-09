import Markdown

public enum ParseError: Error, Equatable {
	case noTableFound
	case invalidColumnCount(expected: Int, found: Int)
}

public func parse(_ markdown: String) throws -> [Instruction] {
	let document = Document(parsing: markdown)
	guard let table = document.children.compactMap({ $0 as? Table }).first else {
		throw ParseError.noTableFound
	}

	var instructions: [Instruction] = []
	for row in table.body.rows {
		let cells = Array(row.cells)
		if cells.count != 2 {
			throw ParseError.invalidColumnCount(expected: 2, found: cells.count)
		}
		let from = cells[0].plainText.trimmingCharacters(in: .whitespaces)
		let to = cells[1].plainText.trimmingCharacters(in: .whitespaces)

		if !from.isEmpty && !to.isEmpty {
			instructions.append(Instruction(from: from, to: to))
		}
	}

	return instructions
}

extension Table.Cell {
	var plainText: String {
		children.compactMap { ($0 as? Text)?.string }.joined()
	}
}
