/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A wrapper around a single image file URL that provides easy access to the full image or a thumbnail of it.
*/

import Foundation
import UIKit

struct ImageFile: Identifiable {
    let fileURL: URL
    /// Maximum thumbnail height in points.
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
