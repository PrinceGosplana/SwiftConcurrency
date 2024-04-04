//
//  ActorыView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 04.04.2024.
//

import SwiftUI

actor MyDataManager {
    static let instance = MyDataManager()
    private init() {}

    var data: [String] = []

    func getRandomData() -> String? {
        data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }

    nonisolated func getSaveData() -> String {
        "Non isolated"
    }
}

struct HomeView: View {

    let manager = MyDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.mint.opacity(0.3).ignoresSafeArea()

            Text(text)
                .font(.headline)
        }
        .onAppear {
            let newString = manager.getSaveData()
            Task {
                let non = await manager.getRandomData()
            }
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct BrowseView: View {

    let manager = MyDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.indigo.opacity(0.3).ignoresSafeArea()

            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct ActorыView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                        .tint(.white)
                }
        }

    }
}

#Preview {
    ActorыView()
}
