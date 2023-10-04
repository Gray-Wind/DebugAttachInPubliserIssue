//
//  PubliserSubscriptionIssueApp.swift
//  PubliserSubscriptionIssue
//
//  Created by Ilia Kolomeitsev on 04.10.2023.
//

import SwiftUI

let modelTracker = ModelTracker()

@main
struct PubliserSubscriptionIssueApp: App {

    @StateObject private var model = Model()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .onAppear {
                    modelTracker.model = model
                }
        }
    }
}
