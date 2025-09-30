//
//  ContentView.swift
//  WhisperZen
//
//  Created by Vishwas B S on 30/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var quote: String = UserDefaults.standard.string(forKey: "lastQuote") ?? "Click below to see a quote."
    let quotes = [
        "Stay hungry, stay foolish.",
        "The best way to get started is to quit talking and begin doing.",
        "Success is not in what you have, but who you are."
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(quote)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .accessibilityLabel("Quote of the day")
                Button("New Quote") {
                    let newQuote = quotes.randomElement()!
                    quote = newQuote
                    UserDefaults.standard.set(newQuote, forKey: "lastQuote")
                }
                .buttonStyle(.borderedProminent)
                Button("Copy Quote") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(quote, forType: .string)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
