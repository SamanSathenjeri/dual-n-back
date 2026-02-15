import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Header
                HStack() {
                    Spacer()
                    Text("Dual N-Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                // Text("Home")
                //     .font(.largeTitle)
                //     .fontWeight(.bold)

                // Today progress ring
                HStack() {
                    Spacer()
                    BrainProgressView(
                        completed: viewModel.roundsCompletedToday,
                        goal: viewModel.dailyGoal
                    )
                    Spacer()
                }

                // Calendar history
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Progress")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))

                    HistoryGridView(history: viewModel.history)
                }
            }
            .padding()
        }
    }
}
