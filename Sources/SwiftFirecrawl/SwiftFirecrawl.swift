import Foundation

// On Linux, we need to import FoundationNetworking for URLSession and URLRequest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if os(Linux)
// Linux compatibility for URL.appending which is missing on Linux
extension URL {
    public func appending<S>(path: S, directoryHint: URL.DirectoryHint = .inferFromPath) -> URL where S : StringProtocol {
        var url = self
        url.appendPathComponent(String(path))
        return url
    }
    
    public func appending<S>(path: S) -> URL where S : StringProtocol {
        var url = self
        url.appendPathComponent(Self.scrapeUrl)
        return url
    }
}
extension URLSession {
    public static let shared = URLSession(configuration: .default)
}
#endif

//{
//  "url": "<string>",
//  "formats": [
//    "markdown"
//  ],
//  "onlyMainContent": true,
//  "includeTags": [
//    "<string>"
//  ],
//  "excludeTags": [
//    "<string>"
//  ],
//  "headers": {},
//  "waitFor": 0,
//  "mobile": false,
//  "skipTlsVerification": false,
//  "timeout": 30000,
//  "extract": {
//    "schema": {},
//    "systemPrompt": "<string>",
//    "prompt": "<string>"
//  },
//  "actions": [
//    {
//      "type": "wait",
//      "milliseconds": 2,
//      "selector": "#my-element"
//    }
//  ],
//  "location": {
//    "country": "US",
//    "languages": [
//      "en-US"
//    ]
//  },
//  "removeBase64Images": true
//}

//      "formats": [
//        "markdown"
//      ],
//      "onlyMainContent": true,
//      "waitFor": 0,
//      "mobile": false,
//      "skipTlsVerification": false,
//      "timeout": 30000,
//      "location": {
//        "country": "US",
//        "languages": [
//          "en-US"
//        ]
//      },
//      "removeBase64Images": true

fileprivate struct FcRequest: Codable {
    
    static func defaultConfig(with url: String) -> Self {
        return Self(url: url)
    }
    
    struct Location: Codable {
        var country: String = "US"
        var languages: [String] = ["en-US"]
    }
    
    var url: String
    var formats = ["markdown"]
    var onlyMainContent = true
    var includeTags: [String]? // = []
    var excludeTags: [String]? // = []
    var headers: [String]? // = []
    var waitFor: Int = 0
    var mobile: Bool = false
    var skipTlsVerification: Bool = false
    var timeout: Int = 30000
    var extract: [String]?// = []
    var actions: [String]?// = []
    var location: Location = Location()
    var removeBase64Images: Bool = true
}


//{
//    "success\":true,
//    
//    "data\":{
//    \"markdown\":\"# A very simple webpage. This is an \\\"h1\\\" level header.\\n\\n## This is a level h2 header.\\n\\n###### This is a level h6 header. Pretty small!\\n\\nThis is a standard paragraph.\\n\\nNow I\'ve aligned it in the center of the screen.\\n\\nNow aligned to the right\\n\\n**Bold text**\\n\\n**Strongly emphasized text** Can you tell the difference vs. bold?\\n\\n_Italics_\\n\\n_Emphasized text_ Just like Italics!\\n\\nHere is a pretty picture: ![Pretty Picture](example/prettypicture.jpg)\\n\\nSame thing, aligned differently to the paragraph: ![Pretty Picture](example/prettypicture.jpg)\\n\\n* * *\\n\\n## How about a nice ordered list!\\n\\n1. This little piggy went to market\\n\\n2. This little piggy went to SB228 class\\n\\n3. This little piggy went to an expensive restaurant in Downtown Palo Alto\\n\\n4. This little piggy ate too much at Indian Buffet.\\n\\n5. This little piggy got lost\\n\\n\\n## Unordered list\\n\\n- First element\\n\\n- Second element\\n\\n- Third element\\n\\n\\n* * *\\n\\n## Nested Lists!\\n\\n- Things to to today:\\n  1. Walk the dog\\n\\n  2. Feed the cat\\n\\n  3. Mow the lawn\\n- Things to do tomorrow:\\n  1. Lunch with mom\\n\\n  2. Feed the hamster\\n\\n  3. Clean kitchen\\n\\nAnd finally, how about some [Links?](http://www.yahoo.com/)\\n\\nOr let\'s just link to [another page on this server](../../index.html)\\n\\nRemember, you can view the HTMl code from this or any other page by using the \\\"View Page Source\\\" command of your browser.\",\"metadata\":{\"title\":\"A very simple webpage\",\"ogLocaleAlternate\":[],\"sourceURL\":\"https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html\",\"url\":\"https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html\",\"statusCode\":200}}}
    
fileprivate struct FcResponse: Codable {
    
    struct FcData: Codable {
        var markdown: String
        var html: String?
        var rawHtml: String?
        var screenshot: String?
        var links: [String]?
        var actions: [String]?
    }
    
    struct FcMetadata: Codable {
        var title: String?
        var description: String?
        var language: String?
        var sourceURL: String?
        var otherMetadata: String?
        var statusCode: Int?
        var error: String?
    }

    var success: Bool
    var data: Self.FcData?
    var metdata: Self.FcMetadata?
    var llmExtraction: [String: String]?
    var warning: String?
    var error: String?
}

open class SwiftFirecrawl {
    
    static public let defaultBaseUrl = "https://api.firecrawl.dev"
    
    let baseUrl: String
    let apiKey: String
    
    let urlSession = URLSession.shared
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    private static let scrapeUrl = "v1/scrape"
    
    public init(baseUrl: String = defaultBaseUrl, apiKey: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }
    
    
    public func scrape(url: URL) async throws -> String {
        return try await scrape(rawUrlString: url.absoluteString)
    }

    public func scrape(rawUrlString: String) async throws -> String {
        
        let url = URL(string: baseUrl)!.appending(path: Self.scrapeUrl)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestData = FcRequest(url: rawUrlString)
        let rawData = try jsonEncoder.encode(requestData)
        request.httpBody = rawData
        
        let (data, _) = try await urlSession.data(for: request)
        
        let response = try jsonDecoder.decode(FcResponse.self, from: data)
        
        guard response.success else {
            throw NSError(domain: response.error ?? "No error", code: 0)
        }
        
        return response.data?.markdown ?? ""
    }
}
