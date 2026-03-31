# AI Assist 활용 프롬프트

본 프로젝트에서 AI(ClaudeCode)를 활용하여 개발한 내용을 정리합니다.

---

## 1. 프로젝트 구조 설계

### 프롬프트
```
SwiftUI + TCA 아키텍처 기반으로 GitHub Repository 검색 앱을 개발하려고 합니다.
Feature / Common / Resource로 모듈을 분리하고, 확장성을 고려한 폴더 구조를 설계해주세요.
```

### 결과
- TCA(The Composable Architecture) 기반 폴더 구조 설계
- Feature / Common / Resource 등 모듈별 분리 구조 확립

---

## 2. 공통 모듈 구현

### 프롬프트
```
여러 Feature에서 공통으로 사용할 수 있는 Base 모듈을 설계해주세요.
로딩, 알림 등 공통 상태를 BaseStore로 관리하고, NavigationStack 기반의 화면 전환 구조를 포함해주세요.
```

### 결과
- BaseStore: 공통 로딩, 알림 상태 관리
- BaseView: 제네릭 컨테이너 (NavigationBar, 로딩/알림 오버레이)
- NavigationAction 패턴을 통한 push/pop/setRoot 네비게이션

---

## 3. 네트워크 레이어 구현

### 프롬프트
```
Moya 기반의 공통 네트워크 레이어를 구축하려고 합니다.
TCA의 DependencyKey 패턴을 활용하여 APIClient를 의존성으로 주입하고,
async/await를 지원하는 구조로 설계해주세요.
```

### 결과
- Moya + withCheckedThrowingContinuation 기반 async/await 네트워크 클라이언트
- DependencyKey를 활용한 TCA 의존성 주입 패턴 적용

---

## 4. 검색 화면 기능 구현

### 프롬프트
```
검색 화면에 다음 기능을 구현해주세요:
1. 검색 입력 바 (포커스 관리, 취소 버튼)
2. 최근 검색어 목록 (최대 10개, 날짜순 정렬, 개별/전체 삭제, UserDefaults 영속성)
3. 입력 중 최근 검색어 기반 자동완성
각 View는 별도 파일로 분리하여 재사용 가능하도록 구성해주세요.
```

### 결과
- SearchBarView: 검색 입력 바 (포커스 관리, 취소 버튼)
- RecentSearchListView: 최근 검색어 목록 (개별/전체 삭제, UserDefaults 영속성)
- AutoCompleteListView: 입력 중 최근 검색어 필터링 자동완성

---

## 5. 검색 결과 및 페이지네이션

### 프롬프트
```
검색 결과를 리스트로 표시하고, 페이징처리 구현해주세요.
스크롤 중에 다음 페이지를 미리 호출(prefetch)하고,
하단에 로딩 인디케이터가 매 페이지 로딩 시마다 정상적으로 노출되도록 해주세요.
```

### 결과
- SearchResultListView: 검색 결과 리스트 (썸네일, 이름, 소유자)
- 듀얼 페이지네이션: threshold 기반 prefetch (끝에서 7개 전) + ProgressView onAppear
- hasMorePages 플래그를 통한 ProgressView 노출 제어

---

## 6. WebView 연동

### 프롬프트
```
검색 결과에서 저장소를 선택하면 WebView로 이동하는 기능을 구현해주세요.
스와이프 백 제스처 시 WebView 내 히스토리 뒤로 가기가 우선되도록 처리해주세요.
```

### 결과
- WKWebView 기반 상세 화면 (allowsBackForwardNavigationGestures)
- UINavigationController Extension으로 커스텀 NavigationBar 환경에서 스와이프 백 지원

---

## 7. 버그 수정 및 트러블슈팅

### 프롬프트
```
다음 이슈들의 원인을 분석하고 해결 방안을 제시해주세요:
1. 검색 API가 중복으로 호출되는 문제
2. 자동완성 리스트 최초 클릭이 동작하지 않는 문제
3. ScrollView의 스크롤 offset이 감지되지 않는 문제
```

### 결과
- API 중복 요청: reducer의 default case가 모든 액션을 캐치하는 문제 → 명시적 case 처리
- 자동완성 클릭 무시: submitSearch가 searchTextChanged를 트리거하여 isSearched 초기화 → isSubmitting 플래그 추가
- 스크롤 offset: GeometryReader를 LazyVStack의 .background로 이동하여 해결

---

## 8. 단위 테스트

### 프롬프트
```
TCA의 TestStore를 활용하여 SearchStore의 단위 테스트를 작성해주세요.
Mock 데이터는 JSON 파일로 분리하여 관리하고,
모든 액션에 대해 과하거나 부족함 없이 적절한 수준의 테스트 케이스를 작성해주세요.
```

### 결과
- TCA TestStore 기반 14개 테스트 케이스 작성
- MockLoader: JSON 파일 기반 목 데이터 로더
- 테스트 범위: onAppear, searchTextChanged, submitSearch, deleteRecentSearch, searchResponse, loadNextPage, nextPageResponse, selectRepository

---

## 9. 이미지 캐시 개선

### 프롬프트
```
AsyncImage와 Kingfisher의 캐시 전략 차이점을 비교하고, Kingfisher로 교체해주세요.
```

### 결과
- AsyncImage → Kingfisher(KFImage)로 교체
- 메모리/디스크 캐시 자동 적용으로 스크롤 시 이미지 깜빡임 방지

## 10. 코드검수

### 프롬프트
```
현재 프로젝트의 전체 소스코드를 분석하여 문제점이나 개선할 부분을 찾아주세요.                                     
구조적 문제, 잠재적 버그, 성능 이슈 등이 있으면 알려주고 없으면 없다고 해도 됩니다. 
```

### 결과
- WebView updateUIView에서 불필요한 reload 호출 발견 → makeUIView로 이동하여 해결
