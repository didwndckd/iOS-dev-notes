import SwiftUI

public struct UserView: View {
    private let viewModel: UserViewModel

    public init(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if let user = viewModel.user {
                Text(String(user.id))
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
