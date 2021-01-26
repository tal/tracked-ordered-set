//
//  relativeDiff.swift
//  
//
//  Created by Tal Atlas on 12/18/20.
//

import Foundation

extension OrderedSet {
	private typealias PositionComp = (origin: Index?, result: Index?)
	func relativeDiff(from newSet: OrderedSet<E>) -> RelativeSetDiff<E> {
//		var positions: [E: PositionComp] = [:]
		
		let mydiff = newSet.difference(from: self).inferringMoves()
		
		let changes = mydiff.compactMap { (change) -> RelativeSetDiff<E>.Change? in
			switch change {
			case .insert(offset: let offset, element: let element, associatedWith: let originalIndex):
				if offset == 0 {
					return .positioning(of: element, position: .first)
				}
				
				let before = newSet[before: offset]
				let after = newSet[after: offset]
				
				guard
					let originalIndex = originalIndex,
					self[safe: originalIndex] != nil
				else {
					if let before = before {
						return .positioning(of: element, position: .after(before))
					}
					
					if let after = after {
						return .positioning(of: element, position: .before(after))
					}
					
					return .positioning(of: element, position: .last)
				}
				
				if originalIndex < offset { // the element was moved earlier in the array
					if let before = before {
						return .positioning(of: element, position: .after(before))
					}
				}
				
				if let after = after {
					return .positioning(of: element, position: .before(after))
				}
				
				return .positioning(of: element, position: .last)
			case .remove(offset: _, element: let element, associatedWith: let otherIdx):
				guard otherIdx == nil else { return nil }
				return .removal(of: element)
			}
		}
		
//		for el in self {
//			positions[el] = (origin: index(of: el), result: nil)
//		}
//
//		for el in newSet {
//			var pos = positions[el] ?? (origin: nil, result: nil)
//			pos.result = newSet.index(of: el)
//			positions[el] = pos
//		}
//
//		let changes = positions.compactMap { (args) -> RelativeSetDiff<E>.Change? in
//			let (el,pos) = args
//
//			switch pos {
//			case (.some(_), .none):
//				return .removal(of: el)
//			case (.some(let origin), .some(let result)):
//				if origin == result {
//					return nil
//				}
//
//				if origin > result { // was moved to earlier in the array
//					if result == newSet.startIndex {
//						return .positioning(of: el, position: .first)
//					}
//
//					let newIdx = newSet.index(before: result)
//
//					let afterEl = newSet[newIdx]
//					return .positioning(of: el, position: .after(afterEl))
//				}
//
//				// was moved to later int he array
//				if result == newSet.endIndex - 1 {
//					return .positioning(of: el, position: .last)
//				}
//
//				let newIdx = newSet.index(after: result)
//
//				let afterEl = newSet[newIdx]
//				return .positioning(of: el, position: .before(afterEl))
//			case (.none, .some(let result)):
//				if result == newSet.startIndex {
//					return .positioning(of: el, position: .first)
//				}
//				if result == newSet.endIndex - 1 {
//					return .positioning(of: el, position: .last)
//				}
//
//				let newIdx = newSet.index(before: result)
//
//				let afterEl = newSet[newIdx]
//				return .positioning(of: el, position: .after(afterEl))
//			case (.none, .none):
//				return nil
//			}
//		}
		
		return RelativeSetDiff(changes: changes)
	}
}
