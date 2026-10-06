import SwiftUI
import Presentation

/// App이 사용하는 DI 진입점. Component는 모듈 내부에 숨긴다.
@MainActor
public final class AppComposition {
    private let root: RootComponent

    public init() {
        registerProviderFactories()
        root = RootComponent()
    }

    public func makeUserView() -> some View {
        UserView(viewModel: root.presentationComponent.userViewModel)
    }
}
