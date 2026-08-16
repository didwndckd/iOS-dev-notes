# `@frozen`

> 라이브러리 진화(Library Evolution) 환경에서 `struct`와 `enum`의 형태를 고정하는 Swift 속성

## 핵심 요약

`@frozen`은 라이브러리 작성자가 공개 타입의 구성을 앞으로 변경하지 않겠다고 약속하는 속성이다.

- `@frozen enum`: case를 추가, 제거, 재정렬할 수 없다.
- `@frozen struct`: 저장 프로퍼티를 추가, 제거, 재정렬할 수 없다.
- 대신 클라이언트 코드는 타입 구성을 더 많이 알 수 있어 컴파일러 최적화가 가능하다.

이 속성은 일반 앱 코드보다, **재컴파일 없이 교체될 수 있는 바이너리 프레임워크**를 설계할 때 중요하다.

## 배경: ABI와 Library Evolution

ABI(Application Binary Interface)는 컴파일된 라이브러리와 이를 사용하는 앱이 이진 수준에서 함께 동작하기 위한 약속이다.

라이브러리 진화 모드에서는 공개 타입의 형태가 나중에 바뀌어도, 이미 배포된 클라이언트가 다시 컴파일되지 않고 동작할 수 있어야 한다. 그래서 기본적으로 공개 `struct`와 `enum`은 미래 변경을 허용하는 **nonfrozen(resilient)** 타입으로 취급된다.

```text
nonfrozen 타입
  → 라이브러리 작성자: 미래 변경에 유연함
  → 클라이언트: 런타임 조회·간접 접근 등을 고려해야 함

@frozen 타입
  → 라이브러리 작성자: 타입 구성 변경 불가
  → 클라이언트: 알려진 구성을 활용한 최적화 가능
```

명령줄에서는 `-enable-library-evolution`으로 Library Evolution 모드를 켤 수 있다. Xcode에서는 **Build Libraries for Distribution** (`BUILD_LIBRARY_FOR_DISTRIBUTION`)을 `Yes`로 설정한다.

## `enum`과 exhaustive `switch`

```swift
@frozen
public enum Direction {
    case north
    case south
    case east
    case west
}
```

위 enum은 새 case를 추가하지 않겠다고 약속한다. 따라서 사용하는 쪽은 `default` 없이 모든 case를 처리할 수 있다.

```swift
func localizedName(for direction: Direction) -> String {
    switch direction {
    case .north: return "북"
    case .south: return "남"
    case .east: return "동"
    case .west: return "서"
    }
}
```

반대로 nonfrozen enum은 라이브러리의 다음 버전에서 case가 추가될 수 있다. 클라이언트는 미래 case를 처리해야 하므로 `@unknown default`를 사용한다.

```swift
switch status {
case .ready:
    start()
case .failed:
    showError()
@unknown default:
    handleUnsupportedStatus()
}
```

`@unknown default`는 현재 알려진 case를 빠뜨렸을 때 경고를 내고, 미래에 추가된 case를 위한 안전망도 제공한다.

## `struct`에서의 의미

```swift
@frozen
public struct Point {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
```

이후 버전에서 `Point`에 저장 프로퍼티를 추가하거나, 기존 저장 프로퍼티의 순서를 바꾸면 ABI 호환성이 깨진다.

```swift
// ABI 호환성을 깨므로 기존 @frozen 공개 타입에는 추가할 수 없음
// public var z: Double
```

다만 `@frozen`이 C 구조체와 같은 메모리 배치를 보장하는 것은 아니다. 특히 다음을 보장하지 않는다.

- 선언 순서대로 메모리에 배치됨
- 항상 컴파일 타임에 크기와 정렬을 알 수 있음
- 복사 비용이 없는 trivial 타입임

핵심은 **타입의 저장 프로퍼티 구성을 바꾸지 않겠다**는 ABI 계약이다.

## Trivial 타입이란?

trivial 타입은 값을 복사하거나 수명이 끝났을 때 **특별한 관리 작업이 필요 없는 타입**을 뜻한다. 개념적으로는 메모리의 값만 복사하거나 버리면 된다.

```swift
struct Point {
    var x: Double
    var y: Double
}
```

위 `Point`는 `Double` 값만 저장하므로 복사할 때 단순 값 복사로 처리할 수 있는 형태다.

반면 참조 카운트 관리나 별도 정리 작업이 필요한 값을 저장하면 trivial하다고 볼 수 없다.

```swift
struct User {
    var name: String
}

struct CallbackHolder {
    var action: () -> Void
}
```

`String`은 내부 저장소를 공유할 수 있고, 클로저와 클래스 참조는 ARC 관리 대상이 될 수 있다. 따라서 이 타입들을 복사하거나 해제할 때 단순한 바이트 복사·폐기만으로 충분하다고 보장할 수 없다.

`@frozen`과 trivial은 별개다. `@frozen`은 저장 프로퍼티 또는 enum case의 **구성이 고정됨**을 의미할 뿐, 복사 비용이 없음을 보장하지 않는다.

```swift
@frozen
public struct UserID {
    public let value: String
}
```

`UserID`는 `@frozen`이지만 `String`을 저장하므로 trivial 타입이라고 단정할 수 없다.

## 제약 사항

- `@frozen`은 Library Evolution 모드에서만 사용할 수 있다.
- frozen 타입과 frozen struct의 저장 프로퍼티 타입, frozen enum의 연관 값 타입은 `public` 또는 `@usableFromInline`이어야 한다.
- frozen struct의 저장 프로퍼티에는 `willSet`, `didSet` observer를 둘 수 없다.
- frozen enum의 case 변경, frozen struct의 저장 프로퍼티 구성 변경, `@frozen` 제거는 ABI 호환성을 깬다.
- 메서드 추가나 프로토콜 채택 추가는 타입의 필드·case 추가와는 별개로 가능하다.

## 언제 사용해야 하나

사용을 검토할 만한 경우:

- 외부에 배포하는 binary framework / XCFramework의 공개 API
- case 집합이 도메인상 명확하게 완결된 enum
- 향후 확장성보다 고정된 레이아웃과 성능이 더 중요한 value type

피하는 편이 좋은 경우:

- 앱 내부 모듈 또는 앱과 함께 다시 빌드되는 Swift Package
- 새 상태나 기능을 추가할 가능성이 있는 enum
- 저장 프로퍼티를 추가할 가능성이 있는 공개 struct

실무에서는 기본적으로 nonfrozen을 선택하고, **앞으로 구성 변경이 없다는 강한 확신**과 성능상 이유가 있을 때만 `@frozen`을 적용한다.

## 스터디 질문

1. `@frozen`은 성능 옵션인가, 공개 API 계약인가?
2. SDK의 nonfrozen enum을 처리할 때 `@unknown default`에서는 어떤 복구 정책을 써야 할까?
3. 현재 만드는 모듈은 독립적으로 바이너리 배포되는가? 아니라면 `@frozen`이 필요한가?
4. 새로운 case 또는 저장 프로퍼티가 절대 필요 없다는 판단을 어떻게 검증할 수 있을까?

## 참고 자료

- [The Swift Programming Language — Attributes: frozen](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html)
- [The Swift Programming Language — Switching Over Future Enumeration Cases](https://docs.swift.org/swift-book/ReferenceManual/Statements.html)
- [SE-0260: Library Evolution for Stable ABI](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0260-library-evolution.md)
- [WWDC19: Binary Frameworks in Swift](https://developer.apple.com/kr/videos/play/wwdc2019/416/)
