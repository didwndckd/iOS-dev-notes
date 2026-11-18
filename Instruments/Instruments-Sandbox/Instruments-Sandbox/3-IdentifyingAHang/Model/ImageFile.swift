
import Foundation
import UIKit
/// 이미지 파일 URL을 감싸서 원본 이미지나 썸네일에 쉽게 접근할 수 있도록 하는 타입입니다.
struct ImageFile: Identifiable {
    let fileURL: URL
    /// 썸네일의 최대 높이입니다. 단위는 포인트입니다.
    static let maxThumbnailHeight: CGFloat = 50
    
    var id: URL {
        fileURL
    }
    
    var name: String {
        fileURL.deletingPathExtension().lastPathComponent
    }
    
    var image: UIImage? {
        UIImage(contentsOfFile: fileURL.path)
    }
    
    func makeThumbnail(displayScale: CGFloat) -> UIImage? {
        guard let image else { return nil }
        let thumbnailSize = thumbnailSize(for: image.size, displayScale: displayScale)
        return image.preparingThumbnail(of: thumbnailSize)
    }
    
    private func thumbnailSize(for originalSize: CGSize, displayScale: CGFloat) -> CGSize {
        let shrinkFactor = Self.maxThumbnailHeight / originalSize.height
        return CGSize(width: originalSize.width * shrinkFactor * displayScale, height: Self.maxThumbnailHeight * displayScale)
    }
}
