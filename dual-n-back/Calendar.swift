import Foundation

extension Calendar {
    func daysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = self.dateInterval(of: .month, for: date) else {
            return []
        }

        return stride(
            from: monthInterval.start,
            to: monthInterval.end,
            by: 60 * 60 * 24
        ).map { $0 }
    }
}
