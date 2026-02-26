import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            LibraryRootView()
                .tabItem {
                    Label("動作庫", systemImage: "books.vertical")
                }

            PlannerView()
                .tabItem {
                    Label("快速排程", systemImage: "calendar.badge.plus")
                }

            DashboardView()
                .tabItem {
                    Label("總覽", systemImage: "chart.bar.fill")
                }
        }
    }
}
