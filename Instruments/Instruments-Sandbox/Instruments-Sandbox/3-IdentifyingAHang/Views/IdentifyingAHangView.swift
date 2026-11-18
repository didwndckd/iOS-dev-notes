import SwiftUI
/// 목록 뷰와 컬렉션 뷰를 전환하는 탭 바를 정의하는 앱의 메인 화면입니다.
struct IdentifyingAHangView: View {
    @State private var images: Result<ImageCollection, Error>? = nil
    @State private var selectedTab: Tab = .list
    
    var body: some View {
        switch images {
        case .success(let images):
            TabView(selection: $selectedTab) {
                ImagesListView(images: images)
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                    .tag(Tab.list)
                ImageCollectionsView(images: images)
                    .tabItem {
                        Label("Collection", systemImage: "square.grid.3x2")
                    }
                    .tag(Tab.collectionView)
            }
        case .failure(let error):
            VStack {
                Text("Failed to load images.").font(.title)
                Text(String(describing: error)).font(.footnote)
            }
        case nil:
            ProgressView("Loading images...")
                .task {
                    do {
                        images = await .success(try ImageCollection.loadFromStorage())
                    } catch {
                        images = .failure(error)
                    }
                }
        }
    }
    
    enum Tab {
        case list
        case collectionView
    }
}

#Preview {
    IdentifyingAHangView()
}

