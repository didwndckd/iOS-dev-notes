# Instruments 학습 로드맵

[Apple — Profiling apps using Instruments](https://developer.apple.com/tutorials/instruments)의 챕터와 각 문서의 다음 단계 링크를 따라 학습한다. Apple의 ImageViewer 샘플에서 Hang을 발견하고, 메인 스레드의 작업을 분석하며, 코드를 수정한 결과를 다시 측정하는 흐름이다.

## 로드맵

### Chapter 1. Hang basics

| 완료 | 순서 | 주제 | 정리할 내용 | 레퍼런스 |
| --- | --- | --- | --- | --- |
| [ ] | 1 | Hang 분석 시작하기 | 사용자 입력과 화면 갱신, Hang의 개념, 샘플에서 사용하는 SwiftUI·Swift Concurrency 배경 | • [Getting started with hang analysis](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis) |
| [ ] | 2 | Hang 식별하기 | 샘플의 멈춤 재현, Profile과 Time Profiler 녹화, Hangs 구간 확인, busy·blocked 메인 스레드 구분 | • [Identifying a hang](https://developer.apple.com/tutorials/instruments/identifying-a-hang) |

### Chapter 2. Busy main thread hangs

| 완료 | 순서 | 주제 | 정리할 내용 | 레퍼런스 |
| --- | --- | --- | --- | --- |
| [ ] | 3 | 메인 스레드 활동 분석 | Profile 뷰와 호출 경로를 읽고 CPU 시간을 많이 사용하는 작업 찾기 | • [Analyzing main thread activity](https://developer.apple.com/tutorials/instruments/analyzing-main-thread-activity) |
| [ ] | 4 | 실행 빈도 이해 | 한 번의 실행 비용과 반복 실행 비용의 차이, Time Profiler 샘플만으로 실행 횟수를 알 수 없는 이유 | • [Determining execution frequency](https://developer.apple.com/tutorials/instruments/determining-execution-frequency) |
| [ ] | 5 | 메인 스레드 작업량 줄이기 | View Body 실행 횟수 측정, LazyHStack 적용, 줄어든 Hang과 스크롤 중 발생하는 Hitch 확인 | • [Reducing main thread work by doing less](https://developer.apple.com/tutorials/instruments/reducing-main-thread-work-by-doing-less) |
| [ ] | 6 | 작업을 비동기로 실행하기 | 썸네일 계산을 비동기로 변경한 결과, 화면 전환 이후에도 남는 메인 스레드 작업과 Hang | • [Executing work asynchronously](https://developer.apple.com/tutorials/instruments/executing-work-asynchronously) |
| [ ] | 7 | 동기·비동기 Hang 이해 | 사용자 입력과 직접 연결된 멈춤과 뒤늦게 발생하는 멈춤, Hangs가 표시하는 잠재적 응답 지연 | • [Understanding synchronous and asynchronous hangs](https://developer.apple.com/tutorials/instruments/understanding-synchronous-and-asynchronous-hangs) |
| [ ] | 8 | 백그라운드 실행 확인 | Swift Tasks로 실제 실행 위치 추적, MainActor와 메인 스레드의 관계, 무거운 작업을 옮긴 뒤 재측정 | • [Ensuring work executes on a background thread](https://developer.apple.com/tutorials/instruments/ensuring-work-executes-in-a-background-thread) |

8번은 7번 문서의 **Next** 링크로 이어지는 튜토리얼이다. 비동기로 예약하는 것과 메인 스레드 밖에서 실행하는 것의 차이를 확인하는 단계까지 포함한다.

## 튜토리얼 환경

- 샘플은 Apple 튜토리얼에서 제공하는 ImageViewer 프로젝트를 기준으로 한다. 프로젝트 파일은 [Identifying a hang](https://developer.apple.com/tutorials/instruments/identifying-a-hang)에서 받을 수 있다.
- 튜토리얼 예제는 Xcode 16·iOS 18을 기준으로 설명한다. 설치된 Xcode에서는 UI 배치와 SwiftUI 관련 도구 이름이 다를 수 있다.
- 성능 측정은 실기기를 기준으로 한다. 첫 Hang 예제는 실기기가 없을 때 시뮬레이터로도 따라갈 수 있다고 안내한다.
- 이후 내용 정리 문서는 위 순서대로 작성하며, 해당 Apple 문서의 개념·분석 과정·결과를 정리한다.

환경과 샘플 안내 출처: [Identifying a hang](https://developer.apple.com/tutorials/instruments/identifying-a-hang), [Reducing main thread work by doing less](https://developer.apple.com/tutorials/instruments/reducing-main-thread-work-by-doing-less).

## 참고 자료

- [Instruments 도구와 템플릿 가이드](1-InstrumentsTools.md): 도구 이름과 구성이 궁금할 때 참고하는 기존 문서.
- [Getting Started with Instruments — WWDC19](https://developer.apple.com/videos/play/wwdc2019/411/): Instruments 기본 조작 보충.
- [Analyze hangs with Instruments — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10248/): Hang 분석과 메인 스레드의 busy·blocked 상태 이해.
- [Visualize and optimize Swift concurrency — WWDC22](https://developer.apple.com/videos/play/wwdc2022/110350/): Swift Tasks·Swift Actors 분석 보충.

메모리·네트워크·GPU 등 다른 주제는 현재 Hang 튜토리얼의 연속 단계에 포함하지 않는다. 후속 학습 자료는 [공식 튜토리얼의 Resources](https://developer.apple.com/tutorials/instruments)에서 확인한다.
