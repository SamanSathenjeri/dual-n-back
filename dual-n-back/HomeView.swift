import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Header
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Today progress ring
                BrainProgressView(
                    completed: viewModel.roundsCompletedToday,
                    goal: viewModel.dailyGoal
                )

                // Calendar history
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Progress")
                        .font(.headline)

                    HistoryGridView(history: viewModel.history)
                }
            }
            .padding()
        }
    }
}
