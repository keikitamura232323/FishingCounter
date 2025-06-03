import SwiftUI

/// 釣果履歴を表示する画面
struct HistoryView: View {
    /// 表示する釣果記録の配列
    let records: [FishRecord]
    
    /// 日付フォーマッター（staticで定義）
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    var body: some View {
        List {
            ForEach(records) { record in
                VStack(alignment: .leading) {
                    Text(Self.dateFormatter.string(from: record.timestamp))
                        .font(.caption)
                    Text("\(record.count)匹")
                        .font(.body)
                }
            }
        }
        .navigationTitle("履歴")
    }
}

/// 1件分の釣果記録を表示する行
private struct RecordRow: View {
    let record: FishRecord
    let dateFormatter: DateFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(dateFormatter.string(from: record.timestamp)) に \(record.count) 匹")
                .font(.caption2)
                .accessibilityLabel("\(dateFormatter.string(from: record.timestamp))に\(record.count)匹釣れました")

            if let url = URL(string: record.mapURL) {
                Link("iPhoneからMapを開く", destination: url)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .accessibilityLabel("iPhoneからMapを開く")
            }
        }
        .listRowBackground(Color.clear)
    }
}

