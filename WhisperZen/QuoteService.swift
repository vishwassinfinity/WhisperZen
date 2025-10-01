import Foundation

struct QuoteService {
    struct QuoteResponse: Decodable {
        let content: String
        let author: String?
    }

    static func fetchRandomQuote() async throws -> String {
        let url = URL(string: "https://api.quotable.io/random")!
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(QuoteResponse.self, from: data)
        return decoded.content
    }
}
