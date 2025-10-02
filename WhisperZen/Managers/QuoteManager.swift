//
//  QuoteManager.swift
//  WhisperZen
//
//  Professional Quote Management System
//

import Foundation
import SwiftUI
import Combine

@MainActor
class QuoteManager: ObservableObject {
    static let shared = QuoteManager()
    
    @Published var currentQuote: Quote
    @Published var favoriteQuotes: [Quote] = []
    @Published var quoteHistory: [Quote] = []
    @Published var isLoading = false
    @Published var error: QuoteError?
    
    private let builtInQuotes: [Quote]
    private let maxHistoryCount = 50
    private var timer: Timer?
    
    private init() {
        // Convert existing quotes to new Quote model with categories
        let quoteData: [(String, QuoteCategory)] = [
            ("Success starts with showing up when you don't feel like it.", .motivation),
            ("Every win begins with a decision to try.", .action),
            ("Fear fades the moment persistence takes the lead.", .courage),
            ("Bravery means acting even while afraid.", .courage),
            ("Discipline builds what talent only promises.", .discipline),
            ("Every seed of effort eventually blooms.", .growth),
            ("The energy you release is the life you live.", .mindset),
            ("Growth is slow but always worth it.", .growth),
            ("Challenges are fuel for greatness.", .resilience),
            ("Your future self will thank you for today's effort.", .motivation),
            ("Quitting guarantees failure—perseverance opens possibility.", .perseverance),
            ("A focused mind creates unstoppable change.", .focus),
            ("Obstacles are stepping stones in disguise.", .resilience),
            ("Confidence grows as excuses shrink.", .mindset),
            ("Each step forward destroys doubt.", .action),
            ("You don't need perfect timing—you need action.", .action),
            ("Tomorrow rewards the courage of today.", .courage),
            ("Strength is built, not found.", .discipline),
            ("Persistence transforms struggle into success.", .perseverance),
            ("Every setback carries a hidden lesson.", .growth),
            ("The best motivation is your own progress.", .motivation),
            ("Consistency is the heartbeat of achievement.", .discipline),
            ("Focus creates power.", .focus),
            ("Keep believing until belief becomes reality.", .mindset),
            ("Risk is proof of ambition.", .courage),
            ("Small daily actions compound into massive results.", .discipline),
            ("Failures teach faster than victories.", .growth),
            ("Your comfort zone is too small for your dreams.", .motivation),
            ("A strong will always finds a way.", .perseverance),
            ("Nobody can outwork a determined heart.", .motivation),
            ("Success is cumulative effort disguised as luck.", .success),
            ("Trying is always better than wondering.", .action),
            ("You are closer than you think.", .motivation),
            ("Rest isn't quitting—it's preparing.", .resilience),
            ("Every great story begins with courage.", .courage),
            ("Hard roads lead to the brightest destinations.", .perseverance),
            ("Excuses destroy what effort can build.", .discipline),
            ("You only fail if you stop.", .resilience),
            ("Resilience is your strongest muscle.", .resilience),
            ("Energy follows attention.", .focus),
            ("Momentum is built through repetition.", .discipline),
            ("Celebrate progress, fuel persistence.", .motivation),
            ("The best time is now, not later.", .action),
            ("Strength comes from struggle, not comfort.", .resilience),
            ("Turn effort into excellence.", .discipline),
            ("Action unlocks opportunity.", .action),
            ("Stay patient, success arrives silently.", .perseverance),
            ("Confidence is the child of practice.", .discipline),
            ("Stay hungry, stay relentless.", .motivation),
            ("The journey matters more than speed.", .mindset),
            ("Courage begins by chasing one small step.", .courage),
            ("Success is built on daily disciplines.", .success),
            ("Focused effort turns dreams to blueprints.", .focus),
            ("No storm lasts forever.", .resilience),
            ("Tough times build tougher people.", .resilience),
            ("You belong to the goals you pursue.", .mindset),
            ("Even slow progress is still progress.", .motivation),
            ("Doubts vanish when you take action.", .action),
            ("Effort multiplies potential.", .growth),
            ("Burn brightly, not quickly.", .discipline),
            ("Mistakes are evidence of forward motion.", .growth),
            ("Persistence writes the story of resilience.", .perseverance),
            ("You are never powerless—you always have choice.", .mindset),
            ("Refuse to accept limits.", .mindset),
            ("Be committed longer than challenges last.", .perseverance),
            ("The biggest risk is not starting.", .action),
            ("Joy hides in effort.", .motivation),
            ("Your 'someday' can be today.", .action),
            ("Success is silent hard work made visible.", .success),
            ("Greatness grows where excuses end.", .discipline),
            ("Brave hearts beat stronger than fear.", .courage),
            ("Keep climbing—the peak is closer with each step.", .perseverance),
            ("Your determination creates your reputation.", .discipline),
            ("Focus beats distraction every time.", .focus),
            ("Every challenge sharpens your edge.", .resilience),
            ("You already possess what it takes.", .mindset),
            ("Discipline is self-respect in action.", .discipline),
            ("Never underestimate the power of persistence.", .perseverance),
            ("Build a life worth waking up for.", .motivation),
            ("Great journeys require long patience.", .perseverance),
            ("Failure is feedback, not the finale.", .growth),
            ("Courage always costs less than regret.", .courage),
            ("Daily consistency outshines occasional intensity.", .discipline),
            ("Strength grows in the waiting.", .resilience),
            ("Struggle is proof of trying.", .action),
            ("Better to stumble forward than stand still.", .action),
            ("Hard work outlives hesitation.", .discipline),
            ("Every limit can be stretched.", .mindset),
            ("Invest effort, reap resilience.", .discipline),
            ("You are stronger at the finish than the start.", .growth),
            ("Quitters never remember what they could have been.", .perseverance),
            ("Willpower is the raw material of success.", .discipline),
            ("Consistency makes impossible things possible.", .discipline),
            ("Your efforts inspire others silently.", .motivation),
            ("Believe first, achieve next.", .mindset),
            ("Bold actions create bold results.", .action),
            ("Focus is the shortcut to mastery.", .focus),
            ("Victory favors the relentless.", .perseverance),
            ("Each sunrise brings fresh opportunities.", .motivation),
            ("Nothing works unless you work.", .action),
            ("Strive to be resilient, not perfect.", .resilience),
            ("Effort today, success tomorrow.", .motivation),
            ("Resilience turns obstacles into milestones.", .resilience),
            ("Every push brings progress.", .action),
            ("Sweat today is glory tomorrow.", .motivation),
            ("Success requires stubborn faith.", .success),
            ("You aren't behind—you're on your path.", .mindset),
            ("Dedication builds impossible dreams.", .discipline),
            ("Consistency is a superpower.", .discipline),
            ("Be stronger than your excuses.", .resilience),
            ("Fear loses to focus.", .focus),
            ("Endurance beats resistance.", .perseverance),
            ("Be the worker your dream deserves.", .motivation),
            ("Every action is a vote for your future.", .mindset),
            ("Effort earns freedom.", .discipline),
            ("The harder the climb, the greater the view.", .perseverance),
            ("Stay grounded, aim higher.", .mindset),
            ("Success rewards those who persist longest.", .success),
            ("Motivation fades, habits last.", .discipline),
            ("Small adjustments build massive change.", .growth),
            ("Inner belief is unshakable armor.", .mindset),
            ("Strive until success bows to persistence.", .perseverance),
            ("Every step builds momentum.", .action),
            ("Be relentless against delay.", .action),
            ("Determination is the key that fits every lock.", .discipline),
            ("Trust effort over luck.", .discipline),
            ("Faith fuels the impossible.", .mindset),
            ("Work until doubt disappears.", .action),
            ("You are your greatest project.", .growth),
            ("Failure doesn't define you, persistence does.", .perseverance),
            ("Refuse to stand still.", .action),
            ("Small acts create giant leaps.", .action),
            ("The habit of effort becomes identity.", .discipline),
            ("Grit is golden.", .resilience),
            ("Enthusiasm fights fatigue.", .motivation),
            ("Break your limits daily.", .mindset),
            ("Every win starts as a choice.", .mindset),
            ("Ambition is your compass.", .motivation),
            ("Stay committed beyond the excitement.", .perseverance),
            ("Your growth inspires others.", .motivation),
            ("Courage is contagious.", .courage),
            ("Keep moving; slowing down isn't stopping.", .action),
            ("Every day counts.", .motivation),
            ("Growth is built, not gifted.", .growth),
            ("Wherever you go, bring persistence.", .perseverance),
            ("Chase your dream as if it's running too.", .motivation),
            ("Fear is a test of seriousness.", .courage),
            ("Motivation begins with motion.", .action),
            ("Push past resistance daily.", .resilience),
            ("Passion makes effort effortless.", .motivation),
            ("No quit, no limits.", .perseverance),
            ("Write your goals in action.", .action),
            ("Invest sweat, collect greatness.", .discipline),
            ("Your challenges are promotions in disguise.", .resilience),
            ("Patience and effort never collide—they combine.", .perseverance),
            ("Keep rising, even if slowly.", .action),
            ("A minute of action beats hours of planning.", .action),
            ("Transformation starts with repetition.", .growth),
            ("Every excuse costs progress.", .action),
            ("Victories love persistence.", .perseverance),
            ("Optimism creates strength.", .mindset),
            ("Grind until your vision is reality.", .discipline),
            ("With endurance, all is possible.", .perseverance),
            ("Growth follows gratitude and grit.", .growth),
            ("No one regrets the hard work done.", .discipline),
            ("Push harder than your obstacles.", .resilience),
            ("Every effort compounds quietly.", .discipline),
            ("You were made to rise.", .motivation),
            ("Your fire burns brightest when winds blow hardest.", .resilience),
            ("Failure is temporary, perseverance permanent.", .perseverance),
            ("Dedication is the bridge to destiny.", .discipline),
            ("Bold steps attract big opportunities.", .action),
            ("You can't outrun effort—it always pays.", .discipline),
            ("Be motivated enough to act, every day.", .motivation),
            ("Dreams expand with persistence.", .perseverance),
            ("Every problem sharpens your resolve.", .resilience),
            ("Sweat transforms potential into power.", .discipline),
            ("Success crowns consistent effort.", .success),
            ("Stand taller after every fall.", .resilience),
            ("Effort is the truest language of ambition.", .discipline),
            ("Purpose fuels persistence.", .motivation),
            ("Each trial makes triumph sweeter.", .resilience),
            ("Focus cracks even the toughest challenges.", .focus),
            ("You are the designer of your direction.", .mindset),
            ("Rise above resistance.", .resilience),
            ("Your limits exist only if you accept them.", .mindset),
            ("Hard work never returns empty-handed.", .discipline),
            ("Effort done in silence is success's loudest noise.", .discipline),
            ("Hold steady, results are forming.", .perseverance),
            ("Believe, act, repeat.", .action),
            ("Nothing replaces persistence.", .perseverance),
            ("One determined person can shift everything.", .motivation),
            ("Work quietly, succeed loudly.", .discipline),
            ("Keep showing up—results are inevitable.", .perseverance),
            ("Every delay is preparation.", .mindset),
            ("Patience polishes perseverance.", .perseverance),
            ("Fuel yourself with goals, not doubts.", .motivation),
            ("Big dreams demand stubborn effort.", .discipline),
            ("Each repetition strengthens destiny.", .discipline),
            ("Every finish line was once a starting point.", .mindset)
        ]
        
        self.builtInQuotes = quoteData.map { Quote(content: $0.0, category: $0.1) }
        
        // Load current quote from UserDefaults or use first quote
        if let savedQuoteData = UserDefaults.standard.data(forKey: "currentQuote"),
           let savedQuote = try? JSONDecoder().decode(Quote.self, from: savedQuoteData) {
            self.currentQuote = savedQuote
        } else {
            self.currentQuote = builtInQuotes.first ?? Quote(content: "Welcome to WhisperZen!")
        }
        
        loadFavorites()
        loadHistory()
        setupAutoChangeTimer()
    }
    
    func getRandomQuote() -> Quote {
        let preferences = UserPreferences.shared
        let availableQuotes = builtInQuotes.filter { quote in
            preferences.preferredCategories.isEmpty || preferences.preferredCategories.contains(quote.category)
        }
        
        // Avoid repeating recent quotes
        let recentQuotes = Array(quoteHistory.prefix(5))
        let filteredQuotes = availableQuotes.filter { quote in
            !recentQuotes.contains { recent in recent.content == quote.content }
        }
        
        return filteredQuotes.randomElement() ?? availableQuotes.randomElement() ?? builtInQuotes.first!
    }
    
    func nextQuote() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newQuote = getRandomQuote()
            setCurrentQuote(newQuote)
        }
    }
    
    func setCurrentQuote(_ quote: Quote) {
        currentQuote = quote
        addToHistory(quote)
        saveCurrentQuote()
    }
    
    private func saveCurrentQuote() {
        if let encoded = try? JSONEncoder().encode(currentQuote) {
            UserDefaults.standard.set(encoded, forKey: "currentQuote")
        }
    }
    
    func toggleFavorite(_ quote: Quote) {
        if favoriteQuotes.contains(where: { $0.id == quote.id }) {
            favoriteQuotes.removeAll { $0.id == quote.id }
        } else {
            favoriteQuotes.append(quote)
        }
        saveFavorites()
    }
    
    func isFavorite(_ quote: Quote) -> Bool {
        favoriteQuotes.contains { $0.id == quote.id }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favoriteQuotes"),
           let quotes = try? JSONDecoder().decode([Quote].self, from: data) {
            favoriteQuotes = quotes
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteQuotes) {
            UserDefaults.standard.set(encoded, forKey: "favoriteQuotes")
        }
    }
    
    private func addToHistory(_ quote: Quote) {
        // Remove if already exists to avoid duplicates
        quoteHistory.removeAll { $0.id == quote.id }
        // Add to beginning
        quoteHistory.insert(quote, at: 0)
        // Keep only recent quotes
        if quoteHistory.count > maxHistoryCount {
            quoteHistory = Array(quoteHistory.prefix(maxHistoryCount))
        }
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "quoteHistory"),
           let quotes = try? JSONDecoder().decode([Quote].self, from: data) {
            quoteHistory = quotes
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(quoteHistory) {
            UserDefaults.standard.set(encoded, forKey: "quoteHistory")
        }
    }
    
    func fetchOnlineQuote() async {
        guard UserPreferences.shared.useOnlineQuotes else { return }
        
        isLoading = true
        error = nil
        
        do {
            let content = try await QuoteService.fetchRandomQuote()
            let onlineQuote = Quote(content: content, author: nil, category: .motivation)
            
            await MainActor.run {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    setCurrentQuote(onlineQuote)
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .networkError(error.localizedDescription)
                self.isLoading = false
                // Fallback to local quote
                nextQuote()
            }
        }
    }
    
    private func setupAutoChangeTimer() {
        timer?.invalidate()
        
        guard let interval = UserPreferences.shared.autoChangeInterval.timeInterval else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task {
                await self?.nextQuote()
            }
        }
    }
    
    func updateAutoChangeTimer() {
        setupAutoChangeTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
}

enum QuoteError: LocalizedError {
    case networkError(String)
    case noQuotesAvailable
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .noQuotesAvailable:
            return "No quotes available"
        }
    }
}