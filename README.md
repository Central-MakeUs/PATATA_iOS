# Patata ReadMe

![Image](https://github.com/user-attachments/assets/93f1ee85-63c0-49a5-ab21-af7b47d035ed)

## 앱의 기능

- 스팟 게시물 조회
- 주변 스팟 조회 (지도를 통해서 내가 저장한 장소및 주변 장소를 볼 수 있습니다.)
- 스팟 검색 (서치바를 통해서 원하는 장소를 검색할 수 있습니다)
- 스팟 스크랩

### 기술 스택

- Swift6, SwiftUI, Combine
- TCA, TCACoordinators
- AuthenticationServices, GoogleSignIn
- KingFisher, NMapsMap
- Realm, UserDefaults
- Alamofire

## 고려한 사항
##  Custom Infinite Carousel

`ScrollView`, `DragGesture`, `Geometry`, `offset`, `scaleEffect`를 조합하여  
유저가 현재 보고 있는 카드가 자연스럽게 강조되며, **좌우 무한 순환**이 가능한 캐러셀을 구현했습니다.

드래그 방향에 따라 카드 스케일이 부드럽게 전환되며,  
좌우 끝에 도달하면 콘텐츠가 순환되어 **끊김 없는 UX**를 제공합니다.

> 현재 카드 확대 + 양옆 카드 축소 효과를 실시간 적용하는 핵심 로직:

```swift
let scale: CGFloat = {
    let isCurrent = normalizedAdjustedIndex == normalizedCurrentIndex
    let isNext = normalizedAdjustedIndex == (normalizedCurrentIndex + 1) % totalCount
    let isPrev = normalizedAdjustedIndex == (normalizedCurrentIndex - 1 + totalCount) % totalCount
    
    if isCurrent {
        return scaleEffect - (abs(progress) * (scaleEffect - 1.0))
    } else if (isNext && dragOffset < 0) || (isPrev && dragOffset > 0) {
        return 1.0 + (abs(progress) * (scaleEffect - 1.0))
    }
    return 1.0
}()

```

> 위치 업데이트는 AsyncStream을 활용하여 비동기적으로 처리하였으며, 위치 정보가 없을 경우 혹은 에러 발생 시, 기본 좌표를 반환하여 안정적인 동작을 보장하였습니다.
```swift
final class LocationManager: NSObject, Sendable {
    
    private override init() {
        …
    }
    
    func checkLocationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            PermissionManager.shared.checkLocationPermission { hasPermission in
                continuation.resume(returning: hasPermission)
                
                if let coordinate = self.locationManager.location?.coordinate {
                    
                    let coord = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    Task {
                        do {
                            try await self.createCoord(coord: coord)
                        } catch {
                           …
                            self.locationUpdateSubject.send(defaultCoordinate)
                        }
                    }
                    
                } else {
                    let defaultCoordinate = Coordinate(
                        latitude: self.defaultLocation.latitude,
                        longitude: self.defaultLocation.longitude
                    )

                    Task {
                        do {
                            try await self.createCoord(coord: defaultCoordinate)
                        } catch {
                           …
                            self.locationUpdateSubject.send(defaultCoordinate)
                        }
                    }
                    
                }
            }
        }
    }
    
    func getLocationUpdates() -> AsyncStream<Coordinate> {
        return AsyncStream { continuation in
            Task {
                let subscription = locationUpdateSubject
                    .sink { coordinate in
                        continuation.yield(coordinate)
                    }
                
                await cancelStoreActor.withValue { value in
                    value.insert(subscription)
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.cancelStoreActor.resetValue()
                    continuation.finish()
                }
            }
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

```


## Realm Actor화
> Realm은 다중 쓰레드에서 접근시 충돌이 날 수 있으며 앱이 동시에 여러 쓰레드에서 접근할 가능성이 있다고 생각하여 프로퍼티 및 메서드에 대한 모든 엑세스를 직렬화하는 Actor를 도입하였습니다.

```swift
final actor DataSourceActor {
    …
    
    func coordCreate(coord: Coordinate) async throws(RealmError) -> Void {
       …
    }
    
    func fetch() async -> Coordinate {
        …
    }
}
```

## 네트워크 단절
> 실시간으로 네트워크의 상태를 감지할 수 있어 단절 상황일때 사용자 경험을 해치지 않도록 감지하는 NWPathManager를 구현하였습니다.
```swift
final class NWPathMonitorManager: @unchecked Sendable {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkManager")
    private let connectionTypeSubject = PassthroughSubject<ConnectionType, Never>()
    private let currentConnectionTrigger = CurrentValueSubject<Bool, Never> (true)
    
    static let shared = NWPathMonitorManager()
    private init () {}
    
    enum ConnectionType {
        case cellular
        case ethernet
        …
    }
    
    func start() {
        startMonitoring()
        #if DEBUG
        print(#function)
        #endif
    }
    
    func getToConnectionType() -> AnyPublisher<ConnectionType, Never> {
        return connectionTypeSubject.eraseToAnyPublisher()
    }
    
    func getToConnectionTrigger() -> AsyncStream<Bool> {
        return AsyncStream { [weak self] continuation in
            guard let weakSelf = self else { return }
            
            weakSelf.monitor.pathUpdateHandler = { path in
                Task {
                    …
                }
            }
        }
    }
    
    func stop() {
        monitor.cancel()
        …
    }
    
}

extension NWPathMonitorManager {
    
    private func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    private func updateHandler(path: NWPath) {
        getConnectionType(path: path)
        …
    }

    
    private func getConnectionType(path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionTypeSubject.send(.wifi)
        } else if path.usesInterfaceType(.cellular) {
            connectionTypeSubject.send(.cellular)
        }…
    }
    
    private func networkConnectStatus(path: NWPath) -> Bool {
        return path.status == .satisfied
    }
}
```

## 트러블 슈팅

## 디지털 풍화 현상

### 문제 상황

> 해당 앱은 풍경 사진만 다루므로, **손실 압축 방식(JPEG)을 선택**하여 파일 크기를 줄였습니다. <br>
> 하지만 기존 방식에서는 **while문을 사용하여 0.1 단위로 압축률을 조정**하면서, 목표 용량에 도달할 때까지 반복했습니다.<br>
> 이 과정에서 **디지털 풍화 현상(압축에 의해 사진의 품질이 점진적으로 저하되는 현상)이 발생**했고, 압축 속도도 느렸습니다. 

### 해결 방법
> 이진 탐색 알고리즘을 적용하여 압축률을 세밀하게 조정하였습니다.<br>
> 이진 탐색은 log(n)의 시간 복잡도를 가지므로 기존 방식보다 더 빠르게 적절한 압축 품질을 찾을 수 있었습니다.<br>

### 이진 탐색 적용 코드
```swift
private func binarySearchCompression(for image: UIImage) async -> Data? {
    var low: CGFloat = 0.1
    var high: CGFloat = 1.0
    var bestData: Data? = nil
    
    while high - low > 0.05 {
        let mid = (low + high) / 2
        guard let compressedData = image.jpegData(compressionQuality: mid) else { return nil }
        
        if Int64(compressedData.count) > maxImageSize {
            high = mid
        } else {
            low = mid
            bestData = compressedData
        }
    }
    
    return bestData
}
```

## 네이버 지도 최적화

### 문제 상황

> 네이버 지도(`NMFNaverMapView`)를 `UIViewRepresentable`을 통해 SwiftUI에서 사용했을 때,  
`updateUIView`가 빈번하게 호출되면서 **마커 생성 및 초기화가 과도하게 반복**되는 문제가 발생했습니다.
> - 불필요한 연산 증가: `updateUIView`에서 마커를 계속 생성/초기화하면서 **성능 저하** 발생
> - 마커 초기화 문제: 기존 마커가 완전히 제거되지 않고 **중복 마커가 계속 쌓이는 현상 발생**

### 문제 코드
```swift
struct UIMapView: UIViewRepresentable {
    
    func makeCoordinator() -> NaverMapManager {
        …
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        …
    }
    
    // ❌ `updateUIView`에서 마커를 추가 및 초기화
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        moveToCamera(coord: mapState.coord, uiView: uiView)

        Task {
            …
        }
        
        await MainActor.run {
            clearMarkers(mapState: mapState)
            mapState.currentMarkers = newMarkers
            mapState.currentMarkers.forEach { $0.mapView = uiView.mapView }
        }
    }
}
```

 
### 해결 방법

> 지도 및 마커 관리를 별도의 매니저(NaverMapManager)로 분리<br>
> 모든 작업을 updateUIView에서 처리하지 않고 매니저에서 **카메라 이동 및 `MBRCoordinates` 값은 `PassthroughSubject`를 활용**하여 이벤트 흐름을 전달하도록 처리하였습니다 .

```swift
struct UIMapView: UIViewRepresentable {
    let mapManager: NaverMapManager
    
    func makeCoordinator() -> NaverMapManager {
        mapManager
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        return context.coordinator.getNaverMapView()
    }
    
    // ✅ `updateUIView`는 비워두고, 매니저에서 직접 관리
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) { }
}  final class NaverMapManager: NSObject, ObservableObject, NMFMapViewTouchDelegate, CLLocationManagerDelegate {

    let view = NMFNaverMapView(frame: .zero)
    
    @Published var mbrLocation: MBRCoordinates = MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0))
    @Published var currentMarkers: [NMFMarker] = []
    @Published var markerImages: [String: NMFOverlayImage] = [:]
    
    let mbrLocationPass: PassthroughSubject<MBRCoordinates, Never> = .init()
    let cameraIdlePass: PassthroughSubject<Coordinate, Never> = .init()
    let moveCameraPass: PassthroughSubject<Void, Never> = .init()
    let markerIndexPass: PassthroughSubject<Int, Never> = .init()
    
    // MARK: - 초기화
    override init() {
        super.init()
        setupMapView()
    }
    
    private func setupMapView() {
        view.showZoomControls = false
        view.mapView.positionMode = .normal
        view.mapView.zoomLevel = 17
        view.mapView.addCameraDelegate(delegate: self)
    }
    
    func getNaverMapView() -> NMFNaverMapView {
        return view
    }
    
    // MARK: - 마커 관리
    func updateMarkers(markers: [MapSpotEntity]) {
        Task {
            let newMarkers = markers.enumerated().map { index, marker in
                createMarker(
                   …
                )
            }
            
            await MainActor.run {
                clearCurrentMarkers()
                currentMarkers = newMarkers
                currentMarkers.forEach { $0.mapView = view.mapView }
            }
        }
    }
    
    @MainActor
    func moveCamera(coord: Coordinate) async -> MBRCoordinates {
        …
    }
    
    func moveCamera(coord: Coordinate) {
        ...
    }
    
    func clearCurrentMarkers() {
        …
    }
    
    private func createMarker(lat: Double, lng: Double, category: String, index: Int) -> NMFMarker {
        …
    }
}  extension NaverMapManager: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        …
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let currentCoord = Coordinate(
            …
        )
        
        let mbrCoord = MBRCoordinates(
            ...
        )

        mbrLocationPass.send(mbrCoord)
        cameraIdlePass.send(currentCoord)
    }
}
```

