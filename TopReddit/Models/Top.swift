import Foundation

// MARK: - Top
struct Top: Codable {
    let kind: String
    let data: TopData
}

// MARK: - TopData
struct TopData: Codable {
    let modhash: String
    let dist: Int
    let children: [Post]
    let after: String?
    let before: String?
}

// MARK: - Post
struct Post: Codable {
    let kind: String
    let data: PostData
}

// MARK: - PostData
struct PostData: Codable {
    let name: String
    let title: String
    let subreddit_name_prefixed: String
    let num_comments: Int
    let created: Int
    let preview: Preview?
}

// MARK: - Preview
struct Preview: Codable {
    let images: [Image]
    let enabled: Bool
}

// MARK: - Image
struct Image: Codable {
    let source: ResizedImage
    let resolutions: [ResizedImage]
    let id: String
}

// MARK: - ResizedImage
struct ResizedImage: Codable {
    private let url: URL
    let width, height: Int
    let format: String?
    
    var cleanURL: URL { URL(string: url.absoluteString.replacingOccurrences(of: "amp;s", with: "s"))! }
}
