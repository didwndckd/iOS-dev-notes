# Needle Sample

SPM의 Domain / Data / Presentation 모듈을 별도 DI 모듈에서 조립하는 Needle 샘플입니다.

## 모듈 의존성

```text
App → DI → Domain
         → Data → Domain
         → Presentation → Domain
         → NeedleFoundation
```

Domain, Data, Presentation은 Needle에 의존하지 않습니다. 기존 생성자 주입을 유지하고 DI 모듈이 객체 생성과 연결을 담당합니다.

## DI 구성

```text
AppComposition (App에 공개하는 @MainActor 진입점)
└── RootComponent
    ├── DataComponent → UserRepositoryImpl
    └── UserComponent → UserUseCaseImpl → UserViewModel
```

- `DataComponent`: `Component<EmptyDependency>`로 Repository를 생성합니다. `Dependency`는 상위에서 요구하는 인터페이스이고, 객체 생성 스코프는 `Component`입니다.
- `RootComponent`: DataComponent에서 만든 Repository를 `shared`로 보관하고 UserComponent에 제공합니다. 형제 Component끼리 직접 의존성을 찾지 않습니다.
- `UserDependency`: 상위에서 필요한 `userRepository`를 선언합니다.
- `UserComponent`: Repository를 주입해 UseCase를 만들고 MainActor에서 ViewModel을 생성합니다.
- `AppComposition`: Provider를 한 번 등록한 뒤 RootComponent를 생성합니다. Component 타입은 DI 내부에 숨깁니다.
- `UserScreen`: `@StateObject`로 화면의 ViewModel을 소유합니다. 기존 UserView는 `@ObservedObject`로 전달받습니다.

Needle 0.25.1 생성기는 상위에서 제공할 프로퍼티에 `public` 선언이 필요합니다. Component 타입은 internal이므로 App에 노출되지 않습니다.

Component는 부모를 강하게 보관하므로 Root에서 자식 Component를 `shared`로 캐시하지 않습니다. 대신 Repository를 Root 스코프에서 공유합니다.

## 코드 생성

NeedleFoundation은 SPM으로 연결되어 있습니다. 별도로 생성기를 설치합니다.

```sh
brew install needle
```

Component / Dependency 선언을 변경하면 프로젝트 루트에서 **빌드 전에** 실행합니다.

```sh
sh Scripts/generate-needle.sh
```

출력은 `Modules/Sources/DI/Generated/NeedleGenerated.swift`이며 DI 타깃에 자동 포함됩니다. 생성 파일은 소스와 함께 버전 관리하고 직접 수정하지 않습니다. 현재 자동 빌드 플러그인은 없으며, 재생성은 위 명령으로 수행합니다. App의 Run Script는 SPM DI 타깃의 컴파일보다 늦게 실행될 수 있어 사용하지 않습니다.

앱 실행 시 `AppComposition`이 생성된 `registerProviderFactories()`를 Component 생성 전에 호출합니다. 화면은 샘플 Repository가 반환하는 사용자 ID `1`을 표시합니다.
