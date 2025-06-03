//
//  ContentView.swift
//  FishingCounter
//
//  Created by Kei Kitamura on 2025/05/21.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var fishCount = 0
    @State private var fishRecords: [FishRecord] = []
    @State private var errorMessage: String?
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            List {
                Text("釣果：\(fishCount)匹")
                    .font(.title3)
                    .listRowBackground(Color.clear)
                    .accessibilityLabel("現在の釣果は\(fishCount)匹です")
                    .accessibilityHint("釣果の合計数が表示されています")

                Button(action: {
                    fishCount += 1
                    addRecord()
                    saveRecords()
                }) {
                    Text("+1")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
                .listRowBackground(Color.clear)
                .accessibilityLabel("釣果を1匹増やす")
                .accessibilityHint("このボタンを押すと、釣果が1匹増えます")

                Button(action: {
                    fishCount = 0
                    fishRecords.removeAll()
                    saveRecords()
                }) {
                    Text("リセット")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.bordered)
                .listRowBackground(Color.clear)
                .accessibilityLabel("釣果をリセット")
                .accessibilityHint("このボタンを押すと、釣果が0にリセットされ、履歴が削除されます")

                NavigationLink(destination: HistoryView(records: fishRecords)) {
                    Text("履歴を見る")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .listRowBackground(Color.clear)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption2)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 30)
            .onAppear {
                loadRecords()
                fishCount = fishRecords.reduce(0) { $0 + $1.count }
            }
        }
    }

    func addRecord() {
        let timestamp = Date()
        let latitude = locationManager.currentLocation?.coordinate.latitude ?? 0.0
        let longitude = locationManager.currentLocation?.coordinate.longitude ?? 0.0
        let newRecord = FishRecord(
            timestamp: timestamp,
            count: 1,
            latitude: latitude,
            longitude: longitude
        )
        fishRecords.append(newRecord)
        if let error = locationManager.locationError {
            errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)\n設定アプリで位置情報の許可を確認してください。"
        } else if locationManager.currentLocation == nil {
            errorMessage = "位置情報を取得できませんでした。\n位置情報の取得を待っています..."
        } else {
            errorMessage = nil
        }
        print("新しい記録を追加: 時刻=\(timestamp), 位置=(\(latitude), \(longitude))")
    }

    func saveRecords() {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(fishRecords)
            UserDefaults.standard.set(encoded, forKey: "fishRecords")
            UserDefaults.standard.set(fishCount, forKey: "fishCount")
            errorMessage = nil
            if let savedData = UserDefaults.standard.data(forKey: "fishRecords"),
               let decodedRecords = try? JSONDecoder().decode([FishRecord].self, from: savedData) {
                print("保存されたデータ: \(decodedRecords.count)件")
                for record in decodedRecords {
                    print("時刻: \(record.timestamp), 匹数: \(record.count)")
                }
            }
            print("保存された釣果数: \(fishCount)匹")
        } catch {
            errorMessage = "データの保存に失敗しました: \(error.localizedDescription)"
            print("保存エラー: \(error)")
        }
    }

    func loadRecords() {
        do {
            fishCount = UserDefaults.standard.integer(forKey: "fishCount")
            print("読み込んだ釣果数: \(fishCount)匹")
            if let data = UserDefaults.standard.data(forKey: "fishRecords") {
                let decoder = JSONDecoder()
                fishRecords = try decoder.decode([FishRecord].self, from: data)
                errorMessage = nil
                print("読み込んだデータ: \(fishRecords.count)件")
                for record in fishRecords {
                    print("時刻: \(record.timestamp), 匹数: \(record.count)")
                }
            } else {
                print("保存されたデータがありません")
                fishRecords = []
            }
        } catch {
            errorMessage = "データの読み込みに失敗しました: \(error.localizedDescription)"
            print("読み込みエラー: \(error)")
            fishRecords = []
        }
    }
}

#Preview {
    ContentView()
}
