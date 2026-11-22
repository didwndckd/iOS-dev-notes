import SwiftUI
/// 이미지 한 장의 썸네일을 표시하는 작은 뷰입니다.
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
