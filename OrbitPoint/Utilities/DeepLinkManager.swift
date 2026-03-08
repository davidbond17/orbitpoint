import Foundation

enum DeepLinkManager {

    static func challengeURL(score: Int, mode: String) -> URL? {
        var components = URLComponents()
        components.scheme = "orbitpoint"
        components.host = "challenge"
        components.queryItems = [
            URLQueryItem(name: "score", value: "\(score)"),
            URLQueryItem(name: "mode", value: mode)
        ]
        return components.url
    }

    static func parseChallenge(url: URL) -> (score: Int, mode: String)? {
        guard url.scheme == "orbitpoint",
              url.host == "challenge",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else {
            return nil
        }

        let scoreStr = items.first(where: { $0.name == "score" })?.value ?? "0"
        let mode = items.first(where: { $0.name == "mode" })?.value ?? "Free Play"

        guard let score = Int(scoreStr) else { return nil }
        return (score, mode)
    }

    static func shareText(score: Int, mode: String) -> String {
        "I scored \(score) in \(mode) on Orbit Point! Can you beat it?"
    }
}
