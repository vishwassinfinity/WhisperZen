//
//  Quote.swift
//  WhisperZen
//
//  Enhanced Quote Model for Professional App
//

import Foundation

struct Quote: Codable, Identifiable, Hashable {
    let id = UUID()
    let content: String
    let author: String?
    let category: QuoteCategory
    let isFavorite: Bool
    let dateAdded: Date
    
    init(content: String, author: String? = nil, category: QuoteCategory = .motivation, isFavorite: Bool = false) {
        self.content = content
        self.author = author
        self.category = category
        self.isFavorite = isFavorite
        self.dateAdded = Date()
    }
    
    var displayText: String {
        if let author = author, !author.isEmpty {
            return "\"\(content)\"\n\n— \(author)"
        }
        return content
    }
    
    var shareText: String {
        if let author = author, !author.isEmpty {
            return "\"\(content)\" - \(author)"
        }
        return content
    }
}

enum QuoteCategory: String, CaseIterable, Codable {
    case motivation = "Motivation"
    case success = "Success"
    case perseverance = "Perseverance"
    case courage = "Courage"
    case growth = "Growth"
    case focus = "Focus"
    case discipline = "Discipline"
    case resilience = "Resilience"
    case action = "Action"
    case mindset = "Mindset"
    
    var icon: String {
        switch self {
        case .motivation: return "flame.fill"
        case .success: return "star.fill"
        case .perseverance: return "mountain.2.fill"
        case .courage: return "shield.fill"
        case .growth: return "leaf.fill"
        case .focus: return "target"
        case .discipline: return "clock.fill"
        case .resilience: return "heart.fill"
        case .action: return "bolt.fill"
        case .mindset: return "brain.head.profile"
        }
    }
    
    var color: String {
        switch self {
        case .motivation: return "orange"
        case .success: return "yellow"
        case .perseverance: return "blue"
        case .courage: return "red"
        case .growth: return "green"
        case .focus: return "purple"
        case .discipline: return "indigo"
        case .resilience: return "pink"
        case .action: return "mint"
        case .mindset: return "cyan"
        }
    }
}