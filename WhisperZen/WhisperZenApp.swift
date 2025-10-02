//
//  WhisperZenApp.swift
//  WhisperZen
//
//  Created by Vishwas B S on 30/09/25.
//

import SwiftUI

@main
struct WhisperZenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("WhisperZen", id: "main") {
            MainWindowView()
        }
    }
}
