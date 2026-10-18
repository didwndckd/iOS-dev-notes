//
//  GettingStartedWithInstrumentsViewModelTests.swift
//  Instruments-SandboxTests
//
//  Created by yjc on 10/18/26.
//

import Testing
@testable import Instruments_Sandbox

// CPU 작업이 서로 겹치지 않도록 순차 실행한다.
@Suite(.serialized)
@MainActor
struct GettingStartedWithInstrumentsViewModelTests {
    @Test func bigTask() {
        let viewModel = GettingStartedWithInstrumentsViewModel()

        viewModel.bigTask()

        #expect(viewModel.bigTaskRepeatCount > 0)
    }

    @Test func optimizedBigTask() async {
        let viewModel = GettingStartedWithInstrumentsViewModel()

        await viewModel.optimizedBigTask()

        #expect(viewModel.bigTaskRepeatCount > 0)
    }

    @Test func runBigTaskRepeatedly() {
        let viewModel = GettingStartedWithInstrumentsViewModel()
        viewModel.increment()
        viewModel.increment()
        viewModel.increment()

        viewModel.runBigTaskRepeatedly()

        #expect(viewModel.count == 3)
        #expect(viewModel.bigTaskRepeatCount > 0)
    }
}
