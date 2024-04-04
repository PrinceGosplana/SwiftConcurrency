//
//  SendableView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 04.04.2024.
//

import SwiftUI

actor CurrentUserManager {

    func updateDatabase(userInfo: MyClassUserInfo) {

    }
}

struct MyUserInfo: Sendable {
    let name: String
}

final class MyClassUserInfo: @unchecked Sendable {
    private var name: String
    let queue = DispatchQueue(label: "com.MyClassUserInfo")

    init(name: String) {
        self.name = name
    }

    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

final class SendableViewModel: ObservableObject {
    let manager: CurrentUserManager

    init(manager: CurrentUserManager) {
        self.manager = manager
    }

    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableView: View {

    @StateObject private var viewModel = SendableViewModel(manager: CurrentUserManager())

    var body: some View {
        Text("Hello, World!")
            .task {

            }
    }
}

#Preview {
    SendableView()
}
