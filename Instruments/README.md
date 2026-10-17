# Instruments 학습 로드맵

iOS 앱의 성능 문제를 **재현 → 측정 → 원인 분석 → 수정 → 재측정**하는 과정을 익힌다. 도구 사용법을 외우는 것보다, 측정 결과를 근거로 원인을 설명하는 것을 목표로 한다.

## 학습 방식

- 빠른 입문: 3일 동안 기본 조작·CPU 분석 → 메모리 분석 → 멈춤 분석을 실습한다. SwiftUI와 Signpost는 선택적으로 1~2일 더 진행한다.
- 아래 8단계는 전체 학습 범위다. 처음부터 모두 끝낼 필요는 없으며, 반복 실습과 심화 주제는 필요할 때 진행한다.
- 매 단계에서 문제를 하나씩 만들고 수정 전후를 같은 조건으로 비교한다.
- 현재 Needle 샘플은 기본 실행과 객체 수명 관찰에 활용한다. 스크롤·이미지 실습은 해당 화면을 추가하거나 Apple 튜토리얼 샘플을 사용한다.
- 실습 노트와 코드는 필요할 때 추가한다. 우선 이 README의 체크리스트로 진행 상황을 관리한다.

## 로드맵

| 완료 | 단계 | 주제 | 실습 | 완료 기준 |
| --- | --- | --- | --- | --- |
| [ ] | 1 | 측정 환경과 기본 조작 | Profile로 앱 실행, 녹화, 구간 선택, trace 저장 | 원하는 사용자 동작 구간을 다시 찾아 설명할 수 있다 |
| [ ] | 2 | CPU 분석: Time Profiler | 반복 계산으로 병목을 만들고 Call Tree에서 찾기 | 비용이 큰 호출 경로와 실제 작업 함수를 구분한다 |
| [ ] | 3 | 응답성: Hangs | 메인 스레드에서 오래 걸리는 작업을 실행하고 개선 | 멈춤 구간을 특정하고 원인과 개선 결과를 설명한다 |
| [ ] | 4 | 메모리: Allocations | 화면 진입·이탈을 반복하며 살아 있는 객체 추적 | 일시적 증가와 계속 남는 할당을 구분한다 |
| [ ] | 5 | 메모리 누수와 객체 수명 | 강한 참조 순환을 만들고 Leaks 및 Memory Graph로 추적 | 참조 경로를 설명하고 수정 후 해제를 확인한다 |
| [ ] | 6 | 화면 성능: Hitches·SwiftUI | 리스트 스크롤과 무거운 뷰 갱신을 측정 | 끊김 구간과 관련 작업을 연결하고 전후를 비교한다 |
| [ ] | 7 | 구간 계측: Signpost | 데이터 로딩·변환·화면 준비 구간에 표식 추가 | 관심 작업을 타임라인에서 구분하고 소요 시간을 비교한다 |
| [ ] | 8 | 종합 실습 | 하나의 화면에서 CPU·메모리·응답성 문제 분석 | 재현 절차와 측정 근거가 있는 개선 보고서를 작성한다 |

## 1. 측정 환경과 기본 조작

**배울 것**

- Xcode의 `Product > Profile`과 Instruments의 관계
- Template, Instrument, Track, Timeline, Detail 영역
- 녹화 시작·종료, 시간 범위 선택, 확대, `.trace` 저장
- Debug와 Release 빌드, 실기기와 시뮬레이터의 차이

**실습**

1. Scheme의 Profile 빌드 구성이 Release인지 확인한다.
2. Time Profiler로 앱 실행부터 화면 표시까지 녹화한다.
3. 특정 동작을 수행한 구간만 선택하고 호출 목록의 변화를 관찰한다.
4. 같은 동작을 3회 측정해 결과가 얼마나 달라지는지 기록한다.

성능 비교는 실기기를 기준으로 한다. 시뮬레이터는 조작 연습에 사용할 수 있지만 실기기 성능의 근거로 삼지 않는다. [Apple의 측정 환경 안내](https://developer.apple.com/tutorials/instruments/identifying-a-hang)

## 2. CPU 분석: Time Profiler

**배울 것**

- 샘플링 기반 CPU 분석과 측정의 한계
- Call Tree, Weight, Self Weight
- Separate by Thread, Invert Call Tree, Hide System Libraries
- 전체 녹화와 문제 구간만 선택했을 때의 차이

**실습**

1. 버튼 동작에 반복 정렬 또는 문자열 변환을 넣는다.
2. 해당 구간에서 비용이 큰 호출 경로와 함수를 찾는다.
3. 중복 계산 제거 또는 결과 재사용으로 작업량을 줄인다.
4. 같은 입력으로 다시 측정한다.

**확인 질문:** 상위 함수의 Weight가 크면 그 함수 자체가 느리다는 뜻일까? CPU 샘플만으로 I/O 대기 시간을 설명할 수 있을까?

## 3. 응답성: Hangs

**배울 것**

- 메인 스레드의 긴 작업과 UI 응답성
- CPU를 사용하며 바쁜 상태와 대기·블로킹 상태의 차이
- Hangs 구간과 Time Profiler 호출 경로 연결

**실습**

1. 메인 스레드에서 큰 데이터를 동기적으로 변환해 멈춤을 재현한다.
2. Hangs에 잡힌 구간을 선택하고 메인 스레드 작업을 조사한다.
3. 불필요한 작업을 줄이고, UI와 무관한 무거운 작업은 적절한 실행 위치로 옮긴다.
4. 응답성과 작업 완료 시간을 각각 비교한다.

**주의:** `async`나 `Task {}`를 붙였다고 CPU 작업이 자동으로 메인 스레드 밖에서 실행되는 것은 아니다. 실제 실행 맥락과 측정 결과를 확인한다.

## 4. 메모리: Allocations

**배울 것**

- 누적 할당량과 현재 살아 있는 할당의 차이
- 객체 수, 할당 크기, 할당 스택
- Mark Generation을 이용한 반복 동작 비교
- 캐시·일시적 피크·계속 누적되는 메모리의 차이

**실습**

1. 화면 진입 → 데이터 생성 → 화면 이탈을 10회 반복한다.
2. 동작 전후에 Generation을 나누고 남은 객체를 조사한다.
3. 큰 배열 또는 이미지를 오래 보관하는 코드를 넣고 차이를 관찰한다.
4. 보관 범위를 줄인 뒤 같은 조건으로 재측정한다.

**완료 기준:** 메모리 그래프가 올랐다는 사실을 넘어 어떤 객체가 어디서 할당되고 왜 남는지 설명한다.

## 5. 메모리 누수와 객체 수명

**배울 것**

- ARC, 강한 참조 순환, `weak`·`unowned`의 용도
- Leaks와 Xcode Memory Graph의 역할 차이
- 클로저·타이머·구독의 수명과 소유 관계
- 누수와 의도보다 오래 유지되는 객체의 차이

**실습**

1. 객체가 보관한 클로저에서 자신을 강하게 캡처하도록 만든다.
2. 화면을 닫아도 객체가 해제되지 않는지 확인한다.
3. Leaks와 Memory Graph로 소유 관계를 조사한다. Memory Graph는 Xcode의 보조 디버깅 도구다.
4. 캡처 또는 정리 로직을 수정하고 `deinit`과 살아 있는 객체 수를 확인한다.
5. Needle 샘플에서 Root·자식 Component·ViewModel의 기대 수명을 적고 실제 수명과 비교한다.

**주의:** Leaks에서 문제가 없다고 모든 객체의 수명이 올바른 것은 아니다. 정상적인 참조 경로로도 객체가 필요 이상으로 오래 유지될 수 있다.

## 6. 화면 성능: Hitches·SwiftUI

**배울 것**

- 긴 멈춤인 hang과 화면 갱신의 끊김인 hitch
- 프레임 갱신, 메인 스레드 작업, 뷰 업데이트의 관계
- SwiftUI의 비싼 `body` 계산과 불필요한 업데이트

**실습**

1. 항목이 많은 리스트를 만들고 일정한 방식으로 스크롤한다.
2. 뷰 계산에 무거운 포맷 변환을 넣어 전후를 비교한다.
3. 문제 구간의 뷰 업데이트와 CPU 작업을 함께 조사한다.
4. 계산 위치와 상태 전달 범위를 조정하고 재측정한다.

SwiftUI 전용 Instrument는 Xcode·OS 버전에 따라 제공 기능이 다르다. 사용 환경을 확인하고, 사용할 수 없다면 Time Profiler와 응답성 분석부터 진행한다. [Apple의 SwiftUI 성능 분석 세션](https://developer.apple.com/videos/play/wwdc2025/306/)

## 7. 구간 계측: Signpost

**배울 것**

- `OSSignposter`를 이용한 이벤트와 구간 기록
- 구간 시작·종료의 대응과 식별자
- 앱의 의미 있는 동작과 CPU·응답성 타임라인 연결

**실습**

1. 데이터 요청, 데이터 변환, 화면 준비를 별도 구간으로 표시한다.
2. 여러 요청이 겹쳐도 구별되도록 식별자를 관리한다.
3. Points of Interest 등 계측 표시를 지원하는 트랙에서 구간을 확인한다.
4. 전체 지연 중 어떤 단계가 큰 비중을 차지하는지 기록한다.

## 8. 종합 실습

**과제:** 데이터 목록 화면의 로딩 지연, 스크롤 끊김, 반복 진입 시 메모리 증가를 분석한다.

1. 재현 시나리오와 관찰한 증상을 작성한다.
2. 가설을 세우고 적절한 Instrument를 선택한다.
3. 수정 전 기준 측정값과 trace를 남긴다.
4. 원인 하나를 수정하고 같은 조건으로 다시 측정한다.
5. 기능이 유지되는지 확인하고 부작용이나 남은 문제를 적는다.

**완료 체크리스트**

- [ ] 추측과 측정으로 확인한 사실을 구분했다.
- [ ] 문제 구간과 관련 호출 또는 참조 경로를 제시했다.
- [ ] 동일 조건에서 수정 전후를 각각 3회 이상 측정했다.
- [ ] 개선 수치와 함께 변동 폭 및 측정 한계를 기록했다.
- [ ] 다른 사람이 따라 할 수 있는 재현 절차를 남겼다.

## 실습 기록 양식

```markdown
# 실습 제목

- 날짜 / 코드 버전:
- 기기 / OS / Xcode / 빌드 구성:
- 사용한 Instrument:
- 재현 절차 / 입력 데이터:
- 증상과 가설:
- 측정으로 확인한 사실:
- 원인과 수정 내용:
- 수정 전 / 후 결과 (단위, 반복 횟수, 변동 폭 포함):
- trace 또는 스크린샷 위치:
- 남은 질문:
```

기기, 입력, 측정 구간, 캐시 상태를 맞춘다. 발열과 백그라운드 작업도 기록한다. 첫 실행과 반복 실행 결과는 나누어 비교한다.

## 이후 확장할 주제

- 앱 시작 시간과 초기화 비용
- 네트워크·파일 I/O와 캐싱
- 전력 사용과 불필요한 주기적 작업
- Swift Concurrency의 작업 흐름과 실행 맥락
- XCTest 성능 측정과 성능 회귀 감지
- MetricKit을 활용한 실제 사용자 환경의 성능 관찰

## WWDC 추천 시청 순서

처음에는 아래 **필수 3편**만 보고 각각 작은 실습을 진행한다. 나머지는 해당 문제가 생겼을 때 찾아본다.

### 먼저 볼 3편

| 순서 | 세션 | 연결 단계 | 집중할 내용 |
| --- | --- | --- | --- |
| 1 | [Getting Started with Instruments — WWDC19](https://developer.apple.com/videos/play/wwdc2019/411/) | 1·2 | 기본 조작, Time Profiler, 병목 찾기, Points of Interest |
| 2 | [Detect and diagnose memory issues — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10180/) | 4·5 | 메모리 문제의 분류, 누수와 힙 증가 진단, Memory Graph 활용 |
| 3 | [Analyze hangs with Instruments — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10248/) | 3 | 멈춤 구간 선택, 바쁜 메인 스레드와 대기 상태 구분, 원인 분석 |

메모리 영상의 XCTest·명령줄 도구 부분은 처음에는 훑어보고, 누수와 힙 증가를 구분하는 흐름부터 이해한다.

### 주제별 선택 영상

| 주제 | 세션 | 볼 때의 목표 |
| --- | --- | --- |
| CPU 심화 | [Optimize CPU performance with Instruments — WWDC25](https://developer.apple.com/videos/play/wwdc2025/308/) | Time Profiler와 CPU Profiler의 차이 이해. 먼저 8:50의 Profilers 챕터를 보고 Processor Trace·CPU Counters는 이후에 진행 |
| 메모리 심화 | [iOS Memory Deep Dive — WWDC18](https://developer.apple.com/videos/play/wwdc2018/416/) | 메모리 footprint, 이미지 비용, 메모리 분석 도구 이해 |
| SwiftUI | [Optimize SwiftUI performance with Instruments — WWDC25](https://developer.apple.com/videos/play/wwdc2025/306/) | 오래 걸리는 뷰 업데이트를 찾아 Time Profiler와 연결 |
| Signpost | [Measuring Performance Using Logging — WWDC18](https://developer.apple.com/videos/play/wwdc2018/405/) | 이벤트·구간 표식으로 앱 동작과 측정 결과 연결. 영상의 기존 API 예제와 README의 OSSignposter 사용법은 구분 |
| 종합 분석 | [Profile, fix, and verify: Improve app responsiveness with Instruments — WWDC26](https://developer.apple.com/videos/play/wwdc2026/268/) | CPU 작업·실행 경합·블로킹을 구분하고 수정 후 재측정하는 흐름 복습 |

오래된 영상은 기본 분석 개념을 중심으로 본다. 최신 영상의 CPU Profiler·Processor Trace·SwiftUI 관련 기능은 Xcode·OS·하드웨어 지원 조건을 확인하고 따라 한다.

### 화면 끊김 보충 자료 — Apple Tech Talks

아래는 WWDC 세션이 아닌 Apple 공식 Tech Talks다. 6단계에서 렌더링 흐름이 궁금할 때 순서대로 본다.

1. [Explore UI animation hitches and the render loop](https://developer.apple.com/videos/play/tech-talks/10855/)
2. [Find and fix hitches in the commit phase](https://developer.apple.com/videos/play/tech-talks/10856/)
3. [Demystify and eliminate hitches in the render phase](https://developer.apple.com/videos/play/tech-talks/10857/)

## 참고 자료

- [Apple Instruments Tutorials](https://developer.apple.com/tutorials/instruments)
- [Xcode에서 Instruments로 프로파일링하기](https://help.apple.com/xcode/mac/current/en.lproj/devcc15e6912.html)
- [메인 스레드 활동 분석](https://developer.apple.com/tutorials/instruments/analyzing-main-thread-activity)
- [Optimize SwiftUI performance with Instruments — WWDC25](https://developer.apple.com/videos/play/wwdc2025/306/)

도구 이름과 UI는 설치한 Xcode 버전에 따라 달라질 수 있다. 튜토리얼 화면을 그대로 따라가기보다 분석 목적과 측정 지표를 기준으로 학습한다.
