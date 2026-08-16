//
//  DI_MultiMoule_SampleApp.swift
//  DI-MultiMoule-Sample
//
//  Created by yjc on 8/17/26.
//

import SwiftUI
import DIContainer
import Presentation

@main
struct DI_MultiMoule_SampleApp: App {
    private let viewModel = DIContainer.userViewModel
    
    var body: some Scene {
        WindowGroup {
            UserView(viewModel: viewModel)
        }
    }
}
