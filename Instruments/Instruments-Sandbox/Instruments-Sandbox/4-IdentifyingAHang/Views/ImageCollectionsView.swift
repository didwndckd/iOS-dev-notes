import SwiftUI
/// 이미지 카테고리마다 하나의 행을 표시하고, 각 행에서 해당 카테고리의 모든 이미지를 가로로 스크롤할 수 있는 컬렉션 뷰입니다.
struct ImageCollectionsView: View {
    var images: ImageCollection
    
    var body: some View {
        let groupNames = images.groupedImages.keys.sorted()
        NavigationStack {
            List(groupNames, id: \.self) { groupName in
                Section(groupName) {
                    let images = images.groupedImages[groupName]!
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(images) { imageFile in
                                ThumbnailView(imageFile: imageFile)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("Collection")
        }
    }
}

#Preview {
    return ImageCollectionsView(images: makeSampleData())
    
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
