import SwiftUI
/// 카테고리별로 묶인 이미지 이름을 표시하는 앱의 목록 뷰입니다.
struct ImagesListView: View {
    var images: ImageCollection
    
    var body: some View {
        NavigationSplitView {
            let groupNames = images.groupedImages.keys.sorted()
            List {
                ForEach(groupNames, id: \.self) { groupName in
                    Section(groupName) {
                        let images = images.groupedImages[groupName]!
                        ForEach(images) { imageFile in
                            NavigationLink {
                                makeImageView(imageFile: imageFile)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .navigationTitle(imageFile.name)
                            } label: {
                                Text(imageFile.name)
                            }
                        }
                    }
                }
            }
        } detail: {
            Text("Select an image on the right")
        }
    }
    
    private func makeImageView(imageFile: ImageFile) -> Image {
        guard let image = imageFile.image else { return Image(systemName: "x.square") }
        return Image(uiImage: image)
    }
}

#Preview {
    return ImagesListView(images: makeSampleData())
    
    func makeSampleData() -> ImageCollection {
        ImageCollection(groupedImages: [
            "Cats": [
                makeImageFile(name: "Funky"),
                makeImageFile(name: "Lucky")
            ],
            "Dogs": [
                makeImageFile(name: "Sniffo"),
                makeImageFile(name: "Rex"),
                makeImageFile(name: "Bones")].flatMap { image in
                    Array(repeating: image, count: 10)
            },
            "Lizards": [makeImageFile(name: "Dabbling Director")]
        ])
    }
    
    func makeImageFile(name: String) -> ImageFile {
        ImageFile(fileURL: Bundle.main.bundleURL.appendingPathComponent("Images").appendingPathComponent(name))
    }
}
