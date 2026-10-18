# Hang 분석 시작하기

- 원문: Apple, [Getting started with hang analysis](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis#Before-you-get-started)
- 열람일: 2026-10-18. 개인 저자·발행일·갱신일은 표시되지 않는다.
- 범위: 링크의 사전 준비 절을 포함한 문서 전체. Apple의 공개 문서 JSON으로 본문을 확인했다.

## 핵심 원리

Hang은 사용자 입력에 대한 반응이 눈에 띄게 지연되는 현상이다. 메인 스레드가 입력을 처리하므로, 그 스레드가 **계산 중인지, 대기 중인지**에 따라 조사 방향이 달라진다. 재현 → 기록·분석 → 수정 → 재측정을 반복한다.

## 시작 전 알아둘 것

SwiftUI 코드와 스레드·동시성의 기초, `Task`·`Actor`·`MainActor`·동시 실행 스레드 풀에 익숙해야 한다. 예제는 SwiftUI와 Swift Concurrency를 사용하지만 같은 성능 문제는 UIKit·AppKit·DispatchQueue에서도 발생한다.

사전 학습 링크: [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) · [Instruments 입문](https://developer.apple.com/videos/play/wwdc2019/411/).

## 입력 처리와 시간 기준

버튼을 누른 뒤 색이 바뀌는 것처럼, 입력과 화면 반응 사이의 지연이 사용자에게 드러나면 응답성이 나빠진다. 원문은 메인 스레드의 작업이 **중단 없이 100ms를 넘지 않도록** 권한다. 이는 프레임 시간이나 도구의 검출 임계값을 설명하는 문장이 아니다.

출처: [Hangs](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis#Hangs) · [Event handling and the main thread](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis#Event-handling-and-the-main-thread).

## 원인에 따른 분석

| 구분 | Busy: 계산으로 바쁨 | Blocked: 대기 때문에 멈춤 |
| --- | --- | --- |
| 메인 스레드 CPU 사용 | 높음 | 낮음 |
| 조사 대상 | CPU 시간을 많이 쓰는 함수 | 대기 시간·대상·대기 호출 코드 |
| 도구 | Time Profiler | Thread State Trace |
| 해결 방향 | 불필요한 작업 제거 또는 백그라운드 이동 | 동기 대기를 없애고 완료를 비동기로 통지 |

CPU 사용이 혼재하면 지배적인 상태부터 조사한다. 대부분 낮고 잠깐 치솟으면 Blocked로, 판단이 어려우면 측정하기 쉬운 Busy부터 접근한다.

Busy에서는 함수의 실행 빈도도 살펴야 한다. Time Profiler만으로 개별 실행 정보를 알 수는 없다. Blocked에서는 작업이 이미 백그라운드에 있어도 메인 스레드가 완료를 기다릴 수 있다. 대기 중에는 CPU를 쓰지 않으므로 Time Profiler만으로 원인을 찾기 어렵다.

출처: [분석 전략](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis#Hang-analysis-strategy) · [Busy](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis#Busy-main-thread) · [Blocked](https://developer.apple.com/tutorials/instruments/getting-started-with-hang-analysis#Blocked-main-thread).

## 다음 단계와 범위

다음은 [Identifying a hang](https://developer.apple.com/tutorials/instruments/identifying-a-hang) 실습이다. 후속 챕터는 Busy 사례를 다룬다. Blocked 분석은 원문이 안내하는 [Analyze hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/)를 참고한다. 이 노트에서는 실습을 실행하지 않았다.

[Instruments 로드맵으로 돌아가기](README.md)
