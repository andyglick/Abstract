#if SWIFT_PACKAGE
	import Operadics
#endif

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: constrainedArbitraryParameter = "A"
// sourcery: arbitraryGenericParameterProtocols = "Multipliable"
public struct Multiply<A>: Wrapper where A: Multipliable {
	public typealias WrappedType = A

	public let unwrap: A

	public init(_ value: A) {
		self.unwrap = value
	}
}

extension Multiply: Semigroup {
	public static func <> (left: Multiply, right: Multiply) -> Multiply {
		return Multiply(A.multiply(left.unwrap,right.unwrap))
	}
}

extension Multiply: Monoid {
	public static var empty: Multiply<A> {
		return Multiply.init(A.one)
	}
}

extension Multiply: CommutativeMonoid {}
