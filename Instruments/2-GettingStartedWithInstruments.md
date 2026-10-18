# 2. Instruments 시작하기 — Time Profiler와 Signpost

- 원본: [Getting Started with Instruments — WWDC19](https://developer.apple.com/kr/videos/play/wwdc2019/411/)
- 정리 기준: [한국어 자막 전문](2-1-GettingStartedWithInstruments-WWDC2019-Korean.md)
- 발표자: Tibet Rooney-Rabdau, Ben Mitchell, Anand Subramanian
- 작성일: 2026-10-18

이 문서는 2019년 발표의 개념과 실습 흐름을 요약한다. 메뉴 위치와 도구 구성은 설치한 Instruments 버전과 다를 수 있다. 마지막의 Sandbox 연결 부분은 영상과 별도로 진행한 로컬 실습 메모다.

## 핵심: 어디서 실행하는가와 얼마나 실행하는가

CPU 성능 분석에서는 작업의 실행 위치와 전체 작업량을 나누어 살펴본다.

| 문제 | 분석 방법 | 수정 | 확인할 결과 |
| --- | --- | --- | --- |
| 데이터 파싱이 메인 스레드를 오래 점유해 UI가 멈춤 | Time Profiler로 메인 스레드의 호출 경로 조사 | 파싱을 별도 큐로 이동하고 완료 후 UI 갱신 | 메인 스레드 부하와 멈춤 감소 |
| UI는 반응하지만 전체 CPU 사용량이 여전히 큼 | Signpost로 작업의 횟수·시간 측정 | 불필요하게 반복되는 작업을 한 번으로 통합 | 불필요한 반복과 전체 작업량 감소 |

**작업을 백그라운드로 옮기는 것만으로 작업량이 줄지는 않는다.** 응답성을 개선한 다음에도 불필요한 CPU 사용이 남아 있는지 확인해야 한다. 성능 문제는 개발 중 언제든 생길 수 있으므로 초기에, 그리고 자주 측정한다.

## 1. 화면을 읽기 위한 기본 개념

영상 구간: **1:35–8:05**

| 용어 | 의미 |
| --- | --- |
| Instruments 앱 | Xcode에 포함된 별도 성능 분석 앱 |
| Instrument | Time Profiler처럼 특정 종류의 데이터를 수집하는 개별 도구 |
| Template | 분석 목적에 맞춰 미리 조합한 Instrument 모음 |
| Trace | 시간에 따라 수집한 기록 |
| Track | 프로세스·스레드·CPU 코어 등 특정 대상의 기록을 표시하는 타임라인 |
| Detail | 선택한 트랙과 시간 구간의 상세 정보 |
| Extended Detail | 선택한 항목의 추가 정보. Time Profiler에서는 Heaviest Stack Trace 등을 제공 |

하나의 Instrument가 여러 트랙을 제공할 수 있다. 따라서 트랙 수와 Instrument 수는 같지 않다. 트레이스 문서를 저장하면 수집한 데이터와 분석 구성을 나중에 다시 열거나 동료와 공유할 수 있다.

주요 조작은 다음과 같다.

- **대상 선택:** 분석할 기기와 프로세스를 선택한다. 확장 프로그램은 앱과 다른 프로세스일 수 있다.
- **시간 구간 선택:** 트랙을 드래그해 관심 구간으로 분석 범위를 좁힌다.
- **Track Filter:** 메인 스레드처럼 필요한 대상만 남긴다.
- **Track Pinning:** 관심 트랙을 고정해 다른 트랙과 같은 시간축에서 비교한다.
- **Inspection Head:** 특정 시점을 지정해 그때의 이벤트와 상세 정보를 확인한다.

녹화 자체도 시스템 자원을 사용한다. 영상의 Windowed Mode는 녹화 중 분석·표시를 미루고 종료 직전 몇 초의 데이터를 대상으로 삼아, 문제가 발생하는 순간을 포착하는 데 활용한다.

## 2. Time Profiler로 메인 스레드의 무거운 작업 찾기

영상 구간: **8:37–17:52**

### 분석 순서

1. Time Profiler 템플릿으로 녹화를 시작한다.
2. 앱에서 문제가 발생하는 동작을 재현한다.
3. 녹화를 멈추고 CPU 사용률이 높은 구간과 응답하지 않던 시점을 비교한다.
4. 앱 프로세스를 펼쳐 메인 스레드의 작업을 확인한다.
5. 관심 시간 구간만 선택하고 호출 트리와 Heaviest Stack Trace를 조사한다.
6. 앱 코드에 속한 함수의 소스를 열어 원인을 찾는다.
7. 수정 후 같은 동작을 재현해 메인 스레드의 부하가 줄었는지 확인한다.

메인 스레드에서 오래 실행되는 연산을 찾았다면, 백그라운드에서 수행할 수 있는 작업을 분리한다. 연산은 별도 큐에서 비동기로 수행하고 UI 갱신은 메인 큐에서 처리한 뒤, 실제로 응답성이 개선됐는지 다시 측정한다.

### 샘플링 결과를 호출 횟수로 읽지 않기

Time Profiler는 **모든 함수의 진입과 종료를 기록하지 않는다.** 일정한 간격으로 스레드의 호출 스택을 수집해 어떤 호출 경로가 CPU 시간을 많이 차지하는지 추정한다.

따라서 Weight와 Heaviest Stack Trace는 비용이 큰 호출 경로를 찾는 단서다. 샘플에 많이 등장했다는 사실만으로 그 함수의 실제 호출 횟수를 알 수는 없다. 한 번 오래 실행된 함수와 여러 번 짧게 실행된 함수가 모두 큰 비중을 차지할 수 있기 때문이다.

번역의 14:21에 나오는 “가장 자주 호출된 함수”는 이 샘플링 맥락에서 읽어야 한다. **정확한 실행 횟수는 다음 단계의 Signpost 같은 직접 계측으로 확인한다.**

호출 스택 위쪽부터 보면 작업이 어떤 경로로 시작됐는지 찾기 좋다. 말단 함수부터 보면 실제로 비용이 큰 연산을 찾기 좋다. `thunk`처럼 컴파일러가 생성한 보조 코드도 있으므로, 모든 항목이 직접 작성한 함수는 아니다.

## 3. Signpost로 작업의 구간과 반복 횟수 확인하기

영상 구간: **20:48–27:35**

Time Profiler로 의심스러운 코드를 찾았다면, Signpost로 그 작업의 시작과 끝을 표시한다. Instruments가 이 구조화된 기록을 읽어 Points of Interest 트랙에 실행 구간을 보여 준다.

| 도구 | 답하기 좋은 질문 |
| --- | --- |
| Time Profiler | 어느 함수와 호출 경로에서 CPU 시간을 많이 쓰는가? |
| Signpost / Points of Interest | 표시한 작업은 언제 시작·종료됐고, 몇 번 실행됐는가? |

영상의 적용 과정은 다음과 같다.

1. `.pointsOfInterest` 카테고리의 로그 객체를 만든다.
2. 측정할 함수 시작에 `os_signpost(.begin, ...)`을 넣는다.
3. `defer`에서 대응하는 `.end`를 기록한다.
4. 같은 동작을 다시 녹화한다.
5. Points of Interest의 요약과 구간 목록에서 횟수·평균 시간·각 구간의 지속 시간을 확인한다.

시작 시각과 종료 시각을 `print`로 출력하는 방식과 달리 Instruments가 작업 구간을 직접 해석할 수 있다. `defer`는 현재 스코프가 끝날 때 실행되므로 시작·종료 쌍을 한곳에서 관리하기 편하다.

작업 구간이 예상보다 많이 나타난다면 호출 횟수를 조사한다. 각 구간의 지속 시간까지 비슷하다면 같은 양의 작업을 반복하고 있는지 확인한다. 한 번의 실행 비용과 전체 실행 횟수를 함께 봐야 총비용의 원인을 이해할 수 있다.

## 4. 호출자를 따라가 중복 작업 제거하기

영상 구간: **27:35–29:51**

Signpost에서 불필요한 반복을 발견하면 Time Profiler의 호출 트리로 돌아가 호출자를 따라 올라간다. 직접 호출하는 함수에 반복문이 없더라도, 더 상위의 호출자가 반복해서 실행하고 있을 수 있다.

1. 비용이 큰 함수의 직접 호출자를 확인한다.
2. 반복 원인이 보이지 않으면 상위 호출자로 범위를 넓힌다.
3. 같은 결과를 여러 번 계산하거나 전체 갱신을 반복하는지 확인한다.
4. 동작의 의미를 유지할 수 있다면 변경 사항을 모아 처리하고 비싼 작업은 한 번 수행한다.
5. 다시 측정해 실행 횟수와 전체 비용이 줄었는지 확인한다.

최적화할 때는 함수 내부의 연산뿐 아니라 **호출하는 위치와 횟수**도 살펴야 한다. 반복문 밖으로 작업을 옮길 때는 각 단계에서 중간 결과가 필요한지 먼저 확인한다.

## 5. 테스트를 사용해 같은 작업 재현하기

영상 구간: **29:51–32:54**

수동 조작 대신 테스트로 분석할 작업을 실행하면 같은 동작을 안정적으로 반복하기 쉽다. 영상에서는 XCTest의 `measure` 안에 작업을 넣고 테스트를 Instruments에서 프로파일링한다.

`measure`는 작업을 여러 차례 실행한다. Points of Interest에서 각 측정 회차와 내부 Signpost 구간을 함께 보면, 회차별 실행이 일관적인지와 한 회차 안에서 작업이 예상한 횟수만큼 수행되는지 확인할 수 있다.

여기서 구분할 것은 **측정을 위한 테스트의 반복**과 **한 번의 작업 안에서 발생하는 불필요한 반복**이다. 전자는 실행 간 편차를 확인하기 위한 것이고, 후자는 제거할 최적화 대상이었다.

### Xcode에서 테스트를 Instruments로 실행하기

1. Xcode에서 테스트 파일을 연다. 로컬 실습에서는 `GettingStartedWithInstrumentsViewModelTests.swift`를 사용한다.
2. 프로파일링할 **테스트 함수 왼쪽의 테스트 실행 아이콘을 우클릭 → Profile**을 선택한다. 일반 클릭은 테스트만 실행한다.
3. Xcode가 테스트를 빌드하고 Instruments를 열면 **Time Profiler** 템플릿을 선택한다.
4. **Record** 버튼을 눌러 테스트 실행과 데이터 수집을 시작한다.
5. 테스트가 끝나면 녹화를 중지하고 **Points of Interest**에서 `Big Task` 또는 `Optimized Big Task` 구간을 선택한다.
6. 같은 시간대의 **Main Thread**와 Time Profiler 호출 트리를 확인해 작업이 어디서 실행됐는지 분석한다.

`bigTask`와 `optimizedBigTask` 테스트를 각각 Profile하면 두 작업을 따로 관찰하기 편하다. `runBigTaskRepeatedly` 테스트에서는 연속된 `Big Task` 구간 세 개를 확인한다. 테스트를 Instruments에서 실행하는 데 `measure`가 필수인 것은 아니다. 현재 실습은 Swift Testing의 `@Test`가 작업을 호출하고, 작업 내부의 Signpost가 측정 구간을 남기는 방식이다.

## 6. 결과를 믿기 위한 측정 조건

영상 구간: **17:57–20:25**

- **Release 구성으로 측정한다.** 실제 배포에 사용하는 최적화 조건과 맞춰야 한다. 사용자 정의 컴파일러 플래그가 있다면 Profile 구성도 확인한다.
- **구형 기기와 큰 작업량으로 확인한다.** 개발 환경에서 드러나지 않은 문제가 실제 사용자 환경에서는 나타날 수 있다.
- **실기기로 확인한다.** 시뮬레이터는 Mac의 CPU·메모리·디스크·열 특성을 따르므로 실제 기기의 절대 실행 시간을 그대로 재현하지 않는다.
- **수정 후 다시 측정한다.** UI 멈춤이 사라졌는지와 전체 CPU 작업량이 줄었는지를 따로 확인한다.

## 로컬 Sandbox에 연결해서 보기

이 절은 영상 요약에 덧붙인 실습 메모다. 앱 소스와 테스트를 각각 `2-GettingStartedWithInstruments` 폴더에 모았고, 타입 이름에도 `GettingStartedWithInstruments`를 사용한다. 앱 진입점은 `GettingStartedWithInstrumentsView`를 표시한다.

- [GettingStartedWithInstrumentsView.swift](Instruments-Sandbox/Instruments-Sandbox/2-GettingStartedWithInstruments/GettingStartedWithInstrumentsView.swift): `bigTask`와 `optimizedBigTask`에 각각 `Big Task`, `Optimized Big Task` Signpost를 추가했다. 이름으로 작업 종류를, 개별 구간으로 각 실행을 구분한다.
- 두 작업은 약 2초간 수행하도록 만든 예제다. 소요 시간 단축보다 **같은 시간대에 메인 스레드가 얼마나 바쁜지**를 비교한다. `optimizedBigTask`도 상태 접근 시 MainActor를 사용하므로 메인 스레드 작업이 완전히 없어지는 것은 아니다.
- [GettingStartedWithInstrumentsViewModelTests.swift](Instruments-Sandbox/Instruments-SandboxTests/2-GettingStartedWithInstruments/GettingStartedWithInstrumentsViewModelTests.swift): Swift Testing으로 `bigTask`와 `optimizedBigTask`는 각각 한 번, `runBigTaskRepeatedly`는 `count = 3`으로 호출해 연속된 세 작업 구간을 관찰하도록 작성했다. 영상의 XCTest `measure`처럼 반복 측정하는 코드는 아니다.
- 소스를 찾지 못했을 때 Symbols 창에서 앱의 **Debug Symbols가 No**인 것을 확인했다. `Add Symbols`로 해당 빌드의 dSYM을 추가한 뒤 **Yes**로 바뀌었다. 심볼 로드 여부와 Swift 소스 표시 성공 여부는 따로 확인해야 한다.

## 다시 볼 영상 구간

| 시간 | 다시 확인할 내용 |
| --- | --- |
| 6:03–8:05 | Track, Detail, Extended Detail의 관계 |
| 12:29–15:19 | 메인 스레드에서 호출 경로와 소스까지 따라가기 |
| 15:48–17:52 | 작업을 별도 큐로 옮긴 뒤 재측정 |
| 24:46–27:35 | Signpost 추가와 실행 횟수·시간 확인 |
| 28:24–29:51 | 반복 호출의 원인과 일괄 갱신 |
| 30:11–32:06 | 테스트를 프로파일링하고 한 회차 분석하기 |

[Instruments 목차](README.md) · [한국어 자막 전문](2-1-GettingStartedWithInstruments-WWDC2019-Korean.md)
