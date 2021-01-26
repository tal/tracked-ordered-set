////
////  OrderedSet.swift
////  
////  https://github.com/apple/swift-package-manager/blob/5d05348c6fd072ae7989ed8b55ac2b017486acf4/Sources/Basic/OrderedSet.swift
////

import Foundation

public enum SetDiffApplicationError: Error {
	case invalidItem(String)
}

internal struct OrderedSet<E: Hashable>: Equatable, Collection {
	internal typealias Element = E
	internal typealias Index = Int
	
	#if swift(>=4.1.50)
	internal typealias Indices = Range<Int>
	#else
	internal typealias Indices = CountableRange<Int>
	#endif
	
	private var array: [Element]
	private var set: Set<Element>
	
	/// Creates an empty ordered set.
	internal init() {
		self.array = []
		self.set = Set()
	}
	
	internal init(_ array: [Element]) {
		self.init()
		for element in array {
			append(element)
		}
	}
	
	/// The number of elements the ordered set stores.
	internal var count: Int { return array.count }
	
	/// Returns `true` if the set is empty.
	internal var isEmpty: Bool { return array.isEmpty }
	
	/// Returns the contents of the set as an array.
	internal var contents: [Element] { return array }
	
	/// Returns `true` if the ordered set contains `member`.
	internal func contains(_ member: Element) -> Bool {
		return set.contains(member)
	}
	
	internal func index(of member: Element) -> Index? {
		return array.firstIndex(of: member)
	}
	
	internal subscript(before index: Index) -> Element? {
		let newIdx = index - 1
		guard newIdx >= startIndex, newIdx < endIndex else {
			return nil
		}
		
		return self[newIdx]
	}
	
	internal subscript(after index: Index) -> Element? {
		let newIdx = index + 1
		guard newIdx >= startIndex, newIdx < endIndex else {
			return nil
		}
		
		return self[newIdx]
	}
	
	internal subscript(safe index: Index) -> Element? {
		guard index >= startIndex, index < endIndex else {
			return nil
		}
		
		return self[index]
	}
	
	/// Adds an element to the ordered set.
	///
	/// If it already contains the element, then the set is unchanged.
	///
	/// - returns: True if the item was inserted.
	@discardableResult
	internal mutating func append(_ newElement: Element) -> Bool {
		let inserted = set.insert(newElement).inserted
		if inserted {
			array.append(newElement)
		}
		return inserted
	}
	
	/// Remove and return the element at the beginning of the ordered set.
	@discardableResult
	internal mutating func removeFirst() -> Element {
		let firstElement = array.removeFirst()
		set.remove(firstElement)
		return firstElement
	}
	
	/// Remove and return the element at the end of the ordered set.
	@discardableResult
	internal mutating func removeLast() -> Element {
		let lastElement = array.removeLast()
		set.remove(lastElement)
		return lastElement
	}
	
	/// Remove all elements.
	internal mutating func removeAll(keepingCapacity keepCapacity: Bool) {
		array.removeAll(keepingCapacity: keepCapacity)
		set.removeAll(keepingCapacity: keepCapacity)
	}
	
	@discardableResult
	internal mutating func remove(at idx: Index) -> Element {
		let el = array[idx]
		set.remove(el)
		array.remove(at: idx)
		return el
	}
	
	internal mutating func move(fromOffsets: IndexSet, toOffset: Index) {
		for idx in fromOffsets {
			let oldIndex = idx
			move(fromOffset: oldIndex, toOffset: toOffset)
		}
	}
	
	internal mutating func move(fromOffset oldIndex: Index, toOffset: Index) {
		// Don't work for free and use swap when indices are next to each other - this
		// won't rebuild array and will be super efficient.
		if oldIndex == toOffset { return }
		if abs(toOffset - oldIndex) == 1 { return array.swapAt(oldIndex, toOffset) }
		array.insert(array.remove(at: oldIndex), at: toOffset)
	}
	
	internal mutating func insert(_ newElement: Element, at i: Index) {
		let inserted = set.insert(newElement).inserted
		if inserted {
			array.insert(newElement, at: i)
		} else {
			move(fromOffset: array.firstIndex(of: newElement)!, toOffset: i)
		}
	}
	
	@discardableResult
	internal mutating func apply(diff: RelativeSetDiff<Element>) -> ([SetDiffApplicationError]) {
		var warnings = Array<SetDiffApplicationError>()
		for change in diff.changes {
			switch change {
			case .positioning(of: let of, position: let position):
				guard let idxToMove = index(of: of) else {
					warnings.append(SetDiffApplicationError.invalidItem("Trying to move item, couldn't find its position: `\(of)`"))
					continue
				}
				
				switch position {
				case .first:
					self.move(fromOffset: idxToMove, toOffset: 0)
				case .last:
					self.append(of)
				case .after(let adjacentItem):
					guard let adjacentIndex = index(of: adjacentItem) else {
						warnings.append(SetDiffApplicationError.invalidItem("Trying to move item, the target position of: `\(adjacentItem)`"))
						self.append(of)
						continue
					}
					self.move(fromOffset: idxToMove, toOffset: adjacentIndex + 1)
				case .before(let adjacentItem):
					guard let adjacentIndex = index(of: adjacentItem) else {
						warnings.append(SetDiffApplicationError.invalidItem("Trying to move item, the target position of: `\(adjacentItem)`"))
						self.append(of)
						continue
					}
					self.move(fromOffset: idxToMove, toOffset: adjacentIndex - 1)
				}
			case .removal(of: let of):
				if let idx = index(of: of) {
					self.remove(at: idx)
				} else {
					warnings.append(SetDiffApplicationError.invalidItem("Couldn't remove item because it wasnt in set `\(of)`"))
				}
			}
		}
		
		return (warnings)
	}
	
	internal func applying(diff: RelativeSetDiff<Element>) -> OrderedSet<E> {
		var other = self
		other.apply(diff: diff)
		return other
	}
}

extension OrderedSet: ExpressibleByArrayLiteral {
	/// Create an instance initialized with `elements`.
	///
	/// If an element occurs more than once in `element`, only the first one
	/// will be included.
	internal init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}

extension OrderedSet: RandomAccessCollection {
	internal subscript(index: Int) -> E {
		get {
			return contents[index]
		}
	}
	
	internal var startIndex: Int { return contents.startIndex }
	internal var endIndex: Int { return contents.endIndex }
}

internal func == <T>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool {
	return lhs.contents == rhs.contents
}

extension OrderedSet: Hashable where Element: Hashable { }

extension OrderedSet: Codable where Element: Codable {
	internal init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let array = try container.decode(Array<Element>.self)
		
		self.init(array)
	}
	
	internal func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(array)
	}
}
