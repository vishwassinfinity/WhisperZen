//
//  FavoritesView.swift
//  WhisperZen
//
//  Favorites Management Interface
//

import SwiftUI
import UniformTypeIdentifiers

struct FavoritesView: View {
    @StateObject private var quoteManager = QuoteManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: QuoteCategory?
    @State private var showingExportSheet = false
    
    var filteredQuotes: [Quote] {
        var quotes = quoteManager.favoriteQuotes
        
        if !searchText.isEmpty {
            quotes = quotes.filter { quote in
                quote.content.localizedCaseInsensitiveContains(searchText) ||
                (quote.author?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let category = selectedCategory {
            quotes = quotes.filter { $0.category == category }
        }
        
        return quotes.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search favorites...", text: $searchText)
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
                
                // Favorites list
                if filteredQuotes.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Favorites Yet" : "No Favorites Found",
                        systemImage: "heart",
                        description: Text(searchText.isEmpty ? "Tap the heart icon on quotes to add them to your favorites" : "No favorite quotes match your search")
                    )
                } else {
                    List {
                        ForEach(filteredQuotes) { quote in
                            FavoriteQuoteRow(quote: quote)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: removeFavorites)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorite Quotes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Export Favorites", systemImage: "square.and.arrow.up") {
                            showingExportSheet = true
                        }
                        .disabled(quoteManager.favoriteQuotes.isEmpty)
                        
                        Divider()
                        
                        Button("Clear All", systemImage: "trash", role: .destructive) {
                            clearAllFavorites()
                        }
                        .disabled(quoteManager.favoriteQuotes.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
        .fileExporter(
            isPresented: $showingExportSheet,
            document: FavoritesDocument(quotes: quoteManager.favoriteQuotes),
            contentType: .plainText,
            defaultFilename: "WhisperZen_Favorites"
        ) { result in
            switch result {
            case .success(let url):
                print("Favorites exported to: \(url)")
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
    }
    
    private func removeFavorites(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let quote = filteredQuotes[index]
                quoteManager.toggleFavorite(quote)
            }
        }
    }
    
    private func clearAllFavorites() {
        withAnimation {
            quoteManager.favoriteQuotes.removeAll()
            UserDefaults.standard.removeObject(forKey: "favoriteQuotes")
        }
    }
}

struct FavoriteQuoteRow: View {
    let quote: Quote
    @StateObject private var quoteManager = QuoteManager.shared
    @State private var showCopiedFeedback = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryBadge(category: quote.category)
                
                Spacer()
                
                Text(quote.dateAdded, style: .date)
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
                
                Button(action: { shareQuote() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("Use Quote") {
                    quoteManager.setCurrentQuote(quote)
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.pink.opacity(0.1),
                    Color.purple.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.pink.opacity(0.2), lineWidth: 1)
        )
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
    
    private func shareQuote() {
        let sharingService = NSSharingService(named: .composeMessage)
        sharingService?.perform(withItems: [quote.shareText])
    }
}

// Document type for exporting favorites
struct FavoritesDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    let quotes: [Quote]
    
    init(quotes: [Quote]) {
        self.quotes = quotes
    }
    
    init(configuration: ReadConfiguration) throws {
        quotes = []
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let text = quotes.map { quote in
            var result = quote.content
            if let author = quote.author, !author.isEmpty {
                result += "\n— \(author)"
            }
            result += "\n[\(quote.category.rawValue)]"
            return result
        }.joined(separator: "\n\n---\n\n")
        
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    FavoritesView()
}