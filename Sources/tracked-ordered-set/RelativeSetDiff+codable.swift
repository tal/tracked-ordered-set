//
//  RelativeSetDiff+codable.swift
//  
//
//  Created by Tal Atlas on 12/18/20.
//

extension RelativeSetDiff.Position: Codable where E: Codable {
	enum CodingKeys: String, CodingKey {
		case type
		case element
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(String.self, forKey: .type)
		
		switch type {
		case "first": self = .first
		case "last": self = .last
		case "after":
			let element = try container.decode(E.self, forKey: .element)
			self = .after(element)
		case "before":
			let element = try container.decode(E.self, forKey: .element)
			self = .after(element)
		default:
			throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type key \(type)")
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case .first:
			try container.encode("first", forKey: .type)
		case .last:
			try container.encode("last", forKey: .type)
		case .after(let el):
			try container.encode("after", forKey: .type)
			try container.encode(el, forKey: .element)
		case .before(let el):
			try container.encode("before", forKey: .type)
			try container.encode(el, forKey: .element)
		}
	}
}

extension RelativeSetDiff.Change: Codable where E: Codable {
	enum CodingKeys: String, CodingKey {
		case type
		case element
		case position
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(String.self, forKey: .type)
		let element = try container.decode(E.self, forKey: .element)
		
		switch type {
		case "positioning":
			let position = try container.decode(RelativeSetDiff<E>.Position.self, forKey: .position)
			self = .positioning(of: element, position: position)
		case "removal":
			self = .removal(of: element)
		default:
			throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type key \(type)")
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case .positioning(of: let of, position: let position):
			try container.encode("positioning", forKey: .type)
			try container.encode(position, forKey: .position)
			try container.encode(of, forKey: .element)
		case .removal(of: let of):
			try container.encode("removal", forKey: .type)
			try container.encode(of, forKey: .element)
		}
	}
}
