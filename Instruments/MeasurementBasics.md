# 측정 환경과 Instruments 기본 조작

[Instruments 로드맵](README.md)의 1단계 문서다. 목표는 앱 동작을 녹화하고, 관심 구간을 다시 찾아 설명하며, 측정 결과를 `.trace`로 보관하는 것이다.

## Instruments와 Profile

Instruments는 Xcode에 포함된 별도 성능 분석 앱이다. Xcode에서 `Product > Profile`을 선택하면 빌드한 앱을 Instruments로 분석할 수 있다. 실행 중인 프로세스를 Instruments에서 직접 선택하는 방법도 있다.

- **Template**: 분석 목적에 맞게 Instrument를 묶어 놓은 구성이다.
- **Instrument**: CPU 샘플 등 특정 데이터를 수집하는 도구다.
- **Track / Timeline**: 프로세스·스레드 등의 데이터를 시간축에 표시한다. 하나의 Instrument가 여러 Track을 제공할 수 있다.
- **Detail**: 선택한 Track과 시간 범위의 상세 데이터를 보여 준다.
- **Trace document**: 수집한 데이터와 분석 구성을 담으며, 저장 후 다시 열 수 있다.

출처: [Getting Started with Instruments — WWDC19](https://developer.apple.com/videos/play/wwdc2019/411/)

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

이 문서의 실습에서는 비교 조건을 다음처럼 고정한다.

| 항목 | 기록하거나 맞출 조건 |
| --- | --- |
| 빌드 | 코드 버전, Scheme, Release 여부 |
| 기기 | 모델, OS, Xcode 버전 |
| 입력 | 같은 데이터와 같은 사용자 동작 |
| 시작 상태 | 앱 재실행 여부, 로그인·캐시 상태 |
| 주변 조건 | 발열, 저전력 모드, 백그라운드 작업 |

## 녹화부터 저장까지

1. Template 선택 화면에서 **Time Profiler**를 선택한다.
2. 대상 기기와 앱 프로세스를 확인한다.
3. **Record**로 수집을 시작하고 관심 동작을 수행한 뒤 **Stop**으로 종료한다. Xcode에서 넘긴 앱은 Record 시 실행할 수 있다.
4. Timeline을 확대하고 관심 시간 범위를 드래그해 선택한다. 해당 범위로 Detail 데이터가 좁혀지는지 확인한다.
5. Time Profiler Track에서 호출 목록을 살핀다. 이는 모든 함수의 진입·종료 기록이 아니라 주기적으로 수집한 호출 스택 샘플이다.
6. `File > Save`로 `.trace` 문서를 저장하고 다시 열어 본다.

확대는 화면의 시간축을 자세히 보는 조작이고, 시간 범위 선택은 분석 대상을 좁히는 조작이다. UI 명칭과 배치는 설치한 버전에 따라 다를 수 있다.

출처: [Getting Started with Instruments — UI 소개와 Time Profiler 실연](https://developer.apple.com/videos/play/wwdc2019/411/)

## 실습: 같은 동작을 3회 기록하기

아래는 기본 조작을 익히기 위한 자체 실습 절차다. 측정할 iOS 앱을 사용한다. 이 단계에서는 성능 문제를 일부러 만들 필요가 없다.

### 1. 관찰할 동작 정하기

앱 실행부터 첫 화면 표시까지를 관찰한다. 추가 화면이 있다면 ‘첫 화면에서 버튼을 눌러 다음 화면으로 이동’처럼 한 가지 동작을 별도로 정해도 된다.

먼저 다음 내용을 적는다.

- 시작: 앱 실행 또는 특정 버튼 입력
- 끝: 관찰하려는 화면이 표시된 시점
- 준비 조건: 앱 종료 여부와 초기 데이터 상태

화면이 보였다는 사실과 CPU 사용량이 줄었다는 사실은 서로 다른 관찰이다. CPU 그래프만 보고 화면 표시 완료 시점을 확정하지 않는다. 정확한 경계 계측은 이후 Signpost 단계에서 다룬다.

### 2. 녹화하고 관심 구간 찾기

1. 정한 시작 상태로 앱을 준비한다.
2. 녹화를 시작하고 동작을 한 번 수행한다.
3. 화면 표시 후 녹화를 종료한다.
4. 관찰한 시점 주변의 Timeline을 확대한다.
5. 관심 범위를 선택하고 시작·끝 시간, 선택 이유, 보이는 호출 이름 하나를 기록한다.
6. 전체 범위로 돌아갔다가 같은 구간을 다시 찾아본다.

이때 기록하는 범위 길이는 **선택한 분석 구간의 길이**다. 계측으로 경계를 확인하지 않았다면 ‘정확한 화면 로딩 시간’이라고 쓰지 않는다.

### 3. 저장하고 반복하기

각 녹화를 `01-launch-run1.trace`, `01-launch-run2.trace`, `01-launch-run3.trace`처럼 구분해 저장한다. 매회 같은 준비 절차를 적용하고, 처음 실행한 결과와 캐시가 준비된 결과를 섞지 않는다.

| 회차 | 선택 구간 시작~끝 | 구간 길이 | 관찰한 호출·동작 | 조건 차이 |
| --- | --- | --- | --- | --- |
| 1 | 직접 기록 | 직접 기록 | 직접 기록 | 직접 기록 |
| 2 | 직접 기록 | 직접 기록 | 직접 기록 | 직접 기록 |
| 3 | 직접 기록 | 직접 기록 | 직접 기록 | 직접 기록 |

결과가 다르면 바로 평균으로 합치기보다 입력·시작 상태·구간 선택 기준이 같았는지 먼저 확인한다. 저장한 trace 하나를 다시 열어 기록한 구간과 호출을 찾으면 이번 실습을 마친다.

## 확인할 것

- [ ] Profile에 사용한 빌드 구성과 기기를 설명할 수 있다.
- [ ] Template, Instrument, Track, Detail을 구분할 수 있다.
- [ ] 녹화 시작·종료와 시간 범위 선택을 할 수 있다.
- [ ] 같은 동작을 3회 기록하고 조건 차이를 남겼다.
- [ ] 저장한 trace를 다시 열어 관심 구간을 찾을 수 있다.

## 레퍼런스

- [Getting Started with Instruments — WWDC19](https://developer.apple.com/videos/play/wwdc2019/411/): UI 소개, Time Profiler 실연, 측정 환경 관련 설명.
- [Xcode — Profile the performance and behavior of your app](https://help.apple.com/xcode/mac/current/en.lproj/devcc15e6912.html): Scheme의 Profile 설정과 실행 절차.
- [Apple Instruments Tutorials](https://developer.apple.com/tutorials/instruments): 후속 실습을 찾기 위한 공식 튜토리얼 진입점.
