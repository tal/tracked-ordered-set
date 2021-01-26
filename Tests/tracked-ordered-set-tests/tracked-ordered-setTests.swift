import XCTest
@testable import TrackedOrderedSet

enum Basic: String {
	case one, two, three, four, five, six, seven
}

final class TrackedOrderedSetTests: XCTestCase {
	func testMoveToFirst() {
		let initialBase: OrderedSet<Basic> = [.one, .two, .three, .four]
		let moved: OrderedSet<Basic> = [.four, .one, .two, .three]
		
		let diff = initialBase.relativeDiff(from: moved)
		XCTAssert(diff.changes == [
			.positioning(of: .four, position: .first)
		])
	}
	
	func testMoveUp() {
		let initialBase: OrderedSet<Basic> = [.one, .two, .three, .four]
		let moved: OrderedSet<Basic> = [.one, .two, .four, .three]
		
		let diff = initialBase.relativeDiff(from: moved)
		XCTAssert(diff.changes == [
			.positioning(of: .four, position: .after(.two))
		] || diff.changes == [
			.positioning(of: .four, position: .before(.three))
		] || diff.changes == [
			.positioning(of: .three, position: .after(.four))
		] || diff.changes == [
			.positioning(of: .three, position: .last)
		])
	}
	
	func testMoveDown() {
		let initialBase: OrderedSet<Basic> = [.one, .two, .three, .four]
		let moved: OrderedSet<Basic> = [.two, .three, .one, .four]
		
		let diff = initialBase.relativeDiff(from: moved)
		XCTAssert(diff.changes == [
			.positioning(of: .one, position: .after(.three))
		])
	}
	
	func testRemoval() {
		let initialBase: OrderedSet<Basic> = [.one, .two, .three, .four]
		let moved: OrderedSet<Basic> = [.one, .two, .four]
		
		let diff = initialBase.relativeDiff(from: moved)
		XCTAssert(diff.changes == [
			.removal(of: .three)
		])
	}
	
	func testTestGoingDown() {
		let tracked = TrackedOrderedSet(["1","2","3","4","5"])
		
		tracked.move(fromOffsets: [1], toOffset: 3)
		XCTAssert(tracked.diff.changes == [.positioning(of: "2", position: .before("5"))])
		XCTAssert(tracked.contents == ["1","3","4","2","5"])
		
//		let newBase = TrackedOrderedSet(["1","hi","2","3","4","5"], diff: tracked.diff)
//		XCTAssert(newBase.contents == ["1","hi","3","4","2","5"])
	}
	
	func testGoingUp() {
		let tracked = TrackedOrderedSet(["1","2","3","4","5"])
		tracked.move(fromOffsets: [3], toOffset: 1)

		XCTAssert(tracked.diff.changes == [.positioning(of: "4", position: .after("1"))])
		XCTAssert(tracked.contents == ["1","4","2","3","5"])
	}
	
	func testGoingUp2() {
		let tracked = TrackedOrderedSet(["1","2","3","4","5"])
		tracked.move(fromOffsets: [4], toOffset: 2)
		
		XCTAssert(tracked.diff.changes == [.positioning(of: "5", position: .after("2"))])
		XCTAssert(tracked.contents == ["1","2","5","3","4"])
	}
	
	func testGoingFirst() {
		let tracked = TrackedOrderedSet(["1","2","3","4","5"])
		tracked.move(fromOffsets: [3], toOffset: 0)
		
		XCTAssert(tracked.diff.changes == [.positioning(of: "4", position: .first)])
		XCTAssert(tracked.contents == ["4","1","2","3","5"])
	}
	
	func testGoingLast() {
		let tracked = TrackedOrderedSet(["1","2","3","4","5"])
		tracked.move(fromOffsets: [3], toOffset: 4)
		
		XCTAssert(tracked.diff.changes == [.positioning(of: "4", position: .last)])
		XCTAssert(tracked.contents == ["1","2","3","5","4"])
	}
	
	func testRegenerating() {
		let diff = RelativeSetDiff(changes: [.positioning(of: "2", position: .before("5"))])
		let newBase = TrackedOrderedSet(["1","hi","2","3","4","5"], diff: diff)
		XCTAssert(newBase.contents == ["1","hi","3","4","2","5"])
	}
	
	func testRegenerating2() {
		let diff = RelativeSetDiff(changes: [.positioning(of: "4", position: .after("1"))])
		let newBase = TrackedOrderedSet(["1","hi","2","3","4","5"], diff: diff)
		XCTAssert(newBase.contents == ["1","4","hi","2","3","5"])
	}
	
	func testRegeneratingMultiple() {
		let diff = RelativeSetDiff(changes: [
			.positioning(of: "4", position: .after("1")),
			.positioning(of: "1", position: .before("3")),
		])
		let newBase = TrackedOrderedSet(["1","hi","2","3","4","5"], diff: diff)
		XCTAssert(newBase.contents == ["4","hi","2","1","3","5"])
	}
	
	func testRegeneratingMultipleSame() {
		let diff = RelativeSetDiff(changes: [
			.positioning(of: "4", position: .after("1")),
			.positioning(of: "1", position: .before("3")),
			.positioning(of: "4", position: .before("3")),
		])
		let newBase = TrackedOrderedSet(["1","hi","2","3","4","5"], diff: diff)
		XCTAssert(newBase.contents == ["hi","2","1","4","3","5"])
	}

	static var allTests = [
		("testMoveToFirst", testMoveToFirst),
		("testMoveUp", testMoveUp),
	]
}
