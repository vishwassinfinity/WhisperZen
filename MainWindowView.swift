import SwiftUI

struct MainWindowView: View {
    @StateObject private var preferences = UserPreferences.shared
    
    var body: some View {
        ContentView()
            .frame(
                width: preferences.popoverSize.dimensions.width,
                height: preferences.popoverSize.dimensions.height
            )
            .preferredColorScheme(preferences.appearanceMode.colorScheme)
    }
}

#Preview {
    MainWindowView()
}
