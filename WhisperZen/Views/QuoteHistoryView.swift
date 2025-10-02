//
//  QuoteHistoryView.swift
//  WhisperZen
//
//  Quote History Interface
//

import SwiftUI

struct QuoteHistoryView: View {
    @StateObject private var quoteManager = QuoteManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: QuoteCategory?
    
    var filteredQuotes: [Quote] {
        var quotes = quoteManager.quoteHistory
        
        if !searchText.isEmpty {
            quotes = quotes.filter { quote in
                quote.content.localizedCaseInsensitiveContains(searchText) ||
                (quote.author?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let category = selectedCategory {
            quotes = quotes.filter { $0.category == category }
        }
        
        return quotes
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search quotes...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryFilterButton(
                                title: "All",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(QuoteCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                Divider()
                
                // Quote list
                if filteredQuotes.isEmpty {
                    ContentUnavailableView(
                        "No Quotes Found",
                        systemImage: "clock",
                        description: Text(searchText.isEmpty ? "Your quote history will appear here" : "No quotes match your search")
                    )
                } else {
                    List {
                        ForEach(filteredQuotes) { quote in
                            QuoteHistoryRow(quote: quote)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Quote History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Clear History", systemImage: "trash") {
                            clearHistory()
                        }
                        .disabled(quoteManager.quoteHistory.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
    
    private func clearHistory() {
        withAnimation {
            quoteManager.quoteHistory.removeAll()
            UserDefaults.standard.removeObject(forKey: "quoteHistory")
        }
    }
}

struct QuoteHistoryRow: View {
    let quote: Quote
    @StateObject private var quoteManager = QuoteManager.shared
    @State private var showCopiedFeedback = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryBadge(category: quote.category)
                
                Spacer()
                
                Text(quote.dateAdded, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(quote.content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .lineSpacing(2)
            
            if let author = quote.author, !author.isEmpty {
                Text("— \(author)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            HStack {
                Button(action: { copyQuote() }) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                        Text(showCopiedFeedback ? "Copied!" : "Copy")
                    }
                    .font(.caption)
                    .foregroundColor(showCopiedFeedback ? .green : .blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: { toggleFavorite() }) {
                    HStack(spacing: 4) {
                        Image(systemName: quoteManager.isFavorite(quote) ? "heart.fill" : "heart")
                        Text(quoteManager.isFavorite(quote) ? "Favorited" : "Favorite")
                    }
                    .font(.caption)
                    .foregroundColor(quoteManager.isFavorite(quote) ? .pink : .gray)
                }
                .buttonStyle(.plain)
                
                Button("Use Quote") {
                    quoteManager.setCurrentQuote(quote)
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func copyQuote() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(quote.shareText, forType: .string)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showCopiedFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showCopiedFeedback = false
            }
        }
    }
    
    private func toggleFavorite() {
        quoteManager.toggleFavorite(quote)
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuoteHistoryView()
}