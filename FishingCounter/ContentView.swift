//
//  ContentView.swift
//  FishingCounter
//
//  Created by Kei Kitamura on 2025/02/02.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
}

struct CatchRecord: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let location: CLLocationCoordinate2D?
}

struct ContentView: View {
    @State private var fishCount = 0
    @State private var catchHistory: [CatchRecord] = []
    @ObservedObject private var locationManager = LocationManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("🎣 釣った魚の数")
                .font(.largeTitle)
                .bold()

            Text("\(fishCount)")
                .font(.system(size: 80))
                .bold()

            Button(action: {
                fishCount += 1
                let newRecord = CatchRecord(date: Date(), count: fishCount, location: locationManager.currentLocation)
                catchHistory.append(newRecord)
            }) {
                Text("+1 カウント")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                if fishCount > 0 {
                    fishCount -= 1
                }
            }) {
                Text("-1 修正")
                    .font(.title2)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            List(catchHistory) { record in
                VStack(alignment: .leading) {
                    Text("日付: \(record.date.formatted())")
                    Text("カウント: \(record.count)")
                    if let location = record.location {
                        Text("位置: \(location.latitude), \(location.longitude)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }
}
