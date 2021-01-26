protocol AutoDecodable: Decodable {}
protocol AutoEncodable: Encodable {}
protocol AutoCodable: AutoDecodable, AutoEncodable {}

public struct RelativeSetDiff<E> {
	public enum Position {
		case first
		case last
		case after(E)
		case before(E)
	}
	
	public enum Change {
		case positioning(of: E, position: Position)
		case removal(of: E)
		
		var position: Position? {
			switch self {
			case .positioning(of: _, position: let position):
				return position
			case .removal(of: _):
				return nil
			}
		}
		
		var element: E {
			switch self {
			case .positioning(of: let of, position: _):
				return of
			case .removal(of: let of):
				return of
			}
		}
	}
	
	public var changes: [Change]
	
	public init(changes: [Change]) {
		self.changes = changes
	}
}

extension RelativeSetDiff: Codable where E: Codable {}

extension RelativeSetDiff.Position: Equatable where E: Equatable {}

extension RelativeSetDiff.Change: Equatable where E: Equatable {}

extension RelativeSetDiff: Equatable where E: Equatable {}
