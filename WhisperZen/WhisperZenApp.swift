//
//  WhisperZenApp.swift
//  WhisperZen
//
//  Created by Vishwas B S on 30/09/25.
//

import SwiftUI

@main
struct WhisperZenApp: App {
    var body: some Scene {
            MenuBarExtra("WhisperZen", systemImage: "quote.bubble") {
                ContentView()
                    .frame(width: 320, height: 180)
            }
        }
}
