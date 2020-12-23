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
struct Post: Codable, Hashable {
    let kind: String
    let data: PostData!
    var height: Double?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(data.name)
    }
    
    static func ==(l: Post, r: Post) -> Bool { l.data?.name == r.data?.name }
}

// MARK: - PostData
struct PostData: Codable, Hashable {
    let name: String
    let title: String
    let author: String
    let num_comments: Int
    let created: Double
    let preview: Preview?
}

// MARK: - Preview
struct Preview: Codable, Hashable {
    let images: [Image]
    let enabled: Bool
}

// MARK: - Image
struct Image: Codable, Hashable {
    let source: ResizedImage
    let resolutions: [ResizedImage]
    let id: String
}

// MARK: - ResizedImage
struct ResizedImage: Codable, Hashable {
    let url: URL
    let width, height: Int
    let format: String?
}
