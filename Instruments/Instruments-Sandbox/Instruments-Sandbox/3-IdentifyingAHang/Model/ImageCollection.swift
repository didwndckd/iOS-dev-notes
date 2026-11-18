/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The data model for the image collection to display, which is also responsible for loading the images from disk.
*/

import Foundation

struct ImageCollection {
    /// Groups the images by types. The key is the name of the group, the value is a collection of images in this group.
    var groupedImages: [String: [ImageFile]] = [:]
    
    static func loadFromStorage() async throws -> ImageCollection {
        let imagesDirectoryURL = Bundle.main.url(forResource: "Images", withExtension: "")!
        let imageGroupDirectoryURLs = try FileManager.default.contentsOfDirectory(at: imagesDirectoryURL,
                                                                                  includingPropertiesForKeys: [.isDirectoryKey])
        let supportedImageExtensions = ["png", "jpeg", "heic"]
        let images = try imageGroupDirectoryURLs.reduce(into: ImageCollection()) { partialResult, groupDirectory in
            let categoryContents = try FileManager.default.contentsOfDirectory(at: groupDirectory,
                                                                               includingPropertiesForKeys: [])
            partialResult.groupedImages[groupDirectory.lastPathComponent] = categoryContents.compactMap { fileURL in
                guard supportedImageExtensions.contains(fileURL.pathExtension) else {
                    return nil
                }
                return ImageFile(fileURL: fileURL)
            }
            .sorted(using: KeyPathComparator(\.name))
        }
        return images
    }
}
