import Foundation

/// 화면에 표시할 이미지 컬렉션의 데이터 모델로, 디스크에서 이미지를 불러오는 역할도 담당합니다.
struct ImageCollection {
    /// 이미지를 종류별로 묶습니다. 키는 그룹 이름이고, 값은 해당 그룹에 속한 이미지 목록입니다.
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
