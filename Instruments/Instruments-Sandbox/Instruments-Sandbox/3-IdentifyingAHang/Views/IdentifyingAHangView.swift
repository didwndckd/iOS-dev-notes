/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main interface of the app, which declares a tab bar with a list view and a collection view.
*/

import SwiftUI

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

