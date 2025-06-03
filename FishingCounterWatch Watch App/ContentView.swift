import SwiftUI
import CoreLocation
// ↓必要に応じてファイル分割時はmodule importが必要
// import Models
// import HistoryView

/// Apple Watch用の釣果カウント画面
/// ボタン操作で釣果を記録・保存し、履歴画面に遷移できる
struct WatchContentView: View {
    /// 現在の合計釣果数（画面に表示するためのカウント）
    @State private var fishCount = 0

    /// 時刻ごとの釣果履歴（FishRecordの配列）
    @State private var fishRecords: [FishRecord] = []

    /// エラーメッセージを表示するための状態
    @State private var errorMessage: String?

    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            List {
                // 現在の釣果数を表示
                Text("釣果：\(fishCount)匹")
                    .font(.title3)
                    .listRowBackground(Color.clear)
                    .accessibilityLabel("現在の釣果は\(fishCount)匹です")
                    .accessibilityHint("釣果の合計数が表示されています")

                // +1ボタン
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

                // リセットボタン
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

                // 「履歴を見る」ボタン（別画面に遷移）
                NavigationLink(destination: HistoryView(records: fishRecords)) {
                    Text("履歴を見る")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .listRowBackground(Color.clear)

                // エラーメッセージの表示
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

    /// 現在の時刻をもとに新しい釣果記録を追加する
    func addRecord() {
        let timestamp = Date()
        
        // 位置情報が取得できない場合でも記録を保存
        let latitude = locationManager.currentLocation?.coordinate.latitude ?? 0.0
        let longitude = locationManager.currentLocation?.coordinate.longitude ?? 0.0
        
        let newRecord = FishRecord(
            timestamp: timestamp,
            count: 1,
            latitude: latitude,
            longitude: longitude
        )
        fishRecords.append(newRecord)
        
        // 位置情報のエラーがある場合は表示
        if let error = locationManager.locationError {
            errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)\n設定アプリで位置情報の許可を確認してください。"
        } else if locationManager.currentLocation == nil {
            errorMessage = "位置情報を取得できませんでした。\n位置情報の取得を待っています..."
        } else {
            errorMessage = nil
        }
        
        // デバッグ用：追加された記録の確認
        print("新しい記録を追加: 時刻=\(timestamp), 位置=(\(latitude), \(longitude))")
    }

    /// 履歴をUserDefaultsに保存する（JSON形式）
    func saveRecords() {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(fishRecords)
            UserDefaults.standard.set(encoded, forKey: "fishRecords")
            // 現在の釣果数も保存
            UserDefaults.standard.set(fishCount, forKey: "fishCount")
            errorMessage = nil
            
            // デバッグ用：保存されたデータの確認
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

    /// UserDefaultsから履歴を読み込み、配列に復元する
    func loadRecords() {
        do {
            // 保存された釣果数を読み込む
            fishCount = UserDefaults.standard.integer(forKey: "fishCount")
            print("読み込んだ釣果数: \(fishCount)匹")
            
            if let data = UserDefaults.standard.data(forKey: "fishRecords") {
                let decoder = JSONDecoder()
                fishRecords = try decoder.decode([FishRecord].self, from: data)
                errorMessage = nil
                
                // デバッグ用：読み込んだデータの確認
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
