//
//  File.swift
//  DIMultiModuleSample
//
//  Created by yjc on 8/17/26.
//

import SwiftUI

public struct UserView: View {
    @ObservedObject private var viewModel: UserViewModel
    
    public init(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if let user = viewModel.user {
                Text(String(user.id))
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
