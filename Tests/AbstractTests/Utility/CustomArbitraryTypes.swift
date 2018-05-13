import XCTest
@testable import Abstract
import SwiftCheck
#if SWIFT_PACKAGE
	import Operadics
#endif

extension Wrapper where WrappedType: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose {
            Self.init($0.generate(using: WrappedType.arbitrary))
        }
    }
}

extension CheckerArguments {
	static func with(_ lhs: Int, _ rhs: Int, _ size: Int) -> CheckerArguments {
		return CheckerArguments(
			replay: .some((StdGen(lhs,rhs),size)))
	}
}

struct TestStructure: Arbitrary, BoundedSemilattice, Equatable {
	let get: Max<Int>
	
	init(_ value: Int) {
		self.get = Max(value)
	}
	
	static var arbitrary: Gen<TestStructure> {
		return Int.arbitrary.map(TestStructure.init)
	}
	
	static func <> (lhs: TestStructure, rhs: TestStructure) -> TestStructure {
		return TestStructure((lhs.get <> rhs.get).unwrap)
	}
	
	static var empty: TestStructure {
		return TestStructure(Max<Int>.empty.unwrap)
	}
	
	static func == (lhs: TestStructure, rhs: TestStructure) -> Bool {
		return lhs.get == rhs.get
	}
}

struct TestFunction: Arbitrary, BoundedSemilattice, EquatableInContext {
	typealias Context = String
	let get: Function<String,Max<Int>>

	init(_ value: @escaping (String) -> Max<Int>) {
		self.get = Function.init(value)
	}

	static var arbitrary: Gen<TestFunction> {
		return ArrowOf<String,Max<Int>>.arbitrary
			.map { f in { f.getArrow($0) } }
			.map(TestFunction.init)
	}

	static func <> (lhs: TestFunction, rhs: TestFunction) -> TestFunction {
		return TestFunction((lhs.get <> rhs.get).unwrap)
	}

	static var empty: TestFunction {
		return TestFunction.init { _ in Max<Int>.empty }
	}

	static func == (lhs: TestFunction, rhs: TestFunction) -> (Context) -> Bool {
		return lhs.get == rhs.get
	}
}

struct TestSemiring: Arbitrary, Semiring, Equatable {
	typealias Additive = Bool.Additive
	typealias Multiplicative = Bool.Multiplicative

	let get: Bool

	init(_ value: Bool) {
		self.get = value
	}

	static var arbitrary: Gen<TestSemiring> {
		return Bool.arbitrary.map(TestSemiring.init)
	}

	static func <>+(lhs: TestSemiring, rhs: TestSemiring) -> TestSemiring {
		return TestSemiring(lhs.get <>+ rhs.get)
	}

	static func <>*(lhs: TestSemiring, rhs: TestSemiring) -> TestSemiring {
		return TestSemiring(lhs.get <>* rhs.get)
	}

	static var zero: TestSemiring {
		return TestSemiring(Bool.zero)
	}

	static var one: TestSemiring {
		return TestSemiring(Bool.one)
	}

	static func == (lhs: TestSemiring, rhs: TestSemiring) -> Bool {
		return lhs.get == rhs.get
	}
}

struct TestProduct: CoArbitrary, Hashable, Arbitrary, Wrapper {
	typealias WrappedType = (Int,Int)

	let unwrap: (Int,Int)
	
	init(_ value: (Int,Int)) {
		self.unwrap = value
	}
	
	static func coarbitrary<C>(_ x: TestProduct) -> ((Gen<C>) -> Gen<C>) {
		return { Int.coarbitrary(x.unwrap.1)(Int.coarbitrary(x.unwrap.0)($0)) }
	}
	
	static func == (lhs: TestProduct, rhs: TestProduct) -> Bool {
		return lhs.unwrap == rhs.unwrap
	}
	
	var hashValue: Int {
		return "\(unwrap.0),\(unwrap.1)".hashValue
	}
	
	static var arbitrary: Gen<TestProduct> {
		return Gen<TestProduct>.compose { TestProduct.init(($0.generate(),$0.generate())) }
	}
}

extension Endofunction: Arbitrary where A: Arbitrary & CoArbitrary & Hashable {
	public static var arbitrary: Gen<Endofunction<A>> {
		return ArrowOf<A,A>.arbitrary.map { Endofunction($0.getArrow) }
	}
}

extension Function: Arbitrary where A: CoArbitrary & Hashable, B: Arbitrary {
	public static var arbitrary: Gen<Function<A, B>> {
		return ArrowOf<A,B>.arbitrary.map { Function($0.getArrow) }
	}
}

extension NonEmptyArray: Arbitrary where A: Arbitrary {
	public static var arbitrary: Gen<NonEmptyArray<A>> {
		return Gen.zip(A.arbitrary, Array<A>.arbitrary).map {
			NonEmptyArray<A>([$0] + $1)!
		}
	}
}

extension Multiset: Arbitrary where A: Arbitrary {
	public static var arbitrary: Gen<Multiset<A>> {
		return Gen<Multiset<A>>.compose {
			Multiset<A>($0.generate(using: Array<A>.arbitrary))
		}
	}
}

extension SetM: Arbitrary where A: Arbitrary {
	public static var arbitrary: Gen<SetM<A>> {
		return Gen<SetM<A>>.compose {
			SetM<A>($0.generate(
				using: Set.arbitrary.scale {
					Swift.min($0,5) /// Without this, tests are too slow
			}))
		}
	}
}
