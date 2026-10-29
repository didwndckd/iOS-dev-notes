import SwiftUI

struct AView: View {
    @ObservedObject var viewModel: AViewModel

    var body: some View {
        VStack(spacing: 24) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else {
                Text("사진을 촬영해 주세요")
                    .foregroundStyle(.secondary)
            }

            Toggle("촬영 후 편집", isOn: $viewModel.allowsEditing)

            Button("사진 촬영", systemImage: "camera") {
                viewModel.didTapCamera()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    AView(viewModel: AViewModel())
}
