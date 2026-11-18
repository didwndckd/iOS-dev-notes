/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A small view, responsible for showing the thumbnail of a single image.
*/

import SwiftUI

struct ThumbnailView: View {
    @Environment(\.displayScale) private var displayScale: CGFloat
    let imageFile: ImageFile
    
    var body: some View {
        imageView
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: ImageFile.maxThumbnailHeight)
    }
    
    @MainActor
    var imageView: Image {
        guard let thumbnail = imageFile.makeThumbnail(displayScale: displayScale) else {
            return Image(systemName: "x.square")
        }
        return Image(uiImage: thumbnail)
    }
}
