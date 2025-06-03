import SwiftUI
import CoreLocation

/// 釣果の1件分の記録データ（時刻・匹数・位置情報）
/// UserDefaultsに保存するためにCodableに準拠
struct FishRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date        // 釣れた時刻
    let count: Int               // この記録で釣れた匹数（通常1匹）
    let latitude: Double         // 緯度（Google Maps用）
    let longitude: Double        // 経度（Google Maps用）
    let mapURL: String           // Google Mapsで開けるURL
    
    init(timestamp: Date, count: Int, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.count = count
        self.latitude = latitude
        self.longitude = longitude
        self.mapURL = "https://www.google.com/maps?q=\(latitude),\(longitude)"
    }
}

/// 現在地を取得するためのロケーションマネージャ
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationError: Error?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location
                self.locationError = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error
        }
    }
} 