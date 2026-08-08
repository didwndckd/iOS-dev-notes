# Opaque Types & Existential Types

> 불투명 타입(`some`) 과 실존 타입(`any`)

Swift에서 "구체 타입을 감추는" 방법은 두 가지다.

| | `some P` (불투명 타입) | `any P` (실존 타입) |
| --- | --- | --- |
| 감추는 대상 | 호출자에게만 감춤. 컴파일러는 앎 | 컴파일러도 런타임까지 모름 |
| 타입 정체성 | **보존** (항상 하나의 구체 타입) | **소거** (매번 다른 타입일 수 있음) |
| 도입 | Swift 5.1 (SE-0244) | Swift 5.6 (SE-0335) |

이 문서는 앞부분에서 `some`을, 뒷부분(`any 실존 타입` 섹션부터)에서 `any`와 둘의 비교를 다룬다.

> 아래 코드는 모두 **Swift 6.3.2 / swiftc** 에서 실제 컴파일해 확인한 결과이며, 주석의 에러 메시지도 컴파일러가 출력한 원문이다.

- **불투명 타입(Opaque Types)**은 구체적인 타입을 숨기고 해당 타입이 채택하고 있는 프로토콜 관점에서 함수의 반환값이나 프로퍼티를 사용하게 함
- 반환값의 기본 타입이 비공개로 유지되어 모듈과 모듈을 호출하는 코드 사이의 경계에서 타입 정보를 숨기는 것이 유용함
- 프로토콜 타입을 반환하는것과 달리 불투명 타입은 **타입 정체성(ID)**을 보존함
  - 컴파일러는 타입 정보에 접근이 가능하지만 모듈의 클라이언트는 접근 불가
  - 불투명 타입은 하나의 구체적 타입만 참조함

- `some` 키워드는 리턴 타입을 자동으로 그리고 빠르게 추론할 수 있는 스위치 기능
- 이를 통해 유연하고 간결한 코드를 작성할 수 있다
- Swift5.1의 새로운 기능임



## 불투명한 타입이 해결하는 문제

예를 들어 ASCII 그림을 그리는 모듈을 작성했다고 가정하자. ASCII 그림을 그리는 타입은 `Shape` 프로토콜을 채택 한다. 그리고 `Shape` 프로토콜의 요구 사항은 ASCII 문자열을 반환하는 `draw() -> String` 함수이다. 

``` swift
protocol Shape {
    func draw() -> String
}

struct Triangle: Shape {
    var size: Int
    func draw() -> String {
        var result: [String] = []
        for length in 1...size {
            result.append(String(repeating: "*", count: length))
        }
        return result.joined(separator: "\n")
    }
}
let smallTriangle = Triangle(size: 3)
print(smallTriangle.draw())
// *
// **
// ***
```

여기까지는 일반적인 프로토콜을 채택한 구조체이다. 하지만 어떤 `Shape`를 채택하는 타입을 받아서 `draw()` 함수를 통해 그것을 수직으로 뒤집는 타입이 있다고 가정했을 때 이 접근방식에는 정확한 제네릭 타입을 노출해야하는 제한이 있다.

- 사실 지금의 경우에는 제네릭을 쓰지 않고도 구현은 가능함 `Shape`가 `associatedtype`이나 `Self`를 사용하면 제네릭을 필수로 써야함

``` swift
struct FlippedShape<T: Shape>: Shape {
    var shape: T
    func draw() -> String {
        let lines = shape.draw().split(separator: "\n")
        return lines.reversed().joined(separator: "\n")
    }
}
let flippedTriangle = FlippedShape(shape: smallTriangle)
print(flippedTriangle.draw())
// ***
// **
// *
```

아래 코드처럼 두개의 모양을 수직으로 결합하는 타입 `JoinedShape<T: Shape, U: Shape>`을 정의하고 `FlippedShape`를 넣어 모양을 만든다고 가정하면 `JoinedShape<FlippedShape<Triangle>, Triangle>`와 같은 복잡한 타입을 생성하게된다.

``` swift
struct JoinedShape<T: Shape, U: Shape>: Shape {
    var top: T
    var bottom: U
    func draw() -> String {
        return top.draw() + "\n" + bottom.draw()
    }
}
let joinedTriangles = JoinedShape(top: smallTriangle, bottom: flippedTriangle) // JoinedShape<FlippedShape<Triangle>, Triangle>
print(joinedTriangles.draw())
// *
// **
// ***
// ***
// **
// *
```

위 코드의 경우 `JoinedShape` 타입의 내부 `T`, `U` 타입을 명시 해야하고 이는 모듈 내 공개되지않은 타입을 모듈 외부에 노출시킬 수 있다.

모듈 내부에서는 다양한 방법으로 같은 모양을 구현할 수 있으며 모듈 외부에서는 이러한 세부 구현 정보를 알 필요가 없다. 이를 알게된다는것은 정확한 반환 유형에 의존하게 된다는 의미이고 해당 모듈의 작성자가 추후에 내용을 변경하려는 경우 문제가 될 수 있음.



## 불투명 타입 반환

불투명 타입 반환은 제네릭과 반대라고 볼 수 있다. 제네릭은 호출자에 의해 타입이 정해지는 반면 불투명 타입은 내부 구현부에서 반환 타입이 정해진다.

그러니까 제네릭은 함수 내부에서 추상화된 타입을 사용하고 불투명 타입은 함수 회부에서 추상적인 타입을 사용하게된다.

아래 코드는 제네릭 사용의 예제이다. 이 함수의 반환 타입은 매개변수 `x`, `y`의 타입에 따라 반환 타입 `T`가 정해진다. 따라서 함수 내부에서 추상적인 타입이 사용되고, 외부에서 정확한 타입 지정이 이루어진다고 볼 수 있다.

``` swift
func max<T>(_ x: T, _ y: T) -> T where T: Comparable { ... }
```

불투명 타입 반환은 제네릭 타입 반환과 반대로 이루어진다 제네릭 타입 반환은 호출자에 의해 반환 타입이 정해지는 반면 불투명 타입 반환은 함수 내부에서 추상화된 방식으로 반환되는 타입을 정하게 된다.

아래 예제를 보면 `makeTrapezoid()` 함수는 정확한 타입을 노출하지않고 사다리꼴을 반환한다. `some Shape`로 반환 타입을 선언하고 내부에서 `Shape` 프로토콜을 준수하는 특정 구체적 타입의 값을 반환한다. 이렇게 구현하게 되면 현재 `makeTRapezoid()` 함수는 내부에 삼각형, 사각형, 뒤집힌 삼각형 등의 조합으로 이루어져있는데 모듈 외부에서는 함수의 구체적인 반환 타입에 의존적이지 않기때문에 추후 수정에 용이함

``` swift
struct Square: Shape {
    var size: Int
    func draw() -> String {
        let line = String(repeating: "*", count: size)
        let result = Array<String>(repeating: line, count: size)
        return result.joined(separator: "\n")
    }
}

func makeTrapezoid() -> some Shape {
    let top = Triangle(size: 2)
    let middle = Square(size: 2)
    let bottom = FlippedShape(shape: top)
    let trapezoid = JoinedShape(
        top: top,
        bottom: JoinedShape(top: middle, bottom: bottom)
    )
    return trapezoid
}
let trapezoid = makeTrapezoid()
print(trapezoid.draw())
// *
// **
// **
// **
// **
// *
```

불투명 반환 타입은 제네릭과 결합해 사용할 수 있음

``` swift
func flip<T: Shape>(_ shape: T) -> some Shape {
    return FlippedShape(shape: shape)
}
func join<T: Shape, U: Shape>(_ top: T, _ bottom: U) -> some Shape {
    JoinedShape(top: top, bottom: bottom)
}

let opaqueJoinedTriangles = join(smallTriangle, flip(smallTriangle))
print(opaqueJoinedTriangles.draw())
// *
// **
// ***
// ***
// **
// *
```



## 불투명 타입 반환 제약 조건

불투명 반환 타입을 가진 함수가 여러 위치에서 반환하는 경우 모든 반환 값은 동일한 타입을 반환해야 한다. 

아래 예제는 함수 내에서 조건에 따라 다른 타입을 반환 하는데 이는 불투명 타입 반환 제약 조건에 부합하지 않음

``` swift
// Error: Function declares an opaque return type 'some Shape', but the return statements in its body do not have matching underlying types
func invalidFlip<T: Shape>(_ shape: T) -> some Shape {
    if shape is Square {
        return shape
    }
    return FlippedShape(shape: shape)
}
```

항상 단일 타입을 반환해야 한다고 해서 불투명 타입 반환에 제네릭 사용을 막지는 않는다. 다음 예제에서는 매개변수 타입에 따라 다른 타입을 반환 하지만 호출 할 때마다 항상 `[T]` 타입을 반환 하는것은 똑같기에 단일 타입을 반환한다는 제약 조건은 성립한다.

``` swift
func `repeat`<T: Shape>(shape: T, count: Int) -> some Collection {
    return Array<T>(repeating: shape, count: count)
}
```



## 불투명 타입과 프로토콜의 차이점

불투명 타입을 반환하는 것과 프로토콜 타입을 반환하는것의 차이는 **타입 정체성**을 유지하느냐 안하느냐의 차이에 있다. 사실 불투명 타입 반환에서 단일 타입을 반환해야 하는 이유도 여기에 있다. **타입 정체성**을 보장해야 하기에 단일 타입을 반환해야 하는것이다.

불투명 타입은 하나의 특정 타입을 참조하지만 함수 호출자는 어떤 타입인지 볼 수 없고 프로토콜 타입은 프로토콜을 준수하는 모든 타입을 참조할 수 있다. 일반적으로 프로토콜 타입은 저장하는 값의 **기본 타입에 대해 더 많은 유연성을 제공**하고 불투명 타입은 **기본 타입에 대해 더 강력한 보증**을 할 수 있다.

### 프로토콜

프로토콜 타입을 반환하는것은 타입 정체성을 지우고 유연성을 제공한다. 아래 코드를 보면 불투명 타입과 달리 `Shape` 프로토콜을 채택한 타입은 뭐든 반환 가능하다.

``` swift
func protoFlip<T: Shape>(_ shape: T) -> Shape {
    if shape is Square {
        return shape
    }

    return FlippedShape(shape: shape)
}
```

> 여기서 반환 타입 `Shape`는 Swift 5.6 이후 문법으로는 `any Shape`로 적는 것이 정식이다. 아래 에러 메시지가 `'any Shape'`라고 말하는 이유도 컴파일러가 이 둘을 같은 것으로 보기 때문. 자세한 내용은 [`any` 실존 타입](#any-실존-타입-existential-types) 참고.

위 함수는 구체적 타입이 아닌 프로토콜 타입으로 반환하기에 구체적 타입에 대한 정보를 알 수 없다. 그 예로 비교 연산자를 사용할 수 없음. `Shape`가 `Equatable` 프로토콜을 채택하고있더라도 문제는 `Equatable`은 내부에 `Self`를 사용하기때문에 위의 `protoFlip(_:)` 함수에서 `Shape` 타입으로의 반환이 불가능하다.

``` swift
let protoFlippedTriangle = protoFlip(smallTriangle)
let sameThing = protoFlip(smallTriangle)
protoFlippedTriangle == sameThing  // Error: Binary operator '==' cannot be applied to two 'any Shape' operands
```



### 불투명 타입

불투명 타입은 타입 정체성을 유지하고 기본 타입에 대해 더 강력한 보증을 한다. 아래 `Container` 프로토콜은 내부에 `Item`이라는 연관 타입을 사용한다.

``` swift
protocol Container {
    associatedtype Item
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}
extension Array: Container { }
```

`associatedtype`을 사용하는 프로토콜은 (Swift 5.7 이전에는) 함수의 반환 타입으로 사용할 수 없었다.

``` swift
// warning: use of protocol 'Container' as a type must be written 'any Container';
//          this will be an error in a future Swift language mode [#ExistentialAny]
func makeProtocolContainer<T>(item: T) -> Container {
    return [item]
}

// Error: Cannot convert return expression of type '[T]' to return type 'C'
func makeProtocolContainer<T, C: Container>(item: T) -> C {
    return [item]
}
```

> **최신 문법 보정**
> Swift 5.7(SE-0309)부터는 `associatedtype`/`Self`를 가진 프로토콜도 `any Container`로 적으면 실존 타입으로 사용할 수 있다. 다만 연관 타입을 반환하는 멤버는 **상한(upper bound)** 으로 지워져서 `Any`가 된다.
>
> ``` swift
> func makeAnyContainer<T>(item: T) -> any Container { [item] }
> let c = makeAnyContainer(item: 12)
> let first = c[0]          // 정적 타입은 Any
> // let bad: Int = c[0]    // Error: cannot convert value of type 'Any' to specified type 'Int'
> print(type(of: first))    // "Int"  ← 런타임 동적 타입은 Int
> ```
>
> 즉 `any`로도 "쓸 수는" 있지만, 연관 타입 정보를 잃기 때문에 아래 `some Container`가 여전히 더 강한 보증을 준다.

하지만 반환 타입으로 `some Container`를 사용하면 가능하며 여기서 `twelve`의 타입은 `Int`로 유추되고 이는 불투명 타입이 타입 추론이 동작한다는 것을 보여준다.

``` swift
func makeOpaqueContainer<T>(item: T) -> some Container {
    return [item]
}
let opaqueContainer = makeOpaqueContainer(item: 12)
let twelve = opaqueContainer[0]
print(type(of: twelve)) // "Int"
```

만약 불투명 타입이 연관 타입을 노출하고 있다면 이 연관 타입에 대한 정보도 유지한다. 아래 `x`와 `y`는 같은 `String` 타입을 인자로 넣은 `foo(x:, y:)` 함수를 호출하여 반환 받은 `some Equatable` 타입이기 때문에 같은 타입임을 보장하고 그에 따라 비교가 가능하다. 하지만 `stringResult`와 `intResult`는 서로 다른 타입을 인자로 넣은 함수 호출 결과이기에 같은 타입임을 보장하지않는다. 때문에 비교가 불가능하다.

``` swift
func foo<T: Equatable>(x: T, y: T) -> some Equatable {
  let condition = x == y
  return condition ? 1738 : 679
}

let x = foo(x: "apples", y: "bananas")
let y = foo(x: "apples", y: "some fruit nobody's ever heard of")

print(x == y) // true

let stringResult = foo(x: "A", y: "B")
let intResult = foo(x: 1, y: 2)
print(stringResult == intResult) // Error : Binary operator '==' cannot be applied to operands of type 'some Equatable' (result of 'ContentView.foo(x:y:)') and 'some Equatable' (result of 'ContentView.foo(x:y:)')
```



## 심화

> 아래 예제는 `protocol P {}`, `extension Int: P {}` 그리고 앞서 정의한 `Shape` / `Triangle` 등을 사용한다고 가정한다.

### 재귀 반환

불투명 타입을 반환하는 함수도 재귀 호출이 가능하다. 단, **모든 반환 분기가 동일한 구체 타입**을 반환해야 하고, **재귀가 아닌 구체 타입을 반환하는 분기가 최소 하나**는 있어야 한다. 그래야 컴파일러가 실제 반환 타입을 추론할 수 있다.

``` swift
func f7(_ i: Int) -> some P {
    if i == 0 {
        return f7(1)
    } else if i < 0 {
        let result = f7(-i)
        return result
    } else {
        return 0 // 구체 타입(Int)을 반환하는 분기
    }
}
```

반면 자기 자신의 결과를 다시 감싸는 재귀는 불투명 타입을 자기 자신으로 정의하는 꼴이라 불가능하다.

``` swift
struct Wrapper<T: P>: P {
    var value: T
}

func f8(_ i: Int) -> some P {
//    return Wrapper(value: f8(i + 1)) // Error: Function opaque return type was inferred as 'Wrapper<some P>', which defines the opaque type in terms of itself
    return Wrapper(value: f7(i))       // 다른 함수의 결과를 감싸는 것은 가능
}
```



### fatalError와 Never

불투명 타입을 반환하는 함수는 반드시 값을 반환해야 한다. 구체 타입을 반환하는 함수는 본문을 `fatalError()`(반환 타입 `Never`)로 대체할 수 있지만, 불투명 타입 함수는 `Never`가 해당 프로토콜을 채택하지 않는 한 불가능하다.

``` swift
func f9() -> some P {
    return 1
//    fatalError("not implemented") // Error: Return type ... requires that 'Never' conform to 'P'
}

func f9Int() -> Int {
    fatalError("error") // 구체 타입 반환 함수는 가능
}

// Never에 프로토콜을 채택시키면 불투명 타입 함수에서도 fatalError 사용 가능
extension Never: P {}
func f9b() -> some P {
    return fatalError("not implemented")
}
```



### 프로퍼티와 서브스크립트

불투명 타입은 함수 반환뿐 아니라 **연산 프로퍼티·저장 프로퍼티·서브스크립트·지역 변수·파라미터**의 타입으로도 쓸 수 있다.

``` swift
let strings: some Collection = ["hello", "world"]

protocol GameObject {
    associatedtype ObjectShape: Shape
    var shape: ObjectShape { get }
}

struct Player: GameObject {
    var shape: some Shape { // 프로퍼티에 some 사용
        return Triangle(size: 1)
    }
}
```

저장 프로퍼티와 서브스크립트에도 동일하게 쓸 수 있다.

``` swift
struct Deck {
    var stored: some Shape = Triangle(size: 1)             // 저장 프로퍼티
    subscript(i: Int) -> some Shape { Triangle(size: i) }  // 서브스크립트
}

print(Deck().stored.draw(), Deck()[3].draw())
```

#### 저장 프로퍼티는 외부에서 주입할 수 없다

저장 프로퍼티의 `some`은 **선언부의 초기화 식이 유일한 타입 정의처**다. 초기화 식을 보고 컴파일러가 실제 타입을 못 박은 뒤 그 사실을 밖으로 감추므로, 바깥에서는 그 타입을 지목할 방법이 없다. 그래서 초기화 식 외의 모든 경로가 막힌다.

``` swift
struct Deck { var stored: some Shape = Triangle(size: 1) }

// ① 멤버와이즈 이니셜라이저
Deck(stored: Triangle(size: 5))
// Error: cannot convert value of type 'Triangle' to expected argument type 'some Shape'

// ② 커스텀 init
struct Deck2 {
    var stored: some Shape = Triangle(size: 1)
    init(_ s: some Shape) { stored = s }
    // Error: cannot assign value of type 'some Shape' to type 'some Shape' (type of 'Deck2.stored')
}

// ③ 나중에 대입
var d = Deck()
d.stored = Triangle(size: 9)
// Error: cannot assign value of type 'Triangle' to type 'some Shape'

// ④ 같은 선언에서 유래한 불투명 타입끼리는 가능
d.stored = Deck().stored   // OK

// ⑤ 초기화 식이 없으면 타입을 추론할 수 없다
struct Deck3 { var stored: some Shape }
// Error: property declares an opaque return type, but has no initializer expression
//        from which to infer an underlying type [#OpaqueTypeInference]
```

②의 에러 메시지가 상황을 정확히 보여준다. **이름은 같은데 서로 다른 불투명 타입**이다. 파라미터의 `some Shape`는 호출자가 정하는 익명 제네릭이고, 프로퍼티의 `some Shape`는 선언부가 정한 별개의 타입이라 접점이 없다.

즉 `some` 저장 프로퍼티는 **타입이 선언 시점에 고정되는 슬롯**이라 주입 지점으로 쓸 수 없다. 주입이 필요하면 제네릭이나 `any`를 써야 한다.

``` swift
struct GenericDeck<S: Shape> { var stored: S }   // 주입 가능, 정적 디스패치
struct AnyDeck { var stored: any Shape }         // 주입 가능, 동적 디스패치
```

파라미터 자리의 `some`은 Swift 5.7(SE-0341)부터 가능한데, 이건 불투명 타입이 아니라 **익명 제네릭 파라미터의 축약**이라 의미가 반대다. 자세한 내용은 [파라미터 위치의 `some`과 `any`](#파라미터-위치의-some과-any-se-0341) 참고.

``` swift
func render(_ s: some Shape) -> String { s.draw() }   // == func render<T: Shape>(_ s: T) -> String
```



### 연관 타입 추론

불투명 타입 프로퍼티를 사용하면 프로토콜의 연관 타입이 자동으로 추론된다. 위 `Player`에서 `ObjectShape`는 `shape`의 실제 타입으로 추론된다.

``` swift
let pos: Player.ObjectShape
pos = Player().shape       // Player.ObjectShape
let pos2 = Player().shape  // some Shape
```



### 옵셔널 반환

불투명 타입은 옵셔널로도 반환할 수 있다. 이때도 모든 반환 분기의 구체 타입은 같아야 한다.

``` swift
func f(flip: Bool) -> (some P)? {
    if flip {
        return 1
    } else {
        return 0 // 같은 Int 타입
    }
}
```



### 오버라이드 제약

불투명 타입을 반환하는 메서드는 오버라이드할 수 없다. 부모 클래스와 동일한 타입을 반환하도록 강제되기 때문이다. (프로토콜 타입을 반환하는 메서드는 오버라이드 가능)

``` swift
class C {
    func f() -> some P { return 0 }
    func g() -> P { return "0" }
}

class D: C {
//    override func f() -> some P { return 2 } // Error: Method does not override any method from its superclass
    override func g() -> P { return 2 }         // OK
}
```

또한 프로토콜 요구사항의 반환 타입으로는 `some`을 쓸 수 없다.

``` swift
protocol Q {
//    func f() -> some P // Error: 'some' type cannot be the return type of a protocol requirement; did you mean to add an associated type?
}
```



### 유일성(Uniqueness)

같은 함수라도 호출 지점마다의 결과는 그 지점에 고정된 불투명 타입이라, 서로 다른 호출 결과끼리는 호환되지 않는다.

``` swift
func makeOpaque<T>(_ : T.Type) -> some Any {
    return 1
}

var xx = makeOpaque(Int.self)
//xx = makeOpaque(Double.self) // Error: Cannot assign value of type 'some Any' (result of 'makeOpaque') to type 'some Any' (result of 'makeOpaque')

extension Array where Element: Comparable {
    func opaqueSorted() -> some Sequence {
        return self.sorted()
    }
}

var xxx = [1, 2, 3].opaqueSorted()
//xxx = ["a", "b", "c"].opaqueSorted() // Error: 원소 타입 불일치
xxx = [3, 4, 5].opaqueSorted()         // OK (같은 Int 결과)
```



### 타입 제약과 합성

`some` 뒤에 오는 타입은 클래스 또는 실존 타입(프로토콜, `Any`, `AnyObject`, 클래스)으로 제한되며 `&`로 합성할 수 있다.

``` swift
func makeMeACollection<T>(with: T) -> some RangeReplaceableCollection & MutableCollection {
    return [with]
}

var c = makeMeACollection(with: 17)
c.append(c.first!)         // RangeReplaceableCollection
c[c.startIndex] = c.first! // MutableCollection
print(c.reversed())        // Collection / Sequence
```



## `any` 실존 타입 (Existential Types)

> 이 절 이후의 예제는 별도 선언이 없으면 아래 타입들을 전제로 한다.
>
> ``` swift
> protocol Shape { func draw() -> String }
> struct Triangle: Shape { var size: Int; func draw() -> String { "T" } }
> struct Square: Shape   { var size: Int; func draw() -> String { "S" } }
> ```

### 왜 `any` 키워드가 생겼나

Swift 5.6 이전에는 프로토콜 이름을 그냥 타입 자리에 쓸 수 있었다.

``` swift
protocol Shape { func draw() -> String }

func bare(_ s: Shape) -> Shape { s }   // 이게 "프로토콜 타입"
```

문제는 이 한 줄에서 `Shape`가 **두 가지 전혀 다른 의미**로 쓰인다는 점이다.

``` swift
struct Triangle: Shape { ... }              // ① 제약(constraint)으로서의 Shape
func f<T: Shape>(_ x: T) { ... }            // ① 제약
let s: Shape = Triangle(size: 1)            // ② 타입(실존 타입)으로서의 Shape
```

②는 "Shape를 준수하는 **어떤** 타입의 값을 담은 박스"라는, 비용도 성능 특성도 다른 별개의 개념인데 문법이 똑같아서 초보자가 구분하지 못했다. 그래서 [SE-0335](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md)에서 ②를 `any Shape`로 **명시적으로** 적도록 바꿨다.

``` swift
func bare(_ s: any Shape) -> any Shape { s }   // 정식 표기
```

`any` 없이 적어도 지금은 컴파일된다. 다만 `ExistentialAny` upcoming feature를 켜면 경고가 나오고, **향후 언어 모드에서는 에러**가 된다.

``` bash
swiftc -swift-version 6 -enable-upcoming-feature ExistentialAny main.swift
```

```
warning: use of protocol 'Shape' as a type must be written 'any Shape';
         this will be an error in a future Swift language mode [#ExistentialAny]
```

> `any P`는 새로운 기능이 아니라 **기존 프로토콜 타입에 이름을 붙인 것**이다. 동작은 예전과 동일하다.



### 실존 컨테이너(Existential Container)

`any P`는 구체 타입을 **박스**에 담는다. 박스의 내부 구조는 대략 이렇다.

| 구성 | 크기 |
| --- | --- |
| 인라인 값 버퍼 | 3 word (24 byte) |
| 타입 메타데이터 포인터 | 1 word (8 byte) |
| 프로토콜 witness table 포인터 | 프로토콜 개수 × 1 word |

실제로 찍어보면 아래와 같다.

``` swift
protocol P {}
struct Small: P { var a: Int }              // 8 byte
struct Big: P { var a, b, c, d, e: Int }    // 40 byte

print(MemoryLayout<any P>.size)     // 40  = 24(buffer) + 8(metadata) + 8(witness table)
print(MemoryLayout<Any>.size)       // 32  = 24(buffer) + 8(metadata), witness table 없음
print(MemoryLayout<AnyObject>.size) //  8  = 클래스 전용이라 포인터 하나면 충분
```

핵심은 **3 word 규칙**이다.

- 값이 24 byte 이하 → 버퍼에 그대로 인라인 저장 (힙 할당 없음)
- 값이 24 byte 초과 → **힙에 박싱**되고 버퍼에는 포인터만 저장

즉 `Big`처럼 프로퍼티가 조금만 많아져도 `any P`에 담는 순간 힙 할당 + 참조 카운팅이 따라붙는다.



### 타입 정체성이 지워진다

`any P`는 "P를 준수하는 어떤 타입"일 뿐이라 서로 다른 두 `any P`가 같은 타입이라는 보장이 없다. 그래서 `Self`를 쓰는 요구사항(대표적으로 `==`)을 쓸 수 없다.

``` swift
protocol Shape: Equatable { func draw() -> String }
struct Triangle: Shape { var size: Int; func draw() -> String { "T" } }

let a: any Shape = Triangle(size: 1)
let b: any Shape = Triangle(size: 1)
let eq = (a == b)
// Error: binary operator '==' cannot be applied to two 'any Shape' operands
```

`some Shape`였다면 둘이 같은 구체 타입임이 보장되므로 비교가 된다. 앞의 [불투명 타입](#불투명-타입) 섹션에서 본 것과 정확히 같은 이야기다.



### `any P`는 `P`를 준수하지 않는다

가장 많이 걸리는 지점. **박스는 그 안에 든 것이 아니다.**

``` swift
protocol Copyable2 { func combine(_ other: Self) -> Self }
struct A: Copyable2 { func combine(_ other: A) -> A { self } }

func combineTwo<T: Copyable2>(_ a: T, _ b: T) -> T { a.combine(b) }

let anyC: any Copyable2 = A()
let bad = combineTwo(anyC, anyC)
// Error: type 'any Copyable2' cannot conform to 'Copyable2' [#ProtocolTypeNonConformance]
// note: only concrete types such as structs, enums and classes can conform to protocols
```

`any Copyable2`가 스스로를 준수한다면 `combine(_:)`의 `Self`가 무엇인지 정할 수 없기 때문이다. (`Error`, `Sendable` 등 극히 일부 프로토콜만 컴파일러가 특별 취급해서 self-conformance를 허용한다.)



### `any`만 할 수 있는 것 — 이종(heterogeneous) 컬렉션

`some`은 "하나의 구체 타입"이므로 서로 다른 타입을 한 배열에 담을 수 없다. 이 경우가 `any`의 존재 이유다.

``` swift
let shapes: [any Shape] = [Triangle(size: 1), Square(size: 2)]   // OK

let bad: [some Shape] = [Triangle(size: 1), Square(size: 2)]
// Error: conflicting arguments to generic parameter 'τ_0_0' ('Triangle' vs. 'Square')
```

박스에 담긴 실제 타입을 다시 꺼내려면 다운캐스트를 쓴다.

``` swift
if let t = shapes[0] as? Triangle { print(t.size) }
```



## `some` vs `any` 정리

| | `some P` | `any P` |
| --- | --- | --- |
| 정식 명칭 | 불투명 타입 (Opaque Type) | 실존 타입 (Existential Type) |
| 제안 | SE-0244(반환) / SE-0341(파라미터) | SE-0335 |
| 타입 정체성 | 보존 — 항상 **하나의** 구체 타입 | 소거 — 값마다 다른 타입 가능 |
| 컴파일러 관점 | 구체 타입을 앎 | 런타임까지 모름 |
| 디스패치 | 정적(제네릭 특수화 가능) | 동적(witness table) |
| 메모리 | 구체 타입 그대로 | 실존 컨테이너 + 24 byte 초과 시 힙 박싱 |
| `Self`/`associatedtype` 요구사항 | 그대로 사용 가능 | 제약됨 (연관 타입은 상한으로 지워짐) |
| 이종 컬렉션 | 불가 | 가능 |
| 여러 분기에서 다른 타입 반환 | 불가 | 가능 |

### 판단 기준

1. **기본은 `some`.** 성능도 좋고 타입 정보도 더 많이 남는다. WWDC22 "Embrace Swift generics"의 권장도 동일하다.
2. `some`으로 안 되는 순간에만 `any`로 내려간다. 구체적으로는
   - 서로 다른 타입을 한 컬렉션에 담아야 할 때 (`[any Shape]`)
   - 런타임 조건에 따라 다른 타입을 반환해야 할 때
   - 저장 프로퍼티로 여러 구현체를 갈아끼워야 할 때 (`var delegate: (any Delegate)?`)
   - 재귀적 자료구조 등 타입이 무한히 커지는 것을 끊어야 할 때
3. `any`로 받았어도 **처리 지점에서는 다시 `some`/제네릭으로 넘겨** 정적 이득을 회복할 수 있다 (아래 [암시적 열기](#암시적-열기-se-0352)).



## 파라미터 위치의 `some`과 `any` (SE-0341)

Swift 5.7부터 `some`을 **파라미터 자리**에도 쓸 수 있다. 이건 불투명 타입이 아니라 **익명 제네릭 파라미터의 축약**이다.

``` swift
func render(_ shape: some Shape) -> String { shape.draw() }

// 위 선언은 아래와 완전히 동일하다
func render<T: Shape>(_ shape: T) -> String { shape.draw() }
```

> 반환 위치의 `some`은 "**구현부**가 타입을 정함", 파라미터 위치의 `some`은 "**호출자**가 타입을 정함"이다. 같은 키워드지만 방향이 반대라는 점을 헷갈리지 말 것.

### 제네릭과의 미묘한 차이

`some`을 두 번 쓰면 서로 **독립된** 타입 파라미터가 된다.

``` swift
func pairSome(_ a: some Shape, _ b: some Shape) -> String { a.draw() + b.draw() }
pairSome(Triangle(size: 1), Square(size: 1))   // OK — 서로 다른 타입 허용

func pairGeneric<T: Shape>(_ a: T, _ b: T) -> String { a.draw() + b.draw() }
pairGeneric(Triangle(size: 1), Square(size: 1))
// Error: conflicting arguments to generic parameter 'T' ('Triangle' vs. 'Square')
```

즉 **두 인자가 같은 타입이어야 한다는 제약을 걸고 싶으면 `some`이 아니라 명시적 제네릭**을 써야 한다. `where` 절이 필요할 때도 마찬가지다.

또 `some` 파라미터는 이름이 없으므로 타입 인자를 직접 지정할 수 없다.

``` swift
pairSome<Triangle, Square>(Triangle(size: 1), Square(size: 1))
// warning: cannot explicitly specialize global function 'pairSome'
```

### 파라미터의 `some` vs `any`

``` swift
func render(_ shape: some Shape) -> String { ... }   // 제네릭 — 호출마다 특수화, 정적 디스패치
func render(_ shape: any Shape)  -> String { ... }   // 박스를 받음 — 동적 디스패치
```

파라미터로 값을 그냥 "쓰기만" 한다면 `some`이 거의 항상 낫다. `any`는 이미 박싱된 값을 **그대로 저장하거나 다시 넘길 때** 의미가 있다.



## 제약된 실존 타입 (SE-0346)

`any Collection`처럼 연관 타입을 가진 실존 타입은 원소 타입 정보를 잃어버린다. Swift 5.7의 **primary associated type** 문법으로 이를 제약할 수 있다.

프로토콜 선언에서 `<>` 안에 주요 연관 타입을 적어둔다.

``` swift
protocol Box<Value> {          // Value 가 primary associated type
    associatedtype Value
    var value: Value { get }
}
struct IntBox: Box { var value: Int }

let b: any Box<Int> = IntBox(value: 7)
let v = b.value                 // 정적 타입이 Int (Any 가 아님!)
```

표준 라이브러리도 이미 적용되어 있어서 `Sequence<Element>`, `Collection<Element>` 등을 쓸 수 있다.

``` swift
func sum(_ seq: any Sequence<Int>) -> Int { seq.reduce(0, +) }

print(sum([1, 2, 3]))          // 6   — Array<Int>
print(sum(Set([1, 2, 3])))     // 6   — Set<Int>

let coll: any Collection<Int> = [10, 20]
print(coll.count, coll.first!) // 2 10
```

`some`에도 똑같이 쓸 수 있다. `some Collection<Int>`는 "Int를 담은 어떤 컬렉션 하나"를 뜻한다.

``` swift
func f() -> some Collection<Int> { [1, 2, 3] }
let c = f()
let n: Int = c.first!   // 원소 타입이 Int 로 보장됨
```



## 암시적 열기 (SE-0352)

`any P` 값을 제네릭/`some` 파라미터에 넘기면 컴파일러가 박스를 **열어서**(open) 그 안의 구체 타입을 임시 타입 파라미터로 바인딩해 준다. Swift 5.7부터 자동이다.

``` swift
protocol Shape { func draw() -> String }
struct Triangle: Shape { var size: Int; func draw() -> String { "T" } }
struct Square: Shape { var size: Int; func draw() -> String { "S" } }

func render(_ shape: some Shape) -> String { shape.draw() }

let boxed: any Shape = Triangle(size: 1)
print(render(boxed))   // OK — boxed 안의 Triangle 이 T 로 열림

// 이종 컬렉션도 원소마다 열려서 제네릭 함수를 호출할 수 있다
let shapes: [any Shape] = [Triangle(size: 1), Square(size: 2)]
for s in shapes {
    print(render(s))
}
```

이것이 "**값을 담아둘 때는 `any`, 실제로 처리할 때는 제네릭/`some`으로 넘겨서** 정적 이득을 회복한다"는 패턴을 가능하게 한다. 축은 `경계 ↔ 내부`가 아니라 **`저장·수집 ↔ 처리`** 다. 타입을 하나로 확정할 수 없어 담아둬야 하는 자리(이종 컬렉션, 저장 프로퍼티, 런타임 조건별 반환)에만 `any`를 쓰고, 담긴 값을 다루는 지점에서는 제네릭 함수로 넘긴다.

### 열린 타입은 반환하면서 다시 지워진다

열린 타입은 **그 호출 표현식 안에서만** 존재한다. 박스 안에 뭐가 들었는지는 런타임에야 알 수 있어서 소스에 적을 이름이 없기 때문이다. 그래서 `T`가 반환 타입에 등장하면 **상한(upper bound)인 `any P`로 다시 지워진다.**

``` swift
protocol Shape { func draw() -> String }
struct Triangle: Shape { func draw() -> String { "T" } }

func identity<T: Shape>(_ s: T) -> T { s }      // 반환 타입에 T 있음
func count<T: Shape>(_ s: T) -> Int { 1 }       // 반환 타입에 T 없음
func wrap<T: Shape>(_ s: T) -> [T] { [s] }      // 반환 타입 안쪽에 T 있음

let boxed: any Shape = Triangle()   // ← 박스
let concrete = Triangle()           // ← 구체 타입

identity(boxed)      // 정적 타입: any Shape    ← 지워짐
count(boxed)         // 정적 타입: Int          ← T 가 없으니 영향 없음
wrap(boxed)          // 정적 타입: [any Shape]  ← 안쪽까지 지워짐
identity(concrete)   // 정적 타입: Triangle     ← 애초에 열지 않았으므로 유지

print(type(of: identity(boxed)))   // "Triangle" ← 정적 타입과 별개로 동적 타입은 멀쩡
```

규칙은 하나다. **박스를 넣으면 박스가 나온다.** 반환 타입에 `T`가 등장하지 않으면(`-> Int`) 아무 일도 일어나지 않는다.

> `some`이 정체성을 유지하는 것과 대비된다. `some Shape` 반환은 **구현부가 타입을 하나로 고정**했으므로 이름이 없어도 컴파일러가 "모든 호출이 같은 그 타입"임을 안다. 반면 열린 존재 타입은 **값마다 다를 수 있는** 타입이라 고정할 것이 없다.

즉 암시적 열기의 이득은 **호출 안쪽에서만** 발생한다. 결과를 밖으로 꺼내오려 하면 다시 박스가 되므로, **작업 자체를 제네릭 함수 안으로 밀어 넣어야** 한다. 값을 열어서 밖으로 들고 나오는 방향은 성립하지 않는다.

### 열리지 않는 경우

박스 두 개를 **같은** 타입 파라미터에 넘기는 것은 불가능하다. 각각의 박스는 서로 다른 타입일 수 있으므로 열어도 같은 `T`로 묶을 수 없기 때문이다.

``` swift
protocol Combinable { func combine(_ other: Self) -> Self }
struct A: Combinable { func combine(_ other: A) -> A { self } }

func combineTwo<T: Combinable>(_ a: T, _ b: T) -> T { a.combine(b) }

let anyC: any Combinable = A()
combineTwo(anyC, anyC)
// Error: type 'any Combinable' cannot conform to 'Combinable'
// note: only concrete types such as structs, enums and classes can conform to protocols
```



## 성능

`any`의 비용은 세 가지다. **동적 디스패치**(witness table 경유 → 인라이닝/특수화 불가), **박싱**(24 byte 초과 시 힙 할당 + ARC), **간접 접근**.

500만 원소 배열을 순회하며 프로토콜 메서드를 호출한 결과 (Swift 6.3.2, `-O`, Apple Silicon).

``` swift
protocol Value { func get() -> Int }
struct Small: Value { var a: Int }                  //  8 byte — 인라인 저장
struct Big: Value { var a, b, c, d, e: Int }        // 40 byte — 힙 박싱

func sumGeneric<T: Value>(_ xs: [T]) -> Int { xs.reduce(0) { $0 &+ $1.get() } }
func sumExistential(_ xs: [any Value]) -> Int { xs.reduce(0) { $0 &+ $1.get() } }
```

| 케이스 | 시간 | 배수 |
| --- | --- | --- |
| `sumGeneric([Small])` | 0.75 ms | 1× |
| `sumExistential([any Value])` (Small) | 22.7 ms | **약 30×** |
| `sumGeneric([Big])` | 3.9 ms | 1× |
| `sumExistential([any Value])` (Big) | 40.3 ms | **약 10×** |

- 제네릭 쪽은 컴파일러가 `Small`로 **특수화(specialization)** 해서 `get()`을 인라인해 버린다. 그래서 격차가 크게 벌어진다.
- 절대 시간으로는 500만 회에 20~40 ms 수준이라, 호출 횟수가 적은 곳에서는 `any`를 쓴다고 체감 문제가 생기지 않는다.
- 다만 **타이트 루프·대량 데이터 처리에서는 유의미**하므로, 이런 자리에서는 `any`를 제네릭 함수로 넘겨 열어서 쓰는 편이 좋다.

> 위 수치는 단일 모듈 + 전체 최적화 조건이라 제네릭 쪽에 가장 유리한 케이스다. 모듈 경계를 넘거나 `@inlinable`이 아니면 제네릭도 특수화되지 않아 격차가 줄어든다. **숫자 자체보다 "정적 vs 동적"이라는 방향성**을 기억할 것.



## SwiftUI 실전

### `body: some View`인 이유

`View` 프로토콜은 `associatedtype Body: View`를 갖는다. SwiftUI는 뷰 계층을 **타입으로 인코딩**해서 (`VStack<TupleView<(Text, Image)>>` 같은 식) 구조가 변하지 않았음을 타입만 보고 판단하고, 이를 통해 diffing과 identity 관리를 한다.

``` swift
struct Stack: View {
    var body: some View {
        VStack { Text("hi"); Image(systemName: "star") }
    }
}
print(type(of: Stack().body))
// VStack<TupleView<(Text, Image)>>
```

이 긴 타입을 개발자가 직접 적을 수는 없으니 `some View`로 감춘다. **타입 정보는 컴파일러에 그대로 남아있고**(정적 디스패치·특수화 가능) 작성자만 편해지는, 불투명 타입의 교과서적 활용이다.

### `if/else`가 하나의 타입이 되는 방법

`some View`는 단일 타입을 요구하는데 어떻게 조건 분기가 되나? ViewBuilder가 `_ConditionalContent`로 감싸주기 때문이다.

``` swift
struct Cond: View {
    var flag = true
    var body: some View {
        if flag { Text("a") } else { Image(systemName: "b") }
    }
}
print(type(of: Cond().body))
// _ConditionalContent<Text, Image>
```

분기 결과가 **타입 자체에 인코딩**되어 있다는 점이 중요하다. SwiftUI는 `_ConditionalContent`의 어느 쪽이 활성인지 바뀌면 뷰 identity가 바뀐 것으로 처리한다.

### `any View`는 쓸 수 없다

``` swift
struct Bad: View {
    var body: any View { Text("x") }
}
// Error: type 'Bad' does not conform to protocol 'View'
// note: cannot infer 'Body' = 'any View' because 'any View' as a type cannot conform
//       to protocols; did you mean to use an opaque result type?
```

`Body`는 `View`를 준수해야 하는데 앞에서 본 것처럼 `any View`는 `View`를 준수하지 않는다.

### 그래서 `AnyView`

`AnyView`는 SwiftUI가 제공하는 **타입 소거 래퍼**다. `struct AnyView: View`이므로 `Body` 요구사항을 만족한다.

``` swift
print(type(of: AnyView(Text("a"))))   // AnyView

var views: [AnyView] = [AnyView(Text("a")), AnyView(Image(systemName: "star"))]
```

다만 **타입 정보를 지우는 것이 곧 SwiftUI의 diffing 근거를 지우는 것**이므로 대가가 크다.

- 뷰 타입이 `AnyView`로 통일되어 구조 비교가 불가능 → 갱신 시 서브트리를 통째로 다시 만들 가능성
- 애니메이션·transition·상태(`@State`)가 예기치 않게 초기화될 수 있음

**대안**

| 상황 | 권장 |
| --- | --- |
| 단순 조건 분기 | `if/else` (ViewBuilder가 `_ConditionalContent` 처리) |
| 분기가 3개 이상 | `switch` + ViewBuilder, 또는 `@ViewBuilder` 프로퍼티/함수로 분리 |
| 뷰를 반환하는 헬퍼 | `@ViewBuilder func makeView() -> some View` |
| 이종 뷰 배열 | 가급적 데이터 배열 + `ForEach`로 재구성 |
| 진짜 타입을 못 정할 때 | 그때만 `AnyView` |

``` swift
enum LoadState { case loading, empty, list([String]) }

@ViewBuilder
func content(for state: LoadState) -> some View {   // AnyView 없이 분기
    switch state {
    case .loading: ProgressView()
    case .empty:   Text("없음")
    case .list(let items): List(items, id: \.self) { Text($0) }
    }
}
```

> 참고: `Body`가 `some View`인 것과 달리, SwiftUI에서 뷰를 **저장**해야 하는 자리(예: 라우팅 테이블, 화면 팩토리 결과 캐시)에서는 여전히 `AnyView`나 `any View`가 필요할 수 있다. 그럴 땐 저장은 지운 타입으로 하되, **렌더링 트리에 들어가는 지점은 최대한 좁게** 유지하는 것이 원칙이다.



## 참조

**Swift Evolution**

- [SE-0244 Opaque Result Types](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0244-opaque-result-types.md) — `some` 반환 타입
- [SE-0309 Unlock existentials for all protocols](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0309-unlock-existential-types-for-all-protocols.md) — `associatedtype`/`Self` 프로토콜의 실존 타입 허용
- [SE-0335 Introduce existential `any`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md)
- [SE-0341 Opaque Parameter Declarations](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0341-opaque-parameters.md) — 파라미터 위치의 `some`
- [SE-0346 Lightweight same-type requirements for primary associated types](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0346-light-weight-same-type-syntax.md) — `any Collection<Int>`
- [SE-0352 Implicitly Opened Existentials](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md)

**WWDC**

- [WWDC22 — Embrace Swift generics](https://developer.apple.com/videos/play/wwdc2022/110352/)
- [WWDC22 — Design protocol interfaces in Swift](https://developer.apple.com/videos/play/wwdc2022/110353/)
- [WWDC21 — Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/) — identity와 뷰 타입

**문서 / 블로그**

- [Swift 공식 문서 — Opaque and Boxed Protocol Types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/opaquetypes/)
- https://bbiguduk.gitbook.io/swift/language-guide-1/opaque-types
- https://jcsoohwancho.github.io/2019-08-24-Opaque-Type-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0/
- https://protocorn93.github.io/2019/12/12/Opaque-Types-in-Swift/
