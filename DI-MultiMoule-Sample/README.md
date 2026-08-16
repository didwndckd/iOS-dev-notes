# DI MultiMoule Sample

Swift Package Manager 기반 멀티 모듈 DI 실험 프로젝트입니다.

## Modules

```text
DI          DI property wrapper, DIValues, DIContext
Domain      Entity, UseCase, Repository protocol
Data        Repository 구현체
Presentation View, ViewModel
DIContainer 실제 의존성 조립(Composition Root)
App         SwiftUI 앱 시작점
```

의존성 방향은 다음과 같습니다.

```text
Data ─────────→ Domain ─→ DI
Presentation ─→ Domain, DI
DIContainer ─→ DI, Domain, Data, Presentation
App ─────────→ DIContainer, Presentation
```

`DIContainer`는 실제 구현체를 `DIValues`에 등록하고, 필요한 객체를 생성하는 동안 `DIContext`로 값을 전달합니다. 각 `@DI` 프로퍼티는 생성 시점의 값을 보관하므로, 화면과 UseCase는 Container scope 밖에서도 주입된 의존성을 사용합니다.

테스트나 Preview에서는 `DIContext.$current.withValue(...)`로 원하는 의존성만 교체할 수 있습니다.
