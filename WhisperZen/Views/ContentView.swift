//
//  ContentView.swift
//  WhisperZen
//
//  Professional Quote Display with Modern Design
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var quoteManager = QuoteManager.shared
    @StateObject private var preferences = UserPreferences.shared
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingFavorites = false
    @State private var isAnimating = false
    @State private var showCopiedFeedback = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with controls
                headerView
                
                // Main quote display
                quoteDisplayView
                
                // Action buttons
                actionButtonsView
            }
        }
        .preferredColorScheme(preferences.appearanceMode.colorScheme)
        .onAppear {
            startBreathingAnimation()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHistory) {
            QuoteHistoryView()
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView()
        }
    }
    
    private var backgroundGradient: some View {
        let baseGradient = LinearGradient(
            gradient: Gradient(colors: [
                .purple.opacity(0.8),
                .blue.opacity(0.9),
                .cyan.opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return ZStack {
            baseGradient
            
            // Animated overlay for breathing effect
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(isAnimating ? 0.1 : 0.05),
                    Color.clear
                ]),
                center: .center,
                startRadius: isAnimating ? 100 : 50,
                endRadius: isAnimating ? 300 : 200
            )
            .animation(
                .easeInOut(duration: 3)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            // Category indicator
            CategoryBadge(category: quoteManager.currentQuote.category)
            
            Spacer()
            
            HStack(spacing: 12) {
                // Loading indicator
                if quoteManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                }
                
                // Favorite button
                Button(action: { toggleFavorite() }) {
                    Image(systemName: quoteManager.isFavorite(quoteManager.currentQuote) ? "heart.fill" : "heart")
                        .foregroundColor(quoteManager.isFavorite(quoteManager.currentQuote) ? .pink : .white.opacity(0.7))
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(quoteManager.isFavorite(quoteManager.currentQuote) ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: quoteManager.isFavorite(quoteManager.currentQuote))
                
                // Menu button
                Menu {
                    Button("History", systemImage: "clock") { showingHistory = true }
                    Button("Favorites", systemImage: "heart") { showingFavorites = true }
                    Divider()
                    Button("Settings", systemImage: "gear") { showingSettings = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                }
                .menuStyle(.borderlessButton)
                .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var quoteDisplayView: some View {
        VStack(spacing: 16) {
            // Quote text with typing animation
            Text(quoteManager.currentQuote.displayText)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .scaleEffect(isAnimating ? 1.02 : 1.0)
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .accessibilityLabel("Current quote: \(quoteManager.currentQuote.content)")
            
            // Error message if any
            if let error = quoteManager.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // New Quote Button
                Button(action: { generateNewQuote() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(rotationAngle))
                        Text("New Quote")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                
                // Copy Button
                Button(action: { copyQuote() }) {
                    HStack(spacing: 8) {
                        Image(systemName: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                            .foregroundColor(showCopiedFeedback ? .green : .white)
                        Text(showCopiedFeedback ? "Copied!" : "Copy")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(showCopiedFeedback ? .green : .white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCopiedFeedback)
            }
            
            // Online quote button (if enabled)
            if preferences.useOnlineQuotes {
                Button(action: { fetchOnlineQuote() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text("Get Online Quote")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(quoteManager.isLoading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
    
    private func generateNewQuote() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            rotationAngle += 360
        }
        
        quoteManager.nextQuote()
        
        if preferences.soundEnabled {
            NSSound(named: "Ping")?.play()
        }
    }
    
    private func copyQuote() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(quoteManager.currentQuote.shareText, forType: .string)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showCopiedFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showCopiedFeedback = false
            }
        }
        
        if preferences.soundEnabled {
            NSSound(named: "Pop")?.play()
        }
    }
    
    private func toggleFavorite() {
        quoteManager.toggleFavorite(quoteManager.currentQuote)
        
        if preferences.soundEnabled {
            NSSound(named: quoteManager.isFavorite(quoteManager.currentQuote) ? "Hero" : "Basso")?.play()
        }
    }
    
    private func fetchOnlineQuote() {
        Task {
            await quoteManager.fetchOnlineQuote()
        }
    }
}

struct CategoryBadge: View {
    let category: QuoteCategory
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 12, weight: .medium))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 280)
}