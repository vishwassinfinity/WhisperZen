import Foundation

actor QuoteStore {
    static let shared = QuoteStore()

    private var cachedQuote: String?

    func getCachedOrStoredQuote() -> String? {
        if let cachedQuote {
            return cachedQuote
        }
        if let stored = UserDefaults.standard.string(forKey: "lastQuote") {
            cachedQuote = stored
            return stored
        }
        return nil
    }

    @discardableResult
    func fetchAndCacheQuote() async throws -> String {
        let fetched = try await QuoteService.fetchRandomQuote()
        cachedQuote = fetched
        UserDefaults.standard.set(fetched, forKey: "lastQuote")
        return fetched
    }
}
