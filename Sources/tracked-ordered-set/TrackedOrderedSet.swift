//
//  TrackedOrderedSet.swift
//  
//
//  Created by Tal Atlas on 1/21/21.
//

import Foundation

public class TrackedOrderedSet<E: Hashable>: Collection {
	typealias Position = RelativeSetDiff<E>.Position
	typealias Change = RelativeSetDiff<E>.Change
	
	public typealias Element = E
	public typealias Index = Int
	public typealias Indices = Range<Int>

	let originalSet: OrderedSet<E>
	private(set) var diff = RelativeSetDiff<E>(changes: [])
	private(set) var set: OrderedSet<E>

	internal init(set: OrderedSet<E>, diff: RelativeSetDiff<E> = RelativeSetDiff<E>(changes: [])) {
		self.diff = diff
		self.set = set.applying(diff: diff)
		self.originalSet = set
	}
	
	public convenience init(_ items: [E], diff: RelativeSetDiff<E> = RelativeSetDiff<E>(changes: [])) {
		let set = OrderedSet(items)
		self.init(set: set, diff: diff)
	}
	
	public func move(fromOffsets: IndexSet, toOffset: Int) {
		for idx in fromOffsets {
			let item = set[idx]
			let position: Position
				
			if idx > toOffset {
				if (toOffset - 1) >= 0 {
					position = .after(set[toOffset - 1])
				}
				else {
					position = .first
				}
			}
			else {
				if (toOffset + 1) < set.endIndex {
					position = .before(set[toOffset + 1])
				} else {
					position = .last
				}
			}
			
			diff.changes.append(.positioning(of: item, position: position))
		}
		
		set.move(fromOffsets: fromOffsets, toOffset: toOffset)
	}
	
	public func remove(at idx: IndexSet) {
		for id in idx {
			let item = set[id]
			diff.changes.append(.removal(of: item))
			set.remove(at: id)
		}
	}
	
	public var contents: [E] {
		return set.contents
	}
}

extension TrackedOrderedSet: RandomAccessCollection {
	public subscript(index: Int) -> E {
		get {
			return set[index]
		}
	}
	
	public var startIndex: Int { return set.startIndex }
	public var endIndex: Int { return set.endIndex }
}

public func == <T>(lhs: TrackedOrderedSet<T>, rhs: TrackedOrderedSet<T>) -> Bool {
	return lhs.set == rhs.set
}
