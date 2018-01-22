/*:
# Semigroup

A Semigroup is a Magma where the composition operation is associative, which means that multiple operations in sequence can happen in any time order.

To put it simply: (a <> b) <> c = a <> (b <> c)
*/

#if SWIFT_PACKAGE
    import Operadics
#endif

public protocol Semigroup: Magma {}

extension Law where Element: Semigroup {
	public static func isAssociative(_ a: Element, _ b: Element, _ c: Element) -> Bool {
		return (a <> b <> c) == (a <> (b <> c))
	}
}

extension LawInContext where Element: Semigroup {
	public static func isAssociative(_ a: Element, _ b: Element, _ c: Element) -> (Element.Context) -> Bool {
		return (a <> b <> c) == (a <> (b <> c))
	}
}

/*:
## Types

Here are some types that form a relevant Semigroup along with a specific operation.

Each type is tested for associativity in `AbstractTests.swift`, and for testing purposes every type is made to conform to `Equatable`.
*/

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "TestStructure"
// sourcery: arbitrary
struct FreeSemigroup<A>: Wrapper, Semigroup {
	typealias WrappedType = Array<A>

	let unwrap: Array<A>
	init(_ value: Array<A>) {
		self.unwrap = value
	}

	static func <> (lhs: FreeSemigroup<A>, rhs: FreeSemigroup<A>) -> FreeSemigroup<A> {
		return FreeSemigroup<A>.init(lhs.unwrap + rhs.unwrap)
	}
}

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: arbitraryGenericParameterProtocols = "Addable & Equatable"
public struct Add<A>: Wrapper, Semigroup where A: Addable {
	public typealias WrappedType = A

	public let unwrap: A
	
	public init(_ value: A) {
		self.unwrap = value
	}
	
	public static func <> (left: Add, right: Add) -> Add {
		return Add.init(A.add(left.unwrap,right.unwrap))
	}
}

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: arbitraryGenericParameterProtocols = "Multipliable"
public struct Multiply<A: Multipliable>: Wrapper, Semigroup {
	public typealias WrappedType = A

	public let unwrap: A
	
	public init(_ value: A) {
		self.unwrap = value
	}
	
	public static func <> (left: Multiply, right: Multiply) -> Multiply {
		return Multiply(A.multiply(left.unwrap,right.unwrap))
	}
}

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: arbitraryGenericParameterProtocols = "ComparableToBottom"
public struct Max<A: ComparableToBottom>: Wrapper, Semigroup {
	public typealias WrappedType = A

	public let unwrap: A
	
	public init(_ value: A) {
		self.unwrap = value
	}
	
	public static func <> (left: Max, right: Max) -> Max {
		return Max(max(left.unwrap, right.unwrap))
	}
}

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: arbitraryGenericParameterProtocols = "ComparableToTop"
public struct Min<A: ComparableToTop>: Wrapper, Semigroup {
	public typealias WrappedType = A

	public let unwrap: A
	
	public init(_ value: A) {
		self.unwrap = value
	}
	
	public static func <> (left: Min, right: Min) -> Min {
		return Min(min(left.unwrap, right.unwrap))
	}
}

//: ------

// sourcery: arbitrary
public struct And: Wrapper, Semigroup, Equatable, ExpressibleByBooleanLiteral {
	public typealias WrappedType = Bool
	public typealias BooleanLiteralType = Bool

	public let unwrap: Bool

	public init(_ value: Bool) {
		self.unwrap = value
	}

	public init(booleanLiteral value: BooleanLiteralType) {
		self.init(value)
	}

	public static func <> (left: And, right: And) -> And {
		return And(left.unwrap && right.unwrap)
	}
}

//: ------

// sourcery: arbitrary
public struct Or: Wrapper, Semigroup, Equatable, ExpressibleByBooleanLiteral {
	public typealias WrappedType = Bool
	public typealias BooleanLiteralType = Bool

	public let unwrap: Bool

	public init(_ value: Bool) {
		self.unwrap = value
	}

	public init(booleanLiteral value: BooleanLiteralType) {
		self.init(value)
	}

	public static func <> (left: Or, right: Or) -> Or {
		return Or(left.unwrap || right.unwrap)
	}
}

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: arbitraryGenericParameterProtocols = "Equatable"
public struct First<A>: Wrapper, Semigroup {
    public typealias WrappedType = A
    
    public let unwrap: A
    
    public init(_ value: A) {
        self.unwrap = value
    }
    
    public static func <> (left: First, right: First) -> First {
        return left
    }
}

//: ------

// sourcery: wrapperEquatable
// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: arbitrary
// sourcery: arbitraryGenericParameterProtocols = "Equatable"
public struct Last<A>: Wrapper, Semigroup {
    public typealias WrappedType = A
    
    public let unwrap: A
    
    public init(_ value: A) {
        self.unwrap = value
    }
    
    public static func <> (left: Last, right: Last) -> Last {
        return right
    }
}

//: ------

// sourcery: fixedTypesForPropertyBasedTests = "Int"
// sourcery: requiredContextForPropertyBasedTests = "Int"
public struct Endofunction<A>: Wrapper, Semigroup {
	public typealias WrappedType = (A) -> A

	public let unwrap: (A) -> A
	
	public init(_ value: @escaping (A) -> A) {
		self.unwrap = value
	}

	public var call: (A) -> A {
		return unwrap
	}

	public static func <> (left: Endofunction, right: Endofunction) -> Endofunction {
		return Endofunction.init { right.call(left.call($0)) }
	}
}

extension Endofunction: EquatableInContext where A: Equatable {
	public typealias Context = A

	public static func == (left: Endofunction, right: Endofunction) -> (Context) -> Bool {
		return { left.call($0) == right.call($0) }
	}
}

//: ------

// sourcery: fixedTypesForPropertyBasedTests = "Int,TestStructure"
// sourcery: requiredContextForPropertyBasedTests = "Int"
// sourcery: arbitraryFunction
// sourcery: arbitraryGenericParameterProtocols = "Semigroup & Equatable"
extension Function: Semigroup where B: Semigroup {
	public static func <> (left: Function, right: Function) -> Function {
		return Function.init { left.call($0) <> right.call($0) }
	}
}

//: ------

// sourcery: arbitrary
public enum Ordering: Semigroup {
	case lowerThan
	case equalTo
	case greaterThan
	
	public static func <> (left: Ordering, right: Ordering) -> Ordering {
		switch (left,right) {
		case (.lowerThan,_):
			return left
		case (.equalTo,_):
			return right
		case (.greaterThan,_):
			return left
		}
	}
}
