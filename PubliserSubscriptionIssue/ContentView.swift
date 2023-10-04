//
//  ContentView.swift
//  PubliserSubscriptionIssue
//
//  Created by Ilia Kolomeitsev on 04.10.2023.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var model: Model

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            model.publisherTrigger.toggle()
        }
    }
}

#Preview {
    ContentView()
}
