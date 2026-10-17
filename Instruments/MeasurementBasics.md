# 측정 환경과 Instruments 기본 조작

[Instruments 로드맵](README.md)의 1단계 문서로, Apple 레퍼런스의 측정 환경과 기본 조작 내용을 정리한다.

## Instruments와 Profile

Instruments는 Xcode에 포함된 별도 성능 분석 앱이다. Xcode에서 `Product > Profile`을 선택하면 빌드한 앱을 Instruments로 분석할 수 있다. 실행 중인 프로세스를 Instruments에서 직접 선택하는 방법도 있다.

- **Template**: 분석 목적에 맞게 Instrument를 묶어 놓은 구성이다.
- **Instrument**: CPU 샘플 등 특정 데이터를 수집하는 도구다.
- **Track / Timeline**: 프로세스·스레드 등의 데이터를 시간축에 표시한다. 하나의 Instrument가 여러 Track을 제공할 수 있다.
- **Detail**: 선택한 Track과 시간 범위의 상세 데이터를 보여 준다.
- **Trace document**: 수집한 데이터와 분석 구성을 담으며, 저장 후 다시 열 수 있다.

출처: [Getting Started with Instruments — WWDC19](https://developer.apple.com/videos/play/wwdc2019/411/)

## 측정 도구 (Instruments)

Instrument는 데이터를 수집·분석하는 개별 도구이고, Template은 목적에 맞게 여러 Instrument를 묶어 놓은 구성이다. 같은 이름이 도구와 템플릿 양쪽에 쓰이기도 한다.

아래는 **Xcode 26.5 (17F42)의 표준 템플릿에 포함된 측정 도구 47개**다. 영문명은 템플릿에 저장된 표시명을 따른다. 라이브러리 전체나 다른 버전의 도구까지 포함한 목록은 아니며, 지원 여부는 대상 OS·기기에 따라 달라진다.

### CPU·스레드·시스템

- **Time Profiler**: 일정 시간 간격으로 CPU에서 실행 중인 스레드의 호출 스택을 샘플링한다. 어떤 함수와 호출 경로에서 실행 시간을 많이 쓰는지 찾는다.
- **CPU Profiler**: CPU 사이클을 기준으로 샘플링해 연산 비용을 분석한다. 성능 코어와 효율 코어 등 실행 환경 차이에 영향을 받는 시간 기반 측정을 보완한다.
- **CPU Counters**: 하드웨어 성능 카운터로 명령 실행과 CPU 내부 병목을 분석한다. 함수 수준의 병목을 찾은 뒤 저수준 최적화를 할 때 사용한다.
- **Processor Trace**: 지원 하드웨어의 추적 기능으로 함수 실행 흐름을 복원한다. 샘플링으로 놓치기 쉬운 짧은 함수 호출과 실행 순서를 분석한다.
- **Activity Monitor**: 프로세스와 시스템의 CPU·메모리·디스크·네트워크 사용량을 개괄적으로 보여 준다.
- **Thread State Trace**: 스레드의 실행·대기 상태와 스케줄링 변화를 추적한다.
- **System Call Trace**: 시스템 호출과 소요 시간을 기록한다.
- **Virtual Memory Trace**: 스레드별 가상 메모리 활동을 추적한다.
- **System Load**: 시스템의 부하를 확인한다.

출처: [CPU 분석](https://developer.apple.com/videos/play/wwdc2025/308/) · [시스템 도구 설명](https://developer.apple.com/documentation/audiotoolbox/analyzing-audio-performance-with-instruments).

### 응답성·UI·동시성

- **Hangs**: 메인 스레드가 제때 응답하지 못한 구간과 지속 시간을 표시한다. CPU 작업이 많아서 바쁜 경우와 대기·블로킹 때문에 멈춘 경우 모두 원인 조사가 필요하다.
- **Hitches**: 프레임이 표시 기한을 놓친 구간을 표시한다. 앱의 commit 작업, 렌더 서버, GPU 작업 중 어디서 지연됐는지 조사하는 출발점이다.
- **SwiftUI**: 뷰의 `body`와 기타 업데이트의 원인·빈도·소요 시간을 분석한다. 오래 걸리는 업데이트와 불필요한 업데이트를 찾고, Cause & Effect Graph로 변경의 원인을 추적한다.
- **Swift Tasks**: Swift Task의 생성·실행·중단 상태와 작업 사이의 관계를 보여 준다.
- **Swift Actors**: Actor에서 수행하는 작업과 경합을 분석한다.
- **Runloops**: Run Loop의 활동 구간을 보여 준다. 이벤트 처리와 프레임 작업의 실행 시점을 확인한다.
- **dyld Activity**: 동적 라이브러리 로딩과 초기화 등의 활동을 보여 준다. 앱 시작 비용 분석에 사용한다.

출처: [Hangs](https://developer.apple.com/videos/play/wwdc2023/10248/) · [Hitches](https://developer.apple.com/documentation/xcode/understanding-hitches-in-your-app) · [SwiftUI](https://developer.apple.com/videos/play/wwdc2025/306/) · [Swift Concurrency](https://developer.apple.com/videos/play/wwdc2022/110350/).

### 메모리

- **Allocations**: 힙과 익명 가상 메모리의 할당을 추적한다. 객체가 어디서 할당되고 언제 해제되는지, 어떤 할당이 계속 남는지 분석한다.
- **Leaks**: 메모리를 검사해 더 이상 도달할 수 없는 할당을 찾는다. 누수 탐지가 목적이며, 정상 참조를 통해 불필요하게 오래 보관되는 객체를 모두 찾아주는 것은 아니다.
- **VM Tracker**: 프로세스의 가상 메모리 영역과 사용 통계를 시점별로 확인한다. Allocations의 할당 이력과 함께 메모리 사용을 분석한다.
- **Metal Resource Events**: 텍스처와 버퍼 등 Metal GPU 리소스의 할당 이벤트를 기록한다.

출처: [힙 메모리 분석](https://developer.apple.com/videos/play/wwdc2024/10173/) · [Metal 메모리 분석](https://developer.apple.com/documentation/xcode/analyzing-the-memory-usage-of-your-metal-app).

### 파일·데이터·네트워크

- **Filesystem Activity**: 파일 열기·읽기·쓰기 등 파일 시스템 작업을 추적한다.
- **Filesystem Suggestions**: 수집한 파일 시스템·디스크 I/O에서 비효율적인 패턴을 찾아 개선 권고를 제공한다.
- **Disk Usage**: 저장 장치의 I/O 작업과 사용 통계를 확인한다.
- **Disk I/O Latency**: 디스크 I/O 완료 시간을 표시해 지연과 I/O 포화 상태를 분석한다.
- **Data Faults**: SwiftData·Core Data의 객체와 관계 fault 발생 및 소요 시간을 추적한다. 여기서 fault는 아직 구체화되지 않은 데이터를 불러오는 동작이다.
- **Data Fetches**: SwiftData·Core Data의 데이터 조회 횟수와 소요 시간을 측정한다.
- **Data Saves**: SwiftData·Core Data의 저장 작업과 소요 시간을 측정한다.
- **Network Connections**: 네트워크 연결과 송수신 활동을 분석한다.
- **HTTP Traffic**: URL Loading System을 통한 요청·응답, 연결 수립 시간, 헤더·본문 등의 정보를 확인한다.

출처: [HTTP 분석](https://developer.apple.com/documentation/foundation/analyzing-http-traffic-with-instruments) · Xcode 내장 FileActivity·DataPersistence 패키지 문서.

### 로그·구간 계측

- **Points of Interest**: 앱과 시스템의 관심 이벤트·구간을 표시한다. Signpost로 표시한 작업을 CPU나 다른 지표와 같은 시간축에서 연결해 볼 수 있다.
- **os_log**: Unified Logging의 로그 메시지를 시간축에서 확인한다.
- **os_signpost**: Signpost로 기록한 이벤트와 구간을 표시하고 소요 시간을 분석한다.

출처: [Getting Started with Instruments](https://developer.apple.com/videos/play/wwdc2019/411/) · Xcode 내장 Logging 템플릿과 Narrative 패키지 문서.

### 전력·열 상태

- **Power Profiler**: CPU·GPU·디스플레이·네트워크 사용이 전력 소비에 미치는 영향을 분석한다. 시스템 전체의 전력 사용과 앱의 하위 시스템별 영향을 함께 본다. iOS·iPadOS 지원 조건을 확인해야 한다.
- **Thermal State**: 기기의 열 상태를 기록한다. 성능 변화가 발열 상태와 함께 나타나는지 확인한다.
- **Location Energy Model**: Core Location 사용이 에너지 소비에 미치는 영향을 모델링해 보여 준다.

출처: [Power Profiler](https://developer.apple.com/documentation/xcode/measuring-your-app-s-power-use-with-power-profiler) · Xcode 내장 Apps 패키지 문서.

### GPU·렌더링

- **Metal Application**: Metal 앱의 API 작업과 관련 이벤트를 기록한다.
- **GPU**: GPU 실행 이벤트를 기록한다. 앱에서 제출한 작업이 GPU에서 언제 수행되는지 분석한다.
- **Display**: 화면 표시와 VSync 이벤트를 기록한다.
- **Metal Performance Overview**: Metal 작업의 성능 지표를 개괄적으로 확인한다.
- **Game Performance Overview**: FPS와 GPU 시간 등의 지표를 초 단위로 집계한다. 낮은 수집 비용으로 긴 게임 실행 구간의 성능 추이를 볼 때 사용한다.
- **RealityKit Frames**: RealityKit 프레임의 렌더링 단계와 소요 시간을 보여 준다.
- **RealityKit Metrics**: 장면·렌더링 지표로 병목을 찾고 관련 권고를 제공한다.

출처: [RealityKit Trace](https://developer.apple.com/videos/play/wwdc2023/10099/) · Xcode 내장 GPU 패키지 문서.

### 오디오·머신러닝

- **Audio Client**: 앱의 오디오 I/O 콜백 타이밍을 추적한다.
- **Audio Server**: 오디오 서버의 엔진 타임스탬프와 I/O 주기 부하 등을 추적한다.
- **Audio Statistics**: 오디오 I/O 주기의 지연 변동과 동시 오디오 스레드 수 등 통계를 기록한다.
- **Core ML**: Core ML로 수행하는 머신러닝 작업을 분석한다. 모델 로딩과 예측 실행에 드는 비용을 확인한다.
- **Neural Engine**: Neural Engine의 하드웨어 실행 이벤트를 보여 준다.

출처: [오디오 분석](https://developer.apple.com/documentation/audiotoolbox/analyzing-audio-performance-with-instruments) · [Core ML](https://developer.apple.com/videos/play/wwdc2023/10049/) · Xcode 내장 Neural Engine 패키지 문서.

**Hangs는 응답이 멈춘 구간, Hitches는 프레임이 제때 표시되지 않은 구간**을 다룬다. 같은 원인으로 둘 다 발생할 수 있지만 서로 다른 관찰이다. Signpost는 코드에서 이벤트·구간을 기록하는 수단이며, 그 기록을 Points of Interest나 os_signpost로 확인한다.

## 템플릿 구성 (Templates)

`xcrun xctrace list templates`에 나오는 **표준 템플릿 25개**와 Blank의 구성이다. 각 템플릿의 용도와 포함된 도구를 정리한다. 구성은 Xcode 26.5에 포함된 `.tracetemplate` 파일에서 확인했으며, 실행 대상이나 Xcode 버전에 따라 달라질 수 있다.

### Activity Monitor

프로세스와 시스템의 CPU·메모리·디스크·네트워크 사용량을 전반적으로 확인한다.

- Activity Monitor
- Thermal State

### Allocations

메모리 할당 이력과 가상 메모리 사용량을 함께 살펴 메모리 증가 원인을 찾는다.

- Allocations
- VM Tracker
- Points of Interest

### Animation Hitches

스크롤·애니메이션의 끊김을 찾고 CPU 작업부터 화면 표시까지의 지연을 분석한다.

- Hitches
- Display
- Time Profiler
- Thread State Trace
- Thermal State
- Hangs

### App Launch

앱 시작 시의 CPU 작업, 라이브러리 로딩, 스레드 상태를 분석해 실행 지연의 원인을 찾는다.

- Thread State Trace
- Time Profiler
- dyld Activity

### Audio System Trace

오디오 처리와 시스템 활동을 함께 살펴 소리가 튀거나 끊기는 원인을 분석한다.

- Points of Interest
- System Load
- Thread State Trace
- Virtual Memory Trace
- System Call Trace
- Thermal State
- Audio Client
- Audio Statistics
- Audio Server
- Hangs

### Blank

필요한 측정 도구를 직접 추가해 분석 구성을 만든다.

- 포함된 도구 없음

### CPU Counters

하드웨어 성능 카운터와 실행 정보를 함께 사용해 CPU 내부 병목을 분석한다.

- CPU Counters
- Time Profiler
- Thread State Trace
- Points of Interest

### CPU Profiler

CPU 사이클 기반으로 작업 비용을 측정하고 비용이 큰 호출 경로를 찾는다.

- CPU Profiler
- Points of Interest
- Thermal State
- Hangs

### Core ML

Core ML 작업과 CPU·GPU·Neural Engine 활동을 함께 살펴 머신러닝 실행 비용을 분석한다.

- Metal Application
- GPU
- Time Profiler
- Core ML
- Neural Engine

### Data Persistence

SwiftData·Core Data의 조회, 저장, fault 처리를 추적해 데이터 접근 비용을 분석한다.

- Data Faults
- Data Fetches
- Data Saves

### File Activity

파일 시스템과 디스크 I/O의 사용량·지연을 살펴 비효율적인 파일 접근을 찾는다.

- Filesystem Suggestions
- Filesystem Activity
- Disk Usage
- Disk I/O Latency

### Game Memory

일반 메모리 할당과 Metal 리소스를 함께 살펴 게임의 CPU·GPU 메모리 사용을 분석한다.

- Allocations
- Metal Resource Events
- VM Tracker
- Virtual Memory Trace
- Metal Application
- GPU

### Game Performance

CPU·GPU·스레드·화면 표시 정보를 함께 살펴 게임의 프레임 성능 병목을 찾는다.

- Points of Interest
- System Load
- Thread State Trace
- System Call Trace
- Virtual Memory Trace
- Time Profiler
- Thermal State
- Metal Resource Events
- Metal Application
- GPU
- Display
- Hangs

### Game Performance Overview

FPS와 GPU 시간 등을 낮은 수집 비용으로 집계해 긴 게임 실행 구간의 성능 추이를 확인한다.

- Game Performance Overview
- Time Profiler
- Thermal State

### Leaks

메모리 할당 이력과 누수 검사 결과를 함께 확인해 누수된 메모리의 발생 지점을 찾는다.

- Allocations
- Leaks
- Points of Interest

### Logging

Unified Logging의 로그와 Signpost를 시간축에서 확인하며, 로그 아카이브 분석에도 사용한다.

- os_log
- os_signpost

### Metal System Trace

Metal 앱에서 GPU와 디스플레이까지 이어지는 작업 흐름을 추적해 렌더링 병목을 분석한다.

- Metal Application
- GPU
- Display
- Metal Resource Events
- Thermal State
- Time Profiler
- Hangs

### Network

HTTP 요청·응답과 네트워크 연결을 함께 살펴 통신 지연과 데이터 전송을 분석한다.

- HTTP Traffic
- Network Connections
- Points of Interest

### Power Profiler

앱의 CPU·GPU·네트워크·위치 서비스 활동 등이 전력 소비에 미치는 영향을 분석한다.

- Power Profiler
- Thermal State
- Time Profiler
- Network Connections
- Metal Performance Overview
- Location Energy Model

### Processor Trace

함수 실행 흐름과 스레드 상태를 함께 살펴 짧은 호출과 세부 실행 순서를 분석한다.

- Points of Interest
- Thread State Trace
- Processor Trace

### RealityKit Trace

visionOS의 프레임 처리와 장면 복잡도, CPU·GPU 활동을 함께 살펴 렌더링 성능을 분석한다.

- RealityKit Frames
- RealityKit Metrics
- Runloops
- Time Profiler
- Hangs
- Metal Application
- GPU

### Swift Concurrency

Task의 실행·중단과 Actor 경합을 CPU 작업에 연결해 동시성 코드의 병목을 찾는다.

- Swift Tasks
- Swift Actors
- Time Profiler
- Hangs

### SwiftUI

뷰 업데이트의 원인·빈도·시간을 CPU 작업 및 화면 끊김과 연결해 분석한다.

- SwiftUI
- Time Profiler
- Hangs
- Hitches

### System Trace

스레드 스케줄링, 시스템 호출, 가상 메모리 활동을 함께 살펴 실행 지연과 대기의 원인을 찾는다.

- Points of Interest
- System Load
- Thread State Trace
- Virtual Memory Trace
- System Call Trace
- Thermal State
- Time Profiler
- Hangs

### Tailspin

시간 기반 프로파일과 파일·디스크 I/O 정보를 함께 살펴 응답성 문제를 분석한다.

- Time Profiler
- Points of Interest
- Filesystem Suggestions
- Filesystem Activity
- Disk Usage
- Disk I/O Latency
- Hangs

### Time Profiler

CPU 호출 스택 샘플을 바탕으로 시간이 많이 드는 작업을 찾고 응답성·열 상태와 함께 살펴본다.

- Time Profiler
- Points of Interest
- Thermal State
- Hangs


구성 출처: Xcode의 `Instruments.app/Contents/Packages` 및 `Contents/Resources/templates` 아래 `.tracetemplate` 파일. 도구 설명은 패키지의 `Contents/Documentation`에 있는 Apple 내장 문서와 위 공식 레퍼런스를 참고했다.

## 측정 환경 준비

### Profile 설정

1. Xcode에서 측정할 앱의 Scheme과 실행 기기를 선택한다.
2. `Product > Scheme > Edit Scheme…`에서 **Profile**을 선택한다.
3. **Info**에서 Build Configuration을 확인한다. 기본 Profile 구성은 Release지만, 사용자 정의 Scheme이라면 직접 확인한다.
4. Instrument 선택을 실행 시점으로 미루려면 **Ask on Launch**를 선택한다.
5. **Arguments**에서 실행 인자와 환경 변수를 확인한다. 기본적으로 Run 설정을 사용하므로 측정용 입력이 의도한 값인지 살핀다.
6. 설정을 닫고 `Product > Profile`을 실행한다.

출처: [Xcode — Profile the performance and behavior of your app](https://help.apple.com/xcode/mac/current/en.lproj/devcc15e6912.html)

### Debug와 Release, 실기기와 시뮬레이터

Debug와 Release는 최적화 조건이 다르므로 성능 비교는 배포 조건에 가까운 Release를 기준으로 한다. 사용자 정의 컴파일러 옵션도 확인한다.

시뮬레이터는 Mac의 CPU·메모리·파일 시스템·발열 특성을 사용한다. 기본 조작과 경향 확인에 활용하되, 실제 기기에서의 성능은 실기기로 측정한다. Instruments 자체의 데이터 수집에도 자원이 필요하다.

출처: [Getting Started with Instruments — Profiling tips](https://developer.apple.com/videos/play/wwdc2019/411/)

## 녹화부터 저장까지

1. Template 선택 화면에서 **Time Profiler**를 선택한다.
2. 대상 기기와 앱 프로세스를 확인한다.
3. **Record**로 수집을 시작하고 관심 동작을 수행한 뒤 **Stop**으로 종료한다. Xcode에서 넘긴 앱은 Record 시 실행할 수 있다.
4. Timeline을 확대하고 관심 시간 범위를 드래그해 선택한다. 해당 범위로 Detail 데이터가 좁혀지는지 확인한다.
5. Time Profiler Track에서 호출 목록을 살핀다. 이는 모든 함수의 진입·종료 기록이 아니라 주기적으로 수집한 호출 스택 샘플이다.
6. `File > Save`로 `.trace` 문서를 저장한다. 저장한 문서는 다시 열어 분석하거나 공유할 수 있다.

확대는 화면의 시간축을 자세히 보는 조작이고, 시간 범위 선택은 분석 대상을 좁히는 조작이다. UI 명칭과 배치는 설치한 버전에 따라 다를 수 있다.

출처: [Getting Started with Instruments — UI 소개와 Time Profiler 실연](https://developer.apple.com/videos/play/wwdc2019/411/)

## 레퍼런스

- [Getting Started with Instruments — WWDC19](https://developer.apple.com/videos/play/wwdc2019/411/): UI 소개, Time Profiler 실연, 측정 환경 관련 설명.
- [Xcode — Profile the performance and behavior of your app](https://help.apple.com/xcode/mac/current/en.lproj/devcc15e6912.html): Scheme의 Profile 설정과 실행 절차.
