//
//  GettingStartedWithInstrumentsView.swift
//  Instruments-Sandbox
//
//  Created by yjc on 10/18/26.
//

import SwiftUI
import os

@MainActor
@Observable
final class GettingStartedWithInstrumentsViewModel {
    private nonisolated let performanceLog = OSLog(
        subsystem: "Instruments-Sandbox",
        category: .pointsOfInterest
    )

    private(set) var count = 0
    private(set) var bigTaskRepeatCount = 0
    private(set) var computationResult: UInt64 = 0

    func increment() {
        count += 1
    }
    func decrement() {
        count -= 1
    }

    func runBigTaskRepeatedly() {
        guard count > 0 else { return }
        for _ in 0..<count {
            bigTask()
        }
    }

    func bigTask() {
        let signpostID = OSSignpostID(log: performanceLog)
        os_signpost(.begin, log: performanceLog, name: "Big Task", signpostID: signpostID)
        defer {
            os_signpost(.end, log: performanceLog, name: "Big Task", signpostID: signpostID)
        }

        // Hang 분석 실습용: 메인 스레드에서 약 2초 동안 CPU 연산을 수행한다.
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(2))
        var value = computationResult &+ 1
        bigTaskRepeatCount = 0

        repeat {
            bigTaskRepeatCount += 1
            for _ in 0..<10_000 {
                value ^= value << 13
                value ^= value >> 7
                value ^= value << 17
                value = value &* 2_862_933_555_777_941_757 &+ 3_037_000_493
            }
        } while clock.now < deadline

        computationResult = value
    }

    @concurrent
    func optimizedBigTask() async {
        let signpostID = OSSignpostID(log: performanceLog)
        os_signpost(.begin, log: performanceLog, name: "Optimized Big Task", signpostID: signpostID)
        defer {
            os_signpost(.end, log: performanceLog, name: "Optimized Big Task", signpostID: signpostID)
        }

        // 응답성 개선 버전: @concurrent로 CPU 연산을 MainActor 밖에서 수행한다.
        // 화면에 표시할 상태를 읽거나 갱신할 때는 await로 MainActor에 접근한다.
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(2))
        var value = await computationResult &+ 1
        await updateBigTaskRepeatCount(0)

        repeat {
            let old = await bigTaskRepeatCount
            await updateBigTaskRepeatCount(old + 1)
            for _ in 0..<10_000 {
                value ^= value << 13
                value ^= value >> 7
                value ^= value << 17
                value = value &* 2_862_933_555_777_941_757 &+ 3_037_000_493
            }
        } while clock.now < deadline

        await setComputationResult(value)
    }

    private func updateBigTaskRepeatCount(_ value: Int) {
        bigTaskRepeatCount = value
    }

    private func setComputationResult(_ value: UInt64) {
        computationResult = value
    }
}

struct GettingStartedWithInstrumentsView: View {
    private let viewModel = GettingStartedWithInstrumentsViewModel()

    var body: some View {
        VStack {
            Text("count: \(viewModel.count)")
                .font(.title)
            Text("big task repeat count: \(viewModel.bigTaskRepeatCount)")
            Text("result: \(viewModel.computationResult)")
                .font(.caption.monospacedDigit())
            Group {
                Button("increment") { viewModel.increment() }
                Button("decrement") { viewModel.decrement() }
                Button("big task") { viewModel.bigTask() }
                Button("optimized big task") {
                    Task { await viewModel.optimizedBigTask() }
                }
                Button("call big task \(viewModel.count) times") {
                    viewModel.runBigTaskRepeatedly()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    GettingStartedWithInstrumentsView()
}
