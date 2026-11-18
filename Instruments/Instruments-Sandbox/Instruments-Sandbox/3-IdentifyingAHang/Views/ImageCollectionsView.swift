/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A collection view that displays one row per image category and all images in that category in a horizontally scrolling list.
*/

import SwiftUI

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
